// DataExportService tests — Dio mocked, no real backend.
// We don't try to verify the share-sheet side (Share.shareXFiles is a
// platform channel call that needs a binding harness) — those paths are
// covered by widget tests against the settings tile. Here we pin the
// service's contract with the backend instead.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/network/api_exception.dart';
import 'package:nuveli/features/settings/services/data_export_service.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late DataExportService service;

  setUp(() {
    dio = _MockDio();
    service = DataExportService(dio: dio);
  });

  group('DataExportService — backend contract', () {
    test('rethrows ApiException so UI can surface the user message', () async {
      final err = ApiException(
        requestOptions: RequestOptions(path: '/me/export'),
        statusCode: 429,
        userMessage: 'Slow down, you can export at most 3 times per hour.',
      );
      when(() => dio.get<Map<String, dynamic>>('/me/export')).thenThrow(err);

      expect(service.exportToFile(), throwsA(isA<ApiException>()));
    });

    test('wraps DioException into ApiException', () async {
      when(() => dio.get<Map<String, dynamic>>('/me/export')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/me/export'),
          response: Response(
            requestOptions: RequestOptions(path: '/me/export'),
            statusCode: 500,
          ),
        ),
      );

      expect(service.exportToFile(), throwsA(isA<ApiException>()));
    });

    test('throws when backend returns 200 with empty body', () async {
      when(() => dio.get<Map<String, dynamic>>('/me/export')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/me/export'),
          statusCode: 200,
          data: null,
        ),
      );

      expect(
        service.exportToFile(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });
}
