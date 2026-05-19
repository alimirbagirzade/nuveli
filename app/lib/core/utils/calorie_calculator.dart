// ============================================================================
// calorie_calculator.dart
// BMR (Mifflin-St Jeor) + TDEE + Calorie target + Water + Macro split.
// Pure Dart — Flutter dependency yok, kolay test edilir.
// Hazırlık dosyası: nuveli_chat15_hazirlik.md → BMR Formülü bölümü
// ============================================================================

import '../../features/auth/models/onboarding_data.dart';

class CalorieCalculation {
  final double bmr;
  final double tdee;
  final int dailyCalorieTarget;
  final int dailyWaterMl;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int proteinPercent;
  final int carbsPercent;
  final int fatPercent;

  const CalorieCalculation({
    required this.bmr,
    required this.tdee,
    required this.dailyCalorieTarget,
    required this.dailyWaterMl,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
  });
}

class CalorieCalculator {
  /// Mifflin-St Jeor formülü.
  /// Erkek:   10·W + 6.25·H − 5·A + 5
  /// Kadın:   10·W + 6.25·H − 5·A − 161
  /// Other:   ortalama (cinsiyet belirtmeyenler için)
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
  }) {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return switch (gender) {
      Gender.male => base + 5,
      Gender.female => base - 161,
      Gender.other => base - 78, // (5 + -161) / 2
    };
  }

  /// TDEE = BMR × activity multiplier
  static double calculateTDEE(double bmr, ActivityLevel level) =>
      bmr * level.multiplier;

  /// Hedefe göre günlük kalori (deficit/surplus).
  /// - Lose:        TDEE − 500  (≈0.5 kg/hafta)
  /// - Maintain:    TDEE
  /// - Gain:        TDEE + 500
  /// - BuildMuscle: TDEE + 300  (lean bulk)
  ///
  /// Güvenlik: kadınlar için minimum 1200, erkekler için 1500 floor.
  static int calculateCalorieTarget({
    required double tdee,
    required GoalType goal,
    required Gender gender,
  }) {
    final raw = switch (goal) {
      GoalType.loseWeight => tdee - 500,
      GoalType.maintain => tdee,
      GoalType.gainWeight => tdee + 500,
      GoalType.buildMuscle => tdee + 300,
    };

    final floor = switch (gender) {
      Gender.male => 1500.0,
      Gender.female => 1200.0,
      Gender.other => 1350.0,
    };

    return raw < floor ? floor.round() : raw.round();
  }

  /// Günlük su (ml) — kilo başına 35 ml, 50ml'lik en yakın değere yuvarla.
  static int calculateDailyWater(double weightKg) {
    final raw = weightKg * 35;
    return (raw / 50).round() * 50;
  }

  /// Makro split (varsayılan 25/45/30). Goal'a göre küçük ayarlama:
  /// - BuildMuscle/Gain: protein ↑ (30/45/25)
  /// - Lose: protein ↑ daha agresif (35/40/25) — sazırlığı korur
  static ({int protein, int carbs, int fat}) calculateMacroSplit(GoalType goal) {
    return switch (goal) {
      GoalType.loseWeight => (protein: 35, carbs: 40, fat: 25),
      GoalType.maintain => (protein: 25, carbs: 45, fat: 30),
      GoalType.gainWeight => (protein: 25, carbs: 50, fat: 25),
      GoalType.buildMuscle => (protein: 30, carbs: 45, fat: 25),
    };
  }

  /// Yüzdeleri gram cinsine çevirir.
  /// Protein/Carbs: 4 kcal/g · Fat: 9 kcal/g
  static ({int protein, int carbs, int fat}) gramsFromPercent({
    required int calories,
    required int proteinPercent,
    required int carbsPercent,
    required int fatPercent,
  }) =>
      (
        protein: (calories * proteinPercent / 100 / 4).round(),
        carbs: (calories * carbsPercent / 100 / 4).round(),
        fat: (calories * fatPercent / 100 / 9).round(),
      );

  // --------------------------------------------------------------------------
  // ALL-IN-ONE — OnboardingData → CalorieCalculation
  // Step 5 bunu çağırır. Eksik alan varsa null döner.
  // --------------------------------------------------------------------------
  static CalorieCalculation? fromOnboarding(OnboardingData data) {
    if (!data.isReadyForCalculation) return null;

    final bmr = calculateBMR(
      weightKg: data.currentWeightKg!,
      heightCm: data.heightCm!,
      age: data.age!,
      gender: data.gender!,
    );
    final tdee = calculateTDEE(bmr, data.activityLevel!);
    final calories = calculateCalorieTarget(
      tdee: tdee,
      goal: data.goalType!,
      gender: data.gender!,
    );
    final water = calculateDailyWater(data.currentWeightKg!);
    final macros = calculateMacroSplit(data.goalType!);
    final grams = gramsFromPercent(
      calories: calories,
      proteinPercent: macros.protein,
      carbsPercent: macros.carbs,
      fatPercent: macros.fat,
    );

    return CalorieCalculation(
      bmr: bmr,
      tdee: tdee,
      dailyCalorieTarget: calories,
      dailyWaterMl: water,
      proteinGrams: grams.protein,
      carbsGrams: grams.carbs,
      fatGrams: grams.fat,
      proteinPercent: macros.protein,
      carbsPercent: macros.carbs,
      fatPercent: macros.fat,
    );
  }
}
