// ============================================================================
// onboarding_provider.dart
// Onboarding'in 5 step'i boyunca akan state.
// - update(OnboardingData) ile her step kendi alanını günceller
// - SharedPreferences ile persist (app kapanırsa kaldığı yerden devam)
// - reset() → flow başa döner (onboarding tamamlanınca temizlenir)
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/onboarding_data.dart';

const _kStorageKey = 'nuveli_onboarding_draft_v1';

// ============================================================================
// NOTIFIER
// ============================================================================

class OnboardingNotifier extends Notifier<OnboardingData> {
  bool _restored = false;

  @override
  OnboardingData build() {
    // Build sync olmak zorunda. Restore'u async background'da yap.
    Future.microtask(_restoreDraft);
    return const OnboardingData();
  }

  // --------------------------------------------------------------------------
  // PERSISTENCE
  // --------------------------------------------------------------------------
  Future<void> _restoreDraft() async {
    if (_restored) return;
    _restored = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw != null) {
        state = OnboardingData.decode(raw);
      }
    } catch (_) {
      // Restore başarısız → ignore, boş state ile devam.
    }
  }

  Future<void> _persistDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kStorageKey, state.encode());
    } catch (_) {
      // Persist başarısız → kullanıcı UX'i etkilemesin.
    }
  }

  // --------------------------------------------------------------------------
  // MUTATIONS
  // --------------------------------------------------------------------------
  /// Step ekranları her field için bunu çağırır.
  void update({
    String? displayName,
    DateTime? dateOfBirth,
    Gender? gender,
    double? heightCm,
    double? currentWeightKg,
    ActivityLevel? activityLevel,
    GoalType? goalType,
    double? targetWeightKg,
    DateTime? targetDate,
    int? dailyCalorieTarget,
    int? dailyWaterMl,
    int? proteinPercent,
    int? carbsPercent,
    int? fatPercent,
  }) {
    state = state.copyWith(
      displayName: displayName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      activityLevel: activityLevel,
      goalType: goalType,
      targetWeightKg: targetWeightKg,
      targetDate: targetDate,
      dailyCalorieTarget: dailyCalorieTarget,
      dailyWaterMl: dailyWaterMl,
      proteinPercent: proteinPercent,
      carbsPercent: carbsPercent,
      fatPercent: fatPercent,
    );
    _persistDraft();
  }

  /// Onboarding tamamlanınca temizle.
  Future<void> reset() async {
    state = const OnboardingData();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStorageKey);
    } catch (_) {}
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

final onboardingDataProvider =
    NotifierProvider<OnboardingNotifier, OnboardingData>(
        OnboardingNotifier.new);

/// Kullanıcı şu an hangi step'te (0..4). PageView controller'la sync edilir.
final onboardingStepProvider = StateProvider<int>((ref) => 0);
