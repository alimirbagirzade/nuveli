import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/meal/data/meal_models.dart';
import 'package:nuveli/features/meal/data/meal_repository.dart';
import 'package:nuveli/features/meal/providers/meal_providers.dart';

import '../../_helpers/test_helpers.dart';

class MockMealRepository extends Mock implements MealRepository {}

MealLog _mkMeal({
  required String id,
  required int calories,
  double? protein,
  double? carb,
  double? fat,
  String mealType = 'snack',
}) {
  return MealLog(
    id: id,
    name: 'test meal $id',
    calories: calories,
    proteinG: protein,
    carbG: carb,
    fatG: fat,
    mealType: mealType,
    source: 'manual',
    localDay: '2025-04-24',
    createdAt: DateTime.parse('2025-04-24T12:00:00Z'),
  );
}

void main() {
  late MockMealRepository mockRepo;

  setUpAll(() {
    registerFallbackValuesForTests();
  });

  setUp(() {
    mockRepo = MockMealRepository();
  });

  group('todayCaloriesProvider', () {
    test('returns 0 when loading', () {
      when(() => mockRepo.listMeals(any())).thenAnswer(
        (_) async => Future.delayed(const Duration(seconds: 10), () => []),
      );
      final container = makeContainer(overrides: [
        mealRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      expect(container.read(todayCaloriesProvider), 0);
    });

    test('sums meal calories correctly', () async {
      when(() => mockRepo.listMeals(any())).thenAnswer((_) async => [
            _mkMeal(id: 'm1', calories: 450),
            _mkMeal(id: 'm2', calories: 620),
            _mkMeal(id: 'm3', calories: 280),
          ]);

      final container = makeContainer(overrides: [
        mealRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      // FutureProvider'ı resolve et
      await container.read(todayMealsProvider.future);

      expect(container.read(todayCaloriesProvider), 1350);
    });

    test('empty list returns 0', () async {
      when(() => mockRepo.listMeals(any())).thenAnswer((_) async => []);

      final container = makeContainer(overrides: [
        mealRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      await container.read(todayMealsProvider.future);
      expect(container.read(todayCaloriesProvider), 0);
    });
  });

  group('todayMacrosProvider', () {
    test('sums all macros across meals', () async {
      when(() => mockRepo.listMeals(any())).thenAnswer((_) async => [
            _mkMeal(id: 'm1', calories: 400, protein: 20, carb: 45, fat: 12),
            _mkMeal(id: 'm2', calories: 500, protein: 35, carb: 30, fat: 18),
          ]);

      final container = makeContainer(overrides: [
        mealRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      await container.read(todayMealsProvider.future);
      final m = container.read(todayMacrosProvider);

      expect(m.protein, 55.0);
      expect(m.carb, 75.0);
      expect(m.fat, 30.0);
    });

    test('handles null macros gracefully (treats as 0)', () async {
      when(() => mockRepo.listMeals(any())).thenAnswer((_) async => [
            _mkMeal(id: 'm1', calories: 400, protein: 20), // sadece protein
            _mkMeal(id: 'm2', calories: 500), // hiç makro yok
          ]);

      final container = makeContainer(overrides: [
        mealRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      await container.read(todayMealsProvider.future);
      final m = container.read(todayMacrosProvider);

      expect(m.protein, 20.0);
      expect(m.carb, 0.0);
      expect(m.fat, 0.0);
    });
  });

  group('todayLocal()', () {
    test('produces YYYY-MM-DD format with zero padding', () {
      final s = todayLocal();
      expect(s, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });
  });
}
