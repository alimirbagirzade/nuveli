import 'package:flutter/material.dart';

import '../models/grocery_item.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';

/// Static mock data matching the Görsel 6 (Plan Meals Ahead) mockup exactly.
///
/// Selected day: Mon 20 May 2026 (cyan circle in the calendar)
/// Daily Total: 420 + 520 + 610 + 130 = 1,680 kcal
/// Target: 2,100 kcal → 80% of goal
/// Grocery: 12 items total, 4 previewed (Oats / Chicken / Spinach / Yogurt)
final MealPlannerData mockPlannerData = MealPlannerData(
  selectedDate: DateTime(2026, 5, 20),
  weekCalories: {
    DateTime(2026, 5, 20): 1680.0, // Mon
    DateTime(2026, 5, 21): 1850.0, // Tue
    DateTime(2026, 5, 22): 1720.0, // Wed
    DateTime(2026, 5, 23): 1640.0, // Thu
    DateTime(2026, 5, 24): 1780.0, // Fri
    DateTime(2026, 5, 25): 1690.0, // Sat
    DateTime(2026, 5, 26): 1610.0, // Sun
  },
  todaysPlans: [
    MealPlan(
      id: '1',
      type: MealType.breakfast,
      planDate: DateTime(2026, 5, 20),
      recipe: const Recipe(
        id: 'r1',
        name: 'Greek Yogurt Bowl',
        calories: 420,
      ),
    ),
    MealPlan(
      id: '2',
      type: MealType.lunch,
      planDate: DateTime(2026, 5, 20),
      recipe: const Recipe(
        id: 'r2',
        name: 'Chicken Wrap',
        calories: 520,
      ),
    ),
    MealPlan(
      id: '3',
      type: MealType.dinner,
      planDate: DateTime(2026, 5, 20),
      recipe: const Recipe(
        id: 'r3',
        name: 'Salmon & Rice',
        calories: 610,
      ),
    ),
    MealPlan(
      id: '4',
      type: MealType.snack,
      planDate: DateTime(2026, 5, 20),
      recipe: const Recipe(
        id: 'r4',
        name: 'Fruit Snack',
        calories: 130,
      ),
    ),
  ],
  dailyTotal: 1680,
  targetCalories: 2100,
  groceryItems: const [
    GroceryItem(name: 'Oats', amount: '1.2 kg', fallbackIcon: Icons.grain),
    GroceryItem(name: 'Chicken', amount: '1.0 kg', fallbackIcon: Icons.egg_outlined),
    GroceryItem(name: 'Spinach', amount: '250 g', fallbackIcon: Icons.eco),
    GroceryItem(name: 'Yogurt', amount: '500 g', fallbackIcon: Icons.icecream_outlined),
  ],
  groceryItemCount: 12,
);
