import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/meal_planner/models/weekly_plan.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// Meal planner & recipe API.
///
/// Backend (verified 2026-05-23, `backend/routers/meal_planner.py`):
///   - GET    /meal-plans?week_start=YYYY-MM-DD → WeeklyPlanResponse
///   - POST   /meal-plans                       → create one entry
///   - PATCH  /meal-plans/{id}                  → edit servings/note/...
///   - DELETE /meal-plans/{id}                  → remove
///   - GET    /meal-plans/grocery?week_start=…  → GrocerySummaryResponse
///   - POST   /meal-plans/generate              → AI generate (premium)
///   - GET    /recipes / /recipes/{id} / POST /recipes
///
/// v0 surfaces only the read paths + AI generate. Manual create/edit/delete
/// land in v0.1.
class MealPlannerRepository extends BaseRepository {
  MealPlannerRepository(super.apiClient);

  Future<WeeklyPlan> getWeeklyPlan({DateTime? weekStart}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mealPlans,
      queryParameters: weekStart == null
          ? null
          : {'week_start': formatDateOnly(weekStart)},
    );
    return WeeklyPlan.fromJson(response);
  }

  Future<GrocerySummary> getGrocery({DateTime? weekStart}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mealPlansGrocery,
      queryParameters: weekStart == null
          ? null
          : {'week_start': formatDateOnly(weekStart)},
    );
    return GrocerySummary.fromJson(response);
  }

  /// AI-generate a week of meal plans. Premium-only (free tier sees
  /// 402 PremiumRequiredException from the backend; the screen routes
  /// to the paywall *before* hitting this).
  Future<GeneratePlanResult> generateWeeklyPlan({
    required DateTime weekStart,
    int days = 7,
    int mealsPerDay = 4,
    int? targetCalories,
    String? dietaryPreference,
    List<String>? avoidIngredients,
    String? note,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mealPlansGenerate,
      data: {
        'week_start': formatDateOnly(weekStart),
        'days': days,
        'meals_per_day': mealsPerDay,
        if (targetCalories != null) 'target_calories': targetCalories,
        if (dietaryPreference != null && dietaryPreference.isNotEmpty)
          'dietary_preference': dietaryPreference,
        if (avoidIngredients != null && avoidIngredients.isNotEmpty)
          'avoid_ingredients': avoidIngredients,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return GeneratePlanResult.fromJson(response);
  }
}

class GeneratePlanResult {
  final int plansCreated;
  final DateTime weekStart;
  final DateTime weekEnd;

  const GeneratePlanResult({
    required this.plansCreated,
    required this.weekStart,
    required this.weekEnd,
  });

  factory GeneratePlanResult.fromJson(Map<String, dynamic> json) {
    return GeneratePlanResult(
      plansCreated: json['plans_created'] is int
          ? json['plans_created'] as int
          : int.tryParse(json['plans_created']?.toString() ?? '') ?? 0,
      weekStart: DateTime.tryParse(json['week_start']?.toString() ?? '') ??
          DateTime.now(),
      weekEnd: DateTime.tryParse(json['week_end']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

final mealPlannerRepositoryProvider =
    Provider<MealPlannerRepository>((ref) {
  return MealPlannerRepository(ref.watch(apiClientProvider));
});
