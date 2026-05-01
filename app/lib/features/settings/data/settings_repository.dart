import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// Bildirim tercihleri modeli.
class NotificationPrefs {
  const NotificationPrefs({
    required this.mealReminders,
    required this.coachNudges,
    required this.weeklySummary,
    required this.quietStart,
    required this.quietEnd,
  });

  final bool mealReminders;
  final bool coachNudges;
  final bool weeklySummary;
  final String quietStart; // "22:00"
  final String quietEnd; // "08:00"

  static const defaults = NotificationPrefs(
    mealReminders: true,
    coachNudges: true,
    weeklySummary: true,
    quietStart: '22:00',
    quietEnd: '08:00',
  );

  factory NotificationPrefs.fromJson(Map<String, dynamic> j) =>
      NotificationPrefs(
        mealReminders: j['meal_reminders'] as bool? ?? true,
        coachNudges: j['coach_nudges'] as bool? ?? true,
        weeklySummary: j['weekly_summary'] as bool? ?? true,
        quietStart: j['quiet_start'] as String? ?? '22:00',
        quietEnd: j['quiet_end'] as String? ?? '08:00',
      );

  Map<String, dynamic> toJson() => {
        'meal_reminders': mealReminders,
        'coach_nudges': coachNudges,
        'weekly_summary': weeklySummary,
        'quiet_start': quietStart,
        'quiet_end': quietEnd,
      };

  NotificationPrefs copyWith({
    bool? mealReminders,
    bool? coachNudges,
    bool? weeklySummary,
    String? quietStart,
    String? quietEnd,
  }) {
    return NotificationPrefs(
      mealReminders: mealReminders ?? this.mealReminders,
      coachNudges: coachNudges ?? this.coachNudges,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
    );
  }
}

/// Settings backend operasyonları.
class SettingsRepository {
  SettingsRepository(this._dio);
  final Dio _dio;

  Future<NotificationPrefs> getNotificationPrefs() async {
    try {
      final resp = await _dio.get('/profile/notification-preferences');
      return NotificationPrefs.fromJson(
          resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  Future<void> saveNotificationPrefs(NotificationPrefs prefs) async {
    try {
      await _dio.post(
        '/profile/notification-preferences',
        data: prefs.toJson(),
      );
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// Hesabı + tüm veriyi kalıcı olarak siler.
  /// Bu başarılı olursa frontend'de Supabase session'ı temizlenmeli.
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/profile');
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(apiClientProvider));
});
