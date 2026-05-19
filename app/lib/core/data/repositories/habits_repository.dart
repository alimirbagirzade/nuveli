import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/habits/models/habit.dart';
import '../../../features/habits/models/habit_completion.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// Habit tracking — daily habits, completion log, streak, weekly
/// consistency.
///
/// "Today's view" returns each habit together with a
/// `completed_today` flag, so the UI doesn't have to cross-reference
/// two lists. A streak is calculated server-side as the number of
/// consecutive days the user completed ≥80% of their active habits.
class HabitsRepository extends BaseRepository {
  HabitsRepository(super.apiClient);

  // ---------------------------------------------------------------
  // Today's view
  // ---------------------------------------------------------------

  /// Returns every active habit annotated with `completedToday`.
  /// Backed by `GET /habits/today`.
  Future<List<Habit>> getTodaysHabits() async {
    final response = await apiClient.get<List<dynamic>>(
      ApiEndpoints.habitsToday,
    );
    return response
        .cast<Map<String, dynamic>>()
        .map(Habit.fromJson)
        .toList(growable: false);
  }

  /// All habits the user has ever created (incl. archived). Used by
  /// the management screen, not the daily tile.
  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiEndpoints.habits,
      queryParameters: {'include_archived': includeArchived},
    );
    return response
        .cast<Map<String, dynamic>>()
        .map(Habit.fromJson)
        .toList(growable: false);
  }

  // ---------------------------------------------------------------
  // Toggle completion
  // ---------------------------------------------------------------

  /// Marks today's completion for a habit on/off. Idempotent — the
  /// backend treats a second toggle in the same day as "uncheck".
  /// Returns the completion record if newly created, `null` if the
  /// habit was unchecked.
  Future<HabitCompletion?> toggleToday(String habitId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.habitToggle(habitId),
    );

    // Backend convention: `{ "completed": false }` when toggled OFF,
    // otherwise the full completion row.
    if (response['completed'] == false) return null;
    return HabitCompletion.fromJson(response);
  }

  // ---------------------------------------------------------------
  // Streak & consistency
  // ---------------------------------------------------------------

  /// Current consecutive-day streak (integer). 0 when the user has
  /// missed yesterday.
  Future<int> getStreak() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.habitsStreak,
    );
    return (response['streak_days'] as num).toInt();
  }

  /// 7-element list of completion ratios (`0.0` → `1.0`) for the
  /// current week's bar chart, ordered Monday → Sunday.
  Future<List<double>> getWeeklyConsistency() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.habitsConsistency,
    );
    final days = response['days'] as List<dynamic>;
    return days
        .map<double>((v) => (v as num).toDouble())
        .toList(growable: false);
  }

  // ---------------------------------------------------------------
  // Manage habits
  // ---------------------------------------------------------------

  Future<Habit> createHabit({
    required String name,
    required String icon,
    required String targetType, // 'check' | 'count' | 'duration'
    int? targetValue,
    String? schedule, // 'daily' | 'weekdays' | 'custom:..."
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.habits,
      data: {
        'name': name,
        'icon': icon,
        'target_type': targetType,
        if (targetValue != null) 'target_value': targetValue,
        if (schedule != null) 'schedule': schedule,
      },
    );
    return Habit.fromJson(response);
  }

  Future<Habit> updateHabit(
    String id, {
    String? name,
    String? icon,
    int? targetValue,
    String? schedule,
    bool? archived,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (targetValue != null) 'target_value': targetValue,
      if (schedule != null) 'schedule': schedule,
      if (archived != null) 'archived': archived,
    };
    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.habitById(id),
      data: body,
    );
    return Habit.fromJson(response);
  }

  Future<void> deleteHabit(String id) {
    return apiClient.delete(ApiEndpoints.habitById(id));
  }
}

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return HabitsRepository(ref.watch(apiClientProvider));
});
