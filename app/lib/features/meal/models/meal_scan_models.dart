/// Models mirroring `MealScanResponse` from `backend/models/meal.py`.
///
/// `POST /meals/scan` returns:
///   {
///     foods: [{name, portion, grams?, calories, protein_g, carbs_g, fat_g}],
///     total_calories, total_protein_g, total_carbs_g, total_fat_g,
///     portion_insight: {score, main_text, highlights[]},
///     suggested_meal_type?: 'breakfast'|'lunch'|'dinner'|'snack',
///   }
class DetectedFood {
  final String name;
  final String portion;
  final double? grams;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const DetectedFood({
    required this.name,
    required this.portion,
    this.grams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory DetectedFood.fromJson(Map<String, dynamic> json) => DetectedFood(
        name: json['name']?.toString() ?? 'Food',
        portion: json['portion']?.toString() ?? '',
        grams: _asDoubleOrNull(json['grams']),
        calories: _asInt(json['calories']),
        proteinG: _asDouble(json['protein_g']),
        carbsG: _asDouble(json['carbs_g']),
        fatG: _asDouble(json['fat_g']),
      );

  /// Multiply all numbers by [factor] (used by whole-meal scale slider).
  DetectedFood scaledBy(double factor) => DetectedFood(
        name: name,
        portion: portion,
        grams: grams == null ? null : grams! * factor,
        calories: (calories * factor).round(),
        proteinG: _round1(proteinG * factor),
        carbsG: _round1(carbsG * factor),
        fatG: _round1(fatG * factor),
      );

  DetectedFood copyWith({
    String? name,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) =>
      DetectedFood(
        name: name ?? this.name,
        portion: portion,
        grams: grams,
        calories: calories ?? this.calories,
        proteinG: proteinG ?? this.proteinG,
        carbsG: carbsG ?? this.carbsG,
        fatG: fatG ?? this.fatG,
      );

  /// Payload for `POST /meals` foods array.
  Map<String, dynamic> toCreatePayload(int position) => {
        'name': name,
        if (portion.isNotEmpty) 'portion': portion,
        if (grams != null) 'grams': grams,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'position': position,
      };
}

class PortionInsight {
  /// 0-100; AI's confidence that the portion estimate is accurate.
  final int score;
  final String mainText;
  final List<String> highlights;

  const PortionInsight({
    required this.score,
    required this.mainText,
    this.highlights = const [],
  });

  factory PortionInsight.fromJson(Map<String, dynamic> json) => PortionInsight(
        score: _asInt(json['score']),
        mainText: json['main_text']?.toString() ?? '',
        highlights: (json['highlights'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
      );
}

class MealScanResult {
  final List<DetectedFood> foods;
  final int totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final PortionInsight portionInsight;
  final String? suggestedMealType;

  const MealScanResult({
    required this.foods,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.portionInsight,
    this.suggestedMealType,
  });

  /// True when AI returned no foods — picture wasn't food (or detection
  /// failed). `portion_insight.main_text` carries the explanation.
  bool get isNotFood => foods.isEmpty;

  factory MealScanResult.fromJson(Map<String, dynamic> json) {
    final foodsRaw = json['foods'] as List<dynamic>? ?? const [];
    final foods = foodsRaw
        .whereType<Map<String, dynamic>>()
        .map(DetectedFood.fromJson)
        .toList(growable: false);
    return MealScanResult(
      foods: foods,
      totalCalories: _asInt(json['total_calories']),
      totalProteinG: _asDouble(json['total_protein_g']),
      totalCarbsG: _asDouble(json['total_carbs_g']),
      totalFatG: _asDouble(json['total_fat_g']),
      portionInsight: json['portion_insight'] is Map<String, dynamic>
          ? PortionInsight.fromJson(json['portion_insight'] as Map<String, dynamic>)
          : const PortionInsight(score: 0, mainText: ''),
      suggestedMealType: json['suggested_meal_type']?.toString(),
    );
  }
}

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

double _asDouble(dynamic v, {double fallback = 0}) {
  if (v == null) return fallback;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

double? _asDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

double _round1(double v) => (v * 10).round() / 10;
