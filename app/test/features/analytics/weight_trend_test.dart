import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/analytics/models/weight_trend.dart';

void main() {
  group('WeightTrendPoint.fromJson', () {
    test('parses standard backend shape', () {
      final p = WeightTrendPoint.fromJson({
        'date': '2026-05-23',
        'weight_kg': 75.5,
        'moving_avg_kg': 75.7,
      });
      expect(p.weightKg, equals(75.5));
      expect(p.movingAvgKg, equals(75.7));
    });
  });

  group('WeightTrend aggregates', () {
    test('hasData false on empty points', () {
      const t = WeightTrend(
        points: [],
        periodDays: 56,
        startWeight: null,
        currentWeight: null,
        deltaKg: null,
      );
      expect(t.hasData, isFalse);
    });

    test('minWeight/maxWeight compute over points', () {
      final t = WeightTrend(
        periodDays: 56,
        startWeight: 80,
        currentWeight: 75,
        deltaKg: -5,
        points: [
          WeightTrendPoint(
            date: DateTime.parse('2026-04-01'),
            weightKg: 80,
            movingAvgKg: 80,
          ),
          WeightTrendPoint(
            date: DateTime.parse('2026-04-15'),
            weightKg: 78,
            movingAvgKg: 79,
          ),
          WeightTrendPoint(
            date: DateTime.parse('2026-05-01'),
            weightKg: 75,
            movingAvgKg: 76,
          ),
        ],
      );
      expect(t.minWeight, equals(75.0));
      expect(t.maxWeight, equals(80.0));
    });
  });

  group('WeightTrend.fromJson', () {
    test('handles missing optional fields', () {
      final t = WeightTrend.fromJson(const {
        'points': [],
        'period_days': 56,
      });
      expect(t.points, isEmpty);
      expect(t.startWeight, isNull);
      expect(t.deltaKg, isNull);
    });
  });
}
