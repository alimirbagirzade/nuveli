import 'package:flutter/material.dart';
import '../_shared/calorie_ring.dart';
import '../_shared/dashboard_theme.dart';

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
        const Text(
          "Today's Summary",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DashboardColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        CalorieRingChart(consumed: consumed, target: target),
        const SizedBox(height: 12),
        Text(
          '$remaining kcal left',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: DashboardColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
