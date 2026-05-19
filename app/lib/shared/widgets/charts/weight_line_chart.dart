import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Single data point on the weight trend chart.
class WeightDataPoint {
  const WeightDataPoint({required this.date, required this.weight});
  final DateTime date;
  final double weight;
}

/// Smooth line chart for weight trend over time (Görsel 4 — Analytics).
///
/// Renders:
/// - A curved aqua line with gradient fill below
/// - Dots only at the first and last data points
/// - A 3-column summary row beneath the chart: Start | Change | Current
///   (Change is success-green for weight loss, warning for gain)
///
/// Example:
/// ```dart
/// WeightLineChart(
///   data: [
///     WeightDataPoint(date: DateTime(2026, 1, 1), weight: 72.6),
///     WeightDataPoint(date: DateTime(2026, 3, 1), weight: 69.1),
///   ],
///   rangeLabel: 'Last 8 Weeks',
/// )
/// ```
class WeightLineChart extends StatelessWidget {
  const WeightLineChart({
    super.key,
    required this.data,
    this.rangeLabel,
    this.height = 180,
  });

  final List<WeightDataPoint> data;
  final String? rangeLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No weight data yet',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    final sorted = [...data]..sort((a, b) => a.date.compareTo(b.date));
    final spots = List.generate(
      sorted.length,
      (i) => FlSpot(i.toDouble(), sorted[i].weight),
    );

    final weights = sorted.map((p) => p.weight).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final padding = (maxW - minW) * 0.2 + 0.5;

    final start = sorted.first;
    final current = sorted.last;
    final change = current.weight - start.weight;
    final isLoss = change < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (rangeLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              rangeLabel!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: minW - padding,
              maxY: maxW + padding,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => AppColors.surface,
                  getTooltipItems: (spots) => spots.map((s) {
                    return LineTooltipItem(
                      '${s.y.toStringAsFixed(1)} kg',
                      AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  preventCurveOverShooting: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, bar) =>
                        spot.x == 0 || spot.x == spots.length - 1,
                    getDotPainter: (spot, percent, bar, idx) =>
                        FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.35),
                        AppColors.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat(
              'Start',
              '${start.weight.toStringAsFixed(1)} kg',
              AppColors.textPrimary,
            ),
            _stat(
              'Change',
              '${isLoss ? '↓' : '↑'} ${change.abs().toStringAsFixed(1)} kg',
              isLoss ? AppColors.success : AppColors.warning,
            ),
            _stat(
              'Current',
              '${current.weight.toStringAsFixed(1)} kg',
              AppColors.textPrimary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
