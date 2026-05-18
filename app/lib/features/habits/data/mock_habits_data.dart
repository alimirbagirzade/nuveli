import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/habit_reminder.dart';
import '../models/habits_screen_data.dart';

// Color tokens used by the mock — matched to the screenshot, not theme-aware.
// These mirror the colors already in use by other screens (meal_planner etc.).
const Color _cyan = Color(0xFF00D4FF);
const Color _orange = Color(0xFFFF9F45);
const Color _green = Color(0xFF3DDC97);
const Color _purple = Color(0xFF9B7EE6);

/// Mock habits matching the Görsel 7 screenshot:
///   - h1..h4 completed (✓)
///   - h5 (Sleep before 11 PM) NOT completed (⚪)
///   - Total: 4 of 5 completed.
final List<Habit> mockHabits = [
  const Habit(
    id: 'h1',
    type: HabitType.meal,
    icon: Icons.rice_bowl_rounded,
    iconColor: _orange,
    title: 'Log breakfast',
    subtitle: 'Track your first meal',
    isCompleted: true,
  ),
  const Habit(
    id: 'h2',
    type: HabitType.hydration,
    icon: Icons.water_drop_rounded,
    iconColor: _cyan,
    title: 'Drink 8 glasses',
    subtitle: 'Stay hydrated',
    isCompleted: true,
  ),
  const Habit(
    id: 'h3',
    type: HabitType.exercise,
    icon: Icons.directions_run_rounded,
    iconColor: _green,
    title: 'Walk 6,000 steps',
    subtitle: 'Daily movement goal',
    isCompleted: true,
  ),
  const Habit(
    id: 'h4',
    type: HabitType.protein,
    icon: Icons.fitness_center_rounded,
    iconColor: _cyan,
    title: 'Protein goal',
    subtitle: 'Hit your daily protein target',
    isCompleted: true,
  ),
  const Habit(
    id: 'h5',
    type: HabitType.sleep,
    icon: Icons.nightlight_round,
    iconColor: _purple,
    title: 'Sleep before 11 PM',
    subtitle: 'Get quality rest',
    isCompleted: false,
  ),
];

/// Two reminders matching the screenshot.
final List<HabitReminder> mockReminders = [
  const HabitReminder(
    id: 'r1',
    icon: Icons.notifications_rounded,
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

/// Weekly consistency snapshot. Mon..Sun values; index 5 = Sat (highlighted today).
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
