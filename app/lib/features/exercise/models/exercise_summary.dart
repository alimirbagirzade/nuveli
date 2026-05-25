/// Today's activity rollup — mirrors backend `GET /exercise/today/summary`.
///
/// Activity counters plus an *informational* `totalCalories` estimate.
/// `totalCalories` is display-only: it is never added to the calorie budget,
/// and is `null` when the backend can't estimate (e.g. weight unknown).
/// Exercise is a positive habit and does NOT touch the calorie budget.
class ExerciseSummary {
  final int totalMinutes;
  final int sessionsCount;

  /// True when the user has logged any activity today.
  final bool active;

  /// Distinct activity types logged today (e.g. ['walking', 'yoga']).
  final List<String> activityTypes;

  /// Informational sum of estimated calories used today. Display-only —
  /// never affects the calorie budget. `null` when the backend can't estimate.
  final int? totalCalories;

  const ExerciseSummary({
    required this.totalMinutes,
    required this.sessionsCount,
    required this.active,
    required this.activityTypes,
    this.totalCalories,
  });

  const ExerciseSummary.empty()
      : totalMinutes = 0,
        sessionsCount = 0,
        active = false,
        activityTypes = const [],
        totalCalories = null;

  factory ExerciseSummary.fromJson(Map<String, dynamic> json) {
    final rawTypes = (json['activity_types'] as List?) ?? const [];
    return ExerciseSummary(
      totalMinutes: (json['total_minutes'] as num?)?.toInt() ?? 0,
      sessionsCount: (json['sessions_count'] as num?)?.toInt() ?? 0,
      active: (json['active'] as bool?) ??
          ((json['total_minutes'] as num?)?.toInt() ?? 0) > 0,
      activityTypes:
          rawTypes.map((e) => e.toString()).toList(growable: false),
      totalCalories: (json['total_calories'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_minutes': totalMinutes,
        'sessions_count': sessionsCount,
        'active': active,
        'activity_types': activityTypes,
        if (totalCalories != null) 'total_calories': totalCalories,
      };
}

/// One day bucket in the weekly activity view.
class ExerciseDayTotal {
  final DateTime day;
  final int totalMinutes;
  final int sessionsCount;

  /// Informational estimate of calories used this day. Display-only —
  /// never affects the calorie budget. `null` when the backend can't estimate.
  final int? totalCalories;

  const ExerciseDayTotal({
    required this.day,
    required this.totalMinutes,
    required this.sessionsCount,
    this.totalCalories,
  });

  factory ExerciseDayTotal.fromJson(Map<String, dynamic> json) {
    final rawDay = json['day'] as String?;
    final day = (rawDay != null && rawDay.length >= 10)
        ? (DateTime.tryParse(rawDay.substring(0, 10)) ?? DateTime.now())
        : DateTime.now();
    return ExerciseDayTotal(
      day: day,
      totalMinutes: (json['total_minutes'] as num?)?.toInt() ?? 0,
      sessionsCount: (json['sessions_count'] as num?)?.toInt() ?? 0,
      totalCalories: (json['total_calories'] as num?)?.toInt(),
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }
}

/// Mirrors backend `GET /exercise/weekly`. 7 day buckets, oldest → today.
class ExerciseWeekly {
  final List<ExerciseDayTotal> days;
  final int weekTotalMinutes;
  final int activeDays;

  /// Informational estimate of total calories used this week. Display-only —
  /// never affects the calorie budget. `null` when the backend can't estimate.
  final int? weekTotalCalories;

  const ExerciseWeekly({
    required this.days,
    required this.weekTotalMinutes,
    required this.activeDays,
    this.weekTotalCalories,
  });

  const ExerciseWeekly.empty()
      : days = const [],
        weekTotalMinutes = 0,
        activeDays = 0,
        weekTotalCalories = null;

  factory ExerciseWeekly.fromJson(Map<String, dynamic> json) {
    final raw = (json['days'] as List?) ?? const [];
    return ExerciseWeekly(
      days: raw
          .whereType<Map<String, dynamic>>()
          .map(ExerciseDayTotal.fromJson)
          .toList(growable: false),
      weekTotalMinutes: (json['week_total_minutes'] as num?)?.toInt() ?? 0,
      activeDays: (json['active_days'] as num?)?.toInt() ?? 0,
      weekTotalCalories: (json['week_total_calories'] as num?)?.toInt(),
    );
  }
}
