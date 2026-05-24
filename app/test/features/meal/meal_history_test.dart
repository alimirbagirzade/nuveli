// Meal history: repository pagination contract + the day-grouping pure
// transform that the screen renders.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/data/repositories/meals_repository.dart';
import 'package:nuveli/core/network/api_client.dart';
import 'package:nuveli/features/dashboard/models/meal.dart';
import 'package:nuveli/features/meal/providers/meal_history_provider.dart';

class _MockApiClient extends Mock implements ApiClient {}

Meal _meal(String id, DateTime at, {int kcal = 100}) => Meal(
      id: id,
      mealType: 'lunch',
      name: 'Meal $id',
      totalCalories: kcal,
      proteinG: 0,
      carbsG: 0,
      fatG: 0,
      consumedAt: at,
    );

void main() {
  group('MealsRepository.getMealHistory', () {
    test('GETs /meals with limit + offset (no date filter)', () async {
      final api = _MockApiClient();
      final repo = MealsRepository(api);
      when(() => api.get<List<dynamic>>(
            '/meals',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => <dynamic>[]);

      await repo.getMealHistory(limit: 50, offset: 100);

      final captured = verify(() => api.get<List<dynamic>>(
            '/meals',
            queryParameters: captureAny(named: 'queryParameters'),
          )).captured.single as Map<String, dynamic>;

      expect(captured['limit'], 50);
      expect(captured['offset'], 100);
      expect(captured.containsKey('date'), isFalse);
    });

    test('parses the response into Meal models', () async {
      final api = _MockApiClient();
      final repo = MealsRepository(api);
      when(() => api.get<List<dynamic>>(
            '/meals',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => [
            {
              'id': 'm1',
              'meal_type': 'dinner',
              'name': 'Soup',
              'total_calories': 320,
              'consumed_at': '2026-05-24T19:00:00Z',
            },
          ]);

      final meals = await repo.getMealHistory();
      expect(meals, hasLength(1));
      expect(meals.first.id, 'm1');
      expect(meals.first.totalCalories, 320);
    });
  });

  group('groupMealsByDay', () {
    test('buckets meals by local calendar day', () {
      final meals = [
        _meal('a', DateTime(2026, 5, 24, 8)),
        _meal('b', DateTime(2026, 5, 24, 20)),
        _meal('c', DateTime(2026, 5, 23, 12)),
      ];
      final grouped = groupMealsByDay(meals);

      expect(grouped.keys, hasLength(2));
      expect(grouped[DateTime(2026, 5, 24)], hasLength(2));
      expect(grouped[DateTime(2026, 5, 23)], hasLength(1));
    });

    test('empty input yields an empty map', () {
      expect(groupMealsByDay(const []), isEmpty);
    });
  });
}
