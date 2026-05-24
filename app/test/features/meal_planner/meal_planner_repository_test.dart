// Verifies MealPlannerRepository builds the exact request bodies/paths the
// backend (backend/routers/meal_planner.py + models/meal_plan.py) expects.
// Mocks ApiClient so no network/Dio is touched — this is the schema-contract
// guard for the write side (POST/PATCH/DELETE /meal-plans).

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/data/repositories/meal_planner_repository.dart';
import 'package:nuveli/core/network/api_client.dart';

class _MockApiClient extends Mock implements ApiClient {}

Map<String, dynamic> _entryResponse() => {
      'id': 'plan-1',
      'plan_date': '2026-05-25',
      'meal_type': 'lunch',
      'custom_name': 'Chicken bowl',
      'servings': 1.0,
      'total_calories': 450,
      'total_protein_g': 40.0,
      'total_carbs_g': 30.0,
      'total_fat_g': 12.0,
    };

void main() {
  late _MockApiClient api;
  late MealPlannerRepository repo;

  setUp(() {
    api = _MockApiClient();
    repo = MealPlannerRepository(api);
  });

  group('createPlanEntry', () {
    test('POSTs /meal-plans with the MealPlanCreate shape', () async {
      when(() => api.post<Map<String, dynamic>>(
            '/meal-plans',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _entryResponse());

      await repo.createPlanEntry(
        planDate: DateTime(2026, 5, 25),
        mealType: 'lunch',
        customName: 'Chicken bowl',
        customCalories: 450,
        customProteinG: 40,
        customCarbsG: 30,
        customFatG: 12,
        servings: 2,
        note: 'meal prep',
      );

      final captured = verify(() => api.post<Map<String, dynamic>>(
            '/meal-plans',
            data: captureAny(named: 'data'),
          )).captured.single as Map<String, dynamic>;

      expect(captured['plan_date'], '2026-05-25');
      expect(captured['meal_type'], 'lunch');
      expect(captured['custom_name'], 'Chicken bowl');
      expect(captured['custom_calories'], 450);
      expect(captured['custom_protein_g'], 40);
      expect(captured['custom_carbs_g'], 30);
      expect(captured['custom_fat_g'], 12);
      expect(captured['servings'], 2);
      expect(captured['note'], 'meal prep');
    });

    test('omits an empty note', () async {
      when(() => api.post<Map<String, dynamic>>(
            '/meal-plans',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _entryResponse());

      await repo.createPlanEntry(
        planDate: DateTime(2026, 5, 25),
        mealType: 'snack',
        customName: 'Apple',
        customCalories: 95,
        note: '',
      );

      final captured = verify(() => api.post<Map<String, dynamic>>(
            '/meal-plans',
            data: captureAny(named: 'data'),
          )).captured.single as Map<String, dynamic>;

      expect(captured.containsKey('note'), isFalse);
    });

    test('returns the parsed MealPlanEntry', () async {
      when(() => api.post<Map<String, dynamic>>(
            '/meal-plans',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _entryResponse());

      final entry = await repo.createPlanEntry(
        planDate: DateTime(2026, 5, 25),
        mealType: 'lunch',
        customName: 'Chicken bowl',
        customCalories: 450,
      );

      expect(entry.id, 'plan-1');
      expect(entry.totalCalories, 450);
      expect(entry.displayName, 'Chicken bowl');
    });
  });

  group('updatePlanEntry', () {
    test('PATCHes /meal-plans/{id} with name + note only', () async {
      when(() => api.patch<Map<String, dynamic>>(
            '/meal-plans/plan-1',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _entryResponse());

      await repo.updatePlanEntry(
        planId: 'plan-1',
        customName: 'Renamed',
        note: 'updated note',
      );

      final captured = verify(() => api.patch<Map<String, dynamic>>(
            '/meal-plans/plan-1',
            data: captureAny(named: 'data'),
          )).captured.single as Map<String, dynamic>;

      expect(captured['custom_name'], 'Renamed');
      expect(captured['note'], 'updated note');
      // Never sends totals/servings — backend wouldn't recompute them.
      expect(captured.containsKey('servings'), isFalse);
      expect(captured.containsKey('total_calories'), isFalse);
    });

    test('omits unset fields', () async {
      when(() => api.patch<Map<String, dynamic>>(
            '/meal-plans/plan-1',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _entryResponse());

      await repo.updatePlanEntry(planId: 'plan-1', note: 'only note');

      final captured = verify(() => api.patch<Map<String, dynamic>>(
            '/meal-plans/plan-1',
            data: captureAny(named: 'data'),
          )).captured.single as Map<String, dynamic>;

      expect(captured.containsKey('custom_name'), isFalse);
      expect(captured['note'], 'only note');
    });
  });

  group('deletePlanEntry', () {
    test('DELETEs /meal-plans/{id}', () async {
      when(() => api.delete('/meal-plans/plan-9'))
          .thenAnswer((_) async {});

      await repo.deletePlanEntry('plan-9');

      verify(() => api.delete('/meal-plans/plan-9')).called(1);
    });
  });
}
