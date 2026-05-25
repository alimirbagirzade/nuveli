import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/exercise/models/exercise_import_item.dart';
import '../../../features/exercise/models/exercise_log.dart';
import '../../../features/exercise/models/exercise_summary.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// Manual exercise / activity logging.
///
/// Exercise in Nuveli is a **positive wellness habit only** — celebratory,
/// neutral, never tied to calories or weight loss. This repository covers
/// the write side (log/delete) plus the read rollups (today summary, weekly)
/// the dashboard card consumes. There is intentionally no "calories burned"
/// concept anywhere — see `docs/protocols/safety-wellness-boundary.md`.
class ExerciseRepository extends BaseRepository {
  ExerciseRepository(super.apiClient);

  // ---------------------------------------------------------------
  // Logs
  // ---------------------------------------------------------------

  /// Log an activity session. `POST /exercise/logs` → 201.
  Future<ExerciseLog> createLog({
    required String activityType,
    required int durationMin,
    String? intensity,
    String? note,
    DateTime? loggedAt,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.exerciseLogs,
      data: {
        'activity_type': activityType,
        'duration_min': durationMin,
        if (intensity != null) 'intensity': intensity,
        if (note != null && note.isNotEmpty) 'note': note,
        if (loggedAt != null) 'logged_at': formatDateTimeUtc(loggedAt),
      },
    );
    return ExerciseLog.fromJson(response);
  }

  /// `GET /exercise/logs?date=YYYY-MM-DD&limit=50` → list, newest first
  /// (ordering is the backend's responsibility). Defaults to today.
  Future<List<ExerciseLog>> listLogs({DateTime? date, int limit = 50}) async {
    final response = await apiClient.get<dynamic>(
      ApiEndpoints.exerciseLogs,
      queryParameters: {
        'date': formatDateOnly(date ?? DateTime.now()),
        'limit': limit,
      },
    );
    if (response is! List) return const <ExerciseLog>[];
    return response
        .cast<Map<String, dynamic>>()
        .map(ExerciseLog.fromJson)
        .toList(growable: false);
  }

  /// `DELETE /exercise/logs/{id}` → 204.
  Future<void> deleteLog(String id) {
    return apiClient.delete(ApiEndpoints.exerciseLogById(id));
  }

  /// Bulk-import device-sourced activities (Health Connect / Apple Health).
  /// `POST /exercise/import` body `{ "items": [...] }` → `{imported, skipped}`.
  /// The backend dedupes on `(source, external_id)`, so resending the same
  /// window is safe. An empty list short-circuits without a round-trip.
  ///
  /// Wellness boundary: any `device_calories` carried here is display-only —
  /// the backend never folds it into the calorie budget.
  Future<ExerciseImportResult> importLogs(
      List<ExerciseImportItem> items) async {
    if (items.isEmpty) {
      return const ExerciseImportResult(imported: 0, skipped: 0);
    }
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.exerciseImport,
      data: {
        'items': items.map((i) => i.toJson()).toList(growable: false),
      },
    );
    return ExerciseImportResult.fromJson(response);
  }

  // ---------------------------------------------------------------
  // Rollups
  // ---------------------------------------------------------------

  /// `GET /exercise/today/summary`.
  Future<ExerciseSummary> todaySummary() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.exerciseTodaySummary,
    );
    return ExerciseSummary.fromJson(response);
  }

  /// `GET /exercise/weekly`.
  Future<ExerciseWeekly> weekly() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.exerciseWeekly,
    );
    return ExerciseWeekly.fromJson(response);
  }
}

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(ref.watch(apiClientProvider));
});
