/// Mirrors `WeeklyAnalyticsResponse` from `GET /analytics/weekly`.
/// Last 7 days of calorie bars + average macros.
class WeeklyCalorieDay {
  final DateTime day;
  final int calories;
  final int target;
  final double percent; // 0..100+

  const WeeklyCalorieDay({
    required this.day,
    required this.calories,
    required this.target,
    required this.percent,
  });

  factory WeeklyCalorieDay.fromJson(Map<String, dynamic> json) {
    return WeeklyCalorieDay(
      day: DateTime.parse((json['day'] as String).substring(0, 10)),
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 2000,
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }

  bool get withinTarget {
    if (target <= 0) return false;
    final ratio = calories / target;
    return ratio >= 0.85 && ratio <= 1.10;
  }

  double get fractionOfTarget {
    if (target <= 0) return 0;
    return (calories / target).clamp(0.0, 1.0);
  }
}

class MacroPercentages {
  final double protein;
  final double carbs;
  final double fat;

  const MacroPercentages({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MacroPercentages.fromJson(Map<String, dynamic> json) {
    return MacroPercentages(
      protein: (json['protein_percent'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs_percent'] as num?)?.toDouble() ?? 0,
      fat: (json['fat_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  bool get hasData => protein > 0 || carbs > 0 || fat > 0;
}

class WeeklyAnalytics {
  final List<WeeklyCalorieDay> days;
  final double avgDailyCalories;
  final MacroPercentages avgMacroBreakdown;
  final int daysWithinTarget;

  const WeeklyAnalytics({
    required this.days,
    required this.avgDailyCalories,
    required this.avgMacroBreakdown,
    required this.daysWithinTarget,
  });

  factory WeeklyAnalytics.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['days'] as List?) ?? const [];
    return WeeklyAnalytics(
      days: rawDays
          .cast<Map<String, dynamic>>()
          .map(WeeklyCalorieDay.fromJson)
          .toList(growable: false),
      avgDailyCalories: (json['avg_daily_calories'] as num?)?.toDouble() ?? 0,
      avgMacroBreakdown: MacroPercentages.fromJson(
        (json['avg_macro_breakdown'] as Map?)?.cast<String, dynamic>() ??
            const {},
      ),
      daysWithinTarget: (json['days_within_target'] as num?)?.toInt() ?? 0,
    );
  }
}
