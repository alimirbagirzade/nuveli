/// Weekly analytics model — mirrors backend `GET /analytics/weekly` response.
///
/// Used to render the 7-day calorie bar chart in ProgressSection.
class WeeklyAnalytics {
  final List<DayCalories> days;
  final int avgDailyCalories;
  final MacroBreakdown avgMacroBreakdown;
  final int daysWithinTarget;

  const WeeklyAnalytics({
    required this.days,
    required this.avgDailyCalories,
    required this.avgMacroBreakdown,
    required this.daysWithinTarget,
  });

  factory WeeklyAnalytics.fromJson(Map<String, dynamic> json) {
    return WeeklyAnalytics(
      days: (json['days'] as List<dynamic>? ?? [])
          .map((d) => DayCalories.fromJson(d as Map<String, dynamic>))
          .toList(),
      avgDailyCalories: (json['avg_daily_calories'] as num?)?.toInt() ?? 0,
      avgMacroBreakdown: MacroBreakdown.fromJson(
          json['avg_macro_breakdown'] as Map<String, dynamic>? ?? const {}),
      daysWithinTarget: (json['days_within_target'] as num?)?.toInt() ?? 0,
    );
  }

  /// Highest calorie day in the window — used for chart Y-axis ceiling.
  int get maxCalories {
    if (days.isEmpty) return 1;
    return days.map((d) => d.calories).reduce((a, b) => a > b ? a : b);
  }
}

class DayCalories {
  final DateTime date;
  final int calories;
  final int target;
  final bool withinTarget;

  const DayCalories({
    required this.date,
    required this.calories,
    required this.target,
    required this.withinTarget,
  });

  factory DayCalories.fromJson(Map<String, dynamic> json) {
    return DayCalories(
      date: DateTime.parse(json['date'] as String),
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 0,
      withinTarget: json['within_target'] as bool? ?? false,
    );
  }

  /// Short weekday label, e.g. "Mon", "Tue".
  String get weekdayLabel {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[(date.weekday - 1) % 7];
  }
}

class MacroBreakdown {
  final int proteinPercent;
  final int carbsPercent;
  final int fatPercent;

  const MacroBreakdown({
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
  });

  factory MacroBreakdown.fromJson(Map<String, dynamic> json) {
    return MacroBreakdown(
      proteinPercent: (json['protein_percent'] as num?)?.toInt() ?? 0,
      carbsPercent: (json['carbs_percent'] as num?)?.toInt() ?? 0,
      fatPercent: (json['fat_percent'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Today's summary, embedded in `GET /analytics/dashboard` response.
///
/// Used by DailyCalorieTargetCard to render the mini donut (consumed / target).
class TodaySummary {
  final int caloriesConsumed;
  final int caloriesTarget;
  final int proteinConsumedG;
  final int carbsConsumedG;
  final int fatConsumedG;
  final int mealsLogged;

  const TodaySummary({
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.proteinConsumedG,
    required this.carbsConsumedG,
    required this.fatConsumedG,
    required this.mealsLogged,
  });

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    return TodaySummary(
      caloriesConsumed: (json['calories_consumed'] as num?)?.toInt() ?? 0,
      caloriesTarget: (json['calories_target'] as num?)?.toInt() ?? 0,
      proteinConsumedG: (json['protein_consumed_g'] as num?)?.toInt() ?? 0,
      carbsConsumedG: (json['carbs_consumed_g'] as num?)?.toInt() ?? 0,
      fatConsumedG: (json['fat_consumed_g'] as num?)?.toInt() ?? 0,
      mealsLogged: (json['meals_logged'] as num?)?.toInt() ?? 0,
    );
  }

  factory TodaySummary.empty() => const TodaySummary(
        caloriesConsumed: 0,
        caloriesTarget: 0,
        proteinConsumedG: 0,
        carbsConsumedG: 0,
        fatConsumedG: 0,
        mealsLogged: 0,
      );

  /// 0..1 fraction. Capped at 1.0 for the ring chart even if user overshoots.
  double get progressFraction {
    if (caloriesTarget <= 0) return 0;
    final raw = caloriesConsumed / caloriesTarget;
    return raw > 1.0 ? 1.0 : raw;
  }

  int get caloriesRemaining => caloriesTarget - caloriesConsumed;
}

/// Wrapper for `GET /analytics/dashboard` response — used to derive streak +
/// today's consumption in a single network call (cost optimization).
class DashboardSummary {
  final TodaySummary todaySummary;
  final int streakDays;
  final int nutritionScore;
  final int waterConsumedMl;
  final int waterTargetMl;

  const DashboardSummary({
    required this.todaySummary,
    required this.streakDays,
    required this.nutritionScore,
    required this.waterConsumedMl,
    required this.waterTargetMl,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      todaySummary: TodaySummary.fromJson(
          json['today_summary'] as Map<String, dynamic>? ?? const {}),
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      nutritionScore: (json['nutrition_score'] as num?)?.toInt() ?? 0,
      waterConsumedMl: (json['water_consumed_ml'] as num?)?.toInt() ?? 0,
      waterTargetMl: (json['water_target_ml'] as num?)?.toInt() ?? 0,
    );
  }
}
