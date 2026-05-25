import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meals_repository.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/utils/meal_image_capture.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/meal_scan_models.dart';
import 'scan_count_provider.dart';

/// Finite-state machine the UI walks through:
///
///   idle → previewing → analyzing → resultEditing → (saved | idle)
///                                  ↘ error → idle
///
/// `notFood` is a special sub-state of resultEditing where the user
/// has no detected foods to edit — only the AI's explanation + a CTA
/// to retake or fall back to manual entry.
enum MealScanPhase {
  idle,
  previewing,
  analyzing,
  resultEditing,
  notFood,
  error,
  saving,
  saved,
}

@immutable
class MealScanState {
  final MealScanPhase phase;
  final String? imagePath;
  final MealScanResult? scanResult;
  final List<DetectedFood> editedFoods;
  final double scaleFactor;
  final String? mealType; // breakfast | lunch | dinner | snack
  final String? mealName; // user override; null/empty → auto-composed
  final String? errorMessage;
  final bool isRateLimited;

  const MealScanState({
    this.phase = MealScanPhase.idle,
    this.imagePath,
    this.scanResult,
    this.editedFoods = const [],
    this.scaleFactor = 1.0,
    this.mealType,
    this.mealName,
    this.errorMessage,
    this.isRateLimited = false,
  });

  MealScanState copyWith({
    MealScanPhase? phase,
    String? imagePath,
    MealScanResult? scanResult,
    List<DetectedFood>? editedFoods,
    double? scaleFactor,
    String? mealType,
    String? mealName,
    String? errorMessage,
    bool? isRateLimited,
    bool clearError = false,
    bool clearImage = false,
    bool clearResult = false,
  }) {
    return MealScanState(
      phase: phase ?? this.phase,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      scanResult: clearResult ? null : (scanResult ?? this.scanResult),
      editedFoods: editedFoods ?? this.editedFoods,
      scaleFactor: scaleFactor ?? this.scaleFactor,
      mealType: mealType ?? this.mealType,
      mealName: mealName ?? this.mealName,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRateLimited: isRateLimited ?? this.isRateLimited,
    );
  }

  /// Foods after the scale-factor slider is applied. Per-food edits in
  /// [editedFoods] are stored at scale=1.0; we re-scale on read so the
  /// slider can be moved without losing edits.
  List<DetectedFood> get effectiveFoods {
    if (scaleFactor == 1.0) return editedFoods;
    return editedFoods.map((f) => f.scaledBy(scaleFactor)).toList(growable: false);
  }

  int get totalCalories =>
      effectiveFoods.fold<int>(0, (sum, f) => sum + f.calories);
  double get totalProteinG =>
      effectiveFoods.fold<double>(0, (sum, f) => sum + f.proteinG);
  double get totalCarbsG =>
      effectiveFoods.fold<double>(0, (sum, f) => sum + f.carbsG);
  double get totalFatG =>
      effectiveFoods.fold<double>(0, (sum, f) => sum + f.fatG);

  /// Auto-composed title from detected foods — the default shown in the
  /// editable name field and the fallback when the user leaves it blank.
  String get autoMealName {
    final foods = effectiveFoods;
    if (foods.isEmpty) return '';
    if (foods.length == 1) return foods.first.name;
    return foods.take(3).map((f) => f.name).join(' + ');
  }
}

class MealScanController extends AutoDisposeNotifier<MealScanState> {
  @override
  MealScanState build() => const MealScanState();

  /// Camera capture. Throws nothing — error surfaces in state.
  Future<void> pickFromCamera() async {
    await _pickAndStage(MealImageCapture.fromCamera);
  }

  Future<void> pickFromGallery() async {
    await _pickAndStage(MealImageCapture.fromGallery);
  }

