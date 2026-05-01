// app/lib/core/services/fcm_service.dart
//
// FCM (Firebase Cloud Messaging) Service.
// PRD §13 Notifications.
//
// Sorumluluklar:
// 1. Permission iste (iOS provisional + Android 13+ runtime)
// 2. FCM token al, backend'e register et
// 3. Token rotation handle et
// 4. Foreground / background / tap handler
// 5. Deep link routing (notification.data.deep_link)
//
// NOTE: pubspec.yaml'da firebase_core + firebase_messaging mevcut.
// main.dart'ta FirebaseApp.initializeApp() öncesinde çağrılmalı.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:nuveli/core/network/api_client.dart';

class FcmService {
  final ApiClient _api;
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _tokenSub;

  // Tap handler — uygulama bunu set eder, deep link'e göre route'lar
  void Function(String? deepLink, Map<String, dynamic> data)? onNotificationTap;

  // Foreground notification handler — uygulama in-app banner gösterebilir
  void Function(RemoteMessage)? onForegroundMessage;

  String? _currentToken;
  String? get currentToken => _currentToken;

  FcmService(this._api);

  // ═══════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════

  /// main.dart'ta auth sonrası çağrılır.
  Future<void> initialize() async {
    if (!_isSupported()) {
      debugPrint('FcmService: platform not supported, skipping init');
      return;
    }

    try {
      final granted = await _requestPermission();
      if (!granted) {
        debugPrint('FcmService: permission denied by user');
        return;
      }

      // Foreground'da iOS için presentation ayarı
      if (Platform.isIOS) {
        await _fm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Token'ı al ve register et
      await _refreshAndRegisterToken();

      // Listener'ları kur
      _setupListeners();

      // Cold-start (uygulama push tap ile açıldıysa)
      final initial = await _fm.getInitialMessage();
      if (initial != null) {
        _handleTap(initial);
      }
    } catch (e, st) {
      debugPrint('FcmService.initialize error: $e\n$st');
    }
  }

  /// Logout sırasında çağrılır — token'ı backend'den sil.
  Future<void> unregister() async {
    if (_currentToken != null) {
      try {
        await _api.delete(
          '/notifications/token',
          data: {'fcm_token': _currentToken},
        );
      } catch (e) {
        debugPrint('FcmService: unregister failed (non-fatal): $e');
      }
    }
    _currentToken = null;
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    await _tokenSub?.cancel();
  }

  // ═══════════════════════════════════════════════════════════════
  // Internals
  // ═══════════════════════════════════════════════════════════════

  bool _isSupported() {
    // FCM web/desktop'ta da var ama biz sadece mobile'da kullanıyoruz.
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  Future<bool> _requestPermission() async {
    final settings = await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // false = explicit prompt
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _refreshAndRegisterToken() async {
    String? token;
    if (Platform.isIOS) {
      // iOS: APNs token önce hazır olmalı
      final apns = await _fm.getAPNSToken();
      if (apns == null) {
        // APNs henüz hazır değil — kısa retry
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    token = await _fm.getToken();
    if (token == null) {
      debugPrint('FcmService: getToken returned null');
      return;
    }
    _currentToken = token;
    await _registerWithBackend(token);
  }

  Future<void> _registerWithBackend(String token) async {
    try {
      await _api.post(
        '/notifications/token',
        data: {
          'fcm_token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'app_version': '1.0.0', // TODO: package_info_plus'tan al
          'os_version': Platform.operatingSystemVersion,
        },
      );
      debugPrint('FcmService: token registered');
    } catch (e) {
      debugPrint('FcmService: token register failed: $e');
      // Sessizce devam — sonraki app open'da tekrar denenecek
    }
  }

  void _setupListeners() {
    // Foreground
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FcmService: foreground message ${message.messageId}');
      onForegroundMessage?.call(message);
    });

    // Background tap (app in background, kullanıcı bildirime dokundu)
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Token rotation
    _tokenSub = _fm.onTokenRefresh.listen((newToken) async {
      debugPrint('FcmService: token rotated');
      _currentToken = newToken;
      await _registerWithBackend(newToken);
    });
  }

  void _handleTap(RemoteMessage message) {
    final data = message.data;
    final deepLink = data['deep_link'] as String?;
    onNotificationTap?.call(deepLink, data);
  }
}

// ═══════════════════════════════════════════════════════════════
// Riverpod provider
// ═══════════════════════════════════════════════════════════════

final fcmServiceProvider = Provider<FcmService>((ref) {
  final api = ref.watch(apiClientProvider);
  final svc = FcmService(api);
  ref.onDispose(() {
    svc.unregister();
  });
  return svc;
});

// ═══════════════════════════════════════════════════════════════
// Background handler (top-level function — required by FCM)
// ═══════════════════════════════════════════════════════════════

/// main.dart'ın en başında bu register edilmeli:
///
/// ```
/// FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
/// ```
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background'da gerçek bir iş yapmıyoruz — Flutter zaten OS notification'ı gösteriyor.
  // Burada ek logic gerekirse (analytics ping vb.) ekle.
  debugPrint('Background FCM: ${message.messageId}');
}
