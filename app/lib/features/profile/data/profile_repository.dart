import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// Public-facing profile data — what the app shows in the Profile screen.
/// Mirrors a subset of the `profiles` table; does not include sensitive
/// fields like onboarding state or birth year (those live in their own
/// flows).
class UserProfile {
  final String id;
  final String? displayName;
  final String avatarStyle; // lorelei | peep | bottts | adventurer | fun-emoji
  final String avatarSeed;
  final String? email;
  final int? targetCalories;

  const UserProfile({
    required this.id,
    required this.avatarStyle,
    required this.avatarSeed,
    this.displayName,
    this.email,
    this.targetCalories,
  });

  /// Display name fallback chain: explicit name > email prefix > "Sen".
  /// Useful in headers where we always want *something* to show.
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

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        displayName: j['display_name'] as String?,
        avatarStyle: j['avatar_style'] as String? ?? 'lorelei',
        avatarSeed: j['avatar_seed'] as String? ?? (j['id'] as String),
        email: j['email'] as String?,
        targetCalories: (j['target_calories'] as num?)?.toInt(),
      );

  UserProfile copyWith({
    String? displayName,
    String? avatarStyle,
    String? avatarSeed,
  }) =>
      UserProfile(
        id: id,
        email: email,
        targetCalories: targetCalories,
        displayName: displayName ?? this.displayName,
        avatarStyle: avatarStyle ?? this.avatarStyle,
        avatarSeed: avatarSeed ?? this.avatarSeed,
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
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (avatarStyle != null) body['avatar_style'] = avatarStyle;
    if (avatarSeed != null) body['avatar_seed'] = avatarSeed;
    try {
      final resp = await _dio.patch('/profile', data: body);
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
