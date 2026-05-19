import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 7-day vertical bar chart with optional target/average reference lines.
///
/// Bars are tinted cyan with a slight gradient. The active day (last bar by
/// convention) gets the full primary color; preceding days are dimmed.
/// Reference lines render as dashed horizontals behind the bars.
///
/// Designed to fit in a 180-200px tall container with day labels under each
/// bar (Mon, Tue, …, Sun).
///
/// Example:
/// ```dart
/// WeeklyBarChart(
///   values: [1800, 2100, 1950, 2200, 1700, 2300, 1900],
///   labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
///   targetLine: 2000,
///   averageLine: 1992,
///   maxY: 3000,
///   showValuesOnTop: false,
/// )
/// ```
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.targetLine,
    this.averageLine,
    this.maxY,
    this.showValuesOnTop = false,
  }) : assert(
          values.length == labels.length,
          'values and labels must have the same length',
        );

  /// Bar heights (typically kcal). Length must match [labels].
  final List<num> values;

  /// X-axis labels under each bar. Length must match [values].
  final List<String> labels;

  /// Horizontal reference line for the goal/target. Rendered prominently.
  final num targetLine;

  /// Optional secondary line for the period average. If null, only [targetLine]
  /// is drawn.
  final num? averageLine;

  /// Y-axis ceiling. Defaults to 1.2 × max(values, targetLine, averageLine).
  final num? maxY;

  /// When true, prints the numeric value above each bar.
  final bool showValuesOnTop;

  @override
  Widget build(BuildContext context) {
    // Resolve the y-axis ceiling.
    final candidates = <num>[
      ...values,
      targetLine,
      if (averageLine != null) averageLine!,
    ];
    final dataMax =
        candidates.isEmpty ? 1 : candidates.reduce((a, b) => a > b ? a : b);
    final resolvedMaxY = maxY ?? (dataMax * 1.2);

    return LayoutBuilder(
      builder: (context, constraints) {
        const labelHeight = 22.0;
        const topPadding = 12.0;
        final chartHeight = constraints.maxHeight - labelHeight - topPadding;

        return Padding(
          padding: const EdgeInsets.only(top: topPadding),
          child: Stack(
            children: [
              // 1) Reference lines (behind bars)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: chartHeight,
                child: CustomPaint(
                  painter: _ReferenceLinePainter(
                    targetValue: targetLine.toDouble(),
                    averageValue: averageLine?.toDouble(),
                    maxY: resolvedMaxY.toDouble(),
                  ),
                ),
              ),

              // 2) Bars + labels
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (i) {
                  final isLast = i == values.length - 1;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _BarColumn(
                        value: values[i],
                        label: labels[i],
                        maxY: resolvedMaxY.toDouble(),
                        chartHeight: chartHeight,
                        labelHeight: labelHeight,
                        isActive: isLast,
                        showValueOnTop: showValuesOnTop,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.value,
    required this.label,
    required this.maxY,
    required this.chartHeight,
    required this.labelHeight,
    required this.isActive,
    required this.showValueOnTop,
  });

  final num value;
  final String label;
  final double maxY;
  final double chartHeight;
  final double labelHeight;
  final bool isActive;
  final bool showValueOnTop;

  @override
  Widget build(BuildContext context) {
    final ratio = (maxY <= 0 ? 0.0 : (value / maxY).clamp(0.0, 1.0)).toDouble();
    final barHeight = chartHeight * ratio;

    final barColor = isActive
        ? AppColors.primaryCyan
        : AppColors.primaryCyan.withValues(alpha: 0.45);
    final glowColor = isActive
        ? AppColors.primaryCyan.withValues(alpha: 0.45)
        : Colors.transparent;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showValueOnTop)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              _shortKcal(value),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
              bottom: Radius.circular(2),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                barColor,
                barColor.withValues(alpha: 0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
        ),
        SizedBox(
          height: labelHeight,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color:
                    isActive ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 2150 → "2.1k" for compact display above bars.
  static String _shortKcal(num value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.round().toString();
  }
}

class _ReferenceLinePainter extends CustomPainter {
  _ReferenceLinePainter({
    required this.targetValue,
    required this.averageValue,
    required this.maxY,
  });

  final double targetValue;
  final double? averageValue;
  final double maxY;

  @override
  void paint(Canvas canvas, Size size) {
    if (maxY <= 0) return;

    // Target line — dashed, brighter
    final targetY = size.height -
        (size.height * (targetValue / maxY)).clamp(0, size.height);
    _drawDashedLine(
      canvas,
      Offset(0, targetY),
      Offset(size.width, targetY),
      color: AppColors.primaryCyan.withValues(alpha: 0.4),
      dashWidth: 5,
      gap: 4,
    );

    // Average line — dashed, more subtle
    if (averageValue != null) {
      final avgY = size.height -
          (size.height * (averageValue! / maxY)).clamp(0, size.height);
      _drawDashedLine(
        canvas,
        Offset(0, avgY),
        Offset(size.width, avgY),
        color: AppColors.textTertiary.withValues(alpha: 0.3),
        dashWidth: 3,
        gap: 4,
      );
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end, {
    required Color color,
    required double dashWidth,
    required double gap,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final total = (end - start).distance;
    final direction = (end - start) / total;
    double drawn = 0;
    while (drawn < total) {
      final from = start + direction * drawn;
      final to = start + direction * (drawn + dashWidth).clamp(0, total);
      canvas.drawLine(from, to, paint);
      drawn += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _ReferenceLinePainter old) =>
      old.targetValue != targetValue ||
      old.averageValue != averageValue ||
      old.maxY != maxY;
}
