import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/meal.dart';
import '../models/water_weekly.dart';

/// Dashboard screen — supporting providers that complement the
/// already-existing `dashboardSummaryProvider` (defined in
/// `profile/providers/profile_provider.dart`).
///
/// What lives where:
///
///   - **`dashboardSummaryProvider`** (in `profile_provider.dart`) —
///     fetches `/analytics/dashboard`, returns the big aggregate
///     object the screen renders (calorie ring, macros, water totals).
///     We don't redefine it here; the screen already imports it.
///
///   - **`todayMealsProvider`** (this file) — fetches today's meal
///     list for the bottom-of-screen meals section.
///
///   - **`logWaterProvider`** (this file) — returns a callable that
///     posts a single water log row and refreshes the dashboard
///     summary so the ring updates.
///
///   - **`refreshDashboard(ref)`** (this file) — top-level helper for
///     pull-to-refresh; invalidates both the summary and the meals
///     and awaits the re-fetch.

// ---------------------------------------------------------------
// Today's meals
// ---------------------------------------------------------------

/// `GET /meals?date=<today>` → list of `Meal` for the meals section.
///
/// Uses the same `apiClientProvider` (Dio + auth interceptor) the
/// repository layer uses, so 401s trigger a transparent refresh and
/// the device-local "today" matches what the dashboard summary uses.
final todayMealsProvider = FutureProvider<List<Meal>>((ref) async {
  final dio = ref.read(apiClientProvider).raw;

  final today = DateTime.now();
  final dateStr =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final response = await dio.get<dynamic>(
    '/meals',
    queryParameters: {'date': dateStr},
  );

  final raw = response.data;
  if (raw is! List) return const <Meal>[];
  return raw
      .cast<Map<String, dynamic>>()
      .map(Meal.fromJson)
      .toList(growable: false);
});

// ---------------------------------------------------------------
// Weekly water totals (Dashboard mini-chart)
// ---------------------------------------------------------------

/// `GET /water/weekly` → 7 day buckets for the daily-water bar chart
/// on the dashboard. Invalidated alongside the summary on a water-add
/// so the chart's "today" bar grows with the optimistic tile update.
final waterWeeklyProvider = FutureProvider<WaterWeekly>((ref) async {
  final dio = ref.read(apiClientProvider).raw;
  final response = await dio.get<Map<String, dynamic>>(
    ApiEndpoints.waterWeekly,
  );
  return WaterWeekly.fromJson(response.data ?? const {});
});

// ---------------------------------------------------------------
// Log water (quick-add)
// ---------------------------------------------------------------

/// Type alias for the water-logging callable.
typedef LogWaterFn = Future<void> Function(int amountMl);

/// Exposes a `Future<void> Function(int amountMl)` for the +250ml /
/// +500ml quick-add buttons on the dashboard.
///
/// After a successful write we invalidate `dashboardSummaryProvider`
/// so the calorie/macros/water ring re-fetches the canonical totals
/// from the backend — no client-side accounting needed.
final logWaterProvider = Provider<LogWaterFn>((ref) {
  final dio = ref.read(apiClientProvider).raw;

  return (int amountMl) async {
    try {
      await dio.post<dynamic>(
        '/water/logs',
        data: {'amount_ml': amountMl},
      );
    } on DioException {
      // Let the screen catch & show a snackbar; do NOT swallow.
      rethrow;
    }
    // Refresh dependent providers so the ring + weekly chart update.
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(waterWeeklyProvider);
  };
});

// ---------------------------------------------------------------
// Pull-to-refresh
// ---------------------------------------------------------------

/// Used by `RefreshIndicator.onRefresh` in the dashboard screen.
/// Invalidates summary + meals in parallel and awaits both fetches.
Future<void> refreshDashboard(WidgetRef ref) async {
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(todayMealsProvider);
  ref.invalidate(waterWeeklyProvider);

  await Future.wait<dynamic>([
    ref.read(dashboardSummaryProvider.future),
    ref.read(todayMealsProvider.future),
    ref.read(waterWeeklyProvider.future),
  ]);
}
