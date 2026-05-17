import 'detected_food.dart';
import 'portion_insight.dart';

/// Tüm scan sonucu — backend response'unun Dart karşılığı
class ScanResult {
  final List<DetectedFood> foods;
  final int totalCalories;
  final PortionInsight portionInsight;
  final DateTime scannedAt;

  const ScanResult({
    required this.foods,
    required this.totalCalories,
    required this.portionInsight,
    required this.scannedAt,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      foods: (json['foods'] as List<dynamic>)
          .map((e) => DetectedFood.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCalories: (json['total_calories'] as num).toInt(),
      portionInsight: PortionInsight.fromJson(
        json['portion_insight'] as Map<String, dynamic>,
      ),
      scannedAt: json['scanned_at'] != null
          ? DateTime.parse(json['scanned_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'foods': foods.map((f) => f.toJson()).toList(),
        'total_calories': totalCalories,
        'portion_insight': portionInsight.toJson(),
        'scanned_at': scannedAt.toIso8601String(),
      };
}
