import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/meal/models/meal_scan_models.dart';

void main() {
  group('DetectedFood.fromJson', () {
    test('parses canonical backend payload', () {
      final f = DetectedFood.fromJson({
        'name': 'Grilled chicken',
        'portion': '1 breast',
        'grams': 150.0,
        'calories': 245,
        'protein_g': 46.2,
        'carbs_g': 0.0,
        'fat_g': 6.4,
      });
      expect(f.name, 'Grilled chicken');
      expect(f.portion, '1 breast');
      expect(f.grams, 150.0);
      expect(f.calories, 245);
      expect(f.proteinG, 46.2);
      expect(f.fatG, 6.4);
    });

    test('tolerates missing optional fields', () {
      final f = DetectedFood.fromJson({
        'name': 'Apple',
        'calories': 80,
      });
      expect(f.portion, '');
      expect(f.grams, isNull);
      expect(f.proteinG, 0);
    });

    test('handles int macros (no decimals)', () {
      final f = DetectedFood.fromJson({
        'name': 'X',
        'calories': 100,
        'protein_g': 10,
        'carbs_g': 20,
        'fat_g': 5,
      });
      expect(f.proteinG, 10);
      expect(f.carbsG, 20);
      expect(f.fatG, 5);
    });
  });

  group('DetectedFood.scaledBy', () {
    test('scales calories + macros, rounds macros to 1 decimal', () {
      const base = DetectedFood(
        name: 'Rice',
        portion: '1 cup',
        calories: 200,
        proteinG: 4,
        carbsG: 45,
        fatG: 0.5,
      );
      final scaled = base.scaledBy(1.5);
      expect(scaled.calories, 300);
      expect(scaled.proteinG, 6.0);
      expect(scaled.carbsG, 67.5);
      expect(scaled.fatG, 0.8); // 0.75 → 0.8
    });

    test('preserves name and portion', () {
      const base = DetectedFood(
        name: 'Rice',
        portion: '1 cup',
        calories: 200,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
      );
      expect(base.scaledBy(0.5).name, 'Rice');
      expect(base.scaledBy(0.5).portion, '1 cup');
    });

    test('scales grams too when present', () {
      const base = DetectedFood(
        name: 'X',
        portion: '',
        grams: 100,
        calories: 100,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
      );
      expect(base.scaledBy(2.0).grams, 200);
    });
  });

  group('DetectedFood.toCreatePayload', () {
    test('emits the keys the meals POST endpoint expects', () {
      const f = DetectedFood(
        name: 'Toast',
        portion: '2 slices',
        grams: 60,
        calories: 160,
        proteinG: 6,
        carbsG: 30,
        fatG: 2,
      );
      final p = f.toCreatePayload(3);
      expect(p['name'], 'Toast');
      expect(p['portion'], '2 slices');
      expect(p['grams'], 60);
      expect(p['calories'], 160);
      expect(p['protein_g'], 6);
      expect(p['carbs_g'], 30);
      expect(p['fat_g'], 2);
      expect(p['position'], 3);
    });

    test('drops grams + portion when absent', () {
      const f = DetectedFood(
        name: 'X',
        portion: '',
        calories: 100,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
      );
      final p = f.toCreatePayload(0);
      expect(p.containsKey('portion'), false);
      expect(p.containsKey('grams'), false);
    });
  });

  group('MealScanResult.fromJson', () {
    test('parses full payload', () {
      final r = MealScanResult.fromJson({
        'foods': [
          {
            'name': 'Salad',
            'portion': '1 bowl',
            'calories': 220,
            'protein_g': 8,
            'carbs_g': 18,
            'fat_g': 12,
          },
        ],
        'total_calories': 220,
        'total_protein_g': 8,
        'total_carbs_g': 18,
        'total_fat_g': 12,
        'portion_insight': {
          'score': 78,
          'main_text': 'Big plate — looks balanced.',
          'highlights': ['Add protein for satiety'],
        },
        'suggested_meal_type': 'lunch',
      });
      expect(r.foods.length, 1);
      expect(r.totalCalories, 220);
      expect(r.portionInsight.score, 78);
      expect(r.portionInsight.highlights.first, 'Add protein for satiety');
      expect(r.suggestedMealType, 'lunch');
      expect(r.isNotFood, false);
    });

    test('flags isNotFood when foods is empty', () {
      final r = MealScanResult.fromJson({
        'foods': const [],
        'total_calories': 0,
        'total_protein_g': 0,
        'total_carbs_g': 0,
        'total_fat_g': 0,
        'portion_insight': {
          'score': 0,
          'main_text': 'No food detected in the photo.',
        },
      });
      expect(r.isNotFood, true);
      expect(r.portionInsight.mainText, contains('No food'));
    });

    test('handles missing portion_insight gracefully', () {
      final r = MealScanResult.fromJson({
        'foods': [
          {'name': 'X', 'calories': 100},
        ],
        'total_calories': 100,
      });
      expect(r.portionInsight.score, 0);
      expect(r.portionInsight.mainText, '');
    });
  });
}
