import 'package:flutter/material.dart';

/// Immutable reminder entity for the Upcoming Reminders section.
@immutable
class HabitReminder {
  final String id;
  final IconData icon;
  final String title;
  final String timeText; // e.g. "1:00 PM • Every day"
  final bool isEnabled;

  const HabitReminder({
    required this.id,
    required this.icon,
    required this.title,
    required this.timeText,
    required this.isEnabled,
  });

  HabitReminder copyWith({
    String? id,
    IconData? icon,
    String? title,
    String? timeText,
    bool? isEnabled,
  }) {
    return HabitReminder(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      timeText: timeText ?? this.timeText,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitReminder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isEnabled == other.isEnabled;

  @override
  int get hashCode => id.hashCode ^ isEnabled.hashCode;
}
