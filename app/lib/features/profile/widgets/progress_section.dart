import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/shared/widgets/empty_state_view.dart';

import '../models/weekly_analytics.dart';

/// "Your Progress" section — weekly calorie bar chart with target line.
///
/// Built inline (no dependency on `shared/widgets/charts/weekly_bar_chart.dart`)
/// to avoid signature surprises. If you later want to use the shared chart,
/// replace [_CalorieBarChart] with that widget.
class ProgressSection extends StatelessWidget {
  final WeeklyAnalytics analytics;

  const ProgressSection({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          color: AppColors.cardBackground,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calories vs Target',
                        style: AppTypography.cardTitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        'Last 7 days',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatPill(
                  label: 'Avg',
                  value: '${analytics.avgDailyCalories} kcal',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            SizedBox(
              height: 140,
              child: _CalorieBarChart(analytics: analytics),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                _LegendDot(
                  color: AppColors.primaryCyan,
                  label: 'Within target',
                ),
                const SizedBox(width: AppSpacing.s16),
                _LegendDot(
                  color: AppColors.warning,
                  label: 'Off target',
                ),
                const Spacer(),
                Text(
                  '${analytics.daysWithinTarget}/7 days hit',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieBarChart extends StatelessWidget {
  final WeeklyAnalytics analytics;
  const _CalorieBarChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final days = analytics.days;
    if (days.isEmpty) {
      return const EmptyStateView(
        icon: Icons.insights_outlined,
        title: 'Henüz veri yok',
        message: 'Birkaç gün yemek logladığında trend buraya gelir.',
        compact: true,
      );
    }

    final maxV = (analytics.maxCalories * 1.15).ceilToDouble();
    final targetAvg = days.isEmpty
        ? 0.0
        : days
                .map((d) => d.target)
                .reduce((a, b) => a + b) /
            days.length;

    return LayoutBuilder(
      builder: (ctx, box) {
        final chartH = box.maxHeight - 20; // reserve for labels
        return Stack(
          children: [
            // Target line
            if (targetAvg > 0)
              Positioned(
                left: 0,
                right: 0,
                top: chartH * (1 - (targetAvg / maxV)),
                child: const _DashedLine(),
              ),
            // Bars
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final h = (d.calories / maxV) * chartH;
                final color =
                    d.withinTarget ? AppColors.primaryCyan : AppColors.warning;
                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 18,
                            height: h.clamp(2, chartH).toDouble(),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  color,
                                  color.withValues(alpha: 0.45),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d.weekdayLabel,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (ctx, box) {
          const dash = 6.0;
          const gap = 4.0;
          final count = (box.maxWidth / (dash + gap)).floor();
          return Row(
            children: List.generate(count, (i) {
              return Container(
                width: dash,
                margin: const EdgeInsets.only(right: gap),
                height: 1,
                color: Colors.white.withValues(alpha: 0.25),
              );
            }),
          );
        },
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primaryCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
