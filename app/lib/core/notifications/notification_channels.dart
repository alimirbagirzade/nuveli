import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_types.dart';

/// Creates one Android channel per [NotificationType].
///
/// On iOS this is a no-op — categories are configured at request time
/// via [DarwinInitializationSettings]. Safe to call multiple times;
/// Android dedupes channels by id.
class NotificationChannels {
  const NotificationChannels(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> registerAll() async {
    if (!Platform.isAndroid) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    for (final type in NotificationType.values) {
      await android.createNotificationChannel(_channelFor(type));
    }
  }

  AndroidNotificationChannel _channelFor(NotificationType type) {
    // Importance.high → heads-up banner on Android 8+.
    // Avoid Importance.max except for streak/achievement (rare, time-sensitive).
    final importance = switch (type) {
      NotificationType.streak ||
      NotificationType.achievement =>
        Importance.max,
      _ => Importance.high,
    };

    return AndroidNotificationChannel(
      type.channelId,
      type.channelName,
      description: _descriptionFor(type),
      importance: importance,
      enableVibration: true,
      playSound: true,
    );
  }

  String _descriptionFor(NotificationType type) => switch (type) {
        NotificationType.water => 'Hydration reminders throughout the day.',
        NotificationType.meal => 'Reminders to log breakfast, lunch and dinner.',
        NotificationType.habit => 'Daily nudges for habits you set up.',
        NotificationType.sleep => 'Wind-down reminders before bedtime.',
        NotificationType.streak =>
          'Late-evening warning to keep your logging streak alive.',
        NotificationType.aiInsight => 'Your morning AI coaching is ready.',
        NotificationType.weeklyRecap => 'Sunday evening summary of your week.',
        NotificationType.achievement => 'You unlocked a new achievement.',
      };
}
