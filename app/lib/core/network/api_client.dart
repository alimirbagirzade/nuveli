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
    connectTimeout: const Duration(seconds: 15),
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
    onError: (e, handler) {
      // GET request'ler için idempotent retry (1 kez).
      // POST/PUT/DELETE retry edilmez — side effect risk'i.
      final isRetriable =
          e.requestOptions.method == 'GET' &&
              (e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.connectionError) &&
              e.requestOptions.extra['retry_attempted'] != true;

      if (isRetriable) {
        e.requestOptions.extra['retry_attempted'] = true;
        // 500ms bekle + tekrar dene
        Future.delayed(const Duration(milliseconds: 500), () async {
          try {
            final resp = await dio.fetch(e.requestOptions);
            handler.resolve(resp);
          } catch (retryErr) {
            handler.reject(retryErr is DioException
                ? retryErr
                : DioException(
                    requestOptions: e.requestOptions,
                    error: retryErr,
                  ));
          }
        });
        return;
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
