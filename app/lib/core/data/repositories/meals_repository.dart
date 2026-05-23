import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/dashboard/models/meal.dart';
import '../../../features/meal/models/meal_scan_models.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// Meal log CRUD against the FastAPI backend.
class MealsRepository extends BaseRepository {
  MealsRepository(super.apiClient);

  /// Today's meals, chronological order.
  Future<List<Meal>> getTodaysMeals() async {
    return getMealsByDate(DateTime.now());
  }

  /// All meals on a specific calendar day (local timezone — backend
  /// converts internally).
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiEndpoints.meals,
      queryParameters: {'date': formatDateOnly(date)},
    );
    return response
        .cast<Map<String, dynamic>>()
        .map(Meal.fromJson)
        .toList(growable: false);
  }

  /// Manual meal log (no photo). The backend's `POST /meals` accepts
  /// a `MealCreate` whose macros come from a `foods: list[MealFoodCreate]`
  /// — the meals table itself doesn't store macros; a DB trigger
  /// recomputes meals.total_* from meal_foods on insert.
  ///
  /// For the simple "I want to log a yogurt with 150 kcal" UX we wrap
  /// the single user entry as a one-element foods list. Future
  /// multi-ingredient entries (recipe import, AI-scan results) can
  /// extend this with a `foods` parameter directly.
  Future<Meal> createMeal({
    required String name,
    required int totalCalories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    String? mealType, // 'breakfast' | 'lunch' | 'dinner' | 'snack'
    DateTime? consumedAt,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.meals,
      data: {
        if (mealType != null) 'meal_type': mealType,
        'name': name,
        if (consumedAt != null) 'consumed_at': formatDateTimeUtc(consumedAt),
        // Single-food wrapping. The DB trigger turns this into the
        // meal-level totals (total_calories, total_protein_g, etc.).
        'foods': [
          {
            'name': name,
            'calories': totalCalories,
            'protein_g': proteinG,
            'carbs_g': carbsG,
            'fat_g': fatG,
            'position': 0,
          },
        ],
      },
    );
    return Meal.fromJson(response);
  }

  Future<void> deleteMeal(String id) {
    return apiClient.delete(ApiEndpoints.mealById(id));
  }

  /// AI vision scan. Sends base64-encoded JPEG to `POST /meals/scan`.
  /// Does NOT save — frontend confirms with the user then calls
  /// [createScannedMeal] with the (possibly edited) detected foods.
  Future<MealScanResult> scanMeal({
    required String imageBase64,
    String? mealTypeHint,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mealsScan,
      data: {
        'image_base64': imageBase64,
        if (mealTypeHint != null) 'meal_type_hint': mealTypeHint,
      },
    );
    return MealScanResult.fromJson(response);
  }

  /// Persist a scanned meal after the user reviewed/edited the foods.
  /// Sets `scan_source='ai_scan'` so the daily scan-count provider can
  /// gate the free tier (5/day).
  Future<Meal> createScannedMeal({
    required String mealType,
    required String? name,
    required List<DetectedFood> foods,
    DateTime? consumedAt,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.meals,
      data: {
        'meal_type': mealType,
        if (name != null && name.isNotEmpty) 'name': name,
        if (consumedAt != null) 'consumed_at': formatDateTimeUtc(consumedAt),
        'scan_source': 'ai_scan',
        'foods': [
          for (var i = 0; i < foods.length; i++) foods[i].toCreatePayload(i),
        ],
      },
    );
    return Meal.fromJson(response);
  }
}

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  return MealsRepository(ref.watch(apiClientProvider));
});
