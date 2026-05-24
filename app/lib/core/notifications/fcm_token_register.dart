import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Glue that pushes the device's FCM token to `POST /me/device-tokens`
/// so the backend cron can address it on daily-insight pushes.
///
/// Call [registerForCurrentUser] once after sign-in and again on
/// `onTokenRefresh`. Safe to call repeatedly — the backend dedupes by
/// `(user_id, token)`.
///
/// Permission UX: on iOS we ask via `requestPermission` (the system
/// modal). On Android the system permission is granted at install time
/// (or via the user's notification settings for Android 13+).
class FcmTokenRegister {
  FcmTokenRegister._();

  static StreamSubscription<String>? _refreshSub;

  /// Returns the registered token, or null if the user denied
  /// permission / FCM isn't reachable.
  static Future<String?> registerForCurrentUser(Dio dio) async {
    try {
      final messaging = FirebaseMessaging.instance;

      // iOS: ask for permission. Android grants by default (per
      // platform contract; user can revoke in system settings).
      if (Platform.isIOS || Platform.isMacOS) {
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          debugPrint('[FCM] user denied notification permission');
          return null;
        }
      }

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[FCM] getToken returned null');
        return null;
      }
      await _postToken(dio, token);

      // Re-register on token rotation. Cancel the prior subscription
      // first so we don't stack listeners across sign-out/sign-in.
      await _refreshSub?.cancel();
      _refreshSub = messaging.onTokenRefresh.listen((next) {
        _postToken(dio, next).catchError((e) {
          debugPrint('[FCM] refresh register failed: $e');
        });
      });

      return token;
    } catch (e, st) {
      debugPrint('[FCM] register failed: $e\n$st');
      return null;
    }
  }

  /// Call on sign-out so the backend stops addressing this device.
  static Future<void> unregisterCurrent(Dio dio) async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      await dio.delete('/me/device-tokens/$token');
    } catch (e) {
      debugPrint('[FCM] unregister failed: $e');
    }
  }

  static Future<void> _postToken(Dio dio, String token) async {
    await dio.post(
      '/me/device-tokens',
      data: {
        'token': token,
        'platform': Platform.isIOS || Platform.isMacOS ? 'ios' : 'android',
      },
    );
  }
}
