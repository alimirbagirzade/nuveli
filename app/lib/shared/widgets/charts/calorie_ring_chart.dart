import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Big circular calorie ring shown at the top of the Dashboard.
///
/// Sweeps a cyan gradient arc from 12 o'clock clockwise, animating in over
/// ~900ms whenever [consumed] changes. The track behind the fill is a
/// dim cyan ring so the empty portion still ties into the brand color.
///
/// Renders the consumed number large in the center, with "of {target} cal"
/// underneath in smaller secondary text.
///
/// Example:
/// ```dart
/// CalorieRingChart(consumed: 1480, target: 2000)
/// ```
class CalorieRingChart extends StatefulWidget {
  const CalorieRingChart({
    super.key,
    required this.consumed,
    required this.target,
    this.size = 200,
    this.strokeWidth = 16,
  });

  final num consumed;
  final num target;

  /// Outer diameter in logical pixels.
  final double size;

  /// Ring thickness.
  final double strokeWidth;

  @override
  State<CalorieRingChart> createState() => _CalorieRingChartState();
}

class _CalorieRingChartState extends State<CalorieRingChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _progressAnim;

  double get _targetRatio {
    if (widget.target <= 0) return 0;
    return (widget.consumed / widget.target).clamp(0.0, 1.0).toDouble();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = Tween<double>(begin: 0, end: _targetRatio).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CalorieRingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newRatio = _targetRatio;
    if (newRatio != _progressAnim.value) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: newRatio,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _progressAnim,
        builder: (context, _) {
          return CustomPaint(
            painter: _RingPainter(
              progress: _progressAnim.value,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatNumber(widget.consumed),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'of ${_formatNumber(widget.target)} cal',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 1480 → "1,480" — basic thousand-separator without intl dep.
  static String _formatNumber(num value) {
    final str = value.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.strokeWidth});

  /// 0.0 → 1.0
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1) Track — dim cyan full circle
    final trackPaint = Paint()
      ..color = AppColors.primaryCyan.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (progress <= 0) return;

    // 2) Glow halo — wider, blurry cyan arc behind the fill
    final glowPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.pi * 2,
        colors: [
          AppColors.primaryCyan.withValues(alpha: 0.6),
          AppColors.cyanGlow.withValues(alpha: 0.6),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sweep = math.pi * 2 * progress;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glowPaint);

    // 3) Fill — sharp cyan gradient arc on top
    final fillPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.pi * 2,
        colors: [
          AppColors.primaryCyan,
          AppColors.cyanGlow,
          AppColors.primaryCyan,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweep, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.strokeWidth != strokeWidth;
}
