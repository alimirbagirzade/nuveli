import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/charts/weekly_bar_chart.dart';
import '../../../../shared/widgets/nuveli_card.dart';
import '../models/user_goals.dart';

/// "Your Progress" section: a section title outside the card, then a card
/// containing the weekly calorie bar chart + period-selector pill + average
/// label.
class ProgressSection extends StatelessWidget {
  final WeeklyCaloriesData weeklyData;

  /// Stub callback for the "Last 7 Days" pill. Will be wired up in Chat 7
  /// (Analytics) where the period selector becomes real.
  final VoidCallback? onPeriodTap;

  const ProgressSection({
    super.key,
    required this.weeklyData,
    this.onPeriodTap,
  });

  String _formatKcal(double value) {
    final intVal = value.round();
    final s = intVal.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buf.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4), // 12
        NuveliCard(
          padding: const EdgeInsets.all(AppSpacing.md), // 16
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: title + period pill.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Calories vs. Target',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _PeriodPill(
                    label: 'Last 7 Days',
                    onTap: onPeriodTap ??
                        () => debugPrint('Period selector tapped'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Average kcal pill (cyan tinted).
              _AverageLabel(
                text: '${_formatKcal(weeklyData.averageCalories)} kcal avg',
              ),
              const SizedBox(height: AppSpacing.sm + 4), // 12
              // The chart itself.
              SizedBox(
                height: 180,
                child: WeeklyBarChart(
                  values: weeklyData.dailyCalories,
                  labels: weeklyData.dayLabels,
                  targetLine: weeklyData.targetCalories,
                  averageLine: weeklyData.averageCalories,
                  maxY: 3000,
                  showValuesOnTop: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Last 7 Days ▾" pill button — visual only, taps are stubbed for Chat 7.
class _PeriodPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PeriodPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.10),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: AppColors.primaryCyan.withOpacity(0.40),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryCyan,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.primaryCyan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small cyan-tinted pill displaying the period average (e.g. "1,850 kcal avg").
class _AverageLabel extends StatelessWidget {
  final String text;

  const _AverageLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: AppColors.primaryCyan,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}
