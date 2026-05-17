import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dashboard_theme.dart';

class CalorieRingChart extends StatelessWidget {
  final double consumed;
  final double target;
  final double size;

  const CalorieRingChart({
    super.key,
    required this.consumed,
    required this.target,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final consumedStr = _withCommas(consumed.toInt());
    final targetStr = _withCommas(target.toInt());

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                consumedStr,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: DashboardColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '/ $targetStr kcal',
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DashboardColors.cyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DashboardColors.cyan,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _withCommas(int n) => n.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * math.pi * progress;
    const startAngle = -math.pi / 2;

    final shader = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: const [
        DashboardColors.cyanGlow,
        DashboardColors.cyan,
        DashboardColors.cyanDark,
        DashboardColors.cyanGlow,
      ],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(rect);

    final glowPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(rect, startAngle, sweep, false, glowPaint);

    final fgPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
