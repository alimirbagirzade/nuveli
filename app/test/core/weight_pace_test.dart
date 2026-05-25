import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/utils/weight_pace.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  group('WeightPace.evaluate', () {
    test('maintain → null (no rate to evaluate)', () {
      expect(
        WeightPace.evaluate(
            startKg: 80, targetKg: 80, direction: 'maintain', now: now),
        isNull,
      );
    });

    test('no meaningful delta → null', () {
      expect(
        WeightPace.evaluate(
            startKg: 80, targetKg: 80.05, direction: 'lose', now: now),
        isNull,
      );
    });

    test('no date yet → verdict none but suggests min weeks (lose)', () {
      // 10 kg / 1.0 kg-wk = 10 weeks minimum.
      final p = WeightPace.evaluate(
          startKg: 90, targetKg: 80, direction: 'lose', now: now)!;
      expect(p.verdict, PaceVerdict.none);
      expect(p.suggestedWeeks, 10);
    });

    test('aggressive lose: 10kg in 4 weeks → 2.5 kg/wk, flagged', () {
      final p = WeightPace.evaluate(
        startKg: 90,
        targetKg: 80,
        direction: 'lose',
        targetDate: now.add(const Duration(days: 28)),
        now: now,
      )!;
      expect(p.kgPerWeek, closeTo(2.5, 0.01));
      expect(p.verdict, PaceVerdict.aggressive);
      expect(p.suggestedWeeks, 10);
    });

    test('healthy lose: 5kg in 8 weeks → 0.625 kg/wk, ok', () {
      final p = WeightPace.evaluate(
        startKg: 85,
        targetKg: 80,
        direction: 'lose',
        targetDate: now.add(const Duration(days: 56)),
        now: now,
      )!;
      expect(p.verdict, PaceVerdict.healthy);
    });

    test('gain uses a slower safe rate (0.5 kg/wk)', () {
      // 5kg in 8 weeks = 0.625 kg/wk → too fast for GAIN (max 0.5).
      final p = WeightPace.evaluate(
        startKg: 70,
        targetKg: 75,
        direction: 'gain',
        targetDate: now.add(const Duration(days: 56)),
        now: now,
      )!;
      expect(p.verdict, PaceVerdict.aggressive);
      expect(p.suggestedWeeks, 10); // 5 / 0.5
    });

    test('past/zero date → aggressive', () {
      final p = WeightPace.evaluate(
        startKg: 90,
        targetKg: 80,
        direction: 'lose',
        targetDate: now,
        now: now,
      )!;
      expect(p.verdict, PaceVerdict.aggressive);
    });

    test('suggestedDate yields a healthy pace', () {
      final p = WeightPace.evaluate(
          startKg: 90, targetKg: 80, direction: 'lose', now: now)!;
      final d = p.suggestedDate(now);
      final recheck = WeightPace.evaluate(
        startKg: 90,
        targetKg: 80,
        direction: 'lose',
        targetDate: d,
        now: now,
      )!;
      expect(recheck.verdict, PaceVerdict.healthy);
    });
  });
}
