import 'recommendation.dart';

/// Aggregate model holding all the data shown on the Goals & Profile screen.
class UserGoals {
  /// Recommended daily calorie target (e.g. 2100 kcal).
  final double dailyCalorieTarget;

  /// Today's consumed / target ratio (0.0 - 1.0). E.g. 0.70 = 70% of goal.
  final double todayProgressPercent;

  final WeightGoal weightGoal;

  /// Number of consecutive days with at least one logged meal.
  final int streakDays;

  final WeeklyCaloriesData weeklyCalories;

  final List<Recommendation> recommendations;

  const UserGoals({
    required this.dailyCalorieTarget,
    required this.todayProgressPercent,
    required this.weightGoal,
    required this.streakDays,
    required this.weeklyCalories,
    required this.recommendations,
  });

  UserGoals copyWith({
    double? dailyCalorieTarget,
    double? todayProgressPercent,
    WeightGoal? weightGoal,
    int? streakDays,
    WeeklyCaloriesData? weeklyCalories,
    List<Recommendation>? recommendations,
  }) {
    return UserGoals(
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      todayProgressPercent: todayProgressPercent ?? this.todayProgressPercent,
      weightGoal: weightGoal ?? this.weightGoal,
      streakDays: streakDays ?? this.streakDays,
      weeklyCalories: weeklyCalories ?? this.weeklyCalories,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}

/// Weight goal tracking. [targetChangeKg] is signed: negative = lose, positive = gain.
class WeightGoal {
  /// Signed total target change in kg. -5.0 means "lose 5 kg total".
  final double targetChangeKg;

  /// Calendar date by which the user wants to reach the goal.
  final DateTime targetDate;

  /// Absolute progress made so far, in kg (always positive).
  /// E.g. 1.8 means "user has already lost/gained 1.8 kg toward the goal".
  final double currentProgressKg;

  const WeightGoal({
    required this.targetChangeKg,
    required this.targetDate,
    required this.currentProgressKg,
  });

  /// How much weight change is still needed (always >= 0).
  double get remainingKg =>
      (targetChangeKg.abs() - currentProgressKg).clamp(0.0, double.infinity);

  /// Progress ratio 0.0 - 1.0.
  double get progressRatio {
    final goalMagnitude = targetChangeKg.abs();
    if (goalMagnitude == 0) return 0;
    return (currentProgressKg / goalMagnitude).clamp(0.0, 1.0);
  }

  /// True if the goal is to lose weight (i.e. targetChangeKg is negative).
  bool get isLossGoal => targetChangeKg < 0;
}

/// Last-N-days calorie data displayed in the Progress bar chart.
class WeeklyCaloriesData {
  /// Daily total calories, indexed by [dayLabels].
  final List<double> dailyCalories;

  /// Short day labels (e.g. "Mon", "Tue", ...). Length must match [dailyCalories].
  final List<String> dayLabels;

  /// Average daily calories across the period (e.g. 1850 kcal).
  final double averageCalories;

  /// Daily target line shown as dashed reference (e.g. 2100 kcal).
  final double targetCalories;

  const WeeklyCaloriesData({
    required this.dailyCalories,
    required this.dayLabels,
    required this.averageCalories,
    required this.targetCalories,
  }) : assert(
          dailyCalories.length == dayLabels.length,
          'dailyCalories and dayLabels must have equal length',
        );
}
