import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/coach_repository.dart';
import '../../../core/network/api_exceptions.dart';
import '../models/ai_insight.dart';
import 'coach_provider.dart';

enum CoachActionPhase { idle, regenerating, applyingTip }

@immutable
class CoachActionState {
  final CoachActionPhase phase;
  final String? errorMessage;
  final String? lastAppliedAction; // e.g. 'add_habit'

  const CoachActionState({
    this.phase = CoachActionPhase.idle,
    this.errorMessage,
    this.lastAppliedAction,
  });

  CoachActionState copyWith({
    CoachActionPhase? phase,
    String? errorMessage,
    String? lastAppliedAction,
    bool clearError = false,
  }) {
    return CoachActionState(
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastAppliedAction: lastAppliedAction ?? this.lastAppliedAction,
    );
  }
}

class CoachActionsController extends AutoDisposeNotifier<CoachActionState> {
  @override
  CoachActionState build() => const CoachActionState();

  Future<AIInsight?> regenerate() async {
    state = state.copyWith(
      phase: CoachActionPhase.regenerating,
      clearError: true,
    );
    try {
      final repo = ref.read(coachRepositoryProvider);
      final insight = await repo.generate(force: true);
      ref.read(regenerateCountProvider.notifier).recordRegen();
      ref.invalidate(coachTodayProvider);
      state = const CoachActionState();
      return insight;
    } on RateLimitedException catch (e) {
      state = state.copyWith(
        phase: CoachActionPhase.idle,
        errorMessage: e.message,
      );
      return null;
    } on PremiumRequiredException catch (e) {
      state = state.copyWith(
        phase: CoachActionPhase.idle,
        errorMessage: e.message,
      );
      return null;
    } on ApiException catch (e) {
      state = state.copyWith(
        phase: CoachActionPhase.idle,
        errorMessage: e.message,
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        phase: CoachActionPhase.idle,
        errorMessage: 'Could not refresh your insight.',
      );
      return null;
    }
  }

  Future<bool> applyRecommendedTip(String insightId) async {
    state = state.copyWith(
      phase: CoachActionPhase.applyingTip,
      clearError: true,
    );
    try {
      final repo = ref.read(coachRepositoryProvider);
      final result = await repo.applyTip(insightId: insightId);
      state = state.copyWith(
        phase: CoachActionPhase.idle,
        lastAppliedAction: result.actionTaken,
      );
      return result.success;
    } on ApiException catch (e) {
      state = state.copyWith(
        phase: CoachActionPhase.idle,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        phase: CoachActionPhase.idle,
        errorMessage: 'Could not apply the tip.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final coachActionsControllerProvider =
    AutoDisposeNotifierProvider<CoachActionsController, CoachActionState>(
  CoachActionsController.new,
);
