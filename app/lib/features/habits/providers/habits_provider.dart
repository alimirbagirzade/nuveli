import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_habits_data.dart';
import '../models/habits_screen_data.dart';

/// Async notifier holding the Healthy Habits screen state.
///
/// Mutations:
///   - [toggleHabit]: flips a habit's completion → recomputes `completedToday`
///     so the streak banner progress bar updates instantly.
///   - [toggleReminder]: flips a reminder's enabled flag.
///
/// Backend integration (Chat 14/15) will replace [_loadInitialData] with a
/// Supabase call to `habit_completions` and `habits` tables.
class HabitsNotifier extends AsyncNotifier<HabitsScreenData> {
  @override
  Future<HabitsScreenData> build() => _loadInitialData();

  Future<HabitsScreenData> _loadInitialData() async {
    // Simulate a brief network/disk fetch so the skeleton state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return mockHabitsData;
  }

  /// Toggles a habit's completion and recomputes `completedToday`.
  void toggleHabit(String id, bool value) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedHabits = current.todaysHabits
        .map((h) => h.id == id ? h.copyWith(isCompleted: value) : h)
        .toList();

    final completed = updatedHabits.where((h) => h.isCompleted).length;

    state = AsyncValue.data(
      current.copyWith(
        todaysHabits: updatedHabits,
        completedToday: completed,
      ),
    );
  }

  /// Toggles a reminder's enabled flag.
  void toggleReminder(String id, bool value) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedReminders = current.upcomingReminders
        .map((r) => r.id == id ? r.copyWith(isEnabled: value) : r)
        .toList();

    state = AsyncValue.data(
      current.copyWith(upcomingReminders: updatedReminders),
    );
  }

  /// Convenience helper for pull-to-refresh.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadInitialData);
  }
}

final habitsProvider =
    AsyncNotifierProvider<HabitsNotifier, HabitsScreenData>(HabitsNotifier.new);
