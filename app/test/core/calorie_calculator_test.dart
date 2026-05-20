// Unit tests for CalorieCalculator — BMR (Mifflin-St Jeor), TDEE,
// calorie target with safety floor, water + macro split.
//
// These are the math the whole onboarding flow depends on. If any of
// these go red, the user gets wrong daily targets → which propagates
// to every screen and notification. Treat as critical-path tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/utils/calorie_calculator.dart';
import 'package:nuveli/features/auth/models/onboarding_data.dart';

void main() {
  group('CalorieCalculator.calculateBMR (Mifflin-St Jeor)', () {
    // Reference: https://en.wikipedia.org/wiki/Basal_metabolic_rate#BMR_estimation_formulas
    // Formula: 10*W + 6.25*H - 5*A + sex_offset
    //   male:   +5
    //   female: -161
    //   other:  -78 (average of male/female offset)

    test('male 30y / 80kg / 180cm → 1780 kcal', () {
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        gender: Gender.male,
      );
      // 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780
      expect(bmr, closeTo(1780, 0.01));
    });

    test('female 25y / 60kg / 165cm → 1345.25 kcal', () {
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: 60,
        heightCm: 165,
        age: 25,
        gender: Gender.female,
      );
      // 10*60 + 6.25*165 - 5*25 - 161 = 600 + 1031.25 - 125 - 161 = 1345.25
      expect(bmr, closeTo(1345.25, 0.01));
    });

    test('other 40y / 70kg / 170cm → 1484.5 kcal (average offset)', () {
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: 70,
        heightCm: 170,
        age: 40,
        gender: Gender.other,
      );
      // 10*70 + 6.25*170 - 5*40 - 78 = 700 + 1062.5 - 200 - 78 = 1484.5
      expect(bmr, closeTo(1484.5, 0.01));
    });

    test('male BMR > female BMR for identical body metrics', () {
      // Same body, sex offset alone should produce ~166 kcal gap (5 - (-161)).
      final male = CalorieCalculator.calculateBMR(
        weightKg: 70, heightCm: 170, age: 30, gender: Gender.male,
      );
      final female = CalorieCalculator.calculateBMR(
        weightKg: 70, heightCm: 170, age: 30, gender: Gender.female,
      );
      expect(male - female, closeTo(166, 0.01));
    });

    test('BMR drops by exactly 5 kcal for each year of age', () {
      final at30 = CalorieCalculator.calculateBMR(
        weightKg: 70, heightCm: 170, age: 30, gender: Gender.male,
      );
      final at40 = CalorieCalculator.calculateBMR(
        weightKg: 70, heightCm: 170, age: 40, gender: Gender.male,
      );
      expect(at30 - at40, closeTo(50, 0.01)); // 10 years × 5 kcal
    });
  });

  group('CalorieCalculator.calculateTDEE (BMR × activity multiplier)', () {
    // Multipliers (defined on ActivityLevel.multiplier):
    //   sedentary  1.2
    //   light      1.375
    //   moderate   1.55
    //   active     1.725
    //   veryActive 1.9
    const bmr = 1780.0;

    test('sedentary → BMR × 1.2', () {
      expect(
        CalorieCalculator.calculateTDEE(bmr, ActivityLevel.sedentary),
        closeTo(bmr * 1.2, 0.01),
      );
    });

    test('moderate → BMR × 1.55', () {
      expect(
        CalorieCalculator.calculateTDEE(bmr, ActivityLevel.moderate),
        closeTo(bmr * 1.55, 0.01),
      );
    });

    test('veryActive → BMR × 1.9 (highest multiplier)', () {
      expect(
        CalorieCalculator.calculateTDEE(bmr, ActivityLevel.veryActive),
        closeTo(bmr * 1.9, 0.01),
      );
    });

    test('TDEE strictly increases with activity level', () {
      final sedentary = CalorieCalculator.calculateTDEE(bmr, ActivityLevel.sedentary);
      final light = CalorieCalculator.calculateTDEE(bmr, ActivityLevel.light);
      final moderate = CalorieCalculator.calculateTDEE(bmr, ActivityLevel.moderate);
      final active = CalorieCalculator.calculateTDEE(bmr, ActivityLevel.active);
      final veryActive = CalorieCalculator.calculateTDEE(bmr, ActivityLevel.veryActive);
      expect(sedentary < light, isTrue);
      expect(light < moderate, isTrue);
      expect(moderate < active, isTrue);
      expect(active < veryActive, isTrue);
    });
  });

  group('CalorieCalculator.calculateCalorieTarget (goal-based + floors)', () {
    test('maintain → TDEE unchanged', () {
      final target = CalorieCalculator.calculateCalorieTarget(
        tdee: 2500,
        goal: GoalType.maintain,
        gender: Gender.male,
      );
      expect(target, 2500);
    });

    test('loseWeight → TDEE − 500', () {
      final target = CalorieCalculator.calculateCalorieTarget(
        tdee: 2500,
        goal: GoalType.loseWeight,
        gender: Gender.male,
      );
      expect(target, 2000);
    });

    test('gainWeight → TDEE + 500', () {
      final target = CalorieCalculator.calculateCalorieTarget(
        tdee: 2500,
        goal: GoalType.gainWeight,
        gender: Gender.male,
      );
      expect(target, 3000);
    });

    test('buildMuscle → TDEE + 300 (lean bulk)', () {
      final target = CalorieCalculator.calculateCalorieTarget(
        tdee: 2500,
        goal: GoalType.buildMuscle,
        gender: Gender.male,
      );
      expect(target, 2800);
    });

    test('female safety floor = 1200 kcal (deficit cannot dip below)', () {
      // TDEE 1400 - 500 (lose) = 900, must clamp to 1200.
      final target = CalorieCalculator.calculateCalorieTarget(
        tdee: 1400,
        goal: GoalType.loseWeight,
        gender: Gender.female,
      );
      expect(target, 1200);
    });

    test('male safety floor = 1500 kcal', () {
      // TDEE 1700 - 500 = 1200, must clamp to 1500 for males.
      final target = CalorieCalculator.calculateCalorieTarget(
        tdee: 1700,
        goal: GoalType.loseWeight,
        gender: Gender.male,
      );
      expect(target, 1500);
    });

    test('floor does not affect non-deficit goals', () {
      // Maintain at 1600 for a male — above floor, should pass through.
      final target = CalorieCalculator.calculateCalorieTarget(
        tdee: 1600,
        goal: GoalType.maintain,
        gender: Gender.male,
      );
      expect(target, 1600);
    });
  });

  group('CalorieCalculator.calculateDailyWater', () {
    test('70 kg → 2450 ml (70 × 35 = 2450, already a multiple of 50)', () {
      expect(CalorieCalculator.calculateDailyWater(70), 2450);
    });

    test('80 kg → 2800 ml', () {
      expect(CalorieCalculator.calculateDailyWater(80), 2800);
    });

    test('rounds to the nearest 50 ml', () {
      // 73 × 35 = 2555 → nearest multiple of 50 is 2550.
      expect(CalorieCalculator.calculateDailyWater(73), 2550);
      // 76 × 35 = 2660 → rounds to 2650.
      expect(CalorieCalculator.calculateDailyWater(76), 2650);
    });
  });

  group('CalorieCalculator.calculateMacroSplit', () {
    test('lose → protein-heavy (35/40/25)', () {
      final s = CalorieCalculator.calculateMacroSplit(GoalType.loseWeight);
      expect(s.protein, 35);
      expect(s.carbs, 40);
      expect(s.fat, 25);
    });

    test('maintain → 25/45/30', () {
      final s = CalorieCalculator.calculateMacroSplit(GoalType.maintain);
      expect(s.protein, 25);
      expect(s.carbs, 45);
      expect(s.fat, 30);
    });

    test('gainWeight → 25/50/25', () {
      final s = CalorieCalculator.calculateMacroSplit(GoalType.gainWeight);
      expect(s.protein, 25);
      expect(s.carbs, 50);
      expect(s.fat, 25);
    });

    test('buildMuscle → protein-heavy lean bulk (30/45/25)', () {
      final s = CalorieCalculator.calculateMacroSplit(GoalType.buildMuscle);
      expect(s.protein, 30);
      expect(s.carbs, 45);
      expect(s.fat, 25);
    });

    test('macro percentages always sum to 100', () {
      for (final g in GoalType.values) {
        final s = CalorieCalculator.calculateMacroSplit(g);
        expect(
          s.protein + s.carbs + s.fat,
          100,
          reason: 'split for $g should sum to 100',
        );
      }
    });
  });

  group('CalorieCalculator.gramsFromPercent', () {
    test('protein/carbs at 4 kcal/g, fat at 9 kcal/g', () {
      final g = CalorieCalculator.gramsFromPercent(
        calories: 2000,
        proteinPercent: 25,
        carbsPercent: 45,
        fatPercent: 30,
      );
      // protein: 2000 * 0.25 / 4 = 125
      // carbs:   2000 * 0.45 / 4 = 225
      // fat:     2000 * 0.30 / 9 = 66.67 → 67
      expect(g.protein, 125);
      expect(g.carbs, 225);
      expect(g.fat, 67);
    });

    test('rounds each macro to nearest gram independently', () {
      final g = CalorieCalculator.gramsFromPercent(
        calories: 2046,
        proteinPercent: 35,
        carbsPercent: 40,
        fatPercent: 25,
      );
      // protein: 2046 * 0.35 / 4 = 179.025 → 179
      // carbs:   2046 * 0.40 / 4 = 204.6   → 205
      // fat:     2046 * 0.25 / 9 = 56.83   → 57
      expect(g.protein, 179);
      expect(g.carbs, 205);
      expect(g.fat, 57);
    });
  });

  group('CalorieCalculator.fromOnboarding', () {
    test('null when isReadyForCalculation is false', () {
      // No dob / gender / heightCm / weightKg / activityLevel / goalType.
      const empty = OnboardingData();
      expect(CalorieCalculator.fromOnboarding(empty), isNull);
    });

    test('null when a required field is still missing', () {
      // All but goalType set.
      final partial = const OnboardingData().copyWith(
        dateOfBirth: DateTime(1995, 6, 15),
        gender: Gender.male,
        heightCm: 178,
        currentWeightKg: 75,
        activityLevel: ActivityLevel.moderate,
        // goalType omitted on purpose
      );
      expect(CalorieCalculator.fromOnboarding(partial), isNull);
    });

    test('full happy path: produces a coherent CalorieCalculation', () {
      final data = const OnboardingData().copyWith(
        dateOfBirth: DateTime(1995, 6, 15),
        gender: Gender.male,
        heightCm: 178,
        currentWeightKg: 75,
        activityLevel: ActivityLevel.moderate,
        goalType: GoalType.maintain,
      );
      final calc = CalorieCalculator.fromOnboarding(data)!;

      // bmr/tdee positive
      expect(calc.bmr, greaterThan(0));
      expect(calc.tdee, greaterThan(calc.bmr));
      // Maintain → calorie target ≈ TDEE (rounded)
      expect(calc.dailyCalorieTarget, calc.tdee.round());
      // Water target is a multiple of 50.
      expect(calc.dailyWaterMl % 50, 0);
      // Macro grams sum back to (~) the calorie target (allow rounding drift).
      final reconstructed = calc.proteinGrams * 4 + calc.carbsGrams * 4 + calc.fatGrams * 9;
      expect(
        (reconstructed - calc.dailyCalorieTarget).abs(),
        lessThanOrEqualTo(10),
      );
      // Macro percentages reflect the maintain split.
      expect(calc.proteinPercent, 25);
      expect(calc.carbsPercent, 45);
      expect(calc.fatPercent, 30);
    });
  });
}
