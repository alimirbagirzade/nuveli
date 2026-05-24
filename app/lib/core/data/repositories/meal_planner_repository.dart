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
/// v0.1 adds manual create/edit/delete on top of v0's read + AI generate.
/// Edit is name+note only (backend PATCH does not recompute totals on a
/// servings change — calorie/serving edits go via delete + re-add).
class MealPlannerRepository extends BaseRepository {
  MealPlannerRepository(super.apiClient);

  /// Create one manual plan entry (custom food — no recipe link).
  /// Mirrors `MealPlanCreate`. `calories`/macros are the **entry total**
  /// (backend stores custom calories as-is; servings is metadata, not a
  /// multiplier). Returns the created [MealPlanEntry].
  Future<MealPlanEntry> createPlanEntry({
    required DateTime planDate,
    required String mealType,
    required String customName,
    required int customCalories,
    double customProteinG = 0,
    double customCarbsG = 0,
    double customFatG = 0,
    double servings = 1.0,
    String? note,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mealPlans,
      data: {
        'plan_date': formatDateOnly(planDate),
        'meal_type': mealType,
        'custom_name': customName,
        'custom_calories': customCalories,
        'custom_protein_g': customProteinG,
        'custom_carbs_g': customCarbsG,
        'custom_fat_g': customFatG,
        'servings': servings,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return MealPlanEntry.fromJson(response);
  }

  /// Edit an existing entry. Backend `MealPlanUpdate` accepts
  /// recipe_id/custom_name/servings/note, but the PATCH path does NOT
  /// recompute `total_*` — so we only expose name + note here. Calorie/
  /// serving changes are done via delete + re-add.
  Future<MealPlanEntry> updatePlanEntry({
    required String planId,
    String? customName,
    String? note,
  }) async {
    final response = await apiClient.patch<Map<String, dynamic>>(
      '${ApiEndpoints.mealPlans}/$planId',
      data: {
        if (customName != null) 'custom_name': customName,
        if (note != null) 'note': note,
      },
    );
    return MealPlanEntry.fromJson(response);
  }

  /// Remove a plan entry. Backend returns 204 No Content.
  Future<void> deletePlanEntry(String planId) async {
    await apiClient.delete('${ApiEndpoints.mealPlans}/$planId');
  }

  Future<WeeklyPlan> getWeeklyPlan({DateTime? weekStart}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mealPlans,
      queryParameters: weekStart == null
          ? null
          : {'week_start': formatDateOnly(weekStart)},
    );
    return WeeklyPlan.fromJson(response);
  }

  /// `GET /recipes` — full recipe catalogue.
  ///
  /// Returns an empty list when the backend recipes table is unseeded
  /// (expected on fresh deployments; UI shows an empty state).
  Future<List<RecipeResponse>> getRecipes({String? search}) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiEndpoints.recipes,
      queryParameters: search != null && search.isNotEmpty
          ? {'search': search}
          : null,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(RecipeResponse.fromJson)
        .toList(growable: false);
  }

  /// `POST /meal-plans` with a `recipe_id` — add a recipe to the plan.
  ///
  /// Backend multiplies `recipe.calories_per_serving * servings` to fill
  /// `total_*` columns. Returns the created [MealPlanEntry].
  Future<MealPlanEntry> createPlanEntryFromRecipe({
    required DateTime planDate,
    required String mealType,
    required String recipeId,
    double servings = 1.0,
    String? note,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mealPlans,
      data: {
        'plan_date': formatDateOnly(planDate),
        'meal_type': mealType,
        'recipe_id': recipeId,
        'servings': servings,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return MealPlanEntry.fromJson(response);
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
