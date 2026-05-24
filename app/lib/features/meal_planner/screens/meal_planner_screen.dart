import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meal_planner_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../premium/premium_paywall_screen.dart';
import '../models/weekly_plan.dart';
import '../providers/planner_providers.dart';
import '../widgets/add_meal_plan_sheet.dart';
import '../widgets/day_plan_card.dart';
import '../widgets/edit_meal_plan_sheet.dart';
import '../widgets/generate_plan_sheet.dart';
import '../widgets/grocery_list_sheet.dart';
import '../widgets/recipe_browser_sheet.dart';

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
        title: Text(
          AppLocalizations.of(context)?.plannerScreenTitle ?? 'Meal Plan',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)?.recipeBrowserTitle ??
                'Browse Recipes',
            icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
            onPressed: () => RecipeBrowserSheet.show(
              context,
              day: weekStartFor(ref.read(weekOffsetProvider)),
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)?.plannerGroceryListTooltip ??
                'Grocery list',
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
                    canEdit: gate.canViewWeek,
                    onPrev: () =>
                        ref.read(weekOffsetProvider.notifier).state = offset - 1,
                    onNext: () =>
                        ref.read(weekOffsetProvider.notifier).state = offset + 1,
                    onJumpToToday: () =>
                        ref.read(weekOffsetProvider.notifier).state = 0,
                    onGenerate: () => _onGenerate(context, ref, gate),
                    onAddMeal: (day) => _onAddMeal(context, day),
                    onEntryTap: (entry) => _onEntryTap(context, ref, entry),
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
    GeneratePlanSheet.show(context, weekStart: weekStartFor(gate.weekOffset));
  }

  Future<void> _onAddMeal(BuildContext context, DateTime day) async {
    await AddMealPlanSheet.show(context, day);
  }

  /// Tapping an entry opens an Edit / Delete action sheet.
  Future<void> _onEntryTap(
    BuildContext context,
    WidgetRef ref,
    MealPlanEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<_EntryAction>(
      context: context,
      backgroundColor: const Color(0xFF142346),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  entry.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.white),
              title: Text(
                l10n?.plannerEditNameNote ?? 'Edit name / note',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_EntryAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppColors.error),
              title: Text(
                l10n?.plannerRemoveFromPlan ?? 'Remove from plan',
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_EntryAction.delete),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;
    if (action == _EntryAction.edit) {
      await EditMealPlanSheet.show(context, entry);
    } else {
      await _confirmAndDelete(context, ref, entry);
    }
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    MealPlanEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF142346),
        title: Text(
          l10n?.plannerRemoveEntryTitle ?? 'Remove entry?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n?.plannerRemoveEntryBody(entry.displayName) ??
              'Remove "${entry.displayName}" from this plan?',
          style: const TextStyle(color: Color(0xFFB8C5D6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n?.commonCancel ?? 'Cancel',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n?.plannerRemove ?? 'Remove',
              style: const TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(mealPlannerRepositoryProvider).deletePlanEntry(entry.id);
      refreshPlanner(ref);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Could not remove: ${e.toString().split('\n').first}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
    }
  }
}

enum _EntryAction { edit, delete }

class _PlanBody extends StatelessWidget {
  const _PlanBody({
    required this.plan,
    required this.offset,
    required this.canGenerate,
    required this.canEdit,
    required this.onPrev,
    required this.onNext,
    required this.onJumpToToday,
    required this.onGenerate,
    required this.onAddMeal,
    required this.onEntryTap,
  });

  final WeeklyPlan plan;
  final int offset;
  final bool canGenerate;
  final bool canEdit;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onJumpToToday;
  final VoidCallback onGenerate;
  final void Function(DateTime day) onAddMeal;
  final void Function(MealPlanEntry entry) onEntryTap;

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
          _EmptyState(
            canGenerate: canGenerate,
            onGenerate: onGenerate,
            onAddManually:
                canEdit ? () => onAddMeal(plan.weekStart) : null,
          )
        else
          for (final day in plan.days)
            DayPlanCard(
              day: day,
              plans: plan.plansFor(day.planDate),
              onAddMeal: canEdit ? onAddMeal : null,
              onEntryTap: canEdit ? onEntryTap : null,
            ),
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
              canGenerate
                  ? (AppLocalizations.of(context)?.plannerGenerateAiPlan ??
                      'Generate AI plan')
                  : (AppLocalizations.of(context)?.plannerUnlockAiPlan ??
                      'Unlock AI plan generation'),
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
          tooltip: AppLocalizations.of(context)?.plannerPrevWeekTooltip ??
              'Previous week',
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
        ),
        Expanded(
          child: GestureDetector(
            onTap: offset == 0 ? null : onJumpToToday,
            child: Column(
              children: [
                Text(
                  offset == 0
                      ? (AppLocalizations.of(context)?.plannerThisWeek ??
                          'This week')
                      : _weekLabel(context, offset),
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
          tooltip: AppLocalizations.of(context)?.plannerNextWeekTooltip ??
              'Next week',
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

  static String _weekLabel(BuildContext context, int offset) {
    final l10n = AppLocalizations.of(context);
    if (offset == 1) return l10n?.plannerNextWeek ?? 'Next week';
    if (offset == -1) return l10n?.plannerLastWeek ?? 'Last week';
    if (offset > 1) return l10n?.plannerInWeeks(offset) ?? 'In $offset weeks';
    return l10n?.plannerWeeksAgo(offset.abs()) ?? '${offset.abs()} weeks ago';
  }
}

class _TotalsBanner extends StatelessWidget {
  const _TotalsBanner({required this.totalCalories, required this.dayCount});
  final int totalCalories;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              l10n?.plannerTotalsBanner(totalCalories, dayCount) ??
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
  const _EmptyState({
    required this.canGenerate,
    required this.onGenerate,
    this.onAddManually,
  });
  final bool canGenerate;
  final VoidCallback onGenerate;
  final VoidCallback? onAddManually;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(
            l10n?.plannerEmptyTitle ?? 'No plan for this week yet',
            style: const TextStyle(
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
                  ? (l10n?.plannerEmptyAiHint ??
                      'Let your AI coach draft a full week in seconds.')
                  : (l10n?.plannerEmptyPremiumHint ??
                      'AI weekly plans are part of Premium. Upgrade to unlock.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB8D4D2),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          if (onAddManually != null) ...[
            const SizedBox(height: 18),
            TextButton.icon(
              onPressed: onAddManually,
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              label: Text(
                l10n?.plannerAddMealManually ?? 'Add a meal manually',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
    final l10n = AppLocalizations.of(context);
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
              Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.plannerPremiumFeature ?? 'Premium feature',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.plannerPaywallTitle ?? 'See and plan beyond this week',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.plannerPaywallBody ??
                    'Free plans cover the current week. Upgrade to look '
                    'ahead, draft repeating plans, and let AI generate a '
                    'full week for you.',
                style: const TextStyle(
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
                  child: Text(
                    l10n?.plannerSeePremium ?? 'See Premium',
                    style: const TextStyle(
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
                  child: Text(
                    l10n?.plannerBackToThisWeek ?? 'Back to this week',
                    style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.error, size: 56),
        const SizedBox(height: 12),
        Text(
          l10n?.plannerLoadError ?? 'Could not load your plan',
          textAlign: TextAlign.center,
          style: const TextStyle(
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
            label: Text(
              l10n?.commonRetry ?? 'Try again',
              style: const TextStyle(color: Colors.white),
            ),
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
