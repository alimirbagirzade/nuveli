import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/habits_repository.dart';
import '../../../core/data/repositories/profile_repository.dart';
import '../../../core/data/repositories/weight_repository.dart';
// UserProfile lives under auth/ in this codebase (not profile/models/).
import '../../auth/services/profile_service.dart';
// WeightGoal lives in goals_overview/.
import '../goals_overview/models/user_goals.dart';

/// Profile / Goals screen — three independent slices.
///
/// Rather than one monolithic state, we split the screen into three
/// providers so each part can refresh / fail independently:
///
///   - [profileProvider]    — `UserProfile` (display name, weight,
///                            daily target, etc.)
///   - [weightGoalProvider] — current weight goal, nullable
///   - [streakProvider]     — habit streak (int)
///
/// The screen widget can `ref.watch` each one and render its own
/// skeleton/error per section. This avoids "the whole screen is in
/// error because the streak endpoint hiccupped" UX.

/// User profile — primary identity object. Cheap fetch (single row),
/// shared across many screens.
final profileProvider = FutureProvider<UserProfile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getCurrentProfile();
});

/// Active weight goal, or `null` if the user hasn't set one.
/// Repository normalises 404 → null already.
final weightGoalProvider = FutureProvider<WeightGoal?>((ref) async {
  final repo = ref.watch(weightRepositoryProvider);
  return repo.getGoal();
});

/// Consecutive-day habit streak (drives the flame card).
final streakProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(habitsRepositoryProvider);
  return repo.getStreak();
});

// --------------------------------------------------------------------
// Mutations — exposed as a thin notifier so the screen can `read` it
// (e.g. when the user taps "Edit profile" and saves).
// --------------------------------------------------------------------

/// Actions related to the profile (update, set goal, etc.). Stateless;
/// just routes calls to the right repository and invalidates the
/// affected providers so the screen re-fetches fresh data.
class ProfileActions {
  ProfileActions(this._ref);

  final Ref _ref;

  Future<void> updateProfile({
    String? displayName,
    double? weightKg,
    double? heightCm,
    int? dailyCalorieTarget,
    double? proteinTargetPct,
    double? carbsTargetPct,
    double? fatTargetPct,
    String? activityLevel,
    String? goalType,
  }) async {
    await _ref.read(profileRepositoryProvider).updateProfile(
          displayName: displayName,
          weightKg: weightKg,
          heightCm: heightCm,
          dailyCalorieTarget: dailyCalorieTarget,
          proteinTargetPct: proteinTargetPct,
          carbsTargetPct: carbsTargetPct,
          fatTargetPct: fatTargetPct,
          activityLevel: activityLevel,
          goalType: goalType,
        );
    _ref.invalidate(profileProvider);
  }

  Future<void> setWeightGoal({
    required double targetKg,
    required DateTime targetDate,
    String? goalType,
  }) async {
    await _ref.read(weightRepositoryProvider).setGoal(
          targetKg: targetKg,
          targetDate: targetDate,
          goalType: goalType,
        );
    _ref.invalidate(weightGoalProvider);
  }

  Future<void> clearWeightGoal() async {
    await _ref.read(weightRepositoryProvider).clearGoal();
    _ref.invalidate(weightGoalProvider);
  }
}

final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref);
});
