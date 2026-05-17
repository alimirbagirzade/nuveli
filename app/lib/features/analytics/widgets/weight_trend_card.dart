import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/features/analytics/models/analytics_data.dart';
import 'package:nuveli/shared/widgets/nuveli_card.dart';
import 'package:nuveli/shared/widgets/charts/weight_line_chart.dart';

/// 8 haftalık kilo trendini gösteren kart.
///
/// Üst: "Weight Trend" + period dropdown pill.
/// Orta: Smooth line chart (Chat 2'den WeightLineChart).
/// Alt: 3 sütun (Start / Change / Current).
/// En alt: 4 nokta page indicator (sadece görsel — swipe yok).
class WeightTrendCard extends StatelessWidget {
  final List<WeightDataPoint> data;
  final String periodLabel;
  final int activeDotIndex;
  final VoidCallback? onPeriodTap;

  const WeightTrendCard({
    super.key,
    required this.data,
    this.periodLabel = 'Last 8 Weeks',
    this.activeDotIndex = 0,
    this.onPeriodTap,
  });

  @override
  Widget build(BuildContext context) {
    assert(data.isNotEmpty, 'WeightTrendCard requires at least one data point');

    final start = data.first.weight;
    final current = data.last.weight;
    final change = current - start;
    final isLoss = change < 0;
    final changeText = isLoss
        ? '↓ ${change.abs().toStringAsFixed(1)} kg'
        : '↑ ${change.toStringAsFixed(1)} kg';
    final changeColor =
        isLoss ? AppColors.success : AppColors.warning;

    return NuveliCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: Title + period dropdown pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight Trend',
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _PeriodPill(label: periodLabel, onTap: onPeriodTap),
            ],
          ),

          SizedBox(height: AppSpacing.sm + 4), // 12px

          // Chart (Chat 2'den)
          SizedBox(
            height: 120,
            child: WeightLineChart(data: data),
          ),

          SizedBox(height: AppSpacing.sm + 4),

          // Alt 3 sütun: Start / Change / Current
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  value: '${start.toStringAsFixed(1)} kg',
                  label: 'Start',
                  valueColor: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  value: changeText,
                  label: 'Change',
                  valueColor: changeColor,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  value: '${current.toStringAsFixed(1)} kg',
                  label: 'Current',
                  valueColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm + 4),

          // Page dot indicator (4 nokta, ortalı, sadece görsel)
          _PageDots(activeIndex: activeDotIndex, count: 4),
        ],
      ),
    );
  }
}

/// Period dropdown pill (örn: "Last 8 Weeks ▾").
class _PeriodPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PeriodPill({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: AppColors.primaryCyan.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.primaryCyan,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek bir stat sütunu (üstte değer, altta label).
class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Sayfa nokta indicator'ı (örn: ● ● ● ●).
class _PageDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _PageDots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 8 : 6,
            height: isActive ? 8 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.primaryCyan
                  : AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }
}
