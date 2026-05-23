import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../premium/premium_paywall_screen.dart';
import '../models/weekly_plan.dart';
import '../providers/planner_providers.dart';
import '../widgets/day_plan_card.dart';
import '../widgets/grocery_list_sheet.dart';

/// F4 v0 — Weekly meal plan view.
///
/// Read-mostly v0 (no manual create/edit yet). Surfaces:
///   - Week navigator (prev / "This week" / next), paywalled past week 1
///     for free users
///   - One DayPlanCard per day of the week
///   - "Generate AI plan" CTA (premium-only)
///   - "View grocery list" CTA (sheet)
class MealPlannerScreen extends ConsumerWidget {
  const MealPlannerScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MealPlannerScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(plannerGateProvider);
    final planAsync = ref.watch(weeklyPlanProvider);
    final offset = ref.watch(weekOffsetProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Meal Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Grocery list',
            icon: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white),
            onPressed: () => GroceryListSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(weeklyPlanProvider);
            ref.invalidate(groceryProvider);
            await ref.read(weeklyPlanProvider.future);
          },
          child: !gate.canViewWeek
              ? _PaywallBody(
                  onUpgrade: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const PremiumPaywallScreen(source: 'meal_planner'),
                    ),
                  ),
                  onBackToCurrent: () =>
                      ref.read(weekOffsetProvider.notifier).state = 0,
                )
              : planAsync.when(
                  loading: () => const _LoadingBody(),
                  error: (e, _) => _ErrorBody(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(weeklyPlanProvider),
                  ),
                  data: (plan) => _PlanBody(
                    plan: plan,
                    offset: offset,
                    canGenerate: gate.canGenerate,
                    onPrev: () =>
                        ref.read(weekOffsetProvider.notifier).state = offset - 1,
                    onNext: () =>
                        ref.read(weekOffsetProvider.notifier).state = offset + 1,
                    onJumpToToday: () =>
                        ref.read(weekOffsetProvider.notifier).state = 0,
                    onGenerate: () => _onGenerate(context, ref, gate),
                  ),
                ),
        ),
      ),
    );
  }

  void _onGenerate(BuildContext context, WidgetRef ref, PlannerGateStatus gate) {
    if (!gate.canGenerate) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const PremiumPaywallScreen(source: 'meal_planner'),
        ),
      );
      return;
    }
    // v0: backend call surface lives behind a follow-up sheet that
    // collects dietary preferences. For now show a "coming soon" — the
    // repo method is wired and ready for v0.1.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'AI plan generation launches in v0.1 — coming soon.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
  }
}

class _PlanBody extends StatelessWidget {
  const _PlanBody({
    required this.plan,
    required this.offset,
    required this.canGenerate,
    required this.onPrev,
    required this.onNext,
    required this.onJumpToToday,
    required this.onGenerate,
  });

  final WeeklyPlan plan;
  final int offset;
  final bool canGenerate;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onJumpToToday;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _WeekNavigator(
          weekStart: plan.weekStart,
          weekEnd: plan.weekEnd,
          offset: offset,
          onPrev: onPrev,
          onNext: onNext,
          onJumpToToday: onJumpToToday,
        ),
        const SizedBox(height: 12),
        _TotalsBanner(totalCalories: plan.totalCalories, dayCount: plan.days.length),
        const SizedBox(height: 16),
        if (plan.isEmpty)
          _EmptyState(canGenerate: canGenerate, onGenerate: onGenerate)
        else
          for (final day in plan.days)
            DayPlanCard(day: day, plans: plan.plansFor(day.planDate)),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onGenerate,
            icon: Icon(
              canGenerate
                  ? Icons.auto_awesome_rounded
                  : Icons.workspace_premium_rounded,
              color: Colors.white,
            ),
            label: Text(
              canGenerate ? 'Generate AI plan' : 'Unlock AI plan generation',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({
    required this.weekStart,
    required this.weekEnd,
    required this.offset,
    required this.onPrev,
    required this.onNext,
    required this.onJumpToToday,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int offset;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onJumpToToday;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          tooltip: 'Previous week',
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
        ),
        Expanded(
          child: GestureDetector(
            onTap: offset == 0 ? null : onJumpToToday,
            child: Column(
              children: [
                Text(
                  offset == 0 ? 'This week' : _weekLabel(offset),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatShort(weekStart)} – ${_formatShort(weekEnd)}',
                  style: const TextStyle(
                    color: Color(0xFFB8D4D2),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          tooltip: 'Next week',
          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ),
      ],
    );
  }

  static String _formatShort(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  static String _weekLabel(int offset) {
    if (offset == 1) return 'Next week';
    if (offset == -1) return 'Last week';
    if (offset > 1) return 'In $offset weeks';
    return '${offset.abs()} weeks ago';
  }
}

class _TotalsBanner extends StatelessWidget {
  const _TotalsBanner({required this.totalCalories, required this.dayCount});
  final int totalCalories;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$totalCalories kcal planned across $dayCount days',
              style: const TextStyle(
                color: Color(0xFFE8F3F1),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.canGenerate, required this.onGenerate});
  final bool canGenerate;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No plan for this week yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              canGenerate
                  ? 'Let your AI coach draft a full week in seconds.'
                  : 'AI weekly plans are part of Premium. Upgrade to unlock.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB8D4D2),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaywallBody extends StatelessWidget {
  const _PaywallBody({required this.onUpgrade, required this.onBackToCurrent});
  final VoidCallback onUpgrade;
  final VoidCallback onBackToCurrent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Premium feature',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'See and plan beyond this week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Free plans cover the current week. Upgrade to look '
                'ahead, draft repeating plans, and let AI generate a '
                'full week for you.',
                style: TextStyle(
                  color: Color(0xFFB8D4D2),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'See Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onBackToCurrent,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to this week',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        _block(60, 14),
        const SizedBox(height: 12),
        _block(48, 12),
        const SizedBox(height: 12),
        for (var i = 0; i < 5; i++) ...[
          _block(96, 14),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _block(double height, double radius) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.error, size: 56),
        const SizedBox(height: 12),
        const Text(
          'Could not load your plan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB8D4D2), fontSize: 13),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text('Try again',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
