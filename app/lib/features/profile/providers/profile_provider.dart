import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/core/network/authed_dio_provider.dart';

import '../../../core/data/repositories/profile_repository.dart';
import '../../../core/data/repositories/weight_repository.dart';
import '../models/user_profile.dart';
import '../models/weight_goal.dart';
import '../models/weight_trend.dart';
import '../models/weekly_analytics.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS — 6 independent slices.
//
// Why 6 instead of one fat "ProfileState"?
//   • If /weight/goal 404s, only WeightGoalCard breaks (not the whole screen).
//   • If /analytics/weekly is slow, the rest still renders.
//   • Each slice has its own loading shimmer + retry button.
//
// dashboardSummaryProvider is fetched once → streakProvider + todaySummaryProvider
// derive from it to avoid double /analytics/dashboard calls.
// ─────────────────────────────────────────────────────────────────────────────

/// `GET /me` → UserProfile (always present after onboarding).
final profileProvider = FutureProvider<UserProfile>((ref) async {
  final dio = ref.read(authedDioProvider);
  final res = await dio.get('/me');
  return UserProfile.fromJson(res.data as Map<String, dynamic>);
});

/// `GET /weight/goal` → WeightGoal or null when no active goal (404).
/// Provider returns `null` so the UI can show a "Set your weight goal" CTA.
final weightGoalProvider = FutureProvider<WeightGoal?>((ref) async {
  final dio = ref.read(authedDioProvider);
  try {
    final res = await dio.get('/weight/goal');
    if (res.data == null) return null;
    return WeightGoal.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return null;
    rethrow;
  }
});

/// `GET /analytics/dashboard` → streak + today summary + nutrition score, etc.
///
/// All other dashboard-derived slices read from this provider to avoid
/// repeating the network call. Use `ref.refresh(dashboardSummaryProvider)`
/// to invalidate everything that depends on it.
final dashboardSummaryProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final dio = ref.read(authedDioProvider);
  final res = await dio.get('/analytics/dashboard');
  return DashboardSummary.fromJson(res.data as Map<String, dynamic>);
});

/// Derived: streak day count.
final streakProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(dashboardSummaryProvider).whenData((d) => d.streakDays);
});

/// Derived: today's calorie + macro consumption.
final todaySummaryProvider = Provider<AsyncValue<TodaySummary>>((ref) {
  return ref.watch(dashboardSummaryProvider).whenData((d) => d.todaySummary);
});

/// `GET /analytics/weight-trend?period=8w` → mini chart on WeightGoalCard.
final weightTrendProvider = FutureProvider<WeightTrend>((ref) async {
  final dio = ref.read(authedDioProvider);
  final res = await dio.get(
    '/analytics/weight-trend',
    queryParameters: {'period': '8w'},
  );
  return WeightTrend.fromJson(res.data as Map<String, dynamic>);
});

/// `GET /analytics/weekly` → 7-day calorie bar chart in ProgressSection.
final weeklyAnalyticsProvider =
    FutureProvider<WeeklyAnalytics>((ref) async {
  final dio = ref.read(authedDioProvider);
  final res = await dio.get('/analytics/weekly');
  return WeeklyAnalytics.fromJson(res.data as Map<String, dynamic>);
});

// ─────────────────────────────────────────────────────────────────────────────
// REFRESH HELPER — invalidates all profile providers for pull-to-refresh.
// ─────────────────────────────────────────────────────────────────────────────

/// Awaits all profile-related provider re-fetches in parallel.
/// Use inside `RefreshIndicator.onRefresh`.
Future<void> refreshAllProfileData(WidgetRef ref) async {
  ref.invalidate(profileProvider);
  ref.invalidate(weightGoalProvider);
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(weightTrendProvider);
  ref.invalidate(weeklyAnalyticsProvider);

  await Future.wait<dynamic>([
    ref.read(profileProvider.future),
    ref.read(weightGoalProvider.future),
    ref.read(dashboardSummaryProvider.future),
    ref.read(weightTrendProvider.future),
    ref.read(weeklyAnalyticsProvider.future),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// MUTATIONS — added by Chat 16.
//
// Reads still flow through the legacy `authedDioProvider` (above).
// Writes flow through the new repository layer so we get the typed
// exception hierarchy + auto JWT refresh. Both paths share the same
// underlying Dio instance — see `current_user_provider.dart`.
// ─────────────────────────────────────────────────────────────────────────────

/// Stateless action helper for profile / goal mutations. Routes calls
/// to the right repository and invalidates the affected providers so
/// the screen re-fetches fresh data.
class ProfileActions {
  ProfileActions(this._ref);

  final Ref _ref;

  /// Patch any subset of profile fields. Pass only what changed.
  Future<void> updateProfile({
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
    await _ref.read(profileRepositoryProvider).updateProfile(
          fullName: fullName,
          sex: sex,
          dateOfBirth: dateOfBirth,
          heightCm: heightCm,
          weightKg: weightKg,
          activityLevel: activityLevel,
          dietaryPreference: dietaryPreference,
          dailyCalorieTarget: dailyCalorieTarget,
          dailyWaterTargetMl: dailyWaterTargetMl,
          proteinTargetG: proteinTargetG,
          carbsTargetG: carbsTargetG,
          fatTargetG: fatTargetG,
        );
    // Profile + every dashboard slice that displays the same numbers.
    _ref.invalidate(profileProvider);
    _ref.invalidate(dashboardSummaryProvider);
  }

  /// Upsert the user's weight goal. The backend stores at most one
  /// active goal per user.
  Future<void> setWeightGoal({
    required double targetKg,
    DateTime? targetDate,
    required String direction, // 'lose' | 'gain' | 'maintain'
  }) async {
    await _ref.read(weightRepositoryProvider).setGoal(
          targetKg: targetKg,
          targetDate: targetDate,
          direction: direction,
        );
    _ref.invalidate(weightGoalProvider);
    _ref.invalidate(weightTrendProvider);
  }

  Future<void> clearWeightGoal() async {
    await _ref.read(weightRepositoryProvider).clearGoal();
    _ref.invalidate(weightGoalProvider);
  }

  /// Log a single weight reading. After write the trend re-fetches
  /// so the mini-chart on the goal card stays in sync.
  Future<void> logWeight({
    required double kg,
    DateTime? loggedAt,
    String? notes,
  }) async {
    await _ref.read(weightRepositoryProvider).addWeightLog(
          kg: kg,
          loggedAt: loggedAt,
          notes: notes,
        );
    _ref.invalidate(weightTrendProvider);
    _ref.invalidate(dashboardSummaryProvider);
  }
}

final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref);
});
