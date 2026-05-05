/// Meal domain modelleri. Freezed yerine basit sınıflar (MVP için yeterli).
library;

class MealLog {
  final String id;
  final String name;
  final int calories;
  final double? proteinG;
  final double? carbG;
  final double? fatG;
  final String mealType; // breakfast | lunch | dinner | snack
  final String source;   // ai_confirmed | ai_edited | manual
  final String localDay;
  final DateTime createdAt;

  const MealLog({
    required this.id,
    required this.name,
    required this.calories,
    required this.mealType,
    required this.source,
    required this.localDay,
    required this.createdAt,
    this.proteinG,
    this.carbG,
    this.fatG,
  });

  factory MealLog.fromJson(Map<String, dynamic> j) => MealLog(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        calories: (j['calories'] as num?)?.toInt() ?? 0,
        proteinG: (j['protein_g'] as num?)?.toDouble(),
        carbG: (j['carb_g'] as num?)?.toDouble(),
        fatG: (j['fat_g'] as num?)?.toDouble(),
        mealType: j['meal_type'] as String? ?? 'snack',
        source: j['source'] as String? ?? 'manual',
        localDay: j['local_day'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class MealAnalysisResult {
  final String? analysisId;
  final String confidence; // high | medium | low | failed
  final String? suggestedName;
  final int? suggestedCalories;
  final double? suggestedProteinG;
  final double? suggestedCarbG;
  final double? suggestedFatG;

  const MealAnalysisResult({
    required this.confidence,
    this.analysisId,
    this.suggestedName,
    this.suggestedCalories,
    this.suggestedProteinG,
    this.suggestedCarbG,
    this.suggestedFatG,
  });

  factory MealAnalysisResult.fromJson(Map<String, dynamic> j) {
    final suggestion = (j['suggestion'] as Map?)?.cast<String, dynamic>() ?? {};
    return MealAnalysisResult(
      analysisId: j['analysis_id'] as String?,
      confidence: j['confidence'] as String? ?? 'failed',
      suggestedName: suggestion['name'] as String?,
      suggestedCalories: (suggestion['calories'] as num?)?.toInt(),
      suggestedProteinG: (suggestion['protein_g'] as num?)?.toDouble(),
      suggestedCarbG: (suggestion['carb_g'] as num?)?.toDouble(),
      suggestedFatG: (suggestion['fat_g'] as num?)?.toDouble(),
    );
  }

  bool get isLowConfidence => confidence == 'low' || confidence == 'failed';
}
