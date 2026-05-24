import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meal_planner_repository.dart';
import '../../premium/providers/premium_provider.dart';
import '../../premium/services/premium_gate_service.dart';
import '../models/weekly_plan.dart';

/// Week the user is viewing, expressed as offset from current week.
/// 0 = this week, 1 = next week, -1 = last week.
///
/// Premium gate kicks in at offset > 0 for free users
/// (PremiumFeature.mealPlannerBeyondOneWeek caps `free = 1` week).
final weekOffsetProvider = StateProvider<int>((ref) => 0);

/// Monday of the displayed week, in the device's local timezone.
DateTime weekStartFor(int offset) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));
  return mondayThisWeek.add(Duration(days: offset * 7));
}

final weeklyPlanProvider =
    FutureProvider.autoDispose<WeeklyPlan>((ref) async {
  final offset = ref.watch(weekOffsetProvider);
  final repo = ref.watch(mealPlannerRepositoryProvider);
  return repo.getWeeklyPlan(weekStart: weekStartFor(offset));
});

final groceryProvider =
    FutureProvider.autoDispose<GrocerySummary>((ref) async {
  final offset = ref.watch(weekOffsetProvider);
  final repo = ref.watch(mealPlannerRepositoryProvider);
  return repo.getGrocery(weekStart: weekStartFor(offset));
});

/// Invalidate the planner's read providers after a write (add/edit/delete/
/// generate) so the week view + grocery list re-fetch. Fire-and-forget —
/// callers don't await the refetch so the sheet can close immediately.
void refreshPlanner(WidgetRef ref) {
  ref.invalidate(weeklyPlanProvider);
  ref.invalidate(groceryProvider);
}

/// Gate snapshot for the displayed week.
///
/// - Free users may view current week (offset 0). Any other offset shows
///   a paywall card.
/// - "Generate AI plan" is premium-only via mealPlannerAiGenerate.
class PlannerGateStatus {
  final bool isPremium;
  final int weekOffset;

  /// True if the user is allowed to view this week at all.
  final bool canViewWeek;

  /// True if the user is allowed to tap "Generate AI plan".
  final bool canGenerate;

  const PlannerGateStatus({
    required this.isPremium,
    required this.weekOffset,
    required this.canViewWeek,
    required this.canGenerate,
  });
}

final plannerGateProvider = Provider.autoDispose<PlannerGateStatus>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  final offset = ref.watch(weekOffsetProvider);
  final gate = PremiumGateService.instance;

  // Free tier: free=1 means "1 week worth", i.e. offset 0 only. Anything
  // else (offset != 0) is over-limit.
  final canViewWeek = isPremium ? true : (offset == 0);

  // AI generate is premium-only (free=0).
  final canGenerate = gate.canAccess(
    PremiumFeature.mealPlannerAiGenerate,
    isPremium: isPremium,
  );

  return PlannerGateStatus(
    isPremium: isPremium,
    weekOffset: offset,
    canViewWeek: canViewWeek,
    canGenerate: canGenerate,
  );
});
