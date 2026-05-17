import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/recommendation.dart';
import '../models/user_goals.dart';

/// Mock data for the Goals & Profile screen.
///
/// Values are pulled directly from the App Store mockup (Görsel 3) so the
/// rendered UI is a 1:1 visual replica during the mock-driven phase.
/// Replace this with a Supabase-backed repository in Chat 13 / 15.
final UserGoals mockUserGoals = UserGoals(
  dailyCalorieTarget: 2100,
  todayProgressPercent: 0.70,
  weightGoal: WeightGoal(
    targetChangeKg: -5.0,
    targetDate: DateTime(2025, 7, 20),
    currentProgressKg: 1.8, // 5.0 - 1.8 = 3.2 kg left → matches mockup
  ),
  streakDays: 12,
  weeklyCalories: const WeeklyCaloriesData(
    dailyCalories: [1620, 1480, 2050, 1750, 2200, 1390, 1450],
    dayLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    averageCalories: 1850,
    targetCalories: 2100,
  ),
  recommendations: const [
    Recommendation(
      id: 'rec_protein_01',
      icon: Icons.restaurant,
      iconColor: AppColors.protein,
      description:
          'High protein days help you stay full and support your goal.',
      type: RecommendationType.protein,
    ),
    Recommendation(
      id: 'rec_hydration_01',
      icon: Icons.water_drop,
      iconColor: AppColors.primaryCyan,
      description: 'Stay hydrated! Aim for 2-3L of water daily.',
      type: RecommendationType.hydration,
    ),
  ],
);
