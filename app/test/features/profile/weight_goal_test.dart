import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/profile/models/weight_goal.dart';

WeightGoal _build({
  double startingWeightKg = 90,
  double targetKg = 75,
  WeightGoalDirection direction = WeightGoalDirection.lose,
  DateTime? targetDate,
}) {
  return WeightGoal(
    id: 'goal-1',
    userId: 'user-1',
    targetKg: targetKg,
    targetDate: targetDate,
    direction: direction,
    startingWeightKg: startingWeightKg,
    status: WeightGoalStatus.active,
    createdAt: DateTime(2026, 1, 1),
    progressPercent: 50,
    weeklyChangeKg: -0.5,
  );
}

void main() {
  group('WeightGoal.fromJson', () {
    test('parses a minimal active goal', () {
      final goal = WeightGoal.fromJson({
        'id': 'g-1',
        'user_id': 'u-1',
        'target_kg': 70,
        'target_date': '2026-12-31',
        'direction': 'lose',
        'starting_weight_kg': 85,
        'status': 'active',
        'created_at': '2026-01-01T00:00:00Z',
        'progress_percent': 25,
      });
      expect(goal.targetKg, equals(70.0));
      expect(goal.startingWeightKg, equals(85.0));
      expect(goal.direction, equals(WeightGoalDirection.lose));
      expect(goal.status, equals(WeightGoalStatus.active));
      expect(goal.targetDate, equals(DateTime.parse('2026-12-31')));
    });

    test('handles missing optional fields with safe defaults', () {
      final goal = WeightGoal.fromJson({
        'id': 'g-1',
        'user_id': 'u-1',
        'target_kg': 70,
        // target_date omitted
        // direction omitted → defaults to lose
        // starting_weight_kg omitted → defaults to 0
        // status omitted → defaults to active
        // created_at omitted → defaults to now
        // progress_percent omitted → defaults to 0
      });
      expect(goal.targetDate, isNull);
      expect(goal.direction, equals(WeightGoalDirection.lose));
      expect(goal.startingWeightKg, equals(0.0));
      expect(goal.status, equals(WeightGoalStatus.active));
      expect(goal.progressPercent, equals(0.0));
    });

    test('accepts integer-coded weight from API (num → double)', () {
      final goal = WeightGoal.fromJson({
        'id': 'g-1',
        'user_id': 'u-1',
        'target_kg': 70, // int, not double
        'starting_weight_kg': 85, // int
      });
      expect(goal.targetKg, isA<double>());
      expect(goal.startingWeightKg, isA<double>());
    });
  });

  group('deltaKg', () {
    test('absolute distance — lose direction', () {
      expect(_build(startingWeightKg: 90, targetKg: 75).deltaKg, equals(15.0));
    });

    test('absolute distance — gain direction', () {
      expect(
        _build(
          startingWeightKg: 60,
          targetKg: 70,
          direction: WeightGoalDirection.gain,
        ).deltaKg,
        equals(10.0),
      );
    });

    test('zero delta for maintain direction at same weight', () {
      expect(
        _build(
          startingWeightKg: 75,
          targetKg: 75,
          direction: WeightGoalDirection.maintain,
        ).deltaKg,
        equals(0.0),
      );
    });
  });

  group('daysRemaining', () {
    test('null when target_date is not set', () {
      expect(_build(targetDate: null).daysRemaining, isNull);
    });

    test('returns 0 when target_date is in the past (clamped)', () {
      final past = DateTime.now().subtract(const Duration(days: 30));
      expect(_build(targetDate: past).daysRemaining, equals(0));
    });

    test('returns positive day count for future target_date', () {
      final future = DateTime.now().add(const Duration(days: 60));
      final remaining = _build(targetDate: future).daysRemaining!;
      // Allow off-by-one due to clock ticks during test execution
      expect(remaining, inInclusiveRange(59, 60));
    });
  });

  group('summaryText', () {
    test('lose direction shows "X kg to go"', () {
      expect(_build(startingWeightKg: 90, targetKg: 75).summaryText(),
          equals('15 kg to go'));
    });

    test('gain direction shows "+X kg to gain"', () {
      expect(
        _build(
          startingWeightKg: 60,
          targetKg: 70,
          direction: WeightGoalDirection.gain,
        ).summaryText(),
        equals('+10 kg to gain'),
      );
    });

    test('maintain direction shows "Maintain X kg"', () {
      expect(
        _build(
          targetKg: 75,
          direction: WeightGoalDirection.maintain,
        ).summaryText(),
        equals('Maintain 75 kg'),
      );
    });

    test('fractional delta keeps one decimal', () {
      expect(_build(startingWeightKg: 90, targetKg: 75.5).summaryText(),
          equals('14.5 kg to go'));
    });

    test('integer delta hides decimal (clean UI)', () {
      expect(_build(startingWeightKg: 80, targetKg: 75).summaryText(),
          equals('5 kg to go'));
    });
  });

  group('enum parsing', () {
    test('WeightGoalDirection.fromJson handles all valid values', () {
      expect(WeightGoalDirection.fromJson('lose'),
          equals(WeightGoalDirection.lose));
      expect(WeightGoalDirection.fromJson('gain'),
          equals(WeightGoalDirection.gain));
      expect(WeightGoalDirection.fromJson('maintain'),
          equals(WeightGoalDirection.maintain));
    });

    test('WeightGoalDirection.fromJson defaults to lose on unknown', () {
      expect(WeightGoalDirection.fromJson(null),
          equals(WeightGoalDirection.lose));
      expect(WeightGoalDirection.fromJson('garbage'),
          equals(WeightGoalDirection.lose));
    });

    test('WeightGoalStatus.fromJson handles all valid values', () {
      expect(WeightGoalStatus.fromJson('active'),
          equals(WeightGoalStatus.active));
      expect(WeightGoalStatus.fromJson('achieved'),
          equals(WeightGoalStatus.achieved));
      expect(WeightGoalStatus.fromJson('paused'),
          equals(WeightGoalStatus.paused));
      expect(WeightGoalStatus.fromJson('cancelled'),
          equals(WeightGoalStatus.cancelled));
    });

    test('toJson is reversible', () {
      for (final dir in WeightGoalDirection.values) {
        expect(WeightGoalDirection.fromJson(dir.toJson()), equals(dir));
      }
      for (final status in WeightGoalStatus.values) {
        expect(WeightGoalStatus.fromJson(status.toJson()), equals(status));
      }
    });
  });
}
