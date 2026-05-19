import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meals_repository.dart';
import '../../../core/data/repositories/profile_repository.dart';
import '../models/dashboard_data.dart';

/// Dashboard provider.
///
/// Aggregates three backend endpoints in **one parallel round-trip**:
///   - `/meals/today/summary`  → consumed + target totals (server-computed)
///   - `/meals?date=today`     → today's meal list for the timeline
///   - `/me`                   → profile (only needed if the summary
///                               endpoint doesn't include the macro targets)
///
/// We rely on the backend to compute `targetProteinG / targetCarbsG /
/// targetFatG` server-side and surface them on [TodaySummary]. If the
/// backend only returns `dailyCalorieTarget`, derive the macros from
/// the profile's percentages — see the commented fallback below.
///
/// UI usage is unchanged from the mock version:
/// ```dart
/// final data = ref.watch(dashboardProvider);
/// data.when(data: (d) => ..., loading: () => ..., error: ...);
/// ```
///
/// Refresh after logging a new meal:
/// ```dart
/// ref.invalidate(dashboardProvider);
/// ```
final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final mealsRepo = ref.watch(mealsRepositoryProvider);

  // Dart 3 record parallel-fetch — both calls fire simultaneously.
  final (summary, meals) = await (
    mealsRepo.getTodaysSummary(),
    mealsRepo.getTodaysMeals(),
  ).wait;

  return DashboardData(
    consumedCalories: summary.consumedCalories,
    targetCalories: summary.targetCalories,
    macros: MacrosData(
      proteinCurrent: summary.consumedProteinG,
      proteinTarget: summary.targetProteinG,
      carbsCurrent: summary.consumedCarbsG,
      carbsTarget: summary.targetCarbsG,
      fatCurrent: summary.consumedFatG,
      fatTarget: summary.targetFatG,
    ),
    todaysMeals: meals,
  );

  // -----------------------------------------------------------------
  // Fallback if the backend doesn't compute macro targets server-side.
  // Uncomment this block and remove the macros lines above to derive
  // them from the user's profile percentages instead.
  // -----------------------------------------------------------------
  //
  // final profileRepo = ref.watch(profileRepositoryProvider);
  // final profile = await profileRepo.getCurrentProfile();
  // final target = summary.targetCalories;
  // final proteinTargetG = (target * profile.proteinTargetPct / 100) / 4;
  // final carbsTargetG   = (target * profile.carbsTargetPct   / 100) / 4;
  // final fatTargetG     = (target * profile.fatTargetPct     / 100) / 9;
});
