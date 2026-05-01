import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/home/widgets/today_meals_list.dart';
import 'package:nuveli/features/meal/data/meal_models.dart';
import 'package:nuveli/features/meal/data/meal_repository.dart';
import 'package:nuveli/features/meal/providers/meal_providers.dart';

import '../_helpers/test_helpers.dart';
import '../_helpers/widget_test_helpers.dart';

class MockMealRepository extends Mock implements MealRepository {}

MealLog _mkMeal({
  required String id,
  required String name,
  required int calories,
  String mealType = 'lunch',
}) {
  return MealLog(
    id: id,
    name: name,
    calories: calories,
    mealType: mealType,
    source: 'manual',
    localDay: '2025-04-24',
    createdAt: DateTime.parse('2025-04-24T12:00:00Z'),
  );
}

void main() {
  late MockMealRepository mockRepo;

  setUpAll(registerFallbackValuesForTests);

  setUp(() {
    mockRepo = MockMealRepository();
  });

  group('TodayMealsList', () {
    testWidgets('shows skeleton loader while fetching', (tester) async {
      // Bitmeyen future — loading durumunda kalır
      when(() => mockRepo.listMeals(any())).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 30), () => []),
      );

      await pumpWithProviders(
        tester,
        const Scaffold(body: TodayMealsList()),
        overrides: [
          mealRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // Skeleton'da gerçek meal ismi yok
      expect(find.text('Bugünkü öğünler'), findsNothing);
      // Ama Container'lar var (skeleton shimmer boxes)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows empty state CTA when list is empty', (tester) async {
      when(() => mockRepo.listMeals(any())).thenAnswer((_) async => []);

      await pumpWithProviders(
        tester,
        const Scaffold(body: TodayMealsList()),
        overrides: [
          mealRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // Future resolve olsun
      await tester.pumpAndSettle();

      // Empty state → başlık + CTA butonu
      expect(find.text('Henüz öğün eklenmedi'), findsOneWidget);
      expect(find.text('Öğün Ekle'), findsOneWidget);
    });

    testWidgets('renders meal rows with name and calories', (tester) async {
      when(() => mockRepo.listMeals(any())).thenAnswer((_) async => [
            _mkMeal(id: 'm1', name: 'Kahvaltı', calories: 450),
            _mkMeal(id: 'm2', name: 'Öğle yemeği', calories: 620),
          ]);

      await pumpWithProviders(
        tester,
        const Scaffold(body: TodayMealsList()),
        overrides: [
          mealRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Başlık
      expect(find.text('Bugünkü öğünler'), findsOneWidget);
      // İsim + kalori bilgileri
      expect(find.text('Kahvaltı'), findsOneWidget);
      expect(find.text('Öğle yemeği'), findsOneWidget);
      expect(find.text('450 kcal'), findsOneWidget);
      expect(find.text('620 kcal'), findsOneWidget);
      // Öğün sayısı göstergesi
      expect(find.text('2 öğün'), findsOneWidget);
    });

    testWidgets('shows correct meal type label for each type', (tester) async {
      when(() => mockRepo.listMeals(any())).thenAnswer((_) async => [
            _mkMeal(id: '1', name: 'x', calories: 100, mealType: 'breakfast'),
            _mkMeal(id: '2', name: 'y', calories: 200, mealType: 'lunch'),
            _mkMeal(id: '3', name: 'z', calories: 300, mealType: 'dinner'),
            _mkMeal(id: '4', name: 'w', calories: 50, mealType: 'snack'),
          ]);

      await pumpWithProviders(
        tester,
        const Scaffold(body: TodayMealsList()),
        overrides: [
          mealRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Kahvaltı'), findsOneWidget);
      expect(find.text('Öğle'), findsOneWidget);
      expect(find.text('Akşam'), findsOneWidget);
      expect(find.text('Ara öğün'), findsOneWidget);
    });

    testWidgets('swipe to delete shows confirmation dialog',
        (tester) async {
      when(() => mockRepo.listMeals(any())).thenAnswer((_) async => [
            _mkMeal(id: 'm1', name: 'Silinecek', calories: 300),
          ]);

      await pumpWithProviders(
        tester,
        const Scaffold(body: TodayMealsList()),
        overrides: [
          mealRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Dismiss'i trigger et
      await tester.drag(
        find.text('Silinecek'),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      // Onay dialogu açılır
      expect(find.text('Öğünü sil?'), findsOneWidget);
      expect(find.text('Vazgeç'), findsOneWidget);
      expect(find.text('Sil'), findsOneWidget);
    });
  });
}
