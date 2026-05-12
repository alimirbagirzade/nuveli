import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../coach/data/coach_repository.dart';
import '../../home/data/home_repository.dart';
import '../../meal/providers/meal_providers.dart';
import '../../onboarding/providers/onboarding_controller.dart';
import '../../premium/data/premium_service.dart';
import '../../profile/data/profile_repository.dart';
import '../../progress/data/progress_repository.dart';
import '../../streak/data/streak_repository.dart';
import '../../tracking/data/tracking_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/settings_repository.dart';

/// Backend'den bildirim tercihlerini çeker (cache'li).
final notificationPrefsProvider = FutureProvider<NotificationPrefs>((ref) async {
  return ref.watch(settingsRepositoryProvider).getNotificationPrefs();
});

/// Local form state — kullanıcı switch'leri değiştirirken tutar.
/// Backend'den gelen değer ile initialize edilir, "Kaydet" ile server'a gider.
class NotificationPrefsController
    extends StateNotifier<AsyncValue<NotificationPrefs>> {
  NotificationPrefsController(this._repo)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repo;

  Future<void> _load() async {
    try {
      final prefs = await _repo.getNotificationPrefs();
      state = AsyncValue.data(prefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setMealReminders(bool value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(mealReminders: value));
  }

  void setCoachNudges(bool value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(coachNudges: value));
  }

  void setWeeklySummary(bool value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(weeklySummary: value));
  }

  void setQuietStart(String value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(quietStart: value));
  }

  void setQuietEnd(String value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(quietEnd: value));
  }

  /// Değişiklikleri backend'e kaydet.
  Future<void> save() async {
    final current = state.value;
    if (current == null) return;
    await _repo.saveNotificationPrefs(current);
  }
}

final notificationPrefsControllerProvider = StateNotifierProvider<
    NotificationPrefsController, AsyncValue<NotificationPrefs>>((ref) {
  return NotificationPrefsController(ref.watch(settingsRepositoryProvider));
});

/// Hesabı silme action'ı.
/// Sırasıyla: backend DELETE → Supabase session çıkışı.
final deleteAccountActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final authRepo = ref.read(authRepositoryProvider);

    // 1. Backend: tüm veri + auth user sil
    await settingsRepo.deleteAccount();

    // 2. Local: Supabase session'ı temizle (zaten sunucuda silindi ama client state)
    await authRepo.signOut();

    // 3. TÜM kullanıcıya özel cache'i temizle (state leak fix)
    ref.invalidate(bootstrapProvider);
    ref.invalidate(homePayloadProvider);
    ref.invalidate(todayMealsProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(weeklySummaryProvider);
    ref.invalidate(monthlyInsightProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(coachThreadProvider);
    ref.invalidate(notificationPrefsProvider);
    ref.invalidate(waterHistoryProvider);
    ref.invalidate(weightHistoryProvider);
    ref.invalidate(premiumStatusProvider);
    ref.read(onboardingControllerProvider.notifier).reset();
  };
});

/// Save sırasında loading flag.
final settingsSavingProvider = StateProvider<bool>((ref) => false);
