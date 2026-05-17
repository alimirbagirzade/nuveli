import 'package:flutter/material.dart';

/// Tüm analytics ekranının veri modeli.
class AnalyticsData {
  final List<WeightDataPoint> weightTrend;
  final MacroBreakdown macroBreakdown;
  final WeeklyCaloriesData weeklyCalories;
  final List<Achievement> achievements;

  const AnalyticsData({
    required this.weightTrend,
    required this.macroBreakdown,
    required this.weeklyCalories,
    required this.achievements,
  });
}

/// Kilo trendi için tek bir veri noktası.
class WeightDataPoint {
  final DateTime date;
  final double weight;

  const WeightDataPoint({
    required this.date,
    required this.weight,
  });
}

/// Günlük makro dağılımı (gram cinsinden).
class MacroBreakdown {
  final double proteinG;
  final double carbsG;
  final double fatG;

  const MacroBreakdown({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  /// Protein kalorisi (1g = 4 kcal).
  double get proteinKcal => proteinG * 4;

  /// Karbonhidrat kalorisi (1g = 4 kcal).
  double get carbsKcal => carbsG * 4;

  /// Yağ kalorisi (1g = 9 kcal).
  double get fatKcal => fatG * 9;

  /// Toplam kalori.
  double get totalKcal => proteinKcal + carbsKcal + fatKcal;

  /// Yüzdelikler (toplamı 100'e yakın olur, küçük yuvarlama farkı olabilir).
  int get proteinPercent =>
      totalKcal == 0 ? 0 : ((proteinKcal / totalKcal) * 100).round();
  int get carbsPercent =>
      totalKcal == 0 ? 0 : ((carbsKcal / totalKcal) * 100).round();
  int get fatPercent =>
      totalKcal == 0 ? 0 : ((fatKcal / totalKcal) * 100).round();
}

/// Haftalık kalori verisi (7 gün).
class WeeklyCaloriesData {
  final List<double> dailyCalories;
  final List<String> dayLabels;
  final double averageCalories;

  const WeeklyCaloriesData({
    required this.dailyCalories,
    required this.dayLabels,
    required this.averageCalories,
  });
}

/// Tek bir başarım/achievement rozeti.
class Achievement {
  final String id;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.isUnlocked = true,
  });
}
