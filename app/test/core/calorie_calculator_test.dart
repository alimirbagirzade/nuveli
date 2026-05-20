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
}
