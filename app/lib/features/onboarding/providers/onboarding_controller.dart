import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/onboarding_data.dart';
import '../data/onboarding_repository.dart';

/// Onboarding boyunca form state'i tutan notifier.
/// Ekranlar arası geçişte veri korunur; cihaz kapanırsa sıfırlanır (kasıtlı — form kısa).
class OnboardingController extends StateNotifier<OnboardingData> {
  OnboardingController(this._repo, this._ref) : super(const OnboardingData());

  final OnboardingRepository _repo;
  final Ref _ref;

  // ---------------------------------------------------------------------------
  // Local updates (her ekran kendi alanını günceller)
  // ---------------------------------------------------------------------------

  void setGoal(String goal) {
    state = state.copyWith(goal: goal);
  }

  void setProfileBasics({
    required int birthYear,
    required String gender,
    String? displayName,
  }) {
    state = state.copyWith(
      birthYear: birthYear,
      gender: gender,
      displayName: displayName,
    );
  }

  void setPhysical({
    required double heightCm,
    required double weightKg,
    required String activityLevel,
  }) {
    state = state.copyWith(
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
    );
  }

  void setSpecialConditions(List<String> conditions) {
    state = state.copyWith(specialConditions: conditions);
  }

  void setCoachPersona(String persona) {
    state = state.copyWith(coachPersona: persona);
  }

  void setNotificationPrefs({
    bool? mealReminders,
    bool? coachNudges,
    bool? weeklySummary,
  }) {
    state = state.copyWith(
      notifMealReminders: mealReminders ?? state.notifMealReminders,
      notifCoachNudges: coachNudges ?? state.notifCoachNudges,
      notifWeeklySummary: weeklySummary ?? state.notifWeeklySummary,
    );
  }

  // ---------------------------------------------------------------------------
  // Backend sync
  // ---------------------------------------------------------------------------

  /// Profil + goal bilgilerini backend'e gönderir.
  /// Backend kalori hedefini döner.
  Future<Map<String, dynamic>> submitProfile() async {
    if (!state.isProfileComplete || state.goal == null) {
      throw StateError('Profil eksik.');
    }
    return _repo.saveProfile(state);
  }

  /// Koç persona kaydet.
  Future<void> submitCoachPersona() async {
    if (state.coachPersona == null) {
      throw StateError('Koç persona seçilmedi.');
    }
    await _repo.saveCoachPersona(state.coachPersona!);
  }

  /// Notification preferences kaydet.
  Future<void> submitNotificationPrefs() async {
    await _repo.saveNotificationPrefs(state);
  }

  /// Onboarding'i kapat + bootstrap cache'i temizle.
  Future<void> completeOnboarding() async {
    await _repo.completeOnboarding();
    // Home'a gitmeden önce bootstrap'i yenile — onboarding_completed: true
    _ref.invalidate(bootstrapProvider);
  }

  /// Onboarding state'ini sıfırla (örneğin logout'tan sonra).
  void reset() {
    state = const OnboardingData();
  }
}

/// Global onboarding provider. Tüm onboarding ekranları bunu watch/read eder.
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingData>((ref) {
  return OnboardingController(
    ref.watch(onboardingRepositoryProvider),
    ref,
  );
});

/// Onboarding submit sırasında loading.
final onboardingSubmittingProvider = StateProvider<bool>((ref) => false);

/// Onboarding hata mesajı.
final onboardingErrorProvider = StateProvider<String?>((ref) => null);
