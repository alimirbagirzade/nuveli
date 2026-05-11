import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../i18n/language_provider.dart';

/// Nuveli API client. Tüm network istekleri bu provider'dan alınır.
///
/// Timeout stratejisi:
/// - connectTimeout 15s: bağlantı kurma (TCP + TLS handshake)
/// - receiveTimeout 60s: response bekleme (OpenAI Vision 45s'e kadar sürebilir)
/// - sendTimeout 30s: body upload (büyük meal fotoğrafı için)
///
/// Tek seferlik ağır çağrılar için `dio.options.receiveTimeout` per-request
/// override edilebilir (örn. meal_repository.analyze).
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 30),
    headers: const {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Dinamik dil header (her request'te taze okuma)
      final lang = globalLanguageNotifier.value.locale?.languageCode ?? 'tr';
      options.headers['Accept-Language'] = lang;
      
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
      return handler.next(options);
    },
    onError: (e, handler) async {
      // Cold start retry: Render free tier 30-60s uyanma süresi.
      // GET için 3 deneme, exponential backoff (1s, 3s, 6s).
      // POST/PUT/DELETE retry edilmez — side effect risk'i.
      final method = e.requestOptions.method;
      final isRetriableType = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          (e.response?.statusCode == 503) ||
          (e.response?.statusCode == 504);
      
      final isGetOrIdempotent = method == 'GET';
      final attempt = (e.requestOptions.extra['retry_count'] as int?) ?? 0;
      const maxAttempts = 3;

      if (isGetOrIdempotent && isRetriableType && attempt < maxAttempts) {
        // Exponential backoff: 1s, 3s, 6s
        final delay = Duration(seconds: [1, 3, 6][attempt]);
        e.requestOptions.extra['retry_count'] = attempt + 1;
        
        await Future.delayed(delay);
        try {
          final resp = await dio.fetch(e.requestOptions);
          handler.resolve(resp);
          return;
        } catch (retryErr) {
          handler.reject(retryErr is DioException
              ? retryErr
              : DioException(
                  requestOptions: e.requestOptions,
                  error: retryErr,
                ));
          return;
        }
      }
      return handler.next(e);
    },
  ));

  return dio;
});

/// Backend response standardı — { data, error }.
class ApiResponse<T> {
  final T? data;
  final ApiError? error;
  ApiResponse({this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromT) {
    return ApiResponse(
      data: json['data'] != null ? fromT(json['data']) : null,
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
    );
  }
}

class ApiError {
  final String code;
  final String message;
  ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      ApiError(code: json['code'] ?? 'UNKNOWN', message: json['message'] ?? '');
}
