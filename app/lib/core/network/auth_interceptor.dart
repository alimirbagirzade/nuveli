import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dio interceptor that attaches the current Supabase JWT to every
/// outgoing request, and on a 401 attempts ONE silent refresh before
/// bubbling the error up.
///
/// Why a single retry: an expired token from a cold-started app is
/// extremely common, so refreshing transparently fixes the UX without
/// kicking the user back to the login screen. We mark the retried
/// request with a header sentinel so we never loop more than once.
///
/// If refresh itself fails, we call `signOut()` and let the
/// `AuthGate` listener handle the navigation to the login flow.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio);

  final Dio _dio;

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Header sentinel used to detect a request that was already retried
  /// after a refresh attempt. Stripped before the retry is sent.
  static const String _retriedFlag = 'x-nuveli-auth-retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthError = err.response?.statusCode == 401;
    final alreadyRetried =
        err.requestOptions.headers[_retriedFlag] == 'true';

    if (!isAuthError || alreadyRetried) {
      return handler.next(err);
    }

    try {
      if (kDebugMode) {
        debugPrint('[AuthInterceptor] 401 received — refreshing session');
      }

      final refresh = await _supabase.auth.refreshSession();
      final newToken = refresh.session?.accessToken;

      if (newToken == null) {
        await _supabase.auth.signOut();
        return handler.next(err);
      }

      // Clone the original request with the new token + retry sentinel.
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken'
        ..headers[_retriedFlag] = 'true';

      final retryResponse = await _dio.fetch<dynamic>(retryOptions);

      // Strip the sentinel from the resolved response so it doesn't
      // leak into any downstream interceptors / loggers.
      retryResponse.requestOptions.headers.remove(_retriedFlag);

      return handler.resolve(retryResponse);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthInterceptor] Refresh failed: $e — signing out');
      }
      await _supabase.auth.signOut();
      return handler.next(err);
    }
  }
}
