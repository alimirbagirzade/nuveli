// Unit tests for UserProfile.fromJson — backend → Dart model
// serialization. Tests the deserialization logic exactly as it is
// today.
//
// NOTE: The backend's actual response shape (Chat 22 alignment work)
// uses `full_name`, `sex`, `weight_kg`, `weight_goal_direction`,
// `daily_water_target_ml`, `protein_target_g` etc. The current
// fromJson reads the OLDER key names (`display_name`, `gender`,
// `current_weight_kg`, `goal_type`, `daily_water_ml`,
// `protein_percent`). That mismatch is a known follow-up — these
// tests lock the *current* code so the inevitable refactor is
// intentional and visible.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/auth/models/onboarding_data.dart';
import 'package:nuveli/features/auth/services/profile_service.dart';

void main() {
  group('UserProfile.fromJson — happy path', () {
    test('parses a fully-populated profile JSON', () {
      final json = <String, dynamic>{
        'id': 'profile-uuid',
        'display_name': 'Ali',
        'email': 'ali@example.com',
        'date_of_birth': '1995-06-15',
        'gender': 'male',
        'height_cm': 178.0,
        'current_weight_kg': 75.0,
        'activity_level': 'moderate',
        'goal_type': 'maintain',
        'target_weight_kg': 75.0,
        'daily_calorie_target': 2500,
        'daily_water_ml': 2500,
        'protein_percent': 30,
        'carbs_percent': 40,
        'fat_percent': 30,
        'onboarding_completed': true,
        'is_premium': false,
        'created_at': '2026-01-15T08:30:00Z',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'profile-uuid');
      expect(profile.displayName, 'Ali');
      expect(profile.email, 'ali@example.com');
      expect(profile.dateOfBirth, DateTime.parse('1995-06-15'));
      expect(profile.gender, Gender.male);
      expect(profile.heightCm, 178.0);
      expect(profile.currentWeightKg, 75.0);
      expect(profile.activityLevel, ActivityLevel.moderate);
      expect(profile.goalType, GoalType.maintain);
      expect(profile.targetWeightKg, 75.0);
      expect(profile.dailyCalorieTarget, 2500);
      expect(profile.dailyWaterMl, 2500);
      expect(profile.proteinPercent, 30);
      expect(profile.carbsPercent, 40);
      expect(profile.fatPercent, 30);
      expect(profile.onboardingCompleted, true);
      expect(profile.isPremium, false);
      expect(profile.createdAt, DateTime.parse('2026-01-15T08:30:00Z'));
    });
  });

  group('UserProfile.fromJson — null-safety + defaults', () {
    test('minimal JSON (just id + created_at) leaves optional fields null', () {
      final json = <String, dynamic>{
        'id': 'profile-uuid',
        'created_at': '2026-01-15T08:30:00Z',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'profile-uuid');
      expect(profile.displayName, isNull);
      expect(profile.email, isNull);
      expect(profile.dateOfBirth, isNull);
      expect(profile.gender, isNull);
      expect(profile.heightCm, isNull);
      expect(profile.currentWeightKg, isNull);
      expect(profile.activityLevel, isNull);
      expect(profile.goalType, isNull);
      expect(profile.targetWeightKg, isNull);
      expect(profile.dailyCalorieTarget, isNull);
      expect(profile.dailyWaterMl, isNull);
      expect(profile.proteinPercent, isNull);
      expect(profile.carbsPercent, isNull);
      expect(profile.fatPercent, isNull);
    });

    test('missing onboarding_completed defaults to false', () {
      final profile = UserProfile.fromJson({
        'id': 'x',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.onboardingCompleted, false);
    });

    test('missing is_premium defaults to false', () {
      final profile = UserProfile.fromJson({
        'id': 'x',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.isPremium, false);
    });

    test('missing created_at falls back to DateTime.now (lenient parse)', () {
      // Defensive — if Supabase ever omits created_at we don't crash.
      final before = DateTime.now();
      final profile = UserProfile.fromJson({'id': 'x'});
      final after = DateTime.now();

      expect(profile.createdAt.isBefore(before), isFalse);
      expect(profile.createdAt.isAfter(after), isFalse);
    });

    test('integer height_cm/weight_kg widens to double', () {
      // Postgres NUMERIC can deserialize as int when value is whole.
      final profile = UserProfile.fromJson({
        'id': 'x',
        'height_cm': 180, // int, not double
        'current_weight_kg': 70, // int
        'target_weight_kg': 65,
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.heightCm, 180.0);
      expect(profile.currentWeightKg, 70.0);
      expect(profile.targetWeightKg, 65.0);
    });
  });

  group('UserProfile.fromJson — enum tolerance', () {
    test('unknown gender string falls back to Gender.other', () {
      // Gender.tryFromJson uses orElse: () => Gender.other.
      final profile = UserProfile.fromJson({
        'id': 'x',
        'gender': 'something_new',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.gender, Gender.other);
    });

    test('unknown activity_level falls back to ActivityLevel.sedentary', () {
      final profile = UserProfile.fromJson({
        'id': 'x',
        'activity_level': 'extreme',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.activityLevel, ActivityLevel.sedentary);
    });

    test('unknown goal_type falls back to GoalType.maintain', () {
      final profile = UserProfile.fromJson({
        'id': 'x',
        'goal_type': 'shred_extreme',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.goalType, GoalType.maintain);
    });

    test('null enum stays null (does not fall through to default)', () {
      final profile = UserProfile.fromJson({
        'id': 'x',
        'gender': null,
        'activity_level': null,
        'goal_type': null,
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.gender, isNull);
      expect(profile.activityLevel, isNull);
      expect(profile.goalType, isNull);
    });
  });

  group('UserProfile.fromJson — date parsing', () {
    test('ISO 8601 string is parsed', () {
      final profile = UserProfile.fromJson({
        'id': 'x',
        'date_of_birth': '1990-01-15',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.dateOfBirth, DateTime.parse('1990-01-15'));
    });

    test('invalid date string falls back to null (does not crash)', () {
      final profile = UserProfile.fromJson({
        'id': 'x',
        'date_of_birth': 'not-a-date',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.dateOfBirth, isNull);
    });
  });

  // Document the known mismatch: backend now responds with newer
  // keys (full_name, sex, weight_kg, …). The current fromJson does
  // not read them. When the model is updated, the assertions below
  // will flip — and that's the signal to revisit this file.
  group('UserProfile.fromJson — KNOWN follow-up (mismatch with new backend keys)', () {
    test('backend new-key payload currently DROPS values (display_name vs full_name)', () {
      final newBackendJson = <String, dynamic>{
        'id': 'x',
        'full_name': 'Ali',       // new key (backend post Chat 22)
        'sex': 'male',            // was: gender
        'weight_kg': 75.0,        // was: current_weight_kg
        'created_at': '2026-01-01T00:00:00Z',
      };

      final profile = UserProfile.fromJson(newBackendJson);

      // Until UserProfile.fromJson is refactored, these arrive as null.
      // When that PR lands, flip these expectations and remove the
      // legacy-key tests above.
      expect(profile.displayName, isNull, reason: 'TODO: read full_name');
      expect(profile.gender, isNull, reason: 'TODO: read sex');
      expect(profile.currentWeightKg, isNull, reason: 'TODO: read weight_kg');
    });
  });
}
