import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/notifications/notification_service.dart';

/// Persisted notification preferences.
///
/// Stored locally in SharedPreferences as a single JSON blob under
/// [_storageKey]. Backend sync (PATCH /me) is fire-and-forget — local
/// state is the source of truth for scheduling decisions, so the user
/// never sees a stale toggle if the network is flaky.
@immutable
class NotificationSettings {
  const NotificationSettings({
    this.masterEnabled = true,
    this.waterMorning = true,
    this.waterAfternoon = true,
    this.waterEvening = true,
    this.mealReminders = true,
    this.habitReminders = true,
    this.sleepReminder = false,
    this.bedtime = const TimeOfDay(hour: 23, minute: 0),
    this.streakWarning = true,
    this.aiInsightReady = true,
    this.weeklyRecap = true,
  });

  final bool masterEnabled;

  // Water — three independent windows.
  final bool waterMorning; // 09:00
  final bool waterAfternoon; // 13:00
  final bool waterEvening; // 18:30

  final bool mealReminders;
  final bool habitReminders;

  final bool sleepReminder;
  final TimeOfDay bedtime;

  final bool streakWarning;
  final bool aiInsightReady;
  final bool weeklyRecap;

  static const _storageKey = 'nuveli.notifications.settings.v1';

  // Fixed water reminder times. Could be made user-configurable later;
  // for v1 we keep them opinionated and let the user toggle on/off.
  static const waterMorningTime = TimeOfDay(hour: 9, minute: 0);
  static const waterAfternoonTime = TimeOfDay(hour: 13, minute: 0);
  static const waterEveningTime = TimeOfDay(hour: 18, minute: 30);

  List<TimeOfDay> get enabledWaterTimes => [
        if (waterMorning) waterMorningTime,
        if (waterAfternoon) waterAfternoonTime,
        if (waterEvening) waterEveningTime,
      ];

  NotificationSettings copyWith({
    bool? masterEnabled,
    bool? waterMorning,
    bool? waterAfternoon,
    bool? waterEvening,
    bool? mealReminders,
    bool? habitReminders,
    bool? sleepReminder,
    TimeOfDay? bedtime,
    bool? streakWarning,
    bool? aiInsightReady,
    bool? weeklyRecap,
  }) {
    return NotificationSettings(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      waterMorning: waterMorning ?? this.waterMorning,
      waterAfternoon: waterAfternoon ?? this.waterAfternoon,
      waterEvening: waterEvening ?? this.waterEvening,
      mealReminders: mealReminders ?? this.mealReminders,
      habitReminders: habitReminders ?? this.habitReminders,
      sleepReminder: sleepReminder ?? this.sleepReminder,
      bedtime: bedtime ?? this.bedtime,
      streakWarning: streakWarning ?? this.streakWarning,
      aiInsightReady: aiInsightReady ?? this.aiInsightReady,
      weeklyRecap: weeklyRecap ?? this.weeklyRecap,
    );
  }

  Map<String, dynamic> toJson() => {
        'masterEnabled': masterEnabled,
        'waterMorning': waterMorning,
        'waterAfternoon': waterAfternoon,
        'waterEvening': waterEvening,
        'mealReminders': mealReminders,
        'habitReminders': habitReminders,
        'sleepReminder': sleepReminder,
        'bedtimeHour': bedtime.hour,
        'bedtimeMinute': bedtime.minute,
        'streakWarning': streakWarning,
        'aiInsightReady': aiInsightReady,
        'weeklyRecap': weeklyRecap,
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      masterEnabled: json['masterEnabled'] as bool? ?? true,
      waterMorning: json['waterMorning'] as bool? ?? true,
      waterAfternoon: json['waterAfternoon'] as bool? ?? true,
      waterEvening: json['waterEvening'] as bool? ?? true,
      mealReminders: json['mealReminders'] as bool? ?? true,
      habitReminders: json['habitReminders'] as bool? ?? true,
      sleepReminder: json['sleepReminder'] as bool? ?? false,
      bedtime: TimeOfDay(
        hour: json['bedtimeHour'] as int? ?? 23,
        minute: json['bedtimeMinute'] as int? ?? 0,
      ),
      streakWarning: json['streakWarning'] as bool? ?? true,
      aiInsightReady: json['aiInsightReady'] as bool? ?? true,
      weeklyRecap: json['weeklyRecap'] as bool? ?? true,
    );
  }
}

