import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/charts/consistency_bar_chart.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../models/habits_screen_data.dart';

/// Section: "Weekly Consistency" header (with "6 of 7 days" badge) +
/// the 7-pill consistency bar chart from Chat 2.
class WeeklyConsistencySection extends StatelessWidget {
  final WeeklyConsistencyData data;

  const WeeklyConsistencySection({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: title + completed-days badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly Consistency',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${data.completedDays} of ${data.totalDays} days',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        NuveliCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: ConsistencyBarChart(
            dailyConsistency: data.dailyConsistency,
            labels: data.dayLabels,
            highlightIndex: data.highlightIndex,
          ),
        ),
      ],
    );
  }
}
