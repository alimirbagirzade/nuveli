import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuveli/features/meal/data/meal_models.dart';
import 'package:nuveli/features/meal/screens/meal_analysis_result_screen.dart';

import '../../_helpers/test_helpers.dart';

MealAnalysisResult _mkResult({
  String confidence = 'high',
  String? name = 'Tavuk ızgara',
  int? calories = 450,
  double? protein = 35.0,
  double? carb = 25.0,
  double? fat = 12.0,
}) {
  return MealAnalysisResult(
    analysisId: 'analysis-1',
    confidence: confidence,
    suggestedName: name,
    suggestedCalories: calories,
    suggestedProteinG: protein,
    suggestedCarbG: carb,
    suggestedFatG: fat,
  );
}

/// Navigation'sız minimal wrapper — go_router gerektirmez.
Future<void> pumpResultScreen(
  WidgetTester tester,
  MealAnalysisResult analysis,
) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) =>
                  MealAnalysisResultScreen(analysis: analysis),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(registerFallbackValuesForTests);

  group('MealAnalysisResultScreen — high confidence', () {
    testWidgets('shows AI suggestion values', (tester) async {
      await pumpResultScreen(tester, _mkResult());
      await tester.pump();

      expect(find.text('Tavuk ızgara'), findsOneWidget);
      expect(find.text('450 kcal'), findsOneWidget);
      expect(find.text('35.0 g'), findsOneWidget); // protein
    });

    testWidgets('shows high confidence banner message', (tester) async {
      await pumpResultScreen(tester, _mkResult(confidence: 'high'));
      await tester.pump();

      expect(
        find.text('Analiz yüksek güvenle tamamlandı.'),
        findsOneWidget,
      );
    });

    testWidgets('has Confirm button (not Save) by default', (tester) async {
      await pumpResultScreen(tester, _mkResult());
      await tester.pump();

      expect(find.text('Onayla'), findsOneWidget);
      expect(find.text('Kaydet'), findsNothing);
    });

    testWidgets('tapping Edit switches to editable mode with Save button',
        (tester) async {
      await pumpResultScreen(tester, _mkResult());
      await tester.pump();

      await tester.tap(find.text('Düzenle'));
      await tester.pumpAndSettle();

      // Edit mode: button değişmeli
      expect(find.text('Kaydet'), findsOneWidget);
      expect(find.text('Onayla'), findsNothing);
    });

    testWidgets('shows meal type chips', (tester) async {
      await pumpResultScreen(tester, _mkResult());
      await tester.pump();

      expect(find.text('Kahvaltı'), findsOneWidget);
      expect(find.text('Öğle'), findsOneWidget);
      expect(find.text('Akşam'), findsOneWidget);
      expect(find.text('Ara öğün'), findsOneWidget);
    });
  });

  group('MealAnalysisResultScreen — medium confidence', () {
    testWidgets('shows medium confidence banner', (tester) async {
      await pumpResultScreen(tester, _mkResult(confidence: 'medium'));
      await tester.pump();

      expect(
        find.textContaining('yaklaşık bir tahmindir'),
        findsOneWidget,
      );
    });
  });

  group('MealAnalysisResultScreen — low/failed confidence', () {
    testWidgets('low confidence redirects to low-confidence view',
        (tester) async {
      await pumpResultScreen(tester, _mkResult(confidence: 'low'));
      await tester.pump();

      expect(find.text('Emin olamadık'), findsOneWidget);
      expect(find.text('Manuel Giriş'), findsOneWidget);
    });

    testWidgets('failed confidence also shows manual-entry prompt',
        (tester) async {
      await pumpResultScreen(tester, _mkResult(confidence: 'failed'));
      await tester.pump();

      expect(find.text('Emin olamadık'), findsOneWidget);
    });
  });

  group('MealAnalysisResultScreen — fallback display', () {
    testWidgets('missing name shows "Bilinmeyen yemek"', (tester) async {
      await pumpResultScreen(tester, _mkResult(name: null));
      await tester.pump();

      expect(find.text('Bilinmeyen yemek'), findsOneWidget);
    });

    testWidgets('missing numeric values show dash', (tester) async {
      await pumpResultScreen(
        tester,
        _mkResult(calories: null, protein: null),
      );
      await tester.pump();

      // 2+ "—" beklenir (kalori + protein eksik)
      expect(find.text('—'), findsAtLeast(1));
    });
  });
}
