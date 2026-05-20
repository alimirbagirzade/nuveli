import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_channels.dart';
import 'notification_payload.dart';
import 'notification_types.dart';
import 'permission_handler.dart';

/// Signature for the navigation callback used when a notification is tapped.
typedef NotificationTapHandler = void Function(NotificationPayload payload);

/// Singleton wrapper around `flutter_local_notifications` 21.x.
///
/// 21.x breaking changes:
///   - `zonedSchedule` uses ONLY named params (id, title, body,
///     scheduledDate, notificationDetails are all named/required).
///   - `cancel` is now `cancel({required int id, String? tag})`.
///   - `uiLocalNotificationDateInterpretation` is gone (iOS <=10 dropped).
///   - `initialize` takes `settings:` as a named param.
///   - `FlutterTimezone.getLocalTimezone()` returns a `TimezoneInfo` object
///     — use `.identifier`.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  late final NotificationPermissionHandler permissions =
      NotificationPermissionHandler(_plugin);

  bool _initialized = false;
  NotificationTapHandler? _onTap;
  NotificationPayload? _launchPayload;

  // ───────────────────────── INIT ─────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('NotificationService: timezone lookup failed → UTC. $e');
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _handleTap,
      onDidReceiveBackgroundNotificationResponse:
          _backgroundNotificationHandler,
    );

    await NotificationChannels(_plugin).registerAll();

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _launchPayload = NotificationPayload.tryDecode(
        launchDetails?.notificationResponse?.payload,
      );
    }

    _initialized = true;
  }

  // ───────────────────────── TAP HANDLING ─────────────────────────

  void setOnTap(NotificationTapHandler handler) {
    _onTap = handler;
  }

  NotificationPayload? consumeLaunchPayload() {
    final payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }

  void _handleTap(NotificationResponse response) {
    final payload = NotificationPayload.tryDecode(response.payload);
    if (payload == null) return;
    _onTap?.call(payload);
  }

  // ───────────────────────── WATER ─────────────────────────

  Future<void> scheduleWaterReminders(List<TimeOfDay> enabledTimes) async {
    await _cancelType(NotificationType.water);

    for (var i = 0; i < enabledTimes.length; i++) {
      final time = enabledTimes[i];
      await _scheduleDaily(
        notificationId: NotificationType.water.idBase + i,
        type: NotificationType.water,
        title: '💧 Time to hydrate',
        body: _randomWaterMessage(),
        time: time,
        payload: const NotificationPayload(
          type: NotificationType.water,
          route: '/water',
        ),
      );
    }
  }

  static const _waterMessages = <String>[
    'Have a glass of water now.',
    'Stay hydrated, stay sharp.',
    'Quick reminder: drink water!',
    'Your body says thanks.',
    'Sip-sip-sip 💧',
  ];

  String _randomWaterMessage() =>
      _waterMessages[Random().nextInt(_waterMessages.length)];

  // ───────────────────────── MEALS ─────────────────────────

  Future<void> scheduleMealReminders({required bool enabled}) async {
    await _cancelType(NotificationType.meal);
    if (!enabled) return;

    await _scheduleDaily(
      notificationId: NotificationType.meal.idBase + 0,
      type: NotificationType.meal,
      title: '🍽️ Lunch time',
      body: "Don't forget to log what you're eating.",
      time: const TimeOfDay(hour: 12, minute: 30),
      payload: const NotificationPayload(
        type: NotificationType.meal,
        route: '/meals/scan',
      ),
    );

    await _scheduleDaily(
      notificationId: NotificationType.meal.idBase + 1,
      type: NotificationType.meal,
      title: '🍽️ Dinner time',
      body: 'Snap your evening meal to keep your log up to date.',
      time: const TimeOfDay(hour: 19, minute: 0),
      payload: const NotificationPayload(
        type: NotificationType.meal,
        route: '/meals/scan',
      ),
    );
  }

  // ───────────────────────── HABITS ─────────────────────────

  Future<void> scheduleHabitReminders(List<HabitReminderSpec> habits) async {
    await _cancelType(NotificationType.habit);

    final scheduled = habits.take(20).toList();
    for (var i = 0; i < scheduled.length; i++) {
      final h = scheduled[i];
      await _scheduleDaily(
        notificationId: NotificationType.habit.idBase + i,
        type: NotificationType.habit,
        title: '${h.icon} ${h.title}',
        body: h.subtitle ?? 'Daily reminder',
        time: h.time,
        payload: NotificationPayload(
          type: NotificationType.habit,
          route: '/habits',
          extras: {'habit_id': h.habitId},
        ),
      );
    }
  }

  // ───────────────────────── SLEEP ─────────────────────────

  Future<void> scheduleSleepReminder({
    required bool enabled,
    required TimeOfDay bedtime,
  }) async {
    await _cancelType(NotificationType.sleep);
    if (!enabled) return;

    final totalMinutes = (bedtime.hour * 60 + bedtime.minute - 30 + 1440) % 1440;
    final remindAt = TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );

    await _scheduleDaily(
      notificationId: NotificationType.sleep.idBase,
      type: NotificationType.sleep,
      title: '🌙 Wind down',
      body: '30 minutes until your sleep target. Dim the lights.',
      time: remindAt,
      payload: const NotificationPayload(
        type: NotificationType.sleep,
        route: '/habits',
      ),
    );
  }

  // ───────────────────────── STREAK WARNING ─────────────────────────

  Future<void> scheduleStreakWarning({required bool enabled}) async {
    await _cancelType(NotificationType.streak);
    if (!enabled) return;

    await _scheduleDaily(
      notificationId: NotificationType.streak.idBase,
      type: NotificationType.streak,
      title: "🔥 Don't break your streak",
      body: 'Log today before midnight to keep going.',
      time: const TimeOfDay(hour: 21, minute: 0),
      payload: const NotificationPayload(
        type: NotificationType.streak,
        route: '/meals/scan',
      ),
    );
  }

  // ───────────────────────── AI INSIGHT ─────────────────────────

  Future<void> scheduleAiInsightReady({required bool enabled}) async {
    await _cancelType(NotificationType.aiInsight);
    if (!enabled) return;

    await _scheduleDaily(
      notificationId: NotificationType.aiInsight.idBase,
      type: NotificationType.aiInsight,
      title: '🧠 Your coaching is ready',
      body: "Open Nuveli for today's personalized insights.",
      time: const TimeOfDay(hour: 6, minute: 30),
      payload: const NotificationPayload(
        type: NotificationType.aiInsight,
        route: '/ai-coach',
      ),
    );
  }

  // ───────────────────────── WEEKLY RECAP ─────────────────────────

  Future<void> scheduleWeeklyRecap({required bool enabled}) async {
    await _cancelType(NotificationType.weeklyRecap);
    if (!enabled) return;

    final next =
        _nextWeekday(DateTime.sunday, const TimeOfDay(hour: 20, minute: 0));

    await _plugin.zonedSchedule(
      id: NotificationType.weeklyRecap.idBase,
      title: '📊 Your week in Nuveli',
      body: 'Tap to see your weekly recap.',
      scheduledDate: next,
      notificationDetails: _detailsFor(NotificationType.weeklyRecap),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: const NotificationPayload(
        type: NotificationType.weeklyRecap,
        route: '/analytics',
      ).encode(),
    );
  }

  // ───────────────────────── DEV / TEST ─────────────────────────

  Future<void> fireTestInTenSeconds() async {
    final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    await _plugin.zonedSchedule(
      id: 99999,
      title: '🧪 Nuveli test',
      body: 'If you see this, scheduling works. ✅',
      scheduledDate: when,
      notificationDetails: _detailsFor(NotificationType.water),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: const NotificationPayload(
        type: NotificationType.water,
        route: '/water',
      ).encode(),
    );
  }

  // ───────────────────────── CANCELLATION ─────────────────────────

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _cancelType(NotificationType type) async {
    final base = type.idBase;
    final pending = await _plugin.pendingNotificationRequests();
    for (final n in pending) {
      if (n.id >= base && n.id < base + 1000) {
        // 21.x: cancel() now requires a named `id:` parameter.
        await _plugin.cancel(id: n.id);
      }
    }
  }

  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

  // ───────────────────────── INTERNALS ─────────────────────────

  Future<void> _scheduleDaily({
    required int notificationId,
    required NotificationType type,
    required String title,
    required String body,
    required TimeOfDay time,
    required NotificationPayload payload,
  }) async {
    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: _detailsFor(type),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload.encode(),
    );
  }

  NotificationDetails _detailsFor(NotificationType type) {
    final isHighPriority = type == NotificationType.streak ||
        type == NotificationType.achievement;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        type.channelId,
        type.channelName,
        importance: isHighPriority ? Importance.max : Importance.high,
        priority: isHighPriority ? Priority.max : Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: isHighPriority
            ? InterruptionLevel.timeSensitive
            : InterruptionLevel.active,
        threadIdentifier: type.channelId,
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextWeekday(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// DTO for habit scheduling — keeps the service decoupled from the full
/// Habit domain model.
class HabitReminderSpec {
  const HabitReminderSpec({
    required this.habitId,
    required this.title,
    required this.icon,
    required this.time,
    this.subtitle,
  });

  final String habitId;
  final String title;
  final String icon;
  final TimeOfDay time;
  final String? subtitle;
}

/// Top-level background handler — must be top-level / static for tree
/// shaking survival in release builds.
@pragma('vm:entry-point')
void _backgroundNotificationHandler(NotificationResponse response) {
  if (kDebugMode) {
    debugPrint('Background notification tapped: ${response.payload}');
  }
}

bool get supportsLocalNotifications =>
    Platform.isIOS || Platform.isAndroid || Platform.isMacOS;
