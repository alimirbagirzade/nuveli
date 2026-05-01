import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/network/app_error.dart';
import 'package:nuveli/features/settings/data/settings_repository.dart';

import '../../_helpers/test_helpers.dart';

void main() {
  late MockDio mockDio;
  late SettingsRepository repo;

  setUpAll(registerFallbackValuesForTests);

  setUp(() {
    mockDio = MockDio();
    repo = SettingsRepository(mockDio);
  });

  group('NotificationPrefs', () {
    test('defaults are all-on with sensible quiet hours', () {
      const d = NotificationPrefs.defaults;
      expect(d.mealReminders, true);
      expect(d.coachNudges, true);
      expect(d.weeklySummary, true);
      expect(d.quietStart, '22:00');
      expect(d.quietEnd, '08:00');
    });

    test('fromJson handles partial data with defaults', () {
      final p = NotificationPrefs.fromJson({
        'meal_reminders': false,
        // diğer alanlar yok — default'lar kullanılsın
      });
      expect(p.mealReminders, false);
      expect(p.coachNudges, true); // default
      expect(p.quietStart, '22:00'); // default
    });

    test('toJson produces backend shape', () {
      const p = NotificationPrefs(
        mealReminders: false,
        coachNudges: true,
        weeklySummary: false,
        quietStart: '23:00',
        quietEnd: '07:30',
      );
      final j = p.toJson();
      expect(j['meal_reminders'], false);
      expect(j['coach_nudges'], true);
      expect(j['quiet_start'], '23:00');
    });

    test('copyWith updates only specified fields', () {
      const base = NotificationPrefs.defaults;
      final updated = base.copyWith(mealReminders: false);
      expect(updated.mealReminders, false);
      expect(updated.coachNudges, true);
      expect(updated.quietStart, '22:00');
    });
  });

  group('getNotificationPrefs()', () {
    test('returns parsed prefs on success', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => successResponse({
          'meal_reminders': true,
          'coach_nudges': false,
          'weekly_summary': true,
          'quiet_start': '21:30',
          'quiet_end': '07:00',
        }),
      );

      final prefs = await repo.getNotificationPrefs();
      expect(prefs.coachNudges, false);
      expect(prefs.quietStart, '21:30');
    });

    test('network error converts to AppError', () async {
      when(() => mockDio.get(any())).thenThrow(networkError());
      expect(
        () => repo.getNotificationPrefs(),
        throwsA(isA<NetworkError>()),
      );
    });
  });

  group('deleteAccount()', () {
    test('sends DELETE /profile', () async {
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => successResponse({'deleted': true}),
      );

      await repo.deleteAccount();
      verify(() => mockDio.delete('/profile')).called(1);
    });

    test('propagates server error', () async {
      when(() => mockDio.delete(any())).thenThrow(
        errorResponse(
          statusCode: 500,
          code: 'INTERNAL_ERROR',
          message: 'Silme başarısız.',
        ),
      );

      expect(
        () => repo.deleteAccount(),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
