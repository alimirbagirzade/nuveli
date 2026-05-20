// Unit tests for OnboardingData — the immutable model that holds every
// answer the user gives across the 5-step onboarding flow. Locks the
// copyWith / readiness flags / toJson wire format the rest of the
// flow depends on.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/auth/models/onboarding_data.dart';

void main() {
  group('OnboardingData.copyWith', () {
    test('null arguments leave existing fields untouched', () {
      final base = const OnboardingData().copyWith(
        displayName: 'Ali',
        heightCm: 178,
      );
      // Calling copyWith with no overrides returns a value-equal copy.
      final copy = base.copyWith();
      expect(copy.displayName, 'Ali');
      expect(copy.heightCm, 178);
    });

    test('provided values override only the named fields', () {
      final base = const OnboardingData().copyWith(
        displayName: 'Ali',
        heightCm: 178,
        currentWeightKg: 75,
      );
      final updated = base.copyWith(currentWeightKg: 80);
      expect(updated.displayName, 'Ali');
      expect(updated.heightCm, 178);
      expect(updated.currentWeightKg, 80);
    });
  });

  group('OnboardingData.isReadyForCalculation', () {
    test('false when any required field is missing', () {
      expect(const OnboardingData().isReadyForCalculation, isFalse);

      final almost = const OnboardingData().copyWith(
        dateOfBirth: DateTime(1995, 6, 15),
        gender: Gender.male,
        heightCm: 178,
        currentWeightKg: 75,
        activityLevel: ActivityLevel.moderate,
        // goalType deliberately missing
      );
      expect(almost.isReadyForCalculation, isFalse);
    });

    test('true once dob + gender + height + weight + activity + goal are set',
        () {
      final ready = const OnboardingData().copyWith(
        dateOfBirth: DateTime(1995, 6, 15),
        gender: Gender.male,
        heightCm: 178,
        currentWeightKg: 75,
        activityLevel: ActivityLevel.moderate,
        goalType: GoalType.maintain,
      );
      expect(ready.isReadyForCalculation, isTrue);
    });
  });

  group('OnboardingData.isComplete', () {
    test('isReadyForCalculation true is NOT enough — needs targets too', () {
      final ready = const OnboardingData().copyWith(
        dateOfBirth: DateTime(1995, 6, 15),
        gender: Gender.male,
        heightCm: 178,
        currentWeightKg: 75,
        activityLevel: ActivityLevel.moderate,
        goalType: GoalType.maintain,
      );
      // Step 5 hasn't run yet, no dailyCalorieTarget / dailyWaterMl.
      expect(ready.isComplete, isFalse);
    });

    test('true once Step 5 has populated calorie + water targets', () {
      final done = const OnboardingData().copyWith(
        dateOfBirth: DateTime(1995, 6, 15),
        gender: Gender.male,
        heightCm: 178,
        currentWeightKg: 75,
        activityLevel: ActivityLevel.moderate,
        goalType: GoalType.maintain,
        dailyCalorieTarget: 2500,
        dailyWaterMl: 2500,
      );
      expect(done.isComplete, isTrue);
    });
  });

  group('OnboardingData.toJson — wire shape', () {
    test('only emits backend keys for non-null fields', () {
      final data = const OnboardingData().copyWith(
        displayName: 'Ali',
        gender: Gender.male,
        currentWeightKg: 75,
        goalType: GoalType.loseWeight,
        activityLevel: ActivityLevel.veryActive,
      );
      final j = data.toJson();

      // Renamed keys (Chat 22 alignment)
      expect(j['full_name'], 'Ali');
      expect(j['sex'], 'male');
      expect(j['weight_kg'], 75);
      expect(j['weight_goal_direction'], 'lose');
      expect(j['activity_level'], 'very_active');

      // Legacy keys are NOT emitted on the wire.
      expect(j.containsKey('display_name'), isFalse);
      expect(j.containsKey('gender'), isFalse);
      expect(j.containsKey('current_weight_kg'), isFalse);
      expect(j.containsKey('goal_type'), isFalse);

      // Null fields stay omitted (so the backend's Optional defaults win).
      expect(j.containsKey('date_of_birth'), isFalse);
      expect(j.containsKey('height_cm'), isFalse);
    });

    test('buildMuscle goal maps to "gain" on the wire', () {
      final data = const OnboardingData().copyWith(
        goalType: GoalType.buildMuscle,
      );
      expect(data.toJson()['weight_goal_direction'], 'gain');
    });
  });

  group('OnboardingData.fromJson — wire shape', () {
    test('reads new + legacy backend key payloads symmetrically', () {
      final fromNew = OnboardingData.fromJson({
        'full_name': 'Ali',
        'sex': 'male',
        'weight_kg': 75.0,
        'weight_goal_direction': 'lose',
      });
      expect(fromNew.displayName, 'Ali');
      expect(fromNew.gender, Gender.male);
      expect(fromNew.currentWeightKg, 75.0);
      expect(fromNew.goalType, GoalType.loseWeight);
    });

    test('round-trip: toJson → fromJson preserves the populated fields', () {
      final original = const OnboardingData().copyWith(
        displayName: 'Ali',
        gender: Gender.male,
        currentWeightKg: 75,
        heightCm: 178,
        goalType: GoalType.maintain,
        activityLevel: ActivityLevel.moderate,
        dailyCalorieTarget: 2500,
      );
      final round = OnboardingData.fromJson(original.toJson());
      expect(round.displayName, original.displayName);
      expect(round.gender, original.gender);
      expect(round.currentWeightKg, original.currentWeightKg);
      expect(round.heightCm, original.heightCm);
      expect(round.goalType, original.goalType);
      expect(round.activityLevel, original.activityLevel);
      expect(round.dailyCalorieTarget, original.dailyCalorieTarget);
    });
  });
}
