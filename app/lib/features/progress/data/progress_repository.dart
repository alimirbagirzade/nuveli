import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// One day's summary from the weekly progress endpoint.
/// Mirrors a row of `daily_summaries` plus the local_day key the
/// chart needs for grouping.
class DaySummary {
  final String localDay; // 'YYYY-MM-DD'
  final int totalCalories;
  final int targetCalories;
  final int mealCount;
  final double proteinG;
  final double carbG;
  final double fatG;
  final int waterMl;

  const DaySummary({
    required this.localDay,
    required this.totalCalories,
    required this.targetCalories,
    required this.mealCount,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    required this.waterMl,
  });

  /// Convenience: fraction of target reached today (0 → 1+).
  /// Used by the bar chart to scale heights. Capped at 1.5 so a
  /// way-over day still renders inside the chart frame.
  double get fractionOfTarget {
    if (targetCalories <= 0) return 0;
    final f = totalCalories / targetCalories;
    return f.clamp(0.0, 1.5);
  }

  bool get hasData => mealCount > 0;

  /// Day-of-week index 0=Monday … 6=Sunday for charting.
  /// Built from the localDay string to avoid timezone drift.
  int get weekdayIndex {
    final parts = localDay.split('-');
    final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    return d.weekday - 1; // DateTime weekday is 1=Mon..7=Sun
  }

  factory DaySummary.fromJson(Map<String, dynamic> j) => DaySummary(
        localDay: j['local_day'] as String,
        totalCalories: (j['total_calories'] as num?)?.toInt() ?? 0,
        targetCalories: (j['target_calories'] as num?)?.toInt() ?? 2000,
        mealCount: (j['meal_count'] as num?)?.toInt() ?? 0,
        proteinG: (j['total_protein_g'] as num?)?.toDouble() ?? 0,
        carbG: (j['total_carb_g'] as num?)?.toDouble() ?? 0,
        fatG: (j['total_fat_g'] as num?)?.toDouble() ?? 0,
        waterMl: (j['water_ml'] as num?)?.toInt() ?? 0,
      );
}

/// Aggregated summary for the past 7 days, returned by /summary/weekly/current.
class WeeklySummary {
  final String startDate;
  final String endDate;
  final int totalCalories;
  final int avgCalories;
  final int totalMeals;
  final int daysLogged;
  final List<DaySummary> dailyBreakdown;
  final String headline;

  const WeeklySummary({
    required this.startDate,
    required this.endDate,
    required this.totalCalories,
    required this.avgCalories,
    required this.totalMeals,
    required this.daysLogged,
    required this.dailyBreakdown,
    required this.headline,
  });

  /// Build a complete 7-day series [Mon..Sun] of the *current calendar week*,
  /// filling in empty DaySummary records for any day the backend didn't
  /// return. The chart needs exactly 7 slots in weekday order — the backend
  /// returns rolling 7 days and skips no-data days, so we reconcile here.
  List<DaySummary> get sevenDays {
    final byDay = <String, DaySummary>{};
    for (final d in dailyBreakdown) {
      byDay[d.localDay] = d;
    }
    final today = DateTime.now();
    final list = <DaySummary>[];
    // Build the last 7 days ending today, oldest first
    for (int i = 6; i >= 0; i--) {
      final dt = today.subtract(Duration(days: i));
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      list.add(
        byDay[key] ??
            DaySummary(
              localDay: key,
              totalCalories: 0,
              targetCalories: 2000,
              mealCount: 0,
              proteinG: 0,
              carbG: 0,
              fatG: 0,
              waterMl: 0,
            ),
      );
    }
    return list;
  }

  factory WeeklySummary.fromJson(Map<String, dynamic> j) => WeeklySummary(
        startDate: j['start_date'] as String? ?? '',
        endDate: j['end_date'] as String? ?? '',
        totalCalories: (j['total_calories'] as num?)?.toInt() ?? 0,
        avgCalories: (j['avg_calories'] as num?)?.toInt() ?? 0,
        totalMeals: (j['total_meals'] as num?)?.toInt() ?? 0,
        daysLogged: (j['days_logged'] as num?)?.toInt() ?? 0,
        dailyBreakdown: ((j['daily_breakdown'] as List?) ?? [])
            .map((e) => DaySummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        headline: j['headline'] as String? ?? '',
      );
}

class ProgressRepository {
  ProgressRepository(this._dio);
  final Dio _dio;

  /// GET /summary/weekly/current
  Future<WeeklySummary> getWeekly() async {
    try {
      final resp = await _dio.get('/summary/weekly/current');
      return WeeklySummary.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(apiClientProvider)),
);

final weeklySummaryProvider = FutureProvider<WeeklySummary>((ref) async {
  return ref.watch(progressRepositoryProvider).getWeekly();
});
