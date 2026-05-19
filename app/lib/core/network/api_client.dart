import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_endpoints.dart';
import 'api_exceptions.dart';
import 'auth_interceptor.dart';

/// Single source of truth for all HTTP traffic between the Flutter app
/// and the Nuveli FastAPI backend.
///
/// Responsibilities:
///   1. Configure a long-lived [Dio] instance with sensible timeouts
///      (Render free tier cold-starts can take ~30s).
///   2. Inject the [AuthInterceptor] so every request carries the
///      current Supabase JWT and 401s are transparently refreshed.
///   3. Expose generic `get / post / patch / put / delete` helpers that
///      return decoded JSON and normalise every failure to an
///      [ApiException] subclass — repositories should never see a raw
///      [DioException].
///
/// Usage:
/// ```dart
/// final client = ref.watch(apiClientProvider);
/// final summary = await client.get<Map<String, dynamic>>(
///   ApiEndpoints.mealsTodaySummary,
/// );
/// ```
class ApiClient {
  ApiClient._(this._dio);

  final Dio _dio;

  /// Builds a fully-wired client. Public so tests can inject a mock
  /// `Dio` via the named-arg constructor below if needed.
  factory ApiClient() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      // Render free tier cold-starts the container on the first call
      // after ~15 min of inactivity. Keep these high — the user sees
      // a skeleton loader, not a frozen UI.
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Let 4xx through to our own status-checker so we can throw
      // typed exceptions. 5xx still trips Dio's badResponse.
      validateStatus: (status) => status != null && status < 500,
      responseType: ResponseType.json,
    ));

    dio.interceptors.add(AuthInterceptor(dio));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        // Avoid printing raw bytes for image scans — they're enormous.
        request: false,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (msg) => debugPrint('[Dio] $msg'),
      ));
    }

    return ApiClient._(dio);
  }

  /// Test-only constructor for injecting a pre-configured Dio.
  @visibleForTesting
  ApiClient.test(this._dio);

  /// Exposes the underlying Dio for advanced cases (multipart upload,
  /// cancellation tokens). Prefer the typed helpers below.
  Dio get raw => _dio;

  // ================================================================
  // Generic HTTP helpers
  // ================================================================

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      _ensureSuccess(response);
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      _ensureSuccess(response);
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        cancelToken: cancelToken,
      );
      _ensureSuccess(response);
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        cancelToken: cancelToken,
      );
      _ensureSuccess(response);
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<void> delete(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        cancelToken: cancelToken,
      );
      _ensureSuccess(response);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  // ================================================================
  // Status / exception mapping
  // ================================================================

  /// Throws the right [ApiException] for any non-2xx response that
  /// Dio's `validateStatus` let through (i.e. 400-499).
  void _ensureSuccess(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return;

    final detail = _extractDetailMessage(response.data);

    switch (status) {
      case 400:
        throw ApiException(detail ?? 'Bad request', statusCode: 400);
      case 401:
        throw AuthException(detail ?? 'Not authenticated');
      case 402:
        throw PremiumRequiredException(
          detail ?? 'Premium subscription required',
        );
      case 403:
        throw ForbiddenException(detail ?? 'Access forbidden');
      case 404:
        throw NotFoundException(detail ?? 'Resource not found');
      case 422:
        throw ValidationException(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : null,
          detail ?? 'Validation failed',
        );
      case 429:
        throw RateLimitedException(detail ?? 'Too many requests');
      default:
        throw UnknownApiException(
          detail ?? 'HTTP $status',
          statusCode: status,
        );
    }
  }

  /// FastAPI conventionally returns `{"detail": "..."}` on errors.
  String? _extractDetailMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final detail = body['detail'];
      if (detail is String) return detail;
    }
    return null;
  }

  /// Maps any [DioException] (network, timeout, 5xx, etc.) to a
  /// concrete [ApiException]. Anything we've already thrown ourselves
  /// inside `_ensureSuccess` will arrive here wrapped in `e.error` —
  /// we unwrap it untouched.
  ApiException _mapDioException(DioException e) {
    // If `_ensureSuccess` already threw a typed exception, Dio may
    // re-wrap it; unwrap and re-throw to preserve the original type.
    if (e.error is ApiException) {
      return e.error as ApiException;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return TimeoutException();

      case DioExceptionType.connectionError:
        return NetworkException();

      case DioExceptionType.cancel:
        return CancelledException();

      case DioExceptionType.badCertificate:
        return NetworkException('SSL certificate error');

      case DioExceptionType.badResponse:
        // This branch is reached for 5xx (validateStatus rejected them).
        final code = e.response?.statusCode ?? 0;
        final detail = _extractDetailMessage(e.response?.data);
        if (code >= 500) return ServerException(detail ?? 'Server error');
        return UnknownApiException(
          detail ?? 'HTTP $code',
          statusCode: code,
        );

      case DioExceptionType.unknown:
        return UnknownApiException(e.message ?? 'Unknown network error');
    }
  }
}

// ================================================================
// Riverpod provider — single shared instance per app run.
// ================================================================

/// Long-lived; we do NOT use `autoDispose` because every repository
/// in the app depends on the same Dio instance and recreating the
/// interceptor chain on each rebuild would lose pending refresh state.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
