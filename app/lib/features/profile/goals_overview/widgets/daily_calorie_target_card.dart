import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/nuveli_card.dart';

/// Large hero card on the Profile screen:
///   Left  : "Daily Calorie Target" + "2,100 kcal" + "Recommended for you"
///   Right : Mini cyan donut showing today's progress (e.g. 70% of goal)
class DailyCalorieTargetCard extends StatelessWidget {
  /// Target calories (e.g. 2100).
  final double target;

  /// Today's progress as 0.0 - 1.0 (e.g. 0.70 for 70%).
  final double progressPercent;

  const DailyCalorieTargetCard({
    super.key,
    required this.target,
    required this.progressPercent,
  });

  String get _formattedTarget {
    final intTarget = target.round();
    final s = intTarget.toString();
    // Insert thousand separator (",") manually to avoid depending on locale.
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buf.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final clampedPercent = progressPercent.clamp(0.0, 1.0);
    final percentLabel = '${(clampedPercent * 100).round()}%';

    return NuveliCard(
      padding: const EdgeInsets.all(AppSpacing.lg), // 20
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: text block ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily Calorie Target',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formattedTarget,
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kcal',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Recommended for you',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ── Right: mini donut ─────────────────────────────────────────
          _MiniProgressDonut(
            progress: clampedPercent,
            percentLabel: percentLabel,
          ),
        ],
      ),
    );
  }
}

/// Tiny self-contained donut chart used inside the daily-target card.
///
/// Drawn with CustomPainter instead of pulling in a chart library because the
/// shape is minimal and we want a precise cyan glow.
class _MiniProgressDonut extends StatelessWidget {
  final double progress;
  final String percentLabel;

  const _MiniProgressDonut({
    required this.progress,
    required this.percentLabel,
  });

  @override
  Widget build(BuildContext context) {
    const size = 92.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle outer glow.
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withOpacity(0.20),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(size, size),
            painter: _DonutPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                percentLabel,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryCyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'of goal',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;

  _DonutPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Background track.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.primaryText.withOpacity(0.10);
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc.
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [AppColors.cyanGlow, AppColors.primaryCyan],
        startAngle: -math.pi / 2,
        endAngle: math.pi * 2 - math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start at 12 o'clock
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}
