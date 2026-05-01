import 'package:dio/dio.dart';

/// Uygulama boyunca kullanılan hata tipi.
/// UI bu tipleri string message olarak göstermeden önce `userMessage` kullanır.
sealed class AppError {
  const AppError(this.message);
  final String message;

  String get userMessage => message;

  factory AppError.network() => const NetworkError('Bağlantı kurulamadı. Tekrar dene.');
  factory AppError.auth() => const AuthError('Oturumun süresi doldu.');
  factory AppError.limitExceeded(String msg) => LimitExceededError(msg);
  factory AppError.server() => const ServerError('Bir şeyler ters gitti. Az sonra tekrar dene.');
  factory AppError.unknown([String? msg]) => UnknownError(msg ?? 'Beklenmeyen hata.');

  /// Dio hatasını AppError'a çevirir.
  static AppError fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return AppError.network();
    }

    final status = e.response?.statusCode ?? 0;
    final body = e.response?.data;

    // Backend standart error formatı: { data: null, error: { code, message } }
    if (body is Map && body['error'] is Map) {
      final err = body['error'] as Map;
      final code = err['code']?.toString() ?? 'UNKNOWN';
      final msg = err['message']?.toString() ?? 'Bir hata oluştu.';

      if (code == 'AUTH_REQUIRED' || status == 401) return AppError.auth();
      if (code == 'LIMIT_EXCEEDED' || status == 429) return AppError.limitExceeded(msg);
      if (status >= 500) return AppError.server();
      return AppError.unknown(msg);
    }

    if (status == 401) return AppError.auth();
    if (status >= 500) return AppError.server();
    return AppError.unknown();
  }
}

class NetworkError extends AppError {
  const NetworkError(super.message);
}

class AuthError extends AppError {
  const AuthError(super.message);
}

class LimitExceededError extends AppError {
  const LimitExceededError(super.message);
}

class ServerError extends AppError {
  const ServerError(super.message);
}

class UnknownError extends AppError {
  const UnknownError(super.message);
}
