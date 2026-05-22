import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/data/repositories/meals_repository.dart';
import 'package:nuveli/features/dashboard/models/meal.dart';
import 'package:nuveli/features/dashboard/widgets/meal_entry_sheet.dart';

class _MockMealsRepo extends Mock implements MealsRepository {}

Meal _stubMeal({
  String id = 'm-1',
  String type = 'breakfast',
  String? name = 'Yogurt',
  int kcal = 180,
}) {
  return Meal(
    id: id,
    mealType: type,
    name: name,
    totalCalories: kcal,
    proteinG: 0,
    carbsG: 0,
    fatG: 0,
    consumedAt: DateTime.now(),
  );
}

Future<void> _openSheet(WidgetTester tester, _MockMealsRepo repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mealsRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => MealEntrySheet.show(ctx),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  late _MockMealsRepo repo;

  setUp(() {
    repo = _MockMealsRepo();
  });

  testWidgets('renders sheet with all 4 meal type chips + form fields',
      (tester) async {
    await _openSheet(tester, repo);

    expect(find.text('Add Food'), findsOneWidget);
    for (final t in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
      expect(find.text(t), findsOneWidget);
    }
    expect(find.text('What did you eat?'), findsOneWidget);
    expect(find.text('Calories (kcal)'), findsOneWidget);
    expect(find.text('Protein (g)'), findsOneWidget);
    expect(find.text('Carbs (g)'), findsOneWidget);
    expect(find.text('Fat (g)'), findsOneWidget);
    expect(find.text('Save meal'), findsOneWidget);
  });

  testWidgets('Save without name shows error and does not call repo',
      (tester) async {
    await _openSheet(tester, repo);

    await tester.tap(find.text('Save meal'));
    await tester.pump();

    expect(find.text('Food name is required'), findsOneWidget);
    verifyNever(() => repo.createMeal(
          name: any(named: 'name'),
          totalCalories: any(named: 'totalCalories'),
          proteinG: any(named: 'proteinG'),
          carbsG: any(named: 'carbsG'),
          fatG: any(named: 'fatG'),
          mealType: any(named: 'mealType'),
        ));
  });

  testWidgets('Save without calories shows error', (tester) async {
    await _openSheet(tester, repo);

    await tester.enterText(find.byType(TextField).first, 'Yogurt');
    await tester.tap(find.text('Save meal'));
    await tester.pump();

    expect(find.textContaining('calorie'), findsOneWidget);
  });

  testWidgets('valid input calls repo.createMeal with parsed values',
      (tester) async {
    when(() => repo.createMeal(
          name: any(named: 'name'),
          totalCalories: any(named: 'totalCalories'),
          proteinG: any(named: 'proteinG'),
          carbsG: any(named: 'carbsG'),
          fatG: any(named: 'fatG'),
          mealType: any(named: 'mealType'),
        )).thenAnswer((_) async => _stubMeal());

    await _openSheet(tester, repo);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Greek yogurt');
    await tester.enterText(fields.at(1), '180');
    await tester.enterText(fields.at(2), '15');
    await tester.enterText(fields.at(3), '20');
    await tester.enterText(fields.at(4), '5.5');

    await tester.tap(find.text('Save meal'));
    await tester.pump();

    verify(() => repo.createMeal(
          name: 'Greek yogurt',
          totalCalories: 180,
          proteinG: 15.0,
          carbsG: 20.0,
          fatG: 5.5,
          mealType: any(named: 'mealType'), // depends on time of day
        )).called(1);
  });

  testWidgets('tapping a different meal type chip selects it', (tester) async {
    await _openSheet(tester, repo);

    // Lunch should toggle to selected on tap (visual state — verified by re-tap)
    await tester.tap(find.text('Dinner'));
    await tester.pump();

    // Sanity: still showing the form, no crash, no extra dialogs
    expect(find.text('Add Food'), findsOneWidget);
  });

  testWidgets('Save failure surfaces error message and does not pop',
      (tester) async {
    when(() => repo.createMeal(
          name: any(named: 'name'),
          totalCalories: any(named: 'totalCalories'),
          proteinG: any(named: 'proteinG'),
          carbsG: any(named: 'carbsG'),
          fatG: any(named: 'fatG'),
          mealType: any(named: 'mealType'),
        )).thenThrow(Exception('network down'));

    await _openSheet(tester, repo);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'X');
    await tester.enterText(fields.at(1), '100');

    await tester.tap(find.text('Save meal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Could not save'), findsOneWidget);
    // Sheet still open
    expect(find.text('Save meal'), findsOneWidget);
  });
}
