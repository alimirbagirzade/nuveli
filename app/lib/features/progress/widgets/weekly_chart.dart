import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/progress_repository.dart';

/// Tap-able 7-day calorie chart shown on the home screen.
///
/// Each bar represents one day of the past week (Mon..Sun). Bar height
/// is the fraction of that day's calorie target reached. Tap a bar to
/// open the day-detail screen for that date. Tap the header to open
/// the full weekly summary.
class WeeklyChart extends ConsumerWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklySummaryProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — also tap target for the full weekly screen
          InkWell(
            onTap: () => context.push(AppRoute.weeklySummary),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text('Bu Hafta', style: AppTextStyles.labelMedium),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                  const Spacer(),
                  weeklyAsync.maybeWhen(
                    data: (w) => Text(
                      '${w.daysLogged}/7 gün',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          weeklyAsync.when(
            loading: () => const _ChartSkeleton(),
            error: (e, _) => _ChartError(
              message: e is AppError ? e.userMessage : 'Veriler yüklenemedi',
              onRetry: () => ref.invalidate(weeklySummaryProvider),
            ),
            data: (weekly) => _ChartBars(days: weekly.sevenDays),
          ),
        ],
      ),
    );
  }
}

// ─── Bars ────────────────────────────────────────────────────────────

class _ChartBars extends StatelessWidget {
  const _ChartBars({required this.days});
  final List<DaySummary> days;

  static const _dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (i) {
          final day = days[i];
          final isToday = day.localDay == todayKey;
          // Map weekday to a label — days are oldest-first, so the
          // weekday of `day.localDay` tells us the column label.
          final label = _dayLabels[day.weekdayIndex];
          return Expanded(
            child: _Bar(
              day: day,
              label: label,
              isToday: isToday,
            ),
          );
        }),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.day,
    required this.label,
    required this.isToday,
  });
  final DaySummary day;
  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final hasData = day.hasData;
    final fraction = day.fractionOfTarget;
    // 55 = max bar height in px (chart frame ~100, label + padding icin yer)
    final barHeight = hasData ? (55 * fraction.clamp(0.05, 1.0)) : 4.0;

    // Color logic:
    //   no data → faint gray
    //   today → bright primary
    //   over target (>1.0) → warning amber
    //   normal → primary 70%
    Color barColor;
    if (!hasData) {
      barColor = AppColors.textTertiary.withOpacity(0.2);
    } else if (fraction > 1.0) {
      barColor = AppColors.warning;
    } else if (isToday) {
      barColor = AppColors.primary;
    } else {
      barColor = AppColors.primary.withOpacity(0.7);
    }

    return GestureDetector(
      onTap: () => _openDayDetail(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calorie label above bar (small, only if data)
            if (hasData)
              Text(
                day.totalCalories.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              height: barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isToday ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDayDetail(BuildContext context) {
    // Navigate to day detail by passing the date as a path param.
    context.push('${AppRoute.dayDetail}/${day.localDay}');
  }
}

// ─── Skeleton + Error ────────────────────────────────────────────────

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          // Different heights so the skeleton doesn't look totally flat
          final h = 20.0 + (i % 3) * 15;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: h,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 18,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ChartError extends StatelessWidget {
  const _ChartError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
