import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/coach_repository.dart';
import '../../premium/providers/premium_provider.dart';
import '../../premium/services/premium_gate_service.dart';
import '../models/ai_insight.dart';

/// Today's cached insight. Backend transparently generates one on first
/// call if cron hasn't run yet.
final coachTodayProvider = FutureProvider.autoDispose<AIInsight>((ref) async {
  final repo = ref.watch(coachRepositoryProvider);
  return repo.getToday();
});

/// Local count of regenerate-presses today. We don't persist across
/// app restarts — the gate is best-effort UX guidance; backend still
/// rate-limits 5/min and ultimately controls cost.
class RegenerateCountNotifier extends Notifier<int> {
  DateTime _lastIncrement = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  int build() => 0;

  void recordRegen() {
    final now = DateTime.now();
    // Reset at local midnight.
    if (now.year != _lastIncrement.year ||
        now.month != _lastIncrement.month ||
        now.day != _lastIncrement.day) {
      state = 0;
    }
    state = state + 1;
    _lastIncrement = now;
  }
}

final regenerateCountProvider =
    NotifierProvider<RegenerateCountNotifier, int>(RegenerateCountNotifier.new);

/// Resolved gating snapshot for the regenerate CTA. Free tier:
/// `aiInsightSecond` allows 1 regen per day (the cron-cached one is
/// "free" from the user's perspective; the first manual regen is the
/// first paid-equivalent use).
class CoachGateStatus {
  final bool isPremium;
  final int regensUsedToday;
  final int? remainingFreeRegens;

  const CoachGateStatus({
    required this.isPremium,
    required this.regensUsedToday,
    required this.remainingFreeRegens,
  });

  bool get canRegenerate {
    if (isPremium) return true;
    return (remainingFreeRegens ?? 0) > 0;
  }

  String get ctaLabel {
    if (isPremium) return 'Regenerate';
    final remaining = remainingFreeRegens ?? 0;
    if (remaining == 0) return 'Upgrade to regenerate';
    return 'Regenerate (1 free / day)';
  }
}

final coachGateProvider = Provider.autoDispose<CoachGateStatus>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  final used = ref.watch(regenerateCountProvider);
  final remaining = PremiumGateService.instance.remainingFree(
    PremiumFeature.aiInsightSecond,
    currentUsage: used,
  );
  return CoachGateStatus(
    isPremium: isPremium,
    regensUsedToday: used,
    remainingFreeRegens: isPremium ? null : remaining,
  );
});
