import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 0-100 nutrition score rendered as a sweep arc. Color follows the
/// same thresholds the rest of the app uses for "doing well / could
/// improve / needs attention".
class NutritionScoreMeter extends StatelessWidget {
  const NutritionScoreMeter({
    super.key,
    required this.score,
    this.size = 132,
  });

  final int score;
  final double size;

  Color get _tint {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String get _label {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'On track';
    if (score >= 40) return 'Could improve';
    return 'Needs care';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _ScoreArcPainter(score: score, tint: _tint),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: _tint,
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _label,
                style: const TextStyle(
                  color: Color(0xFFB8D4D2),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreArcPainter extends CustomPainter {
  _ScoreArcPainter({required this.score, required this.tint});
  final int score;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.08;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final basePaint = Paint()
      ..color = tint.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, basePaint);

    final progressPaint = Paint()
      ..color = tint
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final sweep = math.pi * 2 * (score.clamp(0, 100) / 100);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(_ScoreArcPainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.tint != tint;
}
