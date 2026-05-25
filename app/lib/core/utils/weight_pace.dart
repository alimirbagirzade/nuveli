/// Evaluates whether a weight goal's timeframe implies a healthy, sustainable
/// rate of change — a wellness guard, NOT medical advice.
///
/// Safe rates (general, non-clinical guidance):
///   • lose: up to ~1.0 kg/week
///   • gain: up to ~0.5 kg/week (steadier = leaner)
///   • maintain: no rate to evaluate
///
/// The UI uses this to gently warn on an over-aggressive timeframe and offer a
/// more sustainable date. It never blocks the user and never frames things as
/// compensation or failure (see docs/protocols/safety-wellness-boundary.md).
library;

import 'dart:math' as math;

enum PaceVerdict {
  /// Timeframe implies a sustainable rate.
  healthy,

  /// Timeframe is too short for the weight change → suggest a longer one.
  aggressive,

  /// Not enough info, or maintain goal — show nothing.
  none,
}

class WeightPace {
  const WeightPace({
    required this.kgPerWeek,
    required this.verdict,
    required this.suggestedWeeks,
  });

  /// Implied rate for the chosen timeframe (0 when no date chosen yet).
  final double kgPerWeek;
  final PaceVerdict verdict;

  /// Minimum number of weeks for a healthy pace toward this target.
  final int suggestedWeeks;

  static const double maxLosePerWeek = 1.0;
  static const double maxGainPerWeek = 0.5;

  /// `direction` is "lose" | "gain" | "maintain".
  static WeightPace? evaluate({
    required double startKg,
    required double targetKg,
    required String direction,
    DateTime? targetDate,
    DateTime? now,
  }) {
    if (direction == 'maintain') return null;

    final delta = (startKg - targetKg).abs();
    if (delta < 0.1) return null; // no meaningful change

    final maxRate = direction == 'gain' ? maxGainPerWeek : maxLosePerWeek;
    final suggestedWeeks = math.max(1, (delta / maxRate).ceil());

    if (targetDate == null) {
      return WeightPace(
        kgPerWeek: 0,
        verdict: PaceVerdict.none,
        suggestedWeeks: suggestedWeeks,
      );
    }

    final days = targetDate.difference(now ?? DateTime.now()).inDays;
    if (days <= 0) {
      return WeightPace(
        kgPerWeek: double.infinity,
        verdict: PaceVerdict.aggressive,
        suggestedWeeks: suggestedWeeks,
      );
    }

    final rate = delta / (days / 7.0);
    return WeightPace(
      kgPerWeek: rate,
      verdict: rate > maxRate ? PaceVerdict.aggressive : PaceVerdict.healthy,
      suggestedWeeks: suggestedWeeks,
    );
  }

  /// A date that yields a healthy pace from [from] (defaults to now).
  DateTime suggestedDate([DateTime? from]) =>
      (from ?? DateTime.now()).add(Duration(days: suggestedWeeks * 7));
}
