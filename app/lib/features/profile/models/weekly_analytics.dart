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
    // Backend ships these as `consumed_*` / `daily_*_target` / `meal_count_today`.
    // The older names below were never live — accept both so callers
    // can't be coupled to either side's wording.
    int asInt(dynamic v) {
      if (v is num) return v.toInt();
      return 0;
    }

    return TodaySummary(
      caloriesConsumed:
          asInt(json['consumed_calories'] ?? json['calories_consumed']),
      caloriesTarget:
          asInt(json['daily_calorie_target'] ?? json['calories_target']),
      proteinConsumedG:
          asInt(json['consumed_protein_g'] ?? json['protein_consumed_g']),
      carbsConsumedG:
          asInt(json['consumed_carbs_g'] ?? json['carbs_consumed_g']),
      fatConsumedG: asInt(json['consumed_fat_g'] ?? json['fat_consumed_g']),
      mealsLogged:
          asInt(json['meal_count_today'] ?? json['meals_logged']),
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

  // Dashboard alias getters
  int get consumedCalories => caloriesConsumed;
  int get dailyCalorieTarget => caloriesTarget;
  int get remainingCalories => caloriesRemaining;
  double get consumedProteinG => proteinConsumedG.toDouble();
  double get consumedCarbsG => carbsConsumedG.toDouble();
  double get consumedFatG => fatConsumedG.toDouble();
  double get dailyProteinTargetG => 0.0;
  double get dailyCarbsTargetG => 0.0;
  double get dailyFatTargetG => 0.0;
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

  // Dashboard alias getters
  int get consumedWaterMl => waterConsumedMl;
  int get dailyWaterTargetMl => waterTargetMl;
  int get consumedCalories => todaySummary.caloriesConsumed;
  int get dailyCalorieTarget => todaySummary.caloriesTarget;
  int get remainingCalories => todaySummary.caloriesRemaining;
  int get consumedProteinG => todaySummary.proteinConsumedG;
  int get consumedCarbsG => todaySummary.carbsConsumedG;
  int get consumedFatG => todaySummary.fatConsumedG;
  int get dailyProteinTargetG => 0;
  int get dailyCarbsTargetG => 0;
  int get dailyFatTargetG => 0;

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
