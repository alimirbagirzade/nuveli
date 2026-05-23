import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/meal_planner/models/weekly_plan.dart';

void main() {
  group('WeeklyPlan.fromJson', () {
    test('parses canonical /meal-plans payload', () {
      final wp = WeeklyPlan.fromJson({
        'week_start': '2026-05-18',
        'week_end': '2026-05-24',
        'total_calories': 12000,
        'days': [
          {
            'plan_date': '2026-05-18',
            'total_calories': 1800,
            'total_protein_g': 120,
            'total_carbs_g': 200,
            'total_fat_g': 50,
            'meal_count': 3,
          },
          {
            'plan_date': '2026-05-19',
            'total_calories': 0,
            'total_protein_g': 0,
            'total_carbs_g': 0,
            'total_fat_g': 0,
            'meal_count': 0,
          },
        ],
        'plans': [
          {
            'id': 'p-1',
            'plan_date': '2026-05-18',
            'meal_type': 'breakfast',
            'recipe': {'name': 'Greek yogurt + berries'},
            'servings': 1.0,
            'total_calories': 320,
            'total_protein_g': 22,
            'total_carbs_g': 28,
            'total_fat_g': 12,
          },
          {
            'id': 'p-2',
            'plan_date': '2026-05-18',
            'meal_type': 'lunch',
            'custom_name': 'Chicken bowl',
            'servings': 2.0,
            'total_calories': 850,
            'total_protein_g': 60,
            'total_carbs_g': 80,
            'total_fat_g': 25,
          },
        ],
      });

      expect(wp.totalCalories, 12000);
      expect(wp.days.length, 2);
      expect(wp.plans.length, 2);
      expect(wp.isEmpty, false);
    });

    test('plansFor filters by local calendar day', () {
      final wp = WeeklyPlan.fromJson({
        'week_start': '2026-05-18',
        'week_end': '2026-05-24',
        'total_calories': 0,
        'days': const [],
        'plans': [
          {
            'id': 'a',
            'plan_date': '2026-05-19',
            'meal_type': 'breakfast',
            'total_calories': 100,
          },
          {
            'id': 'b',
            'plan_date': '2026-05-20',
            'meal_type': 'breakfast',
            'total_calories': 200,
          },
        ],
      });

      final day19 = DateTime(2026, 5, 19);
      final day20 = DateTime(2026, 5, 20);
      expect(wp.plansFor(day19).length, 1);
      expect(wp.plansFor(day19).first.id, 'a');
      expect(wp.plansFor(day20).first.id, 'b');
    });

    test('empty plans -> isEmpty=true', () {
      final wp = WeeklyPlan.fromJson({
        'week_start': '2026-05-18',
        'week_end': '2026-05-24',
        'total_calories': 0,
        'days': const [],
        'plans': const [],
      });
      expect(wp.isEmpty, true);
    });
  });

  group('MealPlanEntry.displayName', () {
    test('prefers recipe name over custom_name', () {
      final e = MealPlanEntry.fromJson({
        'id': 'x',
        'plan_date': '2026-05-19',
        'meal_type': 'lunch',
        'recipe': {'name': 'Pasta'},
        'custom_name': 'leftovers',
        'total_calories': 100,
      });
      expect(e.displayName, 'Pasta');
    });

    test('falls back to custom_name when no recipe', () {
      final e = MealPlanEntry.fromJson({
        'id': 'x',
        'plan_date': '2026-05-19',
        'meal_type': 'lunch',
        'custom_name': 'leftovers',
        'total_calories': 100,
      });
      expect(e.displayName, 'leftovers');
    });

    test('falls back to meal-type label when neither set', () {
      final e = MealPlanEntry.fromJson({
        'id': 'x',
        'plan_date': '2026-05-19',
        'meal_type': 'snack',
        'total_calories': 50,
      });
      expect(e.displayName, 'Snack');
    });
  });

  group('GrocerySummary + GroceryItem', () {
    test('displayAmount renders integers without decimal', () {
      const g = GroceryItem(name: 'Eggs', totalAmount: 6, unit: 'piece');
      expect(g.displayAmount, '6 piece');
    });

    test('displayAmount renders fractions with 1 decimal', () {
      const g = GroceryItem(name: 'Milk', totalAmount: 1.5, unit: 'L');
      expect(g.displayAmount, '1.5 L');
    });

    test('GrocerySummary.fromJson empty items -> isEmpty', () {
      final s = GrocerySummary.fromJson({
        'week_start': '2026-05-18',
        'week_end': '2026-05-24',
        'recipe_count': 0,
        'items': const [],
      });
      expect(s.isEmpty, true);
    });
  });
}
