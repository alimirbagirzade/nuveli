import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/profile/models/user_profile.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// Profile / onboarding mutations against the FastAPI backend.
///
/// Reads (`GET /me`, `GET /weight/goal`, …) are already handled by the
/// existing `profile_provider.dart` via `authedDioProvider`. This
/// repository exists for the **mutation side** — onboarding completion,
/// patches to the user profile — and is consumed by [ProfileActions]
/// in the provider layer.
///
/// Field names below mirror `features/profile/models/user_profile.dart`
/// and the backend's `PATCH /me` body. Snake-case → camel-case
/// translation lives in `UserProfile.fromJson`.
class ProfileRepository extends BaseRepository {
  ProfileRepository(super.apiClient);

  /// Re-fetch the canonical profile row. The Riverpod `profileProvider`
  /// is normally the entry point for reads, but mutation flows often
  /// want the fresh row immediately so they can update local state.
  Future<UserProfile> getCurrentProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.me,
    );
    return UserProfile.fromJson(response);
  }

  /// Partial update — pass only what changed. Anything left `null`
  /// is omitted from the JSON body so the backend doesn't overwrite
  /// fields the user didn't touch.
  Future<UserProfile> updateProfile({
    String? fullName,
    String? sex,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? dietaryPreference,
    int? dailyCalorieTarget,
    int? dailyWaterTargetMl,
    int? proteinTargetG,
    int? carbsTargetG,
    int? fatTargetG,
  }) async {
    final body = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (sex != null) 'sex': sex,
      if (dateOfBirth != null) 'date_of_birth': formatDateOnly(dateOfBirth),
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (dietaryPreference != null) 'dietary_preference': dietaryPreference,
      if (dailyCalorieTarget != null)
        'daily_calorie_target': dailyCalorieTarget,
      if (dailyWaterTargetMl != null)
        'daily_water_target_ml': dailyWaterTargetMl,
      if (proteinTargetG != null) 'protein_target_g': proteinTargetG,
      if (carbsTargetG != null) 'carbs_target_g': carbsTargetG,
      if (fatTargetG != null) 'fat_target_g': fatTargetG,
    };

    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: body,
    );
    return UserProfile.fromJson(response);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});
