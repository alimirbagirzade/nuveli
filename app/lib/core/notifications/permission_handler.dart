import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Three-state permission outcome so the UI can react appropriately.
enum NotificationPermissionStatus {
  /// User said yes — we can schedule freely.
  granted,

  /// User said no but we can ask again.
  denied,

  /// User permanently denied. We must send them to Settings.
  permanentlyDenied,

  /// iOS provisional only — silent banners allowed, no popup yet.
  provisional,
}

/// Encapsulates iOS + Android (incl. API 33+) permission asks.
///
/// Call [request] on first launch (after onboarding finishes is a good
/// moment — not before, since asking with no context kills opt-in rate).
class NotificationPermissionHandler {
  const NotificationPermissionHandler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<NotificationPermissionStatus> request() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return _requestIOS();
    }
    if (Platform.isAndroid) {
      return _requestAndroid();
    }
    return NotificationPermissionStatus.granted;
  }

  Future<NotificationPermissionStatus> check() async {
    if (Platform.isIOS) {
      final status = await Permission.notification.status;
      return _mapPermissionStatus(status);
    }
    if (Platform.isAndroid) {
      // POST_NOTIFICATIONS is a runtime permission on API 33+.
      // On older Android versions, .status returns granted by default.
      final status = await Permission.notification.status;
      return _mapPermissionStatus(status);
    }
    return NotificationPermissionStatus.granted;
  }

  Future<NotificationPermissionStatus> _requestIOS() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          // critical: false → not needed; would require special entitlement.
        ) ??
        false;
    return granted
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
  }

  Future<NotificationPermissionStatus> _requestAndroid() async {
    // Use permission_handler — it handles API 33+ runtime permission
    // and returns a richer status (permanentlyDenied vs denied) than the
    // raw FLN plugin call.
    final status = await Permission.notification.request();
    return _mapPermissionStatus(status);
  }

  NotificationPermissionStatus _mapPermissionStatus(PermissionStatus status) {
    if (status.isGranted) return NotificationPermissionStatus.granted;
    if (status.isPermanentlyDenied) {
      return NotificationPermissionStatus.permanentlyDenied;
    }
    if (status.isProvisional) return NotificationPermissionStatus.provisional;
    return NotificationPermissionStatus.denied;
  }

  /// Opens the OS-level app settings screen. Use this when status is
  /// [NotificationPermissionStatus.permanentlyDenied].
  Future<void> openSystemSettings() => openAppSettings();
}
