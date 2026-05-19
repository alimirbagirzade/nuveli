import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/dashboard/models/meal.dart';
import '../../../features/dashboard/models/today_summary.dart';
import '../../../features/meal_scan/models/scan_result.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// Everything meal-related — logging, fetching, AI vision scan.
///
/// The backend's `/meals/today/summary` is the single source of
/// truth for the dashboard target-ring; raw `/meals?date=...` is
/// used by the meal list and analytics weekly aggregation.
class MealsRepository extends BaseRepository {
  MealsRepository(super.apiClient);

  // ---------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------

  /// Today's logged meals (chronological order from the backend).
  Future<List<Meal>> getTodaysMeals() async {
    return getMealsByDate(DateTime.now());
  }

  /// Meals on a specific calendar day, evaluated in the user's
  /// local timezone (backend converts internally).
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

  /// Dashboard summary: consumed vs target calories + macros,
  /// computed server-side so the client can't drift from the
  /// canonical value.
  Future<TodaySummary> getTodaysSummary() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.mealsTodaySummary,
    );
    return TodaySummary.fromJson(response);
  }

  // ---------------------------------------------------------------
  // AI Vision
  // ---------------------------------------------------------------

  /// Sends a base64-encoded photo to GPT-4o Vision via the backend
  /// and returns the detected foods + portion insights. **Premium
  /// gating is enforced server-side**; a non-premium user will
  /// receive a 402 → [PremiumRequiredException].
  ///
  /// `imageBase64` must NOT include the `data:image/...;base64,`
  /// prefix — just the raw base64 string.
  Future<ScanResult> scanMeal(String imageBase64) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.mealsScan,
      data: {'image_base64': imageBase64},
    );
    return ScanResult.fromJson(response);
  }

  // ---------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------

  /// Persists a meal log row. `consumedAt` defaults to `now()` on
  /// the server side if omitted.
  Future<Meal> createMeal({
    required String name,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    double? grams,
    String? mealType, // 'breakfast' | 'lunch' | 'dinner' | 'snack'
    DateTime? consumedAt,
    String? photoUrl,
    String? notes,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.meals,
      data: {
        'name': name,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        if (grams != null) 'grams': grams,
        if (mealType != null) 'meal_type': mealType,
        if (consumedAt != null) 'consumed_at': formatDateTimeUtc(consumedAt),
        if (photoUrl != null) 'photo_url': photoUrl,
        if (notes != null) 'notes': notes,
      },
    );
    return Meal.fromJson(response);
  }

  /// Patch any subset of a meal's fields.
  Future<Meal> updateMeal(
    String id, {
    String? name,
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? grams,
    String? mealType,
    DateTime? consumedAt,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (grams != null) 'grams': grams,
      if (mealType != null) 'meal_type': mealType,
      if (consumedAt != null) 'consumed_at': formatDateTimeUtc(consumedAt),
    };

    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.mealById(id),
      data: body,
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
