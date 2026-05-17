import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/shared/widgets/charts/calorie_ring_chart.dart';

class TodaysSummarySection extends StatelessWidget {
  final double consumed;
  final double target;

  const TodaysSummarySection({
    super.key,
    required this.consumed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (target - consumed).clamp(0, target).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Today's Summary",
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(
            color: AppColors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        CalorieRingChart(
          consumed: consumed,
          target: target,
        ),
        const SizedBox(height: 12),
        Text(
          '$remaining kcal left',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(
            color: AppColors.secondaryText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
