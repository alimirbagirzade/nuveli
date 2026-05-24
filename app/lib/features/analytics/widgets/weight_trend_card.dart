import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/weight_trend.dart';

/// Lightweight weight trend visual. Shows current weight, delta
/// since the start of the period, and a polyline of the moving
/// average over the window. Empty state when there are no weights
/// in the period.
class WeightTrendCard extends StatelessWidget {
  final WeightTrend trend;

  const WeightTrendCard({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!trend.hasData) {
      return _empty(l10n);
    }

    final delta = trend.deltaKg;
    final deltaLabel = delta == null
        ? '—'
        : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg';
    final deltaColor = delta == null
        ? const Color(0xFFB8C5D6)
        : delta == 0
            ? const Color(0xFFB8C5D6)
            : delta < 0
                ? const Color(0xFF3DDC97)
                : const Color(0xFFFFB454);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.analyticsWeightTrend ?? 'Weight trend',
            style: const TextStyle(
              color: Color(0xFFB8C5D6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.analyticsWeightTrendDays(trend.periodDays) ??
                '${trend.periodDays} days',
            style: const TextStyle(color: Color(0xFF6E7B91), fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${trend.currentWeight?.toStringAsFixed(1) ?? '—'} kg',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  deltaLabel,
                  style: TextStyle(
                    color: deltaColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size.fromHeight(80),
              painter: _TrendLinePainter(trend: trend),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Center(
        child: Text(
          l10n?.analyticsWeightTrendEmpty ?? 'Log your weight to see the trend',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB8C5D6), fontSize: 13),
        ),
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  final WeightTrend trend;

  _TrendLinePainter({required this.trend});

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.points.length < 2) {
      // Single point — draw a centered dot.
      if (trend.points.length == 1) {
        final paint = Paint()..color = const Color(0xFF4DDBFF);
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          3,
          paint,
        );
      }
      return;
    }

    final minW = trend.minWeight;
    final maxW = trend.maxWeight;
    final spanW = (maxW - minW).abs();
    final yScale = spanW <= 0.05 ? 0.0 : 1.0; // flat line if no change

    final points = <Offset>[];
    final stepX = size.width / (trend.points.length - 1);
    for (var i = 0; i < trend.points.length; i++) {
      final p = trend.points[i];
      final x = stepX * i;
      final normY = yScale == 0
          ? 0.5
          : 1 - ((p.movingAvgKg - minW) / (maxW - minW));
      final y = (size.height - 6) * normY + 3;
      points.add(Offset(x, y));
    }

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF4DDBFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // End dot
    final dotPaint = Paint()..color = const Color(0xFF4DDBFF);
    canvas.drawCircle(points.last, 3, dotPaint);
  }

  @override
  bool shouldRepaint(_TrendLinePainter old) =>
      old.trend != trend;
}
