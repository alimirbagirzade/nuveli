import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/habit.dart';

/// `GET /habits` → active habits with `completed_today` + `current_streak`
/// derived per row. Used on the dashboard's "Today's habits" section.
final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  final dio = ref.read(apiClientProvider).raw;
  final res = await dio.get<dynamic>('/habits');
  final raw = res.data;
  if (raw is! List) return const [];
  return raw
      .cast<Map<String, dynamic>>()
      .map(Habit.fromJson)
      .toList(growable: false);
});

/// Returns a callable that toggles a habit's done-today state by
/// POSTing /habits/{id}/complete (or DELETE on un-check). Invalidates
/// the habits list on success so the dashboard updates.
typedef ToggleHabitFn = Future<void> Function(String habitId, bool nextState);

final toggleHabitProvider = Provider<ToggleHabitFn>((ref) {
  final dio = ref.read(apiClientProvider).raw;
  return (habitId, nextState) async {
    if (nextState) {
      await dio.post<dynamic>('/habits/$habitId/complete');
    } else {
      await dio.delete<dynamic>('/habits/$habitId/complete');
    }
    ref.invalidate(habitsProvider);
  };
});
