import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/habits_repository.dart';
import '../models/habits_screen_state.dart';

/// Habits screen — combines today's habits, streak, and weekly
/// consistency into one [AsyncNotifier] so the screen has a single
/// AsyncValue to watch.
///
/// **Why no optimistic toggle here:** the existing `Habit` model in
/// this codebase doesn't expose a `completedToday` field with a
/// `copyWith`, so a clean optimistic patch isn't possible without
/// touching the shared model. We keep this simple: tap → backend
/// roundtrip (~200-400ms) → invalidate → re-fetch. Optimistic can
/// be added later when the screen / model are firmed up.
class HabitsNotifier extends AsyncNotifier<HabitsScreenState> {
  late HabitsRepository _repo;

  @override
  Future<HabitsScreenState> build() async {
    _repo = ref.watch(habitsRepositoryProvider);
    return _loadState();
  }

  Future<HabitsScreenState> _loadState() async {
    final (habits, streakDays, consistency) = await (
      _repo.getTodaysHabits(),
      _repo.getStreak(),
      _repo.getWeeklyConsistency(),
    ).wait;

    return HabitsScreenState(
      todaysHabits: habits,
      streakDays: streakDays,
      weeklyConsistency: consistency,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadState);
  }

  /// Flips today's completion for [habitId]. No optimistic patch —
  /// the streak & consistency endpoints have to refresh anyway, so
  /// we just await + invalidate.
  Future<void> toggleHabit(String habitId) async {
    try {
      await _repo.toggleToday(habitId);
      ref.invalidateSelf();
    } catch (e) {
      if (kDebugMode) debugPrint('[Habits] toggleHabit failed: $e');
      rethrow;
    }
  }

  Future<void> createHabit({
    required String name,
    required String icon,
    required String targetType,
    int? targetValue,
    String? schedule,
  }) async {
    await _repo.createHabit(
      name: name,
      icon: icon,
      targetType: targetType,
      targetValue: targetValue,
      schedule: schedule,
    );
    ref.invalidateSelf();
  }

  Future<void> deleteHabit(String id) async {
    await _repo.deleteHabit(id);
    ref.invalidateSelf();
  }
}

final habitsProvider =
    AsyncNotifierProvider<HabitsNotifier, HabitsScreenState>(
  HabitsNotifier.new,
);
