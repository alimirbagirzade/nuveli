import 'package:dio/dio.dart';

/// Uygulama boyunca kullanılan hata tipi.
/// UI bu tipleri string message olarak göstermeden önce `userMessage` kullanır.
sealed class AppError {
  const AppError(this.message);
  final String message;

  String get userMessage => message;

  factory AppError.network() => const NetworkError('Bağlantı kurulamadı. Tekrar dene.');
  factory AppError.coldStart() => const ColdStartError('Sunucu uyanıyor, biraz bekle...');
  factory AppError.auth() => const AuthError('Oturumun süresi doldu.');
  factory AppError.forbidden() => const ForbiddenError('Bu işlem için yetkin yok.');
  factory AppError.notFound() => const NotFoundError('Aradığın şey bulunamadı.');
  factory AppError.validation([String? msg]) =>
      ValidationError(msg ?? 'Lütfen girdiğin bilgileri kontrol et.');
  factory AppError.limitExceeded(String msg) => LimitExceededError(msg);
  factory AppError.server() => const ServerError('Bir şeyler ters gitti. Az sonra tekrar dene.');
  factory AppError.unknown([String? msg]) => UnknownError(msg ?? 'Beklenmeyen hata.');

  /// Dio hatasını AppError'a çevirir.
  static AppError fromDio(DioException e) {
    // Cold start göstergeleri: connect timeout veya 503/504
    if (e.type == DioExceptionType.connectionTimeout ||
        e.response?.statusCode == 503 ||
        e.response?.statusCode == 504) {
      return AppError.coldStart();
    }

    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
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
      if (status == 403) return AppError.forbidden();
      if (status == 404) return AppError.notFound();
      if (status == 422) return AppError.validation(msg);
      if (code == 'LIMIT_EXCEEDED' || status == 429) return AppError.limitExceeded(msg);
      if (status >= 500) return AppError.server();
      return AppError.unknown(msg);
    }

    // FastAPI default 422 payload: { detail: [{ loc, msg, type }, …] }
    // Pull the first detail message if we got one.
    if (status == 422) {
      String? detailMsg;
      if (body is Map && body['detail'] is List) {
        final list = body['detail'] as List;
        if (list.isNotEmpty && list.first is Map) {
          detailMsg = (list.first as Map)['msg']?.toString();
        }
      } else if (body is Map && body['detail'] is String) {
        detailMsg = body['detail'] as String;
      }
      return AppError.validation(detailMsg);
    }

    if (status == 401) return AppError.auth();
    if (status == 403) return AppError.forbidden();
    if (status == 404) return AppError.notFound();
    if (status >= 500) return AppError.server();
    return AppError.unknown();
  }
}

class NetworkError extends AppError {
  const NetworkError(super.message);
}
class ColdStartError extends AppError {
  const ColdStartError(super.message);
}


class AuthError extends AppError {
  const AuthError(super.message);
}

class ForbiddenError extends AppError {
  const ForbiddenError(super.message);
}

class NotFoundError extends AppError {
  const NotFoundError(super.message);
}

class ValidationError extends AppError {
  const ValidationError(super.message);
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
