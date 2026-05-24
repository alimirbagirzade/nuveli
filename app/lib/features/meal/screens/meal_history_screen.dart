import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meals_repository.dart';
import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_error_view.dart';
import '../../dashboard/models/meal.dart';
import '../../dashboard/providers/dashboard_provider.dart' show todayMealsProvider;
import '../../profile/providers/profile_provider.dart' show dashboardSummaryProvider;
import '../providers/meal_history_provider.dart';

/// Full meal history — the destination for the dashboard "See all" CTA.
/// Meals grouped by day (newest first), swipe-to-delete with undo via the
/// dashboard refresh.
class MealHistoryScreen extends ConsumerWidget {
  const MealHistoryScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MealHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(mealHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)?.mealHistoryTitle ?? 'Meal History',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(mealHistoryProvider);
            await ref.read(mealHistoryProvider.future);
          },
          child: historyAsync.when(
            loading: () => const _Loading(),
            error: (e, _) => AppErrorView(
              error: AppError.from(e),
              onRetry: () => ref.invalidate(mealHistoryProvider),
            ),
            data: (meals) => meals.isEmpty
                ? const _EmptyState()
                : _HistoryList(meals: meals),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.meals});
  final List<Meal> meals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final grouped = groupMealsByDay(meals);
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        final dayMeals = grouped[day]!;
        final dayTotal =
            dayMeals.fold<int>(0, (sum, m) => sum + m.totalCalories);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Row(
                children: [
                  Text(
                    _dayLabel(day, l10n),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$dayTotal kcal',
                    style: const TextStyle(
                      color: Color(0xFFB8D4D2),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            for (final meal in dayMeals)
              _DismissibleMealRow(meal: meal),
          ],
        );
      },
    );
  }

  static String _dayLabel(DateTime day, AppLocalizations? l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return l10n?.homeToday ?? 'Today';
    if (diff == 1) return l10n?.historyYesterday ?? 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final label = '${months[day.month - 1]} ${day.day}';
    return day.year == now.year ? label : '$label, ${day.year}';
  }
}

class _DismissibleMealRow extends ConsumerWidget {
  const _DismissibleMealRow({required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      // Do the whole delete inside confirmDismiss: returning false on
      // cancel OR failure makes the Dismissible spring the row back
      // natively — no manual invalidate fighting the dismissed animation.
      confirmDismiss: (_) => _confirmAndDelete(context, ref),
      child: _MealRow(meal: meal),
    );
  }

  /// Confirms, then deletes. Returns true only if the meal was actually
  /// removed (so the Dismissible commits the dismissal); false on cancel
  /// or failure (the row animates back into place).
  Future<bool> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF142346),
        title: Text(l10n?.todayMealDeleteTitle ?? 'Delete meal?',
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n?.todayMealDeleteMessage(meal.displayName) ??
              '"${meal.displayName}" will be deleted. This cannot be undone.',
          style: const TextStyle(color: Color(0xFFB8C5D6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n?.commonCancel ?? 'Cancel',
                style: const TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n?.commonDelete ?? 'Delete',
                style: const TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      await ref.read(mealsRepositoryProvider).deleteMeal(meal.id);
      // Deleted server-side — refresh history + the dashboard's today
      // providers (the meal may have been today's). The dismissal commits.
      ref.invalidate(mealHistoryProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(todayMealsProvider);
      return true;
    } catch (e) {
      // Return false → Dismissible springs the row back; no manual
      // invalidate needed.
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              content: Text(
                l10n?.todayMealDeleteFailed ?? 'Could not delete.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
      }
      return false;
    }
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final t = meal.consumedAt.toLocal();
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              meal.mealTypeLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF7A95A0),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${meal.totalCalories} kcal',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.history_rounded,
                size: 44, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n?.mealHistoryEmptyTitle ?? 'No meals logged yet',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n?.mealHistoryEmptyBody ??
              'Your logged meals will show up here, grouped by day.',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Color(0xFFB8D4D2), fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        for (var i = 0; i < 6; i++)
          Container(
            height: 64,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      ],
    );
  }
}
