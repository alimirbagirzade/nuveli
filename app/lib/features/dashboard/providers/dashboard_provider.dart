import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/authed_dio_provider.dart';
import '../models/meal.dart';
import '../models/today_summary.dart';

/// Fetches today's full nutrition summary (calories, macros, water, meal count).
///
/// Backend: `GET /meals/today/summary`
final dashboardSummaryProvider = FutureProvider<TodaySummary>((ref) async {
  final dio = ref.read(authedDioProvider);
  final res = await dio.get('/meals/today/summary');
  return TodaySummary.fromJson(res.data as Map<String, dynamic>);
});

/// Fetches today's meals (used in the "Today's meals" list section).
///
/// Backend: `GET /meals?date=YYYY-MM-DD`
final todayMealsProvider = FutureProvider<List<Meal>>((ref) async {
  final dio = ref.read(authedDioProvider);
  final today = DateTime.now().toIso8601String().split('T').first;
  final res = await dio.get('/meals', queryParameters: {'date': today});
  final list = (res.data as List?) ?? const [];
  return list
      .whereType<Map<String, dynamic>>()
      .map(Meal.fromJson)
      .toList()
    ..sort((a, b) => b.consumedAt.compareTo(a.consumedAt)); // newest first
});

/// Action provider: log water and invalidate summary so UI updates instantly.
///
/// Usage:
/// ```dart
/// await ref.read(logWaterProvider)(250);
/// ```
final logWaterProvider = Provider<Future<void> Function(int amountMl)>((ref) {
  return (int amountMl) async {
    final dio = ref.read(authedDioProvider);
    await dio.post(
      '/water/logs',
      data: {
        'amount_ml': amountMl,
        'logged_at': DateTime.now().toUtc().toIso8601String(),
      },
    );
    // Refresh summary so water count + percent update immediately.
    ref.invalidate(dashboardSummaryProvider);
  };
});

/// Convenience: refresh both summary and meals in parallel (used by pull-to-refresh).
Future<void> refreshDashboard(WidgetRef ref) async {
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(todayMealsProvider);
  // Wait for both to complete so RefreshIndicator's spinner stays correct.
  await Future.wait([
    ref.read(dashboardSummaryProvider.future),
    ref.read(todayMealsProvider.future),
  ]);
}
