import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meals_repository.dart';
import '../models/scan_result.dart';

/// AI Meal Scan — real backend integration via GPT-4o Vision.
///
/// This replaces the mock provider that gated everything behind a
/// `kMockMode = true` constant; that flag is now gone. The provider
/// holds an `AsyncValue<ScanResult?>`:
///
///   - `data(null)`   → idle (initial state, or after `reset()`)
///   - `loading()`    → request in-flight
///   - `data(result)` → scan complete; UI shows detected foods
///   - `error(e, st)` → scan failed (network, premium-gating, etc.)
///
/// The camera widget calls `scan(base64)` after capture; the user
/// then either confirms (→ logs a meal via [MealsRepository]) or
/// hits "Retake" (→ `reset()` and re-opens the camera).
class MealScanNotifier extends AsyncNotifier<ScanResult?> {
  late MealsRepository _repo;

  @override
  Future<ScanResult?> build() async {
    _repo = ref.watch(mealsRepositoryProvider);
    return null; // idle
  }

  /// Sends the captured image to the backend's vision endpoint.
  /// `imageBase64` must be the raw base64 string (no `data:image/...`
  /// prefix). The provider transitions through loading → data/error.
  Future<void> scan(String imageBase64) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.scanMeal(imageBase64));
  }

  /// Resets back to idle so the user can take another photo.
  void reset() {
    state = const AsyncValue.data(null);
  }

  /// After the user confirms the detected foods, persist each as a
  /// meal log entry. We don't bundle this into the scan call so the
  /// user gets the chance to edit / remove items first.
  ///
  /// Returns the number of meal rows created.
  Future<int> confirmAndLog({
    required ScanResult result,
    String? mealType,
    DateTime? consumedAt,
  }) async {
    final foods = result.foods;
    for (final food in foods) {
      await _repo.createMeal(
        name: food.name,
        calories: food.calories,
        proteinG: food.proteinG,
        carbsG: food.carbsG,
        fatG: food.fatG,
        grams: food.grams,
        mealType: mealType,
        consumedAt: consumedAt,
      );
    }
    // Clear scan state once logged.
    state = const AsyncValue.data(null);
    return foods.length;
  }
}

final mealScanProvider =
    AsyncNotifierProvider<MealScanNotifier, ScanResult?>(
  MealScanNotifier.new,
);
