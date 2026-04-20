import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Nuveli API client. Tüm network istekleri bu provider'dan alınır.
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
      return handler.next(options);
    },
    onError: (e, handler) {
      // Logger burada
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
