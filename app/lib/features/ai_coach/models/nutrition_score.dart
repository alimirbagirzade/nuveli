/// Score breakdown matches the backend algorithm:
/// calorieAdherence (0-40) + macroBalance (0-30) + hydration (0-15) + habits (0-15) = 100
class ScoreBreakdown {
  final int calorieAdherence;
  final int macroBalance;
  final int hydration;
  final int habitsCompletion;

  const ScoreBreakdown({
    required this.calorieAdherence,
    required this.macroBalance,
    required this.hydration,
    required this.habitsCompletion,
  });

  int get total => calorieAdherence + macroBalance + hydration + habitsCompletion;
}

class NutritionScore {
  final int value; // 0-100
  final String label;
  final ScoreBreakdown breakdown;

  const NutritionScore({
    required this.value,
    required this.label,
    required this.breakdown,
  });

  /// Score → label mapping (mirrors backend `_label_for` in Chat 11b).
  static String labelFor(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Great';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs work';
  }
}

/// Today's macros, shown as a 4-cell mini summary row.
class TodaysMacros {
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  const TodaysMacros({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
}
