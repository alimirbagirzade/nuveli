import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/coach/models/ai_insight.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import 'base_repository.dart';

/// AI Coach API.
///
/// Backend (verified 2026-05-23, `backend/routers/ai_coach.py`):
///   - GET  /coach/today      → today's cached insight (auto-generates on
///                              first call of the day if cron hasn't run)
///   - POST /coach/generate   → force regen, rate-limited 5/min
///   - POST /coach/apply-tip  → execute `recommended_action.action_type`
///
/// No /coach/chat, no /coach/audio in v0.
class CoachRepository extends BaseRepository {
  CoachRepository(super.apiClient);

  Future<AIInsight> getToday() async {
    final response =
        await apiClient.get<Map<String, dynamic>>(ApiEndpoints.coachToday);
    return AIInsight.fromJson(response);
  }

  /// Force-regenerate today's insight. Premium gating is enforced
  /// client-side via [PremiumGateService.aiInsightSecond] (1/day free).
  /// Backend still rate-limits to 5/min as defense-in-depth.
  Future<AIInsight> generate({bool force = true}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.coachGenerate,
      data: {'force': force},
    );
    return AIInsight.fromJson(response);
  }

  /// Execute the `recommended_action` of a given insight server-side.
  /// Backend dispatches on `action_type` to (e.g.) insert a habit, log
  /// water, add a reminder, or update a profile target.
  Future<ApplyTipResult> applyTip({
    required String insightId,
    Map<String, dynamic>? actionPayloadOverride,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.coachApplyTip,
      data: {
        'insight_id': insightId,
        if (actionPayloadOverride != null)
          'action_payload': actionPayloadOverride,
      },
    );
    return ApplyTipResult.fromJson(response);
  }
}

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepository(ref.watch(apiClientProvider));
});
