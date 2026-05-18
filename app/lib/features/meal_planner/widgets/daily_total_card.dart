import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Card showing consumed/target kcal with an inline circular donut.
///
/// Layout:
/// ┌──────────────────────────────────────┐
/// │ Daily Total                ╭──────╮  │
/// │ 1,680 kcal                 │ 80%  │  │
/// │ Target: 2,100 kcal   80%   │ of   │  │
/// │ ▰▰▰▰▰▰▰▰▱▱▱▱▱            │ goal │  │
/// │                            ╰──────╯  │
/// └──────────────────────────────────────┘
class DailyTotalCard extends StatelessWidget {
  final double consumed;
  final double target;

  const DailyTotalCard({
    super.key,
    required this.consumed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final percent = target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);
    final percentInt = (percent * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _leftContent(percent, percentInt)),
          const SizedBox(width: 16),
          _MiniDonut(percent: percent),
        ],
      ),
    );
  }

  Widget _leftContent(double percent, int percentInt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Daily Total',
          style: TextStyle(
            color: Color(0xFFB8C5D6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              NumberFormat('#,###').format(consumed),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'kcal',
              style: TextStyle(
                color: Color(0xFFB8C5D6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Target: ${NumberFormat('#,###').format(target)} kcal',
              style: const TextStyle(
                color: Color(0xFFB8C5D6),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              '$percentInt%',
              style: const TextStyle(
                color: Color(0xFF00D4FF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ProgressBar(percent: percent),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double percent;
  const _ProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: Stack(
          children: [
            Container(color: Colors.white.withOpacity(0.08)),
            FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF4DDBFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniDonut extends StatelessWidget {
  final double percent;
  const _MiniDonut({required this.percent});

  @override
  Widget build(BuildContext context) {
    final percentInt = (percent * 100).round();
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(82, 82),
            painter: _DonutPainter(percent: percent),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentInt%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'of goal',
                style: TextStyle(
                  color: Color(0xFFB8C5D6),
                  fontSize: 10,
                  height: 1,
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
  final double percent;
  _DonutPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (stroke / 2) - 1;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    final bg = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, bg);

    // Foreground arc
    final fg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00D4FF), Color(0xFF4DDBFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -1.5707963; // -π/2 → start at 12 o'clock
    final sweep = 6.2831853 * percent; // 2π * pct
    canvas.drawArc(rect, startAngle, sweep, false, fg);
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.percent != percent;
}
