import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_meal_planner_data.dart';
import '../models/meal_plan.dart';

/// Provides the [MealPlannerData] for a given date.
///
/// Parameterized via `family` so the screen can re-fetch when the user
/// taps a different day in the weekly calendar. `autoDispose` keeps memory
/// clean when the user navigates away.
///
/// **TODO (Chat 14):** Replace the mock delay + static data with a Supabase
/// query against the `meal_plans` and `recipes` tables.
final mealPlannerProvider =
    FutureProvider.autoDispose.family<MealPlannerData, DateTime>(
  (ref, date) async {
    // Simulate network latency for skeleton testing.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // For now, every date returns the same mock. Once real backend exists,
    // query by `date` and shape the response into `MealPlannerData`.
    return mockPlannerData;
  },
);
