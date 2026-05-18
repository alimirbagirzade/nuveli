import 'package:flutter/material.dart';

import 'habit.dart';
import 'habit_reminder.dart';

/// Per-day consistency data for the Weekly Consistency bar chart.
///
/// `dailyConsistency` values are normalized 0.0–1.0.
/// `highlightIndex` is the day to visually emphasize ("today").
@immutable
class WeeklyConsistencyData {
  final List<double> dailyConsistency;
  final List<String> dayLabels;
  final int highlightIndex;
  final int completedDays;
  final int totalDays;

  const WeeklyConsistencyData({
    required this.dailyConsistency,
    required this.dayLabels,
    required this.highlightIndex,
    required this.completedDays,
    required this.totalDays,
  });

  WeeklyConsistencyData copyWith({
    List<double>? dailyConsistency,
    List<String>? dayLabels,
    int? highlightIndex,
    int? completedDays,
    int? totalDays,
  }) {
    return WeeklyConsistencyData(
      dailyConsistency: dailyConsistency ?? this.dailyConsistency,
      dayLabels: dayLabels ?? this.dayLabels,
      highlightIndex: highlightIndex ?? this.highlightIndex,
      completedDays: completedDays ?? this.completedDays,
      totalDays: totalDays ?? this.totalDays,
    );
  }
}

/// Aggregate state for the Healthy Habits screen.
@immutable
class HabitsScreenData {
  final int streakDays;
  final int completedToday;
  final int totalHabits;
  final List<Habit> todaysHabits;
  final WeeklyConsistencyData weeklyConsistency;
  final List<HabitReminder> upcomingReminders;

  const HabitsScreenData({
    required this.streakDays,
    required this.completedToday,
    required this.totalHabits,
    required this.todaysHabits,
    required this.weeklyConsistency,
    required this.upcomingReminders,
  });

  HabitsScreenData copyWith({
    int? streakDays,
    int? completedToday,
    int? totalHabits,
    List<Habit>? todaysHabits,
    WeeklyConsistencyData? weeklyConsistency,
    List<HabitReminder>? upcomingReminders,
  }) {
    return HabitsScreenData(
      streakDays: streakDays ?? this.streakDays,
      completedToday: completedToday ?? this.completedToday,
      totalHabits: totalHabits ?? this.totalHabits,
      todaysHabits: todaysHabits ?? this.todaysHabits,
      weeklyConsistency: weeklyConsistency ?? this.weeklyConsistency,
      upcomingReminders: upcomingReminders ?? this.upcomingReminders,
    );
  }
}
