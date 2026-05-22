import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/analytics/models/weekly_analytics.dart';

void main() {
  group('WeeklyCalorieDay', () {
    test('withinTarget true when calories are 85%-110% of target', () {
      const a = WeeklyCalorieDay(
        day: _today,
        calories: 1900,
        target: 2000,
        percent: 95,
      );
      expect(a.withinTarget, isTrue);
    });

    test('withinTarget false when below 85%', () {
      const a = WeeklyCalorieDay(
        day: _today,
        calories: 1200,
        target: 2000,
        percent: 60,
      );
      expect(a.withinTarget, isFalse);
    });

    test('withinTarget false when above 110%', () {
      const a = WeeklyCalorieDay(
        day: _today,
        calories: 2500,
        target: 2000,
        percent: 125,
      );
      expect(a.withinTarget, isFalse);
    });

    test('fractionOfTarget clamps at 1.0', () {
      const a = WeeklyCalorieDay(
        day: _today,
        calories: 3000,
        target: 2000,
        percent: 150,
      );
      expect(a.fractionOfTarget, equals(1.0));
    });
  });

  group('MacroPercentages', () {
    test('hasData true when any field positive', () {
      expect(
        const MacroPercentages(protein: 30, carbs: 0, fat: 0).hasData,
        isTrue,
      );
    });

    test('hasData false when all zero', () {
      expect(
        const MacroPercentages(protein: 0, carbs: 0, fat: 0).hasData,
        isFalse,
      );
    });

    test('fromJson defaults', () {
      final m = MacroPercentages.fromJson(const {});
      expect(m.protein, equals(0));
      expect(m.carbs, equals(0));
      expect(m.fat, equals(0));
    });
  });

  group('WeeklyAnalytics.fromJson', () {
    test('parses full shape', () {
      final w = WeeklyAnalytics.fromJson({
        'days': [
          {
            'day': '2026-05-20',
            'calories': 1900,
            'target': 2000,
            'percent': 95,
          },
          {
            'day': '2026-05-21',
            'calories': 0,
            'target': 2000,
            'percent': 0,
          },
        ],
        'avg_daily_calories': 950,
        'avg_macro_breakdown': {
          'protein_percent': 25,
          'carbs_percent': 50,
          'fat_percent': 25,
        },
        'days_within_target': 1,
      });
      expect(w.days, hasLength(2));
      expect(w.avgDailyCalories, equals(950));
      expect(w.avgMacroBreakdown.protein, equals(25));
      expect(w.daysWithinTarget, equals(1));
    });
  });
}

const _today = _Now();

class _Now implements DateTime {
  const _Now();
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
