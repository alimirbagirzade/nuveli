import 'package:flutter/material.dart';

import '../models/detected_food.dart';
import '../models/portion_insight.dart';
import '../models/scan_result.dart';

/// Görsel 2 birebir mock: 250 + 120 + 150 = 520 kcal, %85 skor.
ScanResult buildMockScanResult() {
  return ScanResult(
    foods: const [
      DetectedFood(
        name: 'Grilled Chicken Breast',
        portion: '150g',
        calories: 250,
        proteinG: 46,
        carbsG: 0,
        fatG: 5.5,
        icon: Icons.set_meal,
      ),
      DetectedFood(
        name: 'Quinoa',
        portion: '1/2 cup',
        calories: 120,
        proteinG: 4,
        carbsG: 22,
        fatG: 2,
        icon: Icons.grain,
      ),
      DetectedFood(
        name: 'Steamed Vegetables',
        portion: '1 cup',
        calories: 150,
        proteinG: 5,
        carbsG: 30,
        fatG: 1,
        icon: Icons.eco,
      ),
    ],
    totalCalories: 520,
    portionInsight: const PortionInsight(
      score: 85,
      mainText: 'Great portion!',
      highlights: ['High in protein', 'Balanced meal'],
    ),
    scannedAt: DateTime.now(),
  );
}
