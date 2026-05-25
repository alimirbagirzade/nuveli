import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/exercise_repository.dart';
import '../models/exercise_log.dart';
import '../models/exercise_summary.dart';

/// Riverpod state for the exercise (activity) feature.
///
/// Wellness boundary: these providers expose minutes/sessions only. No
/// calorie or energy accounting exists — logging activity never touches
/// the calorie target.
///
/// What lives where:
///   - `exerciseTodaySummaryProvider` — `GET /exercise/today/summary`,
///     drives the dashboard quick-card headline (total active minutes +
///     sessions count).
///   - `todayExerciseLogsProvider` — today's individual sessions, for the
///     log sheet's recent-activity list.
///   - `exerciseWeeklyProvider` — 7-day rollup for any future weekly view.
///   - `logExerciseProvider` — callable that POSTs a session and refreshes
///     the dependent providers.

final exerciseTodaySummaryProvider =
    FutureProvider<ExerciseSummary>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.todaySummary();
});

final todayExerciseLogsProvider =
    FutureProvider<List<ExerciseLog>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.listLogs();
});

final exerciseWeeklyProvider = FutureProvider<ExerciseWeekly>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.weekly();
});

/// Arguments for a single activity log write.
class ExerciseLogInput {
  final String activityType;
  final int durationMin;
  final String? intensity;
  final String? note;

  const ExerciseLogInput({
    required this.activityType,
    required this.durationMin,
    this.intensity,
    this.note,
  });
}

typedef LogExerciseFn = Future<ExerciseLog> Function(ExerciseLogInput input);

/// Exposes a callable for the log-exercise sheet's Save button.
/// After a successful write, invalidates the summary + today's logs +
/// weekly so the dashboard card and any open lists re-fetch. Returns the
/// saved [ExerciseLog] so the caller can surface the informational
/// `est_calories` badge (display-only — never affects the calorie budget).
final logExerciseProvider = Provider<LogExerciseFn>((ref) {
  final repo = ref.read(exerciseRepositoryProvider);

  return (ExerciseLogInput input) async {
    final log = await repo.createLog(
      activityType: input.activityType,
      durationMin: input.durationMin,
      intensity: input.intensity,
      note: input.note,
    );
    ref.invalidate(exerciseTodaySummaryProvider);
    ref.invalidate(todayExerciseLogsProvider);
    ref.invalidate(exerciseWeeklyProvider);
    return log;
  };
});

typedef DeleteExerciseFn = Future<void> Function(String id);

/// Exposes a callable for deleting a logged activity. After a successful
/// delete, invalidates the summary + today's logs + weekly so the dashboard
/// card and any open lists re-fetch.
final deleteExerciseProvider = Provider<DeleteExerciseFn>((ref) {
  final repo = ref.read(exerciseRepositoryProvider);

  return (String id) async {
    await repo.deleteLog(id);
    ref.invalidate(exerciseTodaySummaryProvider);
    ref.invalidate(todayExerciseLogsProvider);
    ref.invalidate(exerciseWeeklyProvider);
  };
});
