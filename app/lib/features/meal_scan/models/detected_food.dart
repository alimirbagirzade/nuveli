import 'package:flutter/material.dart';

/// Tek bir tespit edilen yemek (örn: "Grilled Chicken Breast 150g — 250 kcal")
class DetectedFood {
  final String name;
  final String portion; // "150g", "1/2 cup", "1 cup"
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final IconData icon; // fallback icon (thumbnail için)

  const DetectedFood({
    required this.name,
    required this.portion,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.icon = Icons.restaurant,
  });

  factory DetectedFood.fromJson(Map<String, dynamic> json) {
    return DetectedFood(
      name: json['name'] as String,
      portion: json['portion'] as String,
      calories: (json['calories'] as num).toInt(),
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'portion': portion,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
      };
}
