import 'package:flutter/material.dart';

/// Type-categorisation of a recommendation. Used for analytics & theming.
enum RecommendationType { protein, hydration, sleep, exercise }

/// Single personalized recommendation card data.
class Recommendation {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String description;
  final RecommendationType type;

  const Recommendation({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.description,
    required this.type,
  });
}
