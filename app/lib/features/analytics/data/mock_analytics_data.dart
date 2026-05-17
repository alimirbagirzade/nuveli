import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/features/analytics/models/analytics_data.dart';

/// Görsel 4 (Analytics mockup) ile birebir uyumlu mock data.
///
/// Uyum kontrolü:
/// - Weight: 72.6 → 69.1, change ↓3.5 kg
/// - Macros: 95g protein / 160g carbs / 48g fat
///   → (95*4)+(160*4)+(48*9) = 380+640+432 = 1452 kcal (~1480)
/// - Yüzdeler: 26% / 44% / 30% (mockup'ta 26/43/29 — yuvarlama farkı normal)
/// - Weekly: 1620/1480/1550/1430/1670/1390/1450 — avg 1,513 (~1,508)
final AnalyticsData mockAnalyticsData = AnalyticsData(
  // 8 haftalık kilo trendi (azalan pattern)
  weightTrend: [
    WeightDataPoint(date: DateTime(2026, 3, 22), weight: 72.6),
    WeightDataPoint(date: DateTime(2026, 3, 29), weight: 72.3),
    WeightDataPoint(date: DateTime(2026, 4, 5),  weight: 71.8),
    WeightDataPoint(date: DateTime(2026, 4, 12), weight: 71.4),
    WeightDataPoint(date: DateTime(2026, 4, 19), weight: 70.9),
    WeightDataPoint(date: DateTime(2026, 4, 26), weight: 70.5),
    WeightDataPoint(date: DateTime(2026, 5, 3),  weight: 69.8),
    WeightDataPoint(date: DateTime(2026, 5, 10), weight: 69.1),
  ],

  macroBreakdown: const MacroBreakdown(
    proteinG: 95,
    carbsG: 160,
    fatG: 48,
  ),

  weeklyCalories: const WeeklyCaloriesData(
    dailyCalories: [1620, 1480, 1550, 1430, 1670, 1390, 1450],
    dayLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    averageCalories: 1508,
  ),

  achievements: [
    Achievement(
      id: 'streak_7d',
      icon: Icons.local_fire_department,
      color: AppColors.streakOrange,
      title: '7 Day Streak',
      subtitle: 'Keep it up!',
    ),
    Achievement(
      id: 'cal_goal',
      icon: Icons.gps_fixed,
      color: AppColors.primaryCyan,
      title: 'Calorie Goal',
      subtitle: '5/7 days',
    ),
    Achievement(
      id: 'weight_lost',
      icon: Icons.scale,
      color: AppColors.primaryCyan,
      title: '3.5 kg Lost',
      subtitle: 'Great progress!',
    ),
  ],
);
