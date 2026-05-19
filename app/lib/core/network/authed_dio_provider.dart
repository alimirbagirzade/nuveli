import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_exception.dart';

/// Backend base URL — production Render endpoint.
/// In future chats this can be moved to .env / dart-define if you want
/// to switch between staging/production builds.
const String kApiBaseUrl = 'https://nuveli-api.onrender.com';

/// A single shared [Dio] instance, configured with:
///  - 60s connect timeout (Render free tier cold start can take ~30s)
///  - Auto-attached `Authorization: Bearer <JWT>` from the current Supabase session
///  - Errors normalized to [ApiException] with user-facing messages
///
/// Every feature that talks to the backend should `ref.read(authedDioProvider)`
/// instead of creating its own Dio. This way auth + base URL + error
/// handling stay consistent.
final authedDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      onError: (err, handler) {
        // Wrap as ApiException so UI code can show userMessage directly.
        handler.next(ApiException.fromDio(err));
      },
    ),
  );

  return dio;
});
