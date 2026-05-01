import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/network/app_error.dart';

import '../_helpers/test_helpers.dart';

void main() {
  group('AppError.fromDio', () {
    test('401 → AuthError', () {
      final e = errorResponse(
        statusCode: 401,
        code: 'AUTH_REQUIRED',
        message: 'Oturum süresi doldu.',
      );
      final result = AppError.fromDio(e);
      expect(result, isA<AuthError>());
    });

    test('429 → LimitExceededError', () {
      final e = errorResponse(
        statusCode: 429,
        code: 'LIMIT_EXCEEDED',
        message: 'Günlük limit aşıldı.',
      );
      final result = AppError.fromDio(e);
      expect(result, isA<LimitExceededError>());
      expect(result.userMessage, 'Günlük limit aşıldı.');
    });

    test('LIMIT_EXCEEDED code mapping (even with non-429 status)', () {
      // Backend 402 veya başka bir kod ile dönse de code doğruysa limit hatası
      final e = errorResponse(
        statusCode: 402,
        code: 'LIMIT_EXCEEDED',
        message: 'Free tier limiti doldu.',
      );
      expect(AppError.fromDio(e), isA<LimitExceededError>());
    });

    test('500 → ServerError', () {
      final e = errorResponse(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Sunucu hatası',
      );
      expect(AppError.fromDio(e), isA<ServerError>());
    });

    test('connectionError → NetworkError', () {
      expect(AppError.fromDio(networkError()), isA<NetworkError>());
    });

    test('unknown status with no body → UnknownError', () {
      final e = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 418,
        ),
        type: DioExceptionType.badResponse,
      );
      expect(AppError.fromDio(e), isA<UnknownError>());
    });

    test('userMessage passes through backend message for known codes', () {
      final e = errorResponse(
        statusCode: 429,
        code: 'LIMIT_EXCEEDED',
        message: 'Günde en fazla 3 analiz yapabilirsin.',
      );
      expect(
        AppError.fromDio(e).userMessage,
        'Günde en fazla 3 analiz yapabilirsin.',
      );
    });
  });
}
