// Widget test for AddMealPlanSheet — validation + that a valid save calls
// the repository with the typed values. Repo is mocked (mocktail) and
// injected via a provider override, so no network is touched.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/data/repositories/meal_planner_repository.dart';
import 'package:nuveli/features/meal_planner/models/weekly_plan.dart';
import 'package:nuveli/features/meal_planner/widgets/add_meal_plan_sheet.dart';

class _MockRepo extends Mock implements MealPlannerRepository {}

MealPlanEntry _dummyEntry() => MealPlanEntry.fromJson({
      'id': 'plan-1',
      'plan_date': '2026-05-25',
      'meal_type': 'lunch',
      'custom_name': 'Chicken bowl',
      'total_calories': 450,
    });

Future<void> _openSheet(WidgetTester tester, MealPlannerRepository repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mealPlannerRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () =>
                    AddMealPlanSheet.show(context, DateTime(2026, 5, 25)),
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
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  testWidgets('blocks save with an empty name', (tester) async {
    final repo = _MockRepo();
    await _openSheet(tester, repo);

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Add to plan'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add to plan'));
    await tester.pump();

    expect(find.text('Meal name is required'), findsOneWidget);
    verifyNever(() => repo.createPlanEntry(
          planDate: any(named: 'planDate'),
          mealType: any(named: 'mealType'),
          customName: any(named: 'customName'),
          customCalories: any(named: 'customCalories'),
        ));
  });

  testWidgets('blocks save with no calories', (tester) async {
    final repo = _MockRepo();
    await _openSheet(tester, repo);

    await tester.enterText(find.byType(TextField).first, 'Chicken bowl');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Add to plan'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add to plan'));
    await tester.pump();

    expect(find.text('Enter a calorie value (> 0)'), findsOneWidget);
  });

  testWidgets('valid input calls createPlanEntry with typed values',
      (tester) async {
    final repo = _MockRepo();
    when(() => repo.createPlanEntry(
          planDate: any(named: 'planDate'),
          mealType: any(named: 'mealType'),
          customName: any(named: 'customName'),
          customCalories: any(named: 'customCalories'),
          customProteinG: any(named: 'customProteinG'),
          customCarbsG: any(named: 'customCarbsG'),
          customFatG: any(named: 'customFatG'),
          servings: any(named: 'servings'),
          note: any(named: 'note'),
        )).thenAnswer((_) async => _dummyEntry());

    await _openSheet(tester, repo);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Chicken bowl'); // name
    await tester.enterText(fields.at(1), '450'); // calories
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Add to plan'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add to plan'));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.createPlanEntry(
          planDate: captureAny(named: 'planDate'),
          mealType: captureAny(named: 'mealType'),
          customName: captureAny(named: 'customName'),
          customCalories: captureAny(named: 'customCalories'),
          customProteinG: any(named: 'customProteinG'),
          customCarbsG: any(named: 'customCarbsG'),
          customFatG: any(named: 'customFatG'),
          servings: any(named: 'servings'),
          note: any(named: 'note'),
        )).captured;

    expect(captured[0], DateTime(2026, 5, 25)); // planDate
    expect(captured[2], 'Chicken bowl'); // customName
    expect(captured[3], 450); // customCalories
    // Sheet closed on success.
    expect(find.widgetWithText(ElevatedButton, 'Add to plan'), findsNothing);
  });
}
