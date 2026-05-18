import 'package:flutter/material.dart';

import 'ai_insight.dart';
import 'nutrition_score.dart';

/// "Recommended for You" actionable card payload.
class CoachRecommendation {
  final String title;
  final String description;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color iconColor;
  final bool applied;

  const CoachRecommendation({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.fallbackIcon,
    required this.iconColor,
    this.applied = false,
  });

  CoachRecommendation copyWith({
    String? title,
    String? description,
    String? imageUrl,
    IconData? fallbackIcon,
    Color? iconColor,
    bool? applied,
  }) {
    return CoachRecommendation(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      fallbackIcon: fallbackIcon ?? this.fallbackIcon,
      iconColor: iconColor ?? this.iconColor,
      applied: applied ?? this.applied,
    );
  }
}

enum RecapStatus { onTrack, behind, ahead }

class DailyRecap {
  final RecapStatus status;
  final String message;

  const DailyRecap({
    required this.status,
    required this.message,
  });
}

/// Aggregate state for the AI Coach screen. The provider exposes one of these.
class AICoachData {
  final NutritionScore nutritionScore;
  final AIInsight mainInsight;
  final List<AIInsight> smallInsights;
  final TodaysMacros todaysMacros;
  final CoachRecommendation recommendation;
  final DailyRecap dailyRecap;

  const AICoachData({
    required this.nutritionScore,
    required this.mainInsight,
    required this.smallInsights,
    required this.todaysMacros,
    required this.recommendation,
    required this.dailyRecap,
  });

  AICoachData copyWith({
    NutritionScore? nutritionScore,
    AIInsight? mainInsight,
    List<AIInsight>? smallInsights,
    TodaysMacros? todaysMacros,
    CoachRecommendation? recommendation,
    DailyRecap? dailyRecap,
  }) {
    return AICoachData(
      nutritionScore: nutritionScore ?? this.nutritionScore,
      mainInsight: mainInsight ?? this.mainInsight,
      smallInsights: smallInsights ?? this.smallInsights,
      todaysMacros: todaysMacros ?? this.todaysMacros,
      recommendation: recommendation ?? this.recommendation,
      dailyRecap: dailyRecap ?? this.dailyRecap,
    );
  }
}
