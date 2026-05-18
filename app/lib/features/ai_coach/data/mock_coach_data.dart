import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/ai_insight.dart';
import '../models/coach_recommendation.dart';
import '../models/nutrition_score.dart';

/// Mock AI Coach data — kept 1:1 with the App Store mockup (Görsel 8).
///
/// Score breakdown reconstructed so the parts sum to 86:
///   35 (calorie ±10%) + 25 (macros slightly off) + 14 (hydration 93%)
///   + 12 (4/5 habits) = 86
///
/// Macros (1480 kcal / 95p / 160c / 48f) match the Dashboard mock from Chat 4.
const AICoachData mockCoachData = AICoachData(
  nutritionScore: NutritionScore(
    value: 86,
    label: 'Great',
    breakdown: ScoreBreakdown(
      calorieAdherence: 35,
      macroBalance: 25,
      hydration: 14,
      habitsCompletion: 12,
    ),
  ),
  mainInsight: AIInsight(
    id: 'main_1',
    icon: Icons.lightbulb_outline,
    iconColor: AppColors.primaryCyan,
    headline:
        "You're on track for your weight loss goal! Add more fiber tomorrow.",
    supportingText: 'Based on your 7-day trend.',
    tone: InsightTone.positive,
  ),
  smallInsights: [
    AIInsight(
      id: 's1',
      icon: Icons.fitness_center,
      iconColor: AppColors.protein,
      headline: 'Protein power',
      supportingText: '+20g for recovery',
    ),
    AIInsight(
      id: 's2',
      icon: Icons.water_drop,
      iconColor: AppColors.primaryCyan,
      headline: 'Hydration',
      supportingText: 'Aim 2L today',
    ),
    AIInsight(
      id: 's3',
      icon: Icons.eco,
      iconColor: AppColors.success,
      headline: 'Smart snack',
      supportingText: 'Almonds, not chips',
    ),
    AIInsight(
      id: 's4',
      icon: Icons.self_improvement,
      iconColor: AppColors.warning,
      headline: 'Mindful eating',
      supportingText: 'Slow down at lunch',
    ),
  ],
  todaysMacros: TodaysMacros(
    calories: 1480,
    proteinG: 95,
    carbsG: 160,
    fatG: 48,
  ),
  recommendation: CoachRecommendation(
    title: 'Try adding avocado to your breakfast',
    description:
        'Healthy fats keep you full and support hormone balance. '
        'Add 1/2 avocado to your Greek yogurt for the best result.',
    fallbackIcon: Icons.spa,
    iconColor: AppColors.success,
  ),
  dailyRecap: DailyRecap(
    status: RecapStatus.onTrack,
    message: "You're on track. Keep going!",
  ),
);