  Future<void> _pickAndStage(Future<String?> Function() picker) async {
    try {
      final path = await picker();
      if (path == null) {
        // user cancelled — stay idle
        return;
      }
      state = state.copyWith(
        phase: MealScanPhase.previewing,
        imagePath: path,
        clearError: true,
        clearResult: true,
      );
    } on CameraUnavailableException catch (e) {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: e.message,
        clearImage: true,
      );
    } catch (e) {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: 'Could not open image picker.',
        clearImage: true,
      );
    }
  }

  /// Discard the previewed photo and go back to idle.
  void retake() {
    state = const MealScanState();
  }

  /// Send the staged image to the backend.
  Future<void> analyze() async {
    final path = state.imagePath;
    if (path == null) return;

    state = state.copyWith(phase: MealScanPhase.analyzing, clearError: true);

    final base64 = await MealImageCapture.toBase64(path);
    if (base64 == null) {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: 'Could not read the image file.',
      );
      return;
    }

    try {
      final repo = ref.read(mealsRepositoryProvider);
      final result = await repo.scanMeal(
        imageBase64: base64,
        mealTypeHint: _defaultMealTypeForNow(),
      );

      if (result.isNotFood) {
        state = state.copyWith(
          phase: MealScanPhase.notFood,
          scanResult: result,
          editedFoods: const [],
          scaleFactor: 1.0,
        );
        return;
      }

      state = state.copyWith(
        phase: MealScanPhase.resultEditing,
        scanResult: result,
        editedFoods: List<DetectedFood>.from(result.foods),
        scaleFactor: 1.0,
        mealType: result.suggestedMealType ?? _defaultMealTypeForNow(),
      );
    } on RateLimitedException catch (e) {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: e.message,
        isRateLimited: true,
      );
    } on PremiumRequiredException catch (e) {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: e.message,
      );
    } on TimeoutException {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: 'AI analysis timed out. Try again in a moment.',
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: 'Something went wrong. Try again.',
      );
    }
  }

  /// Per-food edit (from result screen).
  void updateFood(int index, DetectedFood food) {
    if (index < 0 || index >= state.editedFoods.length) return;
    final next = List<DetectedFood>.from(state.editedFoods);
    next[index] = food;
    state = state.copyWith(editedFoods: next);
  }

  void removeFood(int index) {
    if (index < 0 || index >= state.editedFoods.length) return;
    final next = List<DetectedFood>.from(state.editedFoods)..removeAt(index);
    state = state.copyWith(editedFoods: next);
  }

  void setScale(double factor) {
    state = state.copyWith(scaleFactor: factor.clamp(0.25, 3.0));
  }

  void setMealType(String mealType) {
    state = state.copyWith(mealType: mealType);
  }

  /// User override for the meal title. Empty string is kept (not cleared)
  /// so `save()` knows to fall back to the auto-composed name.
  void setMealName(String name) {
    state = state.copyWith(mealName: name);
  }

  /// Persist via `POST /meals` with scan_source='ai_scan'.
  Future<bool> save() async {
    final foods = state.effectiveFoods;
    if (foods.isEmpty) return false;

    state = state.copyWith(phase: MealScanPhase.saving, clearError: true);

    try {
      final typedName = state.mealName?.trim() ?? '';
      final repo = ref.read(mealsRepositoryProvider);
      await repo.createScannedMeal(
        mealType: state.mealType ?? _defaultMealTypeForNow(),
        name: typedName.isNotEmpty ? typedName : _composeMealName(foods),
        foods: foods,
        consumedAt: DateTime.now(),
      );

      // Refresh dashboard + scan counter so the gating updates.
      ref.invalidate(scanCountTodayProvider);
      ref.invalidate(todayMealsProvider);
      ref.invalidate(dashboardSummaryProvider);

      state = state.copyWith(phase: MealScanPhase.saved);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        phase: MealScanPhase.error,
        errorMessage: 'Failed to save meal. Try again.',
      );
      return false;
    }
  }

  /// Hard reset (used after save / discard / manual fallback).
  void reset() {
    state = const MealScanState();
  }

  static String _composeMealName(List<DetectedFood> foods) {
    if (foods.length == 1) return foods.first.name;
    return foods.take(3).map((f) => f.name).join(' + ');
  }

  /// Same heuristic as MealEntrySheet — saves the user a tap.
  static String _defaultMealTypeForNow() {
    final h = DateTime.now().hour;
    if (h < 11) return 'breakfast';
    if (h < 15) return 'lunch';
    if (h < 17) return 'snack';
    if (h < 22) return 'dinner';
    return 'snack';
  }
}

final mealScanControllerProvider =
    AutoDisposeNotifierProvider<MealScanController, MealScanState>(
  MealScanController.new,
);
