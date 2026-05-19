/// Server-computed daily aggregate consumed by the dashboard ring +
/// macro bars. Backend endpoint: `GET /meals/today/summary`.
///
/// Both consumed and target sides are returned by the backend so the
/// client does no math itself (single source of truth, no drift).
class TodaySummary {
  const TodaySummary({
    required this.consumedCalories,
    required this.targetCalories,
    required this.consumedProteinG,
    required this.targetProteinG,
    required this.consumedCarbsG,
    required this.targetCarbsG,
    required this.consumedFatG,
    required this.targetFatG,
  });

  final double consumedCalories;
  final double targetCalories;

  final double consumedProteinG;
  final double targetProteinG;

  final double consumedCarbsG;
  final double targetCarbsG;

  final double consumedFatG;
  final double targetFatG;

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    double n(String key) => (json[key] as num?)?.toDouble() ?? 0.0;
    return TodaySummary(
      consumedCalories: n('consumed_calories'),
      targetCalories: n('target_calories'),
      consumedProteinG: n('consumed_protein_g'),
      targetProteinG: n('target_protein_g'),
      consumedCarbsG: n('consumed_carbs_g'),
      targetCarbsG: n('target_carbs_g'),
      consumedFatG: n('consumed_fat_g'),
      targetFatG: n('target_fat_g'),
    );
  }
}
