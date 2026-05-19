import 'habit.dart';

/// Composite state powering the habits screen — today's habit list,
/// the current consecutive-day streak, and the 7-element weekly
/// consistency series.
///
/// Provider source: `lib/features/habits/providers/habits_provider.dart`
class HabitsScreenState {
  const HabitsScreenState({
    required this.todaysHabits,
    required this.streakDays,
    required this.weeklyConsistency,
  });

  /// Active habits annotated with `completedToday` (see [Habit]).
  final List<Habit> todaysHabits;

  /// Consecutive-day streak (0 if yesterday was missed).
  final int streakDays;

  /// 7 floats `0.0 .. 1.0`, Monday → Sunday completion ratios.
  final List<double> weeklyConsistency;

  HabitsScreenState copyWith({
    List<Habit>? todaysHabits,
    int? streakDays,
    List<double>? weeklyConsistency,
  }) {
    return HabitsScreenState(
      todaysHabits: todaysHabits ?? this.todaysHabits,
      streakDays: streakDays ?? this.streakDays,
      weeklyConsistency: weeklyConsistency ?? this.weeklyConsistency,
    );
  }
}
