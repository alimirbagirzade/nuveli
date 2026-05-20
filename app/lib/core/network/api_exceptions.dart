/// Domain-specific exception hierarchy for all API & network failures.
///
/// The UI layer pattern-matches on these types via `AsyncValue.error` to
/// decide what to render:
///
/// - `NetworkException` / `TimeoutException` → offline banner with retry
/// - `AuthException`                         → AuthGate handles logout
/// - `PremiumRequiredException`              → upsell paywall
/// - `ValidationException`                   → inline form errors
/// - `ServerException` / `UnknownApiException` → generic retry screen
///
/// Repositories should ONLY throw subclasses of [ApiException]. Raw
/// `DioException` must never escape `ApiClient`.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

// ----------------------------------------------------------------
// Connectivity / transport errors (no HTTP status code)
// ----------------------------------------------------------------

class NetworkException extends ApiException {
  NetworkException([super.message = 'No internet connection']);
}

class TimeoutException extends ApiException {
  TimeoutException([super.message = 'Request timed out']);
}

class CancelledException extends ApiException {
  CancelledException([super.message = 'Request cancelled']);
}

// ----------------------------------------------------------------
// Authentication / authorization
// ----------------------------------------------------------------

/// 401 — session is invalid or expired. AuthGate should sign the user out
/// after the interceptor has already failed to refresh.
class AuthException extends ApiException {
  AuthException([super.message = 'Not authenticated'])
      : super(statusCode: 401);
}

/// 403 — token is valid but the resource is not permitted for this user.
class ForbiddenException extends ApiException {
  ForbiddenException([super.message = 'Access forbidden'])
      : super(statusCode: 403);
}

// ----------------------------------------------------------------
// Resource / validation
// ----------------------------------------------------------------

class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Resource not found'])
      : super(statusCode: 404);
}

/// 422 — FastAPI Pydantic validation. The `errors` map is the raw
/// `detail` payload; format depends on the backend.
class ValidationException extends ApiException {
  ValidationException(
    this.errors, [
    String message = 'Validation failed',
  ]) : super(message, statusCode: 422);

  final Map<String, dynamic>? errors;
}

// ----------------------------------------------------------------
// Business logic
// ----------------------------------------------------------------

/// 402 — backend says this feature is premium-only and the current user
/// has not subscribed. UI should show the paywall.
class PremiumRequiredException extends ApiException {
  PremiumRequiredException([super.message = 'Premium subscription required'])
      : super(statusCode: 402);
}

/// 429 — rate limited (e.g. OpenAI cap reached, or backend throttle).
class RateLimitedException extends ApiException {
  RateLimitedException([super.message = 'Too many requests, try again later'])
      : super(statusCode: 429);
}

// ----------------------------------------------------------------
// Server-side failures
// ----------------------------------------------------------------

class ServerException extends ApiException {
  ServerException([super.message = 'Server error, please try again'])
      : super(statusCode: 500);
}

class UnknownApiException extends ApiException {
  UnknownApiException(super.message, {super.statusCode});
}
