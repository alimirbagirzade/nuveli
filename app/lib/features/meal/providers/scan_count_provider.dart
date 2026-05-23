import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meals_repository.dart';
import '../../premium/providers/premium_provider.dart';
import '../../premium/services/premium_gate_service.dart';

/// Today's count of meals where `scan_source == 'ai_scan'`.
///
/// Used by the scan screen to:
///   1. Display the "N/5 scans left today" badge for free users.
///   2. Block the scan CTA once the daily cap is reached (paywall).
///
/// We fetch via `GET /meals?date=today` and count locally. The
/// dashboard already invalidates `todaysMealsProvider` on save, but
/// this provider is independent so an invalidate after a successful
/// scan keeps both in lockstep.
final scanCountTodayProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(mealsRepositoryProvider);
  final meals = await repo.getTodaysMeals();
  return meals.where((m) => m.scanSource == 'ai_scan').length;
});

/// Resolved daily-gating snapshot the UI can render in one shot.
class ScanGateStatus {
  final bool isPremium;
  final int used;
  final int? remainingFree; // null when premium

  const ScanGateStatus({
    required this.isPremium,
    required this.used,
    required this.remainingFree,
  });

  bool get canScan {
    if (isPremium) return true;
    return (remainingFree ?? 0) > 0;
  }

  String get counterLabel {
    if (isPremium) return 'Unlimited';
    final remaining = remainingFree ?? 0;
    return '$remaining/${used + remaining} scans left today';
  }
}

final scanGateProvider = Provider.autoDispose<AsyncValue<ScanGateStatus>>((ref) {
  final premiumAsync = ref.watch(premiumProvider);
  final countAsync = ref.watch(scanCountTodayProvider);

  return premiumAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (isPremium) => countAsync.when(
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
      data: (used) {
        final remaining = PremiumGateService.instance.remainingFree(
          PremiumFeature.mealScanBeyond5Daily,
          currentUsage: used,
        );
        return AsyncValue.data(ScanGateStatus(
          isPremium: isPremium,
          used: used,
          remainingFree: isPremium ? null : remaining,
        ));
      },
    ),
  );
});
