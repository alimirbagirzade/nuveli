import 'package:flutter/material.dart';

import '../models/today_summary.dart';

/// "Today's Summary" hero card — big calorie ring with consumed/target in center.
///
/// We render the ring inline here (CustomPainter) so the section doesn't
/// depend on a specific `CalorieRingChart` API surface from Chat 2.
/// If you'd rather use the shared chart, swap the [_CalorieRing] widget
/// for `CalorieRingChart(consumed: ..., target: ...)`.
class TodaysSummarySection extends StatelessWidget {
  final TodaySummary summary;
  const TodaysSummarySection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final consumed = summary.consumedCalories;
    final target = summary.dailyCalorieTarget;
    final remaining = summary.remainingCalories;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF142346).withOpacity(0.6),
            const Color(0xFF0B1A3D).withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.12),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Today's Summary",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFB8C5D6),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 200,
            child: _CalorieRing(
              progress: progress,
              consumed: consumed,
              target: target,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            remaining >= 0
                ? '${_formatNumber(remaining)} kcal remaining'
                : '${_formatNumber(remaining.abs())} kcal over',
            style: TextStyle(
              fontSize: 14,
              color: remaining >= 0
                  ? const Color(0xFFB8C5D6)
                  : const Color(0xFFFF9F45),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _CalorieRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final int consumed;
  final int target;

  const _CalorieRing({
    required this.progress,
    required this.consumed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(200, 200),
          painter: _RingPainter(progress: progress),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              TodaysSummarySection._formatNumber(consumed),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'of ${TodaysSummarySection._formatNumber(target)} kcal',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB8C5D6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 12.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring with cyan glow
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -1.5708, // -90 degrees (12 o'clock)
        endAngle: -1.5708 + 6.2832,
        colors: const [
          Color(0xFF00D4FF),
          Color(0xFF4DDBFF),
          Color(0xFF00D4FF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // start at top
      6.2832 * progress, // sweep
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
