import 'package:flutter/material.dart';

/// Type categorization for habits.
enum HabitType { meal, hydration, exercise, protein, sleep, custom }

/// Immutable habit entity for the Healthy Habits screen.
@immutable
class Habit {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final HabitType type;

  const Habit({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.type,
  });

  Habit copyWith({
    String? id,
    IconData? icon,
    Color? iconColor,
    String? title,
    String? subtitle,
    bool? isCompleted,
    HabitType? type,
  }) {
    return Habit(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => id.hashCode ^ isCompleted.hashCode;
}
