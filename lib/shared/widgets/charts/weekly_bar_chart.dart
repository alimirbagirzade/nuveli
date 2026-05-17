import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Vertical bar chart for 7-day calorie history.
///
/// Used on:
/// - Goals & Profile screen ("Calories vs. Target")
/// - Analytics screen ("Weekly Calorie Average")
///
/// Supports two optional dashed reference lines (target + average) and
/// can render the bar's value as a permanent tooltip above each rod when
/// [showValuesOnTop] is true.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.targetLine,
    this.averageLine,
    this.showValuesOnTop = false,
    this.maxY,
    this.height = 200,
  }) : assert(
          values.length == labels.length,
          'values and labels must have the same length',
        );

  final List<double> values;
  final List<String> labels;
  final double? targetLine;
  final double? averageLine;
  final bool showValuesOnTop;
  final double? maxY;
  final double height;

  @override
  Widget build(BuildContext context) {
    final chartMaxY = maxY ??
        (values.isEmpty
            ? 100.0
            : (values.reduce((a, b) => a > b ? a : b)) * 1.25);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: chartMaxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
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
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.cardBg,
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              getTooltipItem: (group, gIdx, rod, rIdx) {
                return BarTooltipItem(
                  rod.toY.toStringAsFixed(0),
                  AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (targetLine != null)
                HorizontalLine(
                  y: targetLine!,
                  color: AppColors.primaryCyan.withOpacity(0.5),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                ),
              if (averageLine != null)
                HorizontalLine(
                  y: averageLine!,
                  color: AppColors.cyanGlow.withOpacity(0.5),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                ),
            ],
          ),
          barGroups: List.generate(values.length, (i) {
            return BarChartGroupData(
              x: i,
              showingTooltipIndicators: showValuesOnTop ? [0] : const [],
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 18,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.cyanGlow,
                      AppColors.primaryCyan,
                      AppColors.cyanDark,
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
