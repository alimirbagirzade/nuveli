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

    // ----- New (Chat 24) error categories -----
    test('403 → ForbiddenError', () {
      final e = errorResponse(
        statusCode: 403,
        code: 'FORBIDDEN',
        message: 'Yetkisiz işlem',
      );
      expect(AppError.fromDio(e), isA<ForbiddenError>());
    });

    test('404 → NotFoundError', () {
      final e = errorResponse(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: 'Bulunamadı',
      );
      expect(AppError.fromDio(e), isA<NotFoundError>());
    });

    test('422 with standard error envelope → ValidationError (uses body msg)', () {
      final e = errorResponse(
        statusCode: 422,
        code: 'VALIDATION_FAILED',
        message: 'Email geçersiz',
      );
      final result = AppError.fromDio(e);
      expect(result, isA<ValidationError>());
      expect(result.userMessage, 'Email geçersiz');
    });

    test('422 with FastAPI {detail: [{msg: ...}]} also resolves to ValidationError', () {
      // FastAPI default validation body shape — surfaces the first
      // detail.msg as the user message.
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 422,
          data: {
            'detail': [
              {
                'loc': ['body', 'email'],
                'msg': 'value is not a valid email',
                'type': 'value_error.email',
              }
            ],
          },
        ),
        type: DioExceptionType.badResponse,
      );
      final result = AppError.fromDio(e);
      expect(result, isA<ValidationError>());
      expect(result.userMessage, 'value is not a valid email');
    });

    test('sendTimeout also maps to NetworkError', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.sendTimeout,
      );
      expect(AppError.fromDio(e), isA<NetworkError>());
    });
  });

  group('AppError.from (any-object adapter)', () {
    test('AppError instance is returned unchanged', () {
      final original = AppError.notFound();
      expect(identical(AppError.from(original), original), isTrue);
    });

    test('DioException → routed through fromDio (network etc.)', () {
      expect(AppError.from(networkError()), isA<NetworkError>());
    });

    test('arbitrary object → UnknownError carrying the stringified form', () {
      final result = AppError.from(StateError('bad state x'));
      expect(result, isA<UnknownError>());
      expect(result.userMessage, contains('bad state x'));
    });

    test('plain string falls into UnknownError', () {
      final result = AppError.from('just a string');
      expect(result, isA<UnknownError>());
      expect(result.userMessage, 'just a string');
    });
  });
}
