import 'package:dio/dio.dart';

/// Backend hatalarını UI'da güvenle gösterilebilir mesajlara çeviren wrapper.
///
/// Tüm feature'lar `catch (e)` yaparken `e is ApiException` ise
/// `e.userMessage` ile direkt gösterilebilir bir mesaj alır.
class ApiException extends DioException {
  final String userMessage;
  final int? statusCode;

  ApiException({
    required super.requestOptions,
    required this.userMessage,
    this.statusCode,
    super.response,
    DioExceptionType? type,
    super.error,
    super.stackTrace,
  }) : super(type: type ?? DioExceptionType.unknown);

  factory ApiException.fromDio(DioException err) {
    final statusCode = err.response?.statusCode;
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Server is waking up — please try again in a moment.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Check your network and retry.';
        break;
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          message = 'Session expired. Please log in again.';
        } else if (statusCode == 403) {
          message = 'You don\'t have access to that.';
        } else if (statusCode == 404) {
          message = 'Resource not found.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server error. Please try again.';
        } else {
          final data = err.response?.data;
          final detail = data is Map<String, dynamic>
              ? (data['detail']?.toString() ?? data['message']?.toString())
              : null;
          message = detail ?? 'Request failed.';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Secure connection failed.';
        break;
      case DioExceptionType.unknown:
        message = 'Something went wrong. Please try again.';
    }

    return ApiException(
      requestOptions: err.requestOptions,
      userMessage: message,
      statusCode: statusCode,
      response: err.response,
      type: err.type,
      error: err.error,
      stackTrace: err.stackTrace,
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $userMessage';
}
