import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Weekly consistency tracker rendered as 7 vertical pill-shaped bars.
///
/// Used on the Healthy Habits screen ("Weekly Consistency").
/// Each value is a 0.0–1.0 ratio representing the share of habits
/// completed that day. The highlighted day (e.g. today) renders with
/// a brighter cyan gradient.
class ConsistencyBarChart extends StatelessWidget {
  const ConsistencyBarChart({
    super.key,
    required this.dailyConsistency,
    required this.labels,
    this.highlightIndex = -1,
    this.summaryText,
    this.height = 160,
  }) : assert(
          dailyConsistency.length == labels.length,
          'dailyConsistency and labels must have the same length',
        );

  /// Values 0.0 to 1.0 per day.
  final List<double> dailyConsistency;
  final List<String> labels;

  /// Index of the day to highlight (e.g. today). Pass -1 to disable.
  final int highlightIndex;

  /// Optional text shown in the top-right (e.g. "6 of 7 days").
  final String? summaryText;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summaryText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                summaryText!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              maxY: 1.0,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      final isHighlight = i == highlightIndex;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          labels[i],
                          style: AppTypography.caption.copyWith(
                            color: isHighlight
                                ? AppColors.primaryCyan
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: isHighlight
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(dailyConsistency.length, (i) {
                final isHighlight = i == highlightIndex;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: dailyConsistency[i].clamp(0.0, 1.0),
                      width: 14,
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isHighlight
                            ? [
                                AppColors.cyanGlow,
                                AppColors.primaryCyan,
                              ]
                            : [
                                AppColors.primaryCyan.withOpacity(0.7),
                                AppColors.cyanDark.withOpacity(0.7),
                              ],
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 1.0,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
