// Pure unit tests for MoodBubbleLogic situation detection. No widget tree,
// no network — every branch of meal/water/streak detection.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/coach/mood/models/mood_situation.dart';
import 'package:nuveli/features/coach/mood/providers/mood_bubble_controller.dart';

void main() {
  group('MoodBubbleLogic.mealSituation', () {
    test('first meal of the day → firstMeal regardless of calories', () {
      final s = MoodBubbleLogic.mealSituation(
        caloriesConsumed: 1800,
        caloriesTarget: 2000,
        mealsLoggedBefore: 0,
      );
      expect(s, MoodSituation.firstMeal);
    });

    test('well under target (later meal) → mealUnder', () {
      final s = MoodBubbleLogic.mealSituation(
        caloriesConsumed: 1000, // 0.5 of target
        caloriesTarget: 2000,
        mealsLoggedBefore: 1,
      );
      expect(s, MoodSituation.mealUnder);
    });

    test('near target → mealOnTrack', () {
      final s = MoodBubbleLogic.mealSituation(
        caloriesConsumed: 1900, // 0.95 of target
        caloriesTarget: 2000,
        mealsLoggedBefore: 2,
      );
      expect(s, MoodSituation.mealOnTrack);
    });

    test('over target beyond slack → mealOver', () {
      final s = MoodBubbleLogic.mealSituation(
        caloriesConsumed: 2200, // 1.1 of target
        caloriesTarget: 2000,
        mealsLoggedBefore: 3,
      );
      expect(s, MoodSituation.mealOver);
    });

    test('exactly at target stays on-track (5% slack, not over)', () {
      final s = MoodBubbleLogic.mealSituation(
        caloriesConsumed: 2000,
        caloriesTarget: 2000,
        mealsLoggedBefore: 1,
      );
      expect(s, MoodSituation.mealOnTrack);
    });

    test('missing target falls back to on-track, never over/under', () {
      final s = MoodBubbleLogic.mealSituation(
        caloriesConsumed: 500,
        caloriesTarget: 0,
        mealsLoggedBefore: 1,
      );
      expect(s, MoodSituation.mealOnTrack);
    });

    test('negative mealsLoggedBefore treated as first meal', () {
      final s = MoodBubbleLogic.mealSituation(
        caloriesConsumed: 500,
        caloriesTarget: 2000,
        mealsLoggedBefore: -1,
      );
      expect(s, MoodSituation.firstMeal);
    });
  });

  group('MoodBubbleLogic.isWaterLow', () {
    test('behind target after the cutoff hour → true', () {
      expect(
        MoodBubbleLogic.isWaterLow(totalMl: 500, targetMl: 2500, hourOfDay: 15),
        isTrue,
      );
    });

    test('behind target but still morning → false (day can catch up)', () {
      expect(
        MoodBubbleLogic.isWaterLow(totalMl: 500, targetMl: 2500, hourOfDay: 9),
        isFalse,
      );
    });

    test('on pace after cutoff → false', () {
      expect(
        MoodBubbleLogic.isWaterLow(totalMl: 2000, targetMl: 2500, hourOfDay: 18),
        isFalse,
      );
    });

    test('zero target never nudges', () {
      expect(
        MoodBubbleLogic.isWaterLow(totalMl: 0, targetMl: 0, hourOfDay: 20),
        isFalse,
      );
    });
  });

  group('MoodBubbleLogic.isStreakMilestone', () {
    test('known milestones fire', () {
      for (final d in [3, 7, 14, 21, 30, 50, 100, 365]) {
        expect(MoodBubbleLogic.isStreakMilestone(d), isTrue, reason: 'day $d');
      }
    });

    test('non-milestone days do not fire', () {
      for (final d in [0, 1, 2, 4, 8, 31, 99]) {
        expect(MoodBubbleLogic.isStreakMilestone(d), isFalse, reason: 'day $d');
      }
    });
  });
}
