import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/profile/models/user_profile.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// Profile / user-account operations.
///
/// `UserProfile` is the canonical user object — created on signup,
/// completed during onboarding (height, weight, goals), and then
/// surfaced everywhere from the dashboard target-ring to AI coach
/// calorie calculations. There is exactly one row per `auth.users`
/// record.
class ProfileRepository extends BaseRepository {
  ProfileRepository(super.apiClient);

  /// Current authenticated user's profile. Falls back to `/me` for
  /// initial onboarding, then `/profile` for subsequent fetches —
  /// both endpoints return the same shape; pick whichever your
  /// backend has wired up.
  Future<UserProfile> getCurrentProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.me,
    );
    return UserProfile.fromJson(response);
  }

  /// Partial-update of editable profile fields. Pass only the fields
  /// the user actually changed; nullable parameters with `null` are
  /// **omitted** from the payload (so we never accidentally null
  /// out a field the user didn't touch).
  Future<UserProfile> updateProfile({
    String? displayName,
    double? weightKg,
    double? heightCm,
    int? dailyCalorieTarget,
    double? proteinTargetPct,
    double? carbsTargetPct,
    double? fatTargetPct,
    String? activityLevel,
    String? goalType, // 'lose' | 'maintain' | 'gain'
  }) async {
    final body = <String, dynamic>{
      if (displayName != null) 'display_name': displayName,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (dailyCalorieTarget != null)
        'daily_calorie_target': dailyCalorieTarget,
      if (proteinTargetPct != null) 'protein_target_pct': proteinTargetPct,
      if (carbsTargetPct != null) 'carbs_target_pct': carbsTargetPct,
      if (fatTargetPct != null) 'fat_target_pct': fatTargetPct,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (goalType != null) 'goal_type': goalType,
    };

    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: body,
    );
    return UserProfile.fromJson(response);
  }

  /// Completes the onboarding flow in a single call — the backend
  /// derives BMR/TDEE from these inputs and seeds the daily targets.
  Future<UserProfile> completeOnboarding({
    required String displayName,
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required String sex, // 'male' | 'female' | 'other'
    required String activityLevel,
    required String goalType,
    double? targetWeightKg,
    DateTime? targetDate,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.onboarding,
      data: {
        'display_name': displayName,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'age_years': ageYears,
        'sex': sex,
        'activity_level': activityLevel,
        'goal_type': goalType,
        if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
        if (targetDate != null) 'target_date': formatDateOnly(targetDate),
      },
    );
    return UserProfile.fromJson(response);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});
