import 'package:flutter/foundation.dart';

import 'grocery_item.dart';
import 'recipe.dart';

/// Type of a planned meal slot in a single day.
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}

/// A single planned meal for a given date.
@immutable
class MealPlan {
  final String id;
  final MealType type;
  final Recipe recipe;
  final DateTime planDate;

  const MealPlan({
    required this.id,
    required this.type,
    required this.recipe,
    required this.planDate,
  });
}

/// Aggregate view-model returned by [mealPlannerProvider].
///
/// Holds everything the Meal Planner screen needs to render for a given date.
@immutable
class MealPlannerData {
  /// The currently selected day in the weekly calendar.
  final DateTime selectedDate;

  /// Total kcal per day for the displayed week. Keys must be normalized to
  /// midnight so equality comparisons work.
  final Map<DateTime, double> weekCalories;

  /// Plans for the [selectedDate].
  final List<MealPlan> todaysPlans;

  /// Sum of [todaysPlans] kcal — pre-computed so the UI does not recalculate.
  final double dailyTotal;

  /// User's calorie target for the day.
  final double targetCalories;

  /// First N grocery items to preview in the summary card (typically 4).
  final List<GroceryItem> groceryItems;

  /// Total grocery item count across the planned week (shown as "12 items").
  final int groceryItemCount;

  const MealPlannerData({
    required this.selectedDate,
    required this.weekCalories,
    required this.todaysPlans,
    required this.dailyTotal,
    required this.targetCalories,
    required this.groceryItems,
    required this.groceryItemCount,
  });
}
