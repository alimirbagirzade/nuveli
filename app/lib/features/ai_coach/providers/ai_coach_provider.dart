import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_coach_data.dart';
import '../models/coach_recommendation.dart';

/// Toggle to swap mock data for the real backend (`GET /coach/today`)
/// once Chat 11b lands. While `true`, the provider returns mock data after
/// a short artificial delay so the loading skeleton is actually exercised.
const bool kCoachMockMode = true;

class AICoachNotifier extends AsyncNotifier<AICoachData> {
  @override
  Future<AICoachData> build() async {
    if (kCoachMockMode) {
      // Tiny delay so the skeleton flashes briefly — matches real network feel.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return mockCoachData;
    }

    // TODO(Chat 11b): replace with real backend call.
    // final response = await ref.read(coachRepositoryProvider).getToday();
    // return response;
    throw UnimplementedError(
      'Real backend wiring will arrive in Chat 11b. '
      'Set kCoachMockMode = true for now.',
    );
  }

  /// Marks the recommendation as applied — purely optimistic for now.
  /// Chat 11b will replace this with a backend mutation (e.g. add to habits
  /// or push to the meal planner).
  Future<void> applyTip() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.recommendation.applied) return; // idempotent

    state = AsyncData(
      current.copyWith(
        recommendation: current.recommendation.copyWith(applied: true),
      ),
    );
  }

  /// Pull-to-refresh hook.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final aiCoachProvider =
    AsyncNotifierProvider<AICoachNotifier, AICoachData>(AICoachNotifier.new);
