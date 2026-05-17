import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Internal painter shared by ring-style charts
/// (CalorieRingChart, WaterRingChart, NutritionScoreRing).
///
/// Draws a circular background track + a foreground progress arc with
/// rounded caps, starting at 12 o'clock and sweeping clockwise.
///
/// The glow effect is intentionally NOT drawn here — parent widgets wrap
/// this painter in a [Container] with a cyan [BoxShadow] for better
/// performance and theming flexibility.
class RingPainter extends CustomPainter {
  RingPainter({
    required this.progress,
    required this.color,
    this.trackColor = const Color(0x1AFFFFFF), // white @ 10%
    this.strokeWidth = 14,
  });

  /// Progress value between 0.0 and 1.0. Values outside this range are clamped.
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Background track (full circle, dim)
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Foreground progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // 12 o'clock
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
  bool shouldRepaint(covariant RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
