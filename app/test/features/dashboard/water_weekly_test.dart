import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/dashboard/models/water_weekly.dart';

void main() {
  group('WaterDayTotal.fromJson', () {
    test('parses standard backend shape', () {
      final d = WaterDayTotal.fromJson({
        'day': '2026-05-23',
        'total_ml': 1500,
        'target_ml': 2500,
      });
      expect(d.day, equals(DateTime.parse('2026-05-23')));
      expect(d.totalMl, equals(1500));
      expect(d.targetMl, equals(2500));
    });

    test('defaults missing target_ml to 2500', () {
      final d = WaterDayTotal.fromJson({
        'day': '2026-05-23',
        'total_ml': 1000,
      });
      expect(d.targetMl, equals(2500));
    });

    test('handles datetime strings (takes first 10 chars)', () {
      final d = WaterDayTotal.fromJson({
        'day': '2026-05-23T00:00:00Z',
        'total_ml': 0,
        'target_ml': 2500,
      });
      expect(d.day, equals(DateTime.parse('2026-05-23')));
    });
  });

  group('fractionOfTarget', () {
    test('clamps over-drink to 1.0', () {
      const d = WaterDayTotal(
        day: _today,
        totalMl: 5000,
        targetMl: 2500,
      );
      expect(d.fractionOfTarget, equals(1.0));
    });

    test('returns zero when nothing logged', () {
      const d = WaterDayTotal(
        day: _today,
        totalMl: 0,
        targetMl: 2500,
      );
      expect(d.fractionOfTarget, equals(0.0));
    });

    test('returns 0 when target is zero (no div-by-zero)', () {
      const d = WaterDayTotal(
        day: _today,
        totalMl: 100,
        targetMl: 0,
      );
      expect(d.fractionOfTarget, equals(0.0));
    });

    test('linear in between', () {
      const d = WaterDayTotal(
        day: _today,
        totalMl: 1250,
        targetMl: 2500,
      );
      expect(d.fractionOfTarget, equals(0.5));
    });
  });

  group('WaterWeekly aggregates', () {
    test('totalConsumedMl sums all days', () {
      final w = WaterWeekly(
        targetMl: 2500,
        days: const [
          WaterDayTotal(day: _today, totalMl: 1000, targetMl: 2500),
          WaterDayTotal(day: _today, totalMl: 2500, targetMl: 2500),
          WaterDayTotal(day: _today, totalMl: 500, targetMl: 2500),
        ],
      );
      expect(w.totalConsumedMl, equals(4000));
    });

    test('daysHittingTarget counts days >= target', () {
      final w = WaterWeekly(
        targetMl: 2500,
        days: const [
          WaterDayTotal(day: _today, totalMl: 2500, targetMl: 2500),
          WaterDayTotal(day: _today, totalMl: 3000, targetMl: 2500),
          WaterDayTotal(day: _today, totalMl: 1000, targetMl: 2500),
          WaterDayTotal(day: _today, totalMl: 2499, targetMl: 2500),
        ],
      );
      expect(w.daysHittingTarget, equals(2));
    });

    test('daysHittingTarget ignores zero-target rows', () {
      final w = WaterWeekly(
        targetMl: 2500,
        days: const [
          WaterDayTotal(day: _today, totalMl: 0, targetMl: 0),
          WaterDayTotal(day: _today, totalMl: 1000, targetMl: 0),
          WaterDayTotal(day: _today, totalMl: 2500, targetMl: 2500),
        ],
      );
      expect(w.daysHittingTarget, equals(1));
    });
  });
}

const _today = _NowDate();

class _NowDate implements DateTime {
  const _NowDate();
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
