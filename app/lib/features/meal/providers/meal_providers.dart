import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/home_repository.dart';
import '../data/meal_models.dart';
import '../data/meal_repository.dart';

/// Bugünün tarihi (YYYY-MM-DD, lokal).
String todayLocal() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

/// Bugün yenen öğünler. Home & history ekranları bunu watch eder.
final todayMealsProvider = FutureProvider<List<MealLog>>((ref) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.listMeals(todayLocal());
});

/// Belirli bir gündeki öğünler (history için).
final mealsForDayProvider =
    FutureProvider.family<List<MealLog>, String>((ref, localDay) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.listMeals(localDay);
});

/// Bugünkü toplam kalori.
final todayCaloriesProvider = Provider<int>((ref) {
  final meals = ref.watch(todayMealsProvider);
  return meals.maybeWhen(
    data: (list) => list.fold<int>(0, (sum, m) => sum + m.calories),
    orElse: () => 0,
  );
});

/// Bugünkü toplam makrolar (gram).
final todayMacrosProvider = Provider<({double protein, double carb, double fat})>((ref) {
  final meals = ref.watch(todayMealsProvider);
  return meals.maybeWhen(
    data: (list) {
      double p = 0, c = 0, f = 0;
      for (final m in list) {
        p += m.proteinG ?? 0;
        c += m.carbG ?? 0;
        f += m.fatG ?? 0;
      }
      return (protein: p, carb: c, fat: f);
    },
    orElse: () => (protein: 0, carb: 0, fat: 0),
  );
});

/// Silme action'ı. Çağrı sonrası todayMealsProvider + homePayloadProvider invalidate edilir.
final deleteMealActionProvider =
    Provider<Future<void> Function(String mealId)>((ref) {
  return (mealId) async {
    final repo = ref.read(mealRepositoryProvider);
    await repo.deleteMeal(mealId);
    // Home ve history otomatik yenilensin
    ref.invalidate(todayMealsProvider);
    ref.invalidate(homePayloadProvider);
  };
});
