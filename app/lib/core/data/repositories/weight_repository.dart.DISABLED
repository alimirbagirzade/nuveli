import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/profile/models/weight_goal.dart';
import '../../../features/profile/models/weight_log.dart';
import '../../../features/profile/models/weight_trend.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// Weight tracking — daily logs, long-term goal, smoothed trend.
///
/// `WeightTrend` is what the analytics line-chart consumes: the
/// backend returns smoothed weekly points so the client doesn't
/// have to roll its own EWMA.
///
/// Reads (`weightGoalProvider`, `weightTrendProvider`) are already
/// wired in `profile_provider.dart`. This repository covers the
/// **mutation side** — adding a weight log, upserting a goal —
/// and is consumed by [ProfileActions] in the provider layer.
class WeightRepository extends BaseRepository {
  WeightRepository(super.apiClient);

  // ---------------------------------------------------------------
  // Logs
  // ---------------------------------------------------------------

  /// Recent weight logs, newest first. `days` caps the lookback
  /// window (default 56 = ~8 weeks for the analytics chart).
  Future<List<WeightLog>> getWeightLogs({int days = 56}) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiEndpoints.weightLogs,
      queryParameters: {'days': days},
    );
    return response
        .cast<Map<String, dynamic>>()
        .map(WeightLog.fromJson)
        .toList(growable: false);
  }

  Future<WeightLog> addWeightLog({
    required double kg,
    DateTime? loggedAt,
    String? notes,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.weightLogs,
      data: {
        'kg': kg,
        if (loggedAt != null) 'logged_at': formatDateTimeUtc(loggedAt),
        if (notes != null) 'notes': notes,
      },
    );
    return WeightLog.fromJson(response);
  }

  Future<void> deleteWeightLog(String id) {
    return apiClient.delete('${ApiEndpoints.weightLogs}/$id');
  }

  // ---------------------------------------------------------------
  // Goal
  // ---------------------------------------------------------------

  /// Active weight goal, or `null` if the user hasn't set one yet.
  /// 404 from the backend is normalised to `null` here so callers
  /// don't have to catch `NotFoundException` themselves.
  Future<WeightGoal?> getGoal() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.weightGoal,
      );
      return WeightGoal.fromJson(response);
    } on Exception catch (e) {
      if (e.toString().toLowerCase().contains('not found')) return null;
      rethrow;
    }
  }

  /// Upsert the user's weight goal. The backend stores at most one
  /// active goal per user; calling this again replaces it.
  ///
  /// `direction` matches [WeightGoalDirection] enum values: 'lose',
  /// 'gain', or 'maintain'.
  Future<WeightGoal> setGoal({
    required double targetKg,
    DateTime? targetDate,
    required String direction,
  }) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.weightGoal,
      data: {
        'target_kg': targetKg,
        if (targetDate != null) 'target_date': formatDateOnly(targetDate),
        'direction': direction,
      },
    );
    return WeightGoal.fromJson(response);
  }

  Future<void> clearGoal() {
    return apiClient.delete(ApiEndpoints.weightGoal);
  }

  // ---------------------------------------------------------------
  // Trend (for analytics line chart) — already exposed via
  // `weightTrendProvider` in profile_provider.dart, but kept here
  // for the repository's completeness.
  // ---------------------------------------------------------------

  Future<WeightTrend> getTrend({int weeks = 8}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.weightTrend,
      queryParameters: {'weeks': weeks},
    );
    return WeightTrend.fromJson(response);
  }
}

final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  return WeightRepository(ref.watch(apiClientProvider));
});
