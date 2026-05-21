import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Progress ring used on the Water Tracker screen (Görsel 5).
///
/// Renders an animated aqua ring with liter values stacked vertically
/// in the center (e.g. "2.1 L / 3.0 L") and a "X L left to goal"
/// caption below.
///
/// Example:
/// ```dart
/// WaterRingChart(consumedLiters: 2.1, targetLiters: 3.0)
/// ```
class WaterRingChart extends StatelessWidget {
  const WaterRingChart({
    super.key,
    required this.consumedLiters,
    required this.targetLiters,
    this.size = 220,
    this.showGlow = true,
    this.animDuration = const Duration(milliseconds: 800),
  });

  final double consumedLiters;
  final double targetLiters;
  final double size;
  final bool showGlow;
  final Duration animDuration;

  @override
  Widget build(BuildContext context) {
    final progress = targetLiters > 0
        ? (consumedLiters / targetLiters).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).round();
    final remaining =
        (targetLiters - consumedLiters).clamp(0.0, double.infinity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: showGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: animDuration,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                painter: _WaterRingPainter(progress: value),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 44,
                            height: 1.0,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: consumedLiters.toStringAsFixed(1),
                            ),
                            TextSpan(
                              text: '  L',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/ ${targetLiters.toStringAsFixed(1)} L',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$percent%',
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${remaining.toStringAsFixed(1)} L left to goal',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Internal painter for the water ring.
/// Draws background track + foreground progress arc starting at 12 o'clock.
class _WaterRingPainter extends CustomPainter {
  _WaterRingPainter({required this.progress});

  final double progress;

  static const double _strokeWidth = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - _strokeWidth) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = _strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaterRingPainter old) =>
      old.progress != progress;
}
