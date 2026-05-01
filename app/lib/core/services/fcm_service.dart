// app/lib/core/services/fcm_service.dart
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:nuveli/core/network/api_client.dart';

class FcmService {
  final Dio _dio;
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _tokenSub;

  void Function(String? deepLink, Map<String, dynamic> data)?
      onNotificationTap;
  void Function(RemoteMessage)? onForegroundMessage;

  String? _currentToken;
  String? get currentToken => _currentToken;

  FcmService(this._dio);

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

      if (Platform.isIOS) {
        await _fm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      await _refreshAndRegisterToken();
      _setupListeners();

      final initial = await _fm.getInitialMessage();
      if (initial != null) {
        _handleTap(initial);
      }
    } catch (e, st) {
      debugPrint('FcmService.initialize error: $e\n$st');
    }
  }

  Future<void> unregister() async {
    if (_currentToken != null) {
      try {
        await _dio.delete(
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

  bool _isSupported() {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  Future<bool> _requestPermission() async {
    final settings = await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _refreshAndRegisterToken() async {
    String? token;
    if (Platform.isIOS) {
      final apns = await _fm.getAPNSToken();
      if (apns == null) {
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
      await _dio.post(
        '/notifications/token',
        data: {
          'fcm_token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'app_version': '1.0.0',
          'os_version': Platform.operatingSystemVersion,
        },
      );
      debugPrint('FcmService: token registered');
    } catch (e) {
      debugPrint('FcmService: token register failed: $e');
    }
  }

  void _setupListeners() {
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FcmService: foreground message ${message.messageId}');
      onForegroundMessage?.call(message);
    });

    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

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

final fcmServiceProvider = Provider<FcmService>((ref) {
  final dio = ref.watch(apiClientProvider);
  final svc = FcmService(dio);
  ref.onDispose(() {
    svc.unregister();
  });
  return svc;
});

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM: ${message.messageId}');
}
