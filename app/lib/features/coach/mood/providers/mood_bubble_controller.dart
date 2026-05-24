import '../models/mood_situation.dart';

/// Pure situation-detection logic for the mood-bubble layer.
///
/// Deliberately static and side-effect free so every branch is unit
/// testable without a widget tree or a network. Presentation (reading the
/// persona, resolving copy, showing the bubble) lives in the widget layer
/// (`mood_bubble.dart`) and the screens that call it.
class MoodBubbleLogic {
  const MoodBubbleLogic._();

  /// Calorie ratio (consumed / target) at/above which a day counts as
  /// "over" target. 5% slack keeps a near-exact match out of the
  /// over-target (potentially discouraging) copy.
  static const double overThreshold = 1.05;

  /// Ratio at/above which the day is "on track" (balanced) rather than
  /// still comfortably under.
  static const double onTrackThreshold = 0.85;

  /// Fraction of the water target below which — late enough in the day —
  /// a water-low nudge is warranted.
  static const double waterLowFraction = 0.5;

  /// Hour (local, 24h) from which a water shortfall is worth nudging.
  /// Before this we assume the day has time to catch up.
  static const int waterLowAfterHour = 14;

  /// Streak lengths worth celebrating with a bubble.
  static const Set<int> streakMilestones = {3, 7, 14, 21, 30, 50, 100, 365};

  /// Which situation a just-logged meal represents.
  ///
  /// [mealsLoggedBefore] is the count *before* this meal landed, so the
  /// very first meal of the day gets the fresh-start line regardless of
  /// calories. [caloriesConsumed]/[caloriesTarget] are today's running
  /// totals *including* the new meal.
  static MoodSituation mealSituation({
    required int caloriesConsumed,
    required int caloriesTarget,
    required int mealsLoggedBefore,
  }) {
    if (mealsLoggedBefore <= 0) return MoodSituation.firstMeal;
    if (caloriesTarget <= 0) return MoodSituation.mealOnTrack;

    final ratio = caloriesConsumed / caloriesTarget;
    if (ratio >= overThreshold) return MoodSituation.mealOver;
    if (ratio >= onTrackThreshold) return MoodSituation.mealOnTrack;
    return MoodSituation.mealUnder;
  }

  /// Whether a water-low bubble should fire given today's intake.
  static bool isWaterLow({
    required int totalMl,
    required int targetMl,
    required int hourOfDay,
  }) {
    if (targetMl <= 0) return false;
    if (hourOfDay < waterLowAfterHour) return false;
    return totalMl / targetMl < waterLowFraction;
  }

  /// Whether [streakDays] is a celebration-worthy milestone.
  static bool isStreakMilestone(int streakDays) =>
      streakMilestones.contains(streakDays);
}
