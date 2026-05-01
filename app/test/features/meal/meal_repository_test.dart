import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/network/app_error.dart';
import 'package:nuveli/features/meal/data/meal_models.dart';
import 'package:nuveli/features/meal/data/meal_repository.dart';

import '../../_helpers/test_helpers.dart';

void main() {
  late MockDio mockDio;
  late MealRepository repo;

  setUpAll(registerFallbackValuesForTests);

  setUp(() {
    mockDio = MockDio();
    repo = MealRepository(mockDio);
  });

  group('MealAnalysisResult', () {
    test('fromJson with high confidence', () {
      final r = MealAnalysisResult.fromJson({
        'analysis_id': 'a-123',
        'confidence': 'high',
        'suggestion': {
          'name': 'Tavuk salata',
          'calories': 420,
          'protein_g': 35,
          'carb_g': 30,
          'fat_g': 15,
        },
      });
      expect(r.analysisId, 'a-123');
      expect(r.confidence, 'high');
      expect(r.suggestedName, 'Tavuk salata');
      expect(r.suggestedCalories, 420);
      expect(r.isLowConfidence, false);
    });

    test('low confidence flag triggers manual redirect path', () {
      final low = MealAnalysisResult.fromJson({'confidence': 'low'});
      expect(low.isLowConfidence, true);

      final failed = MealAnalysisResult.fromJson({'confidence': 'failed'});
      expect(failed.isLowConfidence, true);
    });

    test('missing suggestion handled gracefully', () {
      final r = MealAnalysisResult.fromJson({'confidence': 'medium'});
      expect(r.suggestedName, isNull);
      expect(r.suggestedCalories, isNull);
    });
  });

  group('MealLog', () {
    test('fromJson parses complete meal', () {
      final m = MealLog.fromJson({
        'id': 'meal-1',
        'name': 'Kahvaltı',
        'calories': 450,
        'protein_g': 20.5,
        'carb_g': 55.0,
        'fat_g': 15.2,
        'meal_type': 'breakfast',
        'source': 'ai_confirmed',
        'local_day': '2025-04-24',
        'created_at': '2025-04-24T08:30:00Z',
      });
      expect(m.id, 'meal-1');
      expect(m.calories, 450);
      expect(m.proteinG, 20.5);
      expect(m.source, 'ai_confirmed');
    });

    test('fromJson with null macros defaults gracefully', () {
      final m = MealLog.fromJson({
        'id': 'meal-2',
        'name': 'Atıştırmalık',
        'calories': 120,
        'meal_type': 'snack',
        'source': 'manual',
        'local_day': '2025-04-24',
        'created_at': '2025-04-24T15:00:00Z',
      });
      expect(m.proteinG, isNull);
      expect(m.mealType, 'snack');
    });
  });

  group('analyze()', () {
    test('successful analysis returns parsed result', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => successResponse({
          'analysis_id': 'a-1',
          'confidence': 'high',
          'suggestion': {
            'name': 'Pilav',
            'calories': 320,
          },
        }),
      );

      final result = await repo.analyze(description: 'pilav');
      expect(result.analysisId, 'a-1');
      expect(result.suggestedName, 'Pilav');
    });

    test('429 limit exceeded throws LimitExceededError', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        errorResponse(
          statusCode: 429,
          code: 'LIMIT_EXCEEDED',
          message: 'Free tier günde 3 analiz hakkın var.',
        ),
      );

      expect(
        () => repo.analyze(description: 'test'),
        throwsA(isA<LimitExceededError>()),
      );
    });

    test('network error throws NetworkError', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        networkError(),
      );

      expect(
        () => repo.analyze(description: 'test'),
        throwsA(isA<NetworkError>()),
      );
    });
  });

  group('confirm() / editAndSave()', () {
    test('confirm posts to correct endpoint', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => successResponse({
          'id': 'meal-x',
          'name': 'Tavuk',
          'calories': 300,
          'meal_type': 'lunch',
          'source': 'ai_confirmed',
          'local_day': '2025-04-24',
          'created_at': '2025-04-24T12:00:00Z',
        }),
      );

      await repo.confirm('analysis-1', '2025-04-24', 'lunch');
      verify(() => mockDio.post(
            '/meals/analysis-1/confirm',
            data: {'local_day': '2025-04-24', 'meal_type': 'lunch'},
          )).called(1);
    });
  });

  group('listMeals()', () {
    test('parses empty list', () async {
      when(() => mockDio.get(any(),
          queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {'data': [], 'error': null},
        ),
      );

      final meals = await repo.listMeals('2025-04-24');
      expect(meals, isEmpty);
    });

    test('parses multiple meals', () async {
      when(() => mockDio.get(any(),
          queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'data': [
              {
                'id': 'm1',
                'name': 'Kahvaltı',
                'calories': 400,
                'meal_type': 'breakfast',
                'source': 'manual',
                'local_day': '2025-04-24',
                'created_at': '2025-04-24T08:00:00Z',
              },
              {
                'id': 'm2',
                'name': 'Öğle',
                'calories': 550,
                'meal_type': 'lunch',
                'source': 'ai_confirmed',
                'local_day': '2025-04-24',
                'created_at': '2025-04-24T13:00:00Z',
              },
            ],
            'error': null,
          },
        ),
      );

      final meals = await repo.listMeals('2025-04-24');
      expect(meals, hasLength(2));
      expect(meals[0].name, 'Kahvaltı');
      expect(meals[1].calories, 550);
    });
  });
}
