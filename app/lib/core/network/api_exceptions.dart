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
  NetworkException([String message = 'No internet connection'])
      : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException([String message = 'Request timed out'])
      : super(message);
}

class CancelledException extends ApiException {
  CancelledException([String message = 'Request cancelled'])
      : super(message);
}

// ----------------------------------------------------------------
// Authentication / authorization
// ----------------------------------------------------------------

/// 401 — session is invalid or expired. AuthGate should sign the user out
/// after the interceptor has already failed to refresh.
class AuthException extends ApiException {
  AuthException([String message = 'Not authenticated'])
      : super(message, statusCode: 401);
}

/// 403 — token is valid but the resource is not permitted for this user.
class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Access forbidden'])
      : super(message, statusCode: 403);
}

// ----------------------------------------------------------------
// Resource / validation
// ----------------------------------------------------------------

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found'])
      : super(message, statusCode: 404);
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
  PremiumRequiredException([String message = 'Premium subscription required'])
      : super(message, statusCode: 402);
}

/// 429 — rate limited (e.g. OpenAI cap reached, or backend throttle).
class RateLimitedException extends ApiException {
  RateLimitedException([String message = 'Too many requests, try again later'])
      : super(message, statusCode: 429);
}

// ----------------------------------------------------------------
// Server-side failures
// ----------------------------------------------------------------

class ServerException extends ApiException {
  ServerException([String message = 'Server error, please try again'])
      : super(message, statusCode: 500);
}

class UnknownApiException extends ApiException {
  UnknownApiException(String message, {int? statusCode})
      : super(message, statusCode: statusCode);
}
