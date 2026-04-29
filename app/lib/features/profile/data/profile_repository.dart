import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// Public-facing profile data — what the app shows in the Profile screen.
/// Mirrors a subset of the `profiles` table; does not include sensitive
/// fields like onboarding state (those live in their own flows).
class UserProfile {
  final String id;
  final String? displayName;
  final String avatarStyle;
  final String avatarSeed;
  final String? avatarPhotoUrl; // If set, takes precedence over generated avatar
  final String? email;
  final int? targetCalories;
  final int? targetProteinG;
  final int? targetCarbG;
  final int? targetFatG;

  // Personal info
  final int? birthYear;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel;
  final String? goal;

  const UserProfile({
    required this.id,
    required this.avatarStyle,
    required this.avatarSeed,
    this.displayName,
    this.avatarPhotoUrl,
    this.email,
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbG,
    this.targetFatG,
    this.birthYear,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.goal,
  });

  /// Display name fallback chain: explicit name > email prefix > "Sen".
  String get effectiveName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    final em = email;
    if (em != null && em.contains('@')) {
      return em.split('@').first;
    }
    return 'Sen';
  }

  /// True if user has an uploaded photo (vs. generated avatar).
  bool get hasPhoto =>
      avatarPhotoUrl != null && avatarPhotoUrl!.trim().isNotEmpty;

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        displayName: j['display_name'] as String?,
        avatarStyle: j['avatar_style'] as String? ?? 'lorelei',
        avatarSeed: j['avatar_seed'] as String? ?? (j['id'] as String),
        avatarPhotoUrl: j['avatar_photo_url'] as String?,
        email: j['email'] as String?,
        targetCalories: (j['daily_calorie_target'] as num?)?.toInt(),
        targetProteinG: (j['target_protein_g'] as num?)?.toInt(),
        targetCarbG: (j['target_carb_g'] as num?)?.toInt(),
        targetFatG: (j['target_fat_g'] as num?)?.toInt(),
        birthYear: (j['birth_year'] as num?)?.toInt(),
        gender: j['gender'] as String?,
        heightCm: (j['height_cm'] as num?)?.toDouble(),
        weightKg: (j['weight_kg'] as num?)?.toDouble(),
        activityLevel: j['activity_level'] as String?,
        goal: j['goal'] as String?,
      );

  UserProfile copyWith({
    String? displayName,
    String? avatarStyle,
    String? avatarSeed,
    String? avatarPhotoUrl,
  }) =>
      UserProfile(
        id: id,
        email: email,
        targetCalories: targetCalories,
        targetProteinG: targetProteinG,
        targetCarbG: targetCarbG,
        targetFatG: targetFatG,
        birthYear: birthYear,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: activityLevel,
        goal: goal,
        displayName: displayName ?? this.displayName,
        avatarStyle: avatarStyle ?? this.avatarStyle,
        avatarSeed: avatarSeed ?? this.avatarSeed,
        avatarPhotoUrl: avatarPhotoUrl ?? this.avatarPhotoUrl,
      );
}

class ProfileRepository {
  ProfileRepository(this._dio);
  final Dio _dio;

  /// GET /profile — full profile row for the current user.
  Future<UserProfile> getProfile() async {
    try {
      final resp = await _dio.get('/profile');
      return UserProfile.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// PATCH /profile — partial update. Only sends fields that are non-null.
  /// Returns the refreshed profile so the UI can sync without a follow-up GET.
  Future<UserProfile> updateProfile({
    String? displayName,
    String? avatarStyle,
    String? avatarSeed,
    String? avatarPhotoUrl,
    int? birthYear,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? goal,
    int? dailyCalorieTarget,
    int? targetProteinG,
    int? targetCarbG,
    int? targetFatG,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (avatarStyle != null) body['avatar_style'] = avatarStyle;
    if (avatarSeed != null) body['avatar_seed'] = avatarSeed;
    if (avatarPhotoUrl != null) body['avatar_photo_url'] = avatarPhotoUrl;
    if (birthYear != null) body['birth_year'] = birthYear;
    if (gender != null) body['gender'] = gender;
    if (heightCm != null) body['height_cm'] = heightCm;
    if (weightKg != null) body['weight_kg'] = weightKg;
    if (activityLevel != null) body['activity_level'] = activityLevel;
    if (goal != null) body['goal'] = goal;
    if (dailyCalorieTarget != null) body['daily_calorie_target'] = dailyCalorieTarget;
    if (targetProteinG != null) body['target_protein_g'] = targetProteinG;
    if (targetCarbG != null) body['target_carb_g'] = targetCarbG;
    if (targetFatG != null) body['target_fat_g'] = targetFatG;
    try {
      final resp = await _dio.patch('/profile', data: body);
      return UserProfile.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// POST /profile/avatar — upload a base64-encoded JPEG to Supabase Storage.
  /// Returns the new public URL. The backend also writes it into the
  /// profile row, so a follow-up getProfile() will reflect the change.
  Future<String> uploadAvatarPhoto(String imageB64) async {
    try {
      final resp = await _dio.post(
        '/profile/avatar',
        data: {'image_b64': imageB64, 'content_type': 'image/jpeg'},
      );
      return resp.data['data']['url'] as String;
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// Clear the uploaded photo (revert to generated avatar).
  /// Sends an empty string for avatar_photo_url which the backend
  /// translates into a NULL update.
  Future<UserProfile> clearAvatarPhoto() async {
    try {
      final resp = await _dio.patch('/profile', data: {'avatar_photo_url': ''});
      return UserProfile.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);

/// Cached current-user profile. Auto-refreshes when invalidated.
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.watch(profileRepositoryProvider).getProfile();
});