/// StateNotifier that owns the settings + drives the OS scheduler.
class NotificationSettingsController
    extends StateNotifier<NotificationSettings> {
  NotificationSettingsController(this._prefs, this._service)
      : super(_load(_prefs));

  final SharedPreferences _prefs;
  final NotificationService _service;

  static NotificationSettings _load(SharedPreferences prefs) {
    final raw = prefs.getString(NotificationSettings._storageKey);
    if (raw == null) return const NotificationSettings();
    try {
      return NotificationSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const NotificationSettings();
    }
  }

  // ── Mutators ────────────────────────────────────────────────

  Future<void> setMasterEnabled(bool value) async {
    await _update(state.copyWith(masterEnabled: value));
  }

  Future<void> setWaterMorning(bool value) =>
      _update(state.copyWith(waterMorning: value));
  Future<void> setWaterAfternoon(bool value) =>
      _update(state.copyWith(waterAfternoon: value));
  Future<void> setWaterEvening(bool value) =>
      _update(state.copyWith(waterEvening: value));

  Future<void> setMealReminders(bool value) =>
      _update(state.copyWith(mealReminders: value));

  Future<void> setHabitReminders(bool value) =>
      _update(state.copyWith(habitReminders: value));

  Future<void> setSleepReminder(bool value) =>
      _update(state.copyWith(sleepReminder: value));
  Future<void> setBedtime(TimeOfDay time) =>
      _update(state.copyWith(bedtime: time));

  Future<void> setStreakWarning(bool value) =>
      _update(state.copyWith(streakWarning: value));

  Future<void> setAiInsightReady(bool value) =>
      _update(state.copyWith(aiInsightReady: value));

  Future<void> setWeeklyRecap(bool value) =>
      _update(state.copyWith(weeklyRecap: value));

  // ── Plumbing ────────────────────────────────────────────────

  /// Persist + reschedule everything that changed. Cheap to overschedule
  /// (each scheduler call cancels its own type first), so we don't try to
  /// diff — just reapply.
  Future<void> _update(NotificationSettings next) async {
    state = next;
    await _prefs.setString(
      NotificationSettings._storageKey,
      jsonEncode(next.toJson()),
    );
    await _applyToScheduler();
    // Backend sync is fire-and-forget — wire to your profile repo here.
    // Example: ref.read(profileRepoProvider).updateNotificationSettings(next);
  }

  /// Reapply every schedule to match current state. Call after permission
  /// is granted, after settings change, and once per app launch.
  Future<void> _applyToScheduler() async {
    // Master kill switch — cancel everything and bail.
    if (!state.masterEnabled) {
      await _service.cancelAll();
      return;
    }

    await _service.scheduleWaterReminders(state.enabledWaterTimes);
    await _service.scheduleMealReminders(enabled: state.mealReminders);
    await _service.scheduleSleepReminder(
      enabled: state.sleepReminder,
      bedtime: state.bedtime,
    );
    await _service.scheduleStreakWarning(enabled: state.streakWarning);
    await _service.scheduleAiInsightReady(enabled: state.aiInsightReady);
    await _service.scheduleWeeklyRecap(enabled: state.weeklyRecap);
    // Habit reminders need the habits list — those are scheduled from the
    // habits feature when habits change. See habits provider.
  }

  /// Public hook for app startup: reapply schedules so a fresh OS install
  /// (where pending alarms were lost) gets them back.
  Future<void> reapplyOnStartup() => _applyToScheduler();
}

// ──────────────────── Providers ────────────────────

/// Override this in `main()` after awaiting `SharedPreferences.getInstance()`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main()');
});

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

final notificationSettingsProvider = StateNotifierProvider<
    NotificationSettingsController, NotificationSettings>((ref) {
  return NotificationSettingsController(
    ref.watch(sharedPreferencesProvider),
    ref.watch(notificationServiceProvider),
  );
});
