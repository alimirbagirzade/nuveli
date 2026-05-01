import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// Ortak mock'lar — tüm testler bu dosyadan import eder.

class MockDio extends Mock implements Dio {}

/// Backend'in standart ApiResponse formatı: {data: ..., error: null}
Response<Map<String, dynamic>> successResponse(
  Map<String, dynamic> data, {
  int statusCode = 200,
}) {
  return Response(
    requestOptions: RequestOptions(path: ''),
    statusCode: statusCode,
    data: {'data': data, 'error': null},
  );
}

/// Backend error formatı: {data: null, error: {code, message}}
DioException errorResponse({
  required int statusCode,
  required String code,
  required String message,
}) {
  return DioException(
    requestOptions: RequestOptions(path: ''),
    response: Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: statusCode,
      data: {
        'data': null,
        'error': {'code': code, 'message': message},
      },
    ),
    type: DioExceptionType.badResponse,
  );
}

/// Network timeout simulation.
DioException networkError() {
  return DioException(
    requestOptions: RequestOptions(path: ''),
    type: DioExceptionType.connectionError,
  );
}

/// ProviderContainer'ı override'larla oluşturur.
/// Test sonunda `container.dispose()` çağırmak zorunludur.
ProviderContainer makeContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  return container;
}

/// Fallback values for mocktail — common types used by our Dio mocks.
void registerFallbackValuesForTests() {
  registerFallbackValue(RequestOptions(path: ''));
  registerFallbackValue(<String, dynamic>{});
}
