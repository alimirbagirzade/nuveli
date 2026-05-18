import 'package:flutter/material.dart';

/// Tone of an insight — drives color treatment in the UI.
enum InsightTone { positive, warning, neutral }

/// Generic AI-generated insight, used for both the big "Today's Insight"
/// card and the 2x2 small insights grid.
class AIInsight {
  final String id;
  final String headline;
  final String supportingText;
  final IconData icon;
  final Color iconColor;
  final InsightTone tone;

  const AIInsight({
    required this.id,
    required this.headline,
    required this.supportingText,
    required this.icon,
    required this.iconColor,
    this.tone = InsightTone.neutral,
  });

  AIInsight copyWith({
    String? id,
    String? headline,
    String? supportingText,
    IconData? icon,
    Color? iconColor,
    InsightTone? tone,
  }) {
    return AIInsight(
      id: id ?? this.id,
      headline: headline ?? this.headline,
      supportingText: supportingText ?? this.supportingText,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      tone: tone ?? this.tone,
    );
  }
}
