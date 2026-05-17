import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/features/analytics/models/analytics_data.dart';
import 'package:nuveli/shared/widgets/nuveli_card.dart';
import 'package:nuveli/shared/widgets/charts/weekly_bar_chart.dart';

/// Haftalık ortalama kaloriyi gösteren kart.
///
/// Üst: "Weekly Calorie Average" başlığı.
/// Orta: 7 günlük bar chart (her barın üstünde değer).
/// Sağ alt köşe: "1,508 Avg" pill (Stack ile positioned).
class WeeklyCalorieAverageCard extends StatelessWidget {
  final WeeklyCaloriesData data;

  const WeeklyCalorieAverageCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst başlık
          Text(
            'Weekly Calorie Average',
            style: AppTypography.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: AppSpacing.md), // 16px

          // Chart + Avg pill (Stack ile sağ alt köşeye)
          Stack(
            children: [
              SizedBox(
                height: 160,
                child: WeeklyBarChart(
                  values: data.dailyCalories,
                  labels: data.dayLabels,
                  averageLine: data.averageCalories,
                  showValuesOnTop: true,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 24, // gün etiketlerinin üstünde
                child: _AvgPill(value: data.averageCalories),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "1,508 Avg" pill — cyan @ 15% bg.
class _AvgPill extends StatelessWidget {
  final double value;

  const _AvgPill({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.primaryCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '${_formatNumber(value.round())} Avg',
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          color: AppColors.primaryCyan,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
