import 'dart:convert';

import 'notification_types.dart';

/// Structured payload attached to every scheduled notification.
///
/// Encoded as JSON because `flutter_local_notifications` only carries a
/// single `String? payload`. When the user taps the notification we parse
/// this back to figure out where to deep-link them.
class NotificationPayload {
  const NotificationPayload({
    required this.type,
    required this.route,
    this.extras = const {},
  });

  final NotificationType type;

  /// go_router path to navigate to (e.g. `/dashboard/water`).
  final String route;

  /// Optional extras (e.g. habit_id, meal_id) consumed by the destination
  /// screen. Keep values JSON-serializable.
  final Map<String, dynamic> extras;

  String encode() => jsonEncode({
        'type': type.channelId,
        'route': route,
        'extras': extras,
      });

  static NotificationPayload? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return NotificationPayload(
        type: NotificationType.fromString(map['type'] as String?),
        route: (map['route'] as String?) ?? '/',
        extras: (map['extras'] as Map<String, dynamic>?) ?? const {},
      );
    } catch (_) {
      // Malformed payload — better to drop than crash mid-launch.
      return null;
    }
  }
}
