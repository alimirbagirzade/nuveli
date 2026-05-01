import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// One day's summary from the weekly progress endpoint.
class DaySummary {
  final String localDay;
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

  double get fractionOfTarget {
    if (targetCalories <= 0) return 0;
    final f = totalCalories / targetCalories;
    return f.clamp(0.0, 1.5);
  }

  bool get hasData => mealCount > 0;

  int get weekdayIndex {
    final parts = localDay.split('-');
    final d = DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    return d.weekday - 1;
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

class WeeklySummary {
  final String startDate;
  final String endDate;
  final int totalCalories;
  final int avgCalories;
  final int totalMeals;
  final int daysLogged;
  final List<DaySummary> dailyBreakdown;
  final String headline;
  // Sprint 2.2: premium-only AI insight
  final String? aiInsight;

  const WeeklySummary({
    required this.startDate,
    required this.endDate,
    required this.totalCalories,
    required this.avgCalories,
    required this.totalMeals,
    required this.daysLogged,
    required this.dailyBreakdown,
    required this.headline,
    this.aiInsight,
  });

  List<DaySummary> get sevenDays {
    final byDay = <String, DaySummary>{};
    for (final d in dailyBreakdown) {
      byDay[d.localDay] = d;
    }
    final today = DateTime.now();
    final list = <DaySummary>[];
    for (int i = 6; i >= 0; i--) {
      final dt = today.subtract(Duration(days: i));
      final key =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
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
        aiInsight: j['ai_insight'] as String?,
      );
}

/// Sprint 2.2 Part 2: Monthly insight model.
class MonthlyInsight {
  final String startDate;
  final String endDate;
  final int daysLogged;
  final int totalDays;
  final List<InsightItem> insights;
  final String? aiInsight;

  const MonthlyInsight({
    required this.startDate,
    required this.endDate,
    required this.daysLogged,
    required this.totalDays,
    required this.insights,
    this.aiInsight,
  });

  factory MonthlyInsight.fromJson(Map<String, dynamic> j) => MonthlyInsight(
        startDate: j['start_date'] as String? ?? '',
        endDate: j['end_date'] as String? ?? '',
        daysLogged: (j['days_logged'] as num?)?.toInt() ?? 0,
        totalDays: (j['total_days'] as num?)?.toInt() ?? 30,
        insights: ((j['insights'] as List?) ?? [])
            .map((e) => InsightItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        aiInsight: j['ai_insight'] as String?,
      );
}

class InsightItem {
  final String title;
  final String body;

  const InsightItem({required this.title, required this.body});

  factory InsightItem.fromJson(Map<String, dynamic> j) => InsightItem(
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
      );
}

class ProgressRepository {
  ProgressRepository(this._dio);
  final Dio _dio;

  Future<WeeklySummary> getWeekly() async {
    try {
      final resp = await _dio.get('/summary/weekly/current');
      return WeeklySummary.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  Future<MonthlyInsight> getMonthly() async {
    try {
      final resp = await _dio.get('/summary/monthly/current');
      return MonthlyInsight.fromJson(resp.data['data'] as Map<String, dynamic>);
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

final monthlyInsightProvider = FutureProvider<MonthlyInsight>((ref) async {
  return ref.watch(progressRepositoryProvider).getMonthly();
});
