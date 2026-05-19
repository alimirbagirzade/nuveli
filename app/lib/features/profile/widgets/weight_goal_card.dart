import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';

import '../models/weight_goal.dart';
import '../models/weight_trend.dart';

/// Left slot in the GoalsRow. Renders one of three states:
///  • Goal + trend: full visualisation
///  • Goal but no trend yet: shows numbers, hides line
///  • No goal: "Set your weight goal" CTA (parent decides which to render)
class WeightGoalCard extends StatelessWidget {
  final WeightGoal goal;
  final WeightTrend? trend;
  final VoidCallback? onTap; // open weight_log_sheet or edit goal

  const WeightGoalCard({
    super.key,
    required this.goal,
    required this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (goal.progressPercent.clamp(0, 100)) / 100.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          color: AppColors.cardBackground,
          border: Border.all(
            color: AppColors.primaryCyan.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primaryCyan.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: AppColors.primaryCyan,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    'Weight Goal',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),

            // Numbers row: 101 → 85 kg
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_kg(goal.startingWeightKg)}',
                  style: AppTypography.cardTitle.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_kg(goal.targetKg)} kg',
                  style: AppTypography.cardTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s4),

            // Summary text
            Text(
              goal.summaryText(),
              style: AppTypography.caption.copyWith(
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            // Mini trend line (if data exists)
            if (trend != null && trend!.hasEnoughData)
              SizedBox(
                height: 40,
                child: CustomPaint(
                  size: const Size(double.infinity, 40),
                  painter: _TrendLinePainter(
                    points: trend!.points
                        .map((p) => p.weightKg)
                        .toList(growable: false),
                    lineColor: AppColors.primaryCyan,
                    fillColor: AppColors.primaryCyan.withValues(alpha: 0.12),
                  ),
                ),
              )
            else
              Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  trend == null ? '—' : 'Log weight to see trend',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.s8),

            // Progress bar
            _ProgressBar(value: progress),
            const SizedBox(height: AppSpacing.s4),
            Text(
              '${goal.progressPercent.toStringAsFixed(0)}% complete',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _kg(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

/// Empty-state card shown when [weightGoalProvider] returns null.
class SetWeightGoalCard extends StatelessWidget {
  final VoidCallback onTap;

  const SetWeightGoalCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          color: AppColors.cardBackground.withValues(alpha: 0.5),
          border: Border.all(
            color: AppColors.primaryCyan.withValues(alpha: 0.4),
            width: 1.2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primaryCyan.withValues(alpha: 0.18),
              ),
              child: const Icon(
                Icons.add_circle_outline,
                size: 20,
                color: AppColors.primaryCyan,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Set your\nweight goal',
              style: AppTypography.cardTitle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Tap to start tracking',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value; // 0..1
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            height: 6,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1).toDouble(),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryCyan, AppColors.cyanGlow],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color fillColor;

  _TrendLinePainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minV = points.reduce((a, b) => a < b ? a : b);
    double maxV = points.reduce((a, b) => a > b ? a : b);
    if (maxV - minV < 0.001) {
      // Flat line — render mid
      minV -= 0.5;
      maxV += 0.5;
    }

    final stepX = size.width / (points.length - 1);

    final path = Path();
    final fill = Path();

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final normalized = (points[i] - minV) / (maxV - minV);
      // Invert: weight loss = lower number = visually trending DOWN on the chart
      // But for a "going down is good" feel we want the line to descend when
      // weight descends. So map low weight to bottom of chart? Actually no —
      // standard convention: higher Y position = higher weight. Use inverse.
      final y = size.height - (normalized * size.height * 0.85) - 4;

      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fill, fillPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;
    canvas.drawPath(path, linePaint);

    // End dot
    final last = path.getBounds();
    final endX = (points.length - 1) * stepX;
    final endNormalized = (points.last - minV) / (maxV - minV);
    final endY = size.height - (endNormalized * size.height * 0.85) - 4;
    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(Offset(endX, endY), 3.5, dotPaint);
    // ignore: unused_local_variable
    final _ = last; // silence analyzer
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter old) =>
      old.points != points || old.lineColor != lineColor;
}
