import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/habit.dart';
import '../models/habit_reminder.dart';
import '../models/habits_screen_data.dart';

/// Mock habits matching Görsel 7 exactly.
///
/// State of completion:
///   - h1..h4: completed (✓)
///   - h5 (Sleep before 11 PM): NOT completed (⚪)
/// Total: 4 of 5 completed.
final List<Habit> mockHabits = [
  Habit(
    id: 'h1',
    type: HabitType.meal,
    icon: Icons.rice_bowl,
    iconColor: AppColors.protein,
    title: 'Log breakfast',
    subtitle: 'Track your first meal',
    isCompleted: true,
  ),
  Habit(
    id: 'h2',
    type: HabitType.hydration,
    icon: Icons.water_drop,
    iconColor: AppColors.primaryCyan,
    title: 'Drink 8 glasses',
    subtitle: 'Stay hydrated',
    isCompleted: true,
  ),
  Habit(
    id: 'h3',
    type: HabitType.exercise,
    icon: Icons.directions_run,
    iconColor: AppColors.success,
    title: 'Walk 6,000 steps',
    subtitle: 'Daily movement goal',
    isCompleted: true,
  ),
  Habit(
    id: 'h4',
    type: HabitType.protein,
    icon: Icons.fitness_center,
    iconColor: AppColors.primaryCyan,
    title: 'Protein goal',
    subtitle: 'Hit your daily protein target',
    isCompleted: true,
  ),
  Habit(
    id: 'h5',
    type: HabitType.sleep,
    icon: Icons.nightlight_round,
    iconColor: AppColors.textSecondary,
    title: 'Sleep before 11 PM',
    subtitle: 'Get quality rest',
    isCompleted: false,
  ),
];

/// Two reminders matching Görsel 7.
final List<HabitReminder> mockReminders = [
  const HabitReminder(
    id: 'r1',
    icon: Icons.notifications,
    title: 'Hydration Reminder',
    timeText: '1:00 PM • Every day',
    isEnabled: true,
  ),
  const HabitReminder(
    id: 'r2',
    icon: Icons.nightlight_round,
    title: 'Sleep Reminder',
    timeText: '10:30 PM • Every day',
    isEnabled: true,
  ),
];

/// Weekly consistency snapshot for the last 7 days.
///
/// Values are 0.0–1.0; a day "counts" toward consistency when ≥ 0.8.
/// Mon..Sun: [0.8, 1.0, 0.6, 0.9, 1.0, 1.0, 0.7] → 5 days @ ≥0.8, plus
/// today (Sat = index 5) makes it 6 of 7 days per mockup.
const WeeklyConsistencyData mockWeeklyConsistency = WeeklyConsistencyData(
  dailyConsistency: [0.8, 1.0, 0.6, 0.9, 1.0, 1.0, 0.7],
  dayLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  highlightIndex: 5,
  completedDays: 6,
  totalDays: 7,
);

/// Aggregate mock screen data — entry point for the provider.
final HabitsScreenData mockHabitsData = HabitsScreenData(
  streakDays: 18,
  completedToday: 4,
  totalHabits: 5,
  todaysHabits: mockHabits,
  weeklyConsistency: mockWeeklyConsistency,
  upcomingReminders: mockReminders,
);
