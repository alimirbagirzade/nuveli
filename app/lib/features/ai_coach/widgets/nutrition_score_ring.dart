import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _cyanGlow = Color(0xFF4DDBFF);
const Color _secondaryText = Color(0xFFB8C5D6);

/// Animated circular ring showing the user's nutrition score (0-100).
///
/// On first build, animates from 0 → `score` over 1.2s with easeOutCubic.
/// The numeric label inside the ring counts up in sync, so the score and
/// arc complete together — a small detail that makes the feel premium.
class NutritionScoreRing extends StatelessWidget {
  final int score;
  final String label;
  final double size;

  const NutritionScoreRing({
    super.key,
    required this.score,
    required this.label,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0, 100);
    return Column(
      children: [
        const Text(
          'Nutrition Score',
          style: TextStyle(
            color: _secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: clamped / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              final animatedScore = (t * clamped).round();
              return CustomPaint(
                painter: _ScoreRingPainter(progress: t),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$animatedScore',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: const TextStyle(
                          color: _cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  static const double _strokeWidth = 14;

  _ScoreRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (_strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring — subtle, no glow.
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    const startAngle = -math.pi / 2;
    final sweep = 2 * math.pi * progress;

    // Glow underlay — same arc, blurred, lower opacity.
    final glowPaint = Paint()
      ..color = _cyan.withOpacity(0.45)
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(rect, startAngle, sweep, false, glowPaint);

    // Main arc — gradient stroke on top.
    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: const [_cyan, _cyanGlow],
        startAngle: -math.pi / 2,
        endAngle: (3 * math.pi) / 2,
      ).createShader(rect)
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
