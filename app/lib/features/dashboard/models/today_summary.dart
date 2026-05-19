/// Mirrors the `GET /meals/today/summary` response from the Nuveli backend.
///
/// This is the single source of truth for the Dashboard — calories, macros,
/// water, and meal count all come from one call.
class TodaySummary {
  final int consumedCalories;
  final int dailyCalorieTarget;

  final double consumedProteinG;
  final double dailyProteinTargetG;
  final double consumedCarbsG;
  final double dailyCarbsTargetG;
  final double consumedFatG;
  final double dailyFatTargetG;

  final int consumedWaterMl;
  final int dailyWaterTargetMl;

  final int mealCountToday;
  final int remainingCalories;
  final double percentComplete;

  const TodaySummary({
    required this.consumedCalories,
    required this.dailyCalorieTarget,
    required this.consumedProteinG,
    required this.dailyProteinTargetG,
    required this.consumedCarbsG,
    required this.dailyCarbsTargetG,
    required this.consumedFatG,
    required this.dailyFatTargetG,
    required this.consumedWaterMl,
    required this.dailyWaterTargetMl,
    required this.mealCountToday,
    required this.remainingCalories,
    required this.percentComplete,
  });

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    return TodaySummary(
      consumedCalories: _asInt(json['consumed_calories']),
      dailyCalorieTarget: _asInt(json['daily_calorie_target'], fallback: 2000),
      consumedProteinG: _asDouble(json['consumed_protein_g']),
      dailyProteinTargetG: _asDouble(json['daily_protein_target_g'], fallback: 150),
      consumedCarbsG: _asDouble(json['consumed_carbs_g']),
      dailyCarbsTargetG: _asDouble(json['daily_carbs_target_g'], fallback: 250),
      consumedFatG: _asDouble(json['consumed_fat_g']),
      dailyFatTargetG: _asDouble(json['daily_fat_target_g'], fallback: 65),
      consumedWaterMl: _asInt(json['consumed_water_ml']),
      dailyWaterTargetMl: _asInt(json['daily_water_target_ml'], fallback: 2500),
      mealCountToday: _asInt(json['meal_count_today']),
      remainingCalories: _asInt(json['remaining_calories']),
      percentComplete: _asDouble(json['percent_complete']),
    );
  }

  /// Empty summary for first-render / error fallback.
  factory TodaySummary.empty() => const TodaySummary(
        consumedCalories: 0,
        dailyCalorieTarget: 2000,
        consumedProteinG: 0,
        dailyProteinTargetG: 150,
        consumedCarbsG: 0,
        dailyCarbsTargetG: 250,
        consumedFatG: 0,
        dailyFatTargetG: 65,
        consumedWaterMl: 0,
        dailyWaterTargetMl: 2500,
        mealCountToday: 0,
        remainingCalories: 2000,
        percentComplete: 0,
      );

  // ---- Derived helpers ----

  double get proteinPercent => dailyProteinTargetG > 0
      ? (consumedProteinG / dailyProteinTargetG * 100).clamp(0, 999).toDouble()
      : 0;

  double get carbsPercent => dailyCarbsTargetG > 0
      ? (consumedCarbsG / dailyCarbsTargetG * 100).clamp(0, 999).toDouble()
      : 0;

  double get fatPercent => dailyFatTargetG > 0
      ? (consumedFatG / dailyFatTargetG * 100).clamp(0, 999).toDouble()
      : 0;

  int get waterGlasses => (consumedWaterMl / 250).floor();
  int get waterGlassesTarget => (dailyWaterTargetMl / 250).ceil();

  // ---- Safe parsers ----

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static double _asDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }
}
