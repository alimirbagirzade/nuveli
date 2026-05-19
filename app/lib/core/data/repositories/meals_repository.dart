import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/dashboard/models/meal.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// Meal log CRUD against the FastAPI backend.
///
/// Note: AI-vision scanning (`POST /meals/scan`) is intentionally **NOT**
/// in this repository yet — the meal-scan UI lands in Chat 5 and we'll
/// add `scanMeal()` plus a `ScanResult` model alongside it. Adding it
/// here would require a model that doesn't exist, so we keep this thin
/// for now.
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

  /// Manual meal log (no photo). Used by the "add food manually"
  /// flow until Chat 5 ships the camera-based scan.
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
        'name': name,
        'total_calories': totalCalories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        if (mealType != null) 'meal_type': mealType,
        if (consumedAt != null) 'consumed_at': formatDateTimeUtc(consumedAt),
      },
    );
    return Meal.fromJson(response);
  }

  Future<void> deleteMeal(String id) {
    return apiClient.delete(ApiEndpoints.mealById(id));
  }
}

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  return MealsRepository(ref.watch(apiClientProvider));
});
