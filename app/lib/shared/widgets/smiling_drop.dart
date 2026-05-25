import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nuveli's brand mark: a cute, smiling water drop drawn in code so it stays
/// crisp at any size and needs no raster asset. Use this everywhere a water
/// drop appears (splash, water card, onboarding, streaks…) for a consistent,
/// friendly water identity.
///
/// `size` is the drop's height in logical pixels; width is ~0.86 × height.
/// At small sizes (< 34) the cheeks and eye-sparkles are dropped so the face
/// stays readable.
class SmilingDrop extends StatelessWidget {
  const SmilingDrop({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 0.76,
      height: size,
      child: CustomPaint(painter: _SmilingDropPainter(detailed: size >= 30)),
    );
  }
}

class _SmilingDropPainter extends CustomPainter {
  const _SmilingDropPainter({required this.detailed});

  final bool detailed;

  static const _lightBlue = Color(0xFF7FE9FF);
  static const _cyan = Color(0xFF22C7F2);
  static const _deepBlue = Color(0xFF0A6FB0);
  static const _faceNavy = Color(0xFF06324F);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final r = w * 0.50; // half-width at the widest point
    final wy = h * 0.62; // height of the widest point (low → elegant)

    // Elegant teardrop as four smooth cubics: a long, gently-tapering top
    // stem that only widens low, then a rounded bottom bulb. No hard circle,
    // so it reads slender rather than chubby.
    final body = Path()
      ..moveTo(cx, 0)
      ..cubicTo(cx + r * 0.42, h * 0.18, cx + r, h * 0.42, cx + r, wy)
      ..cubicTo(cx + r, h * 0.86, cx + r * 0.50, h, cx, h)
      ..cubicTo(cx - r * 0.50, h, cx - r, h * 0.86, cx - r, wy)
      ..cubicTo(cx - r, h * 0.42, cx - r * 0.42, h * 0.18, cx, 0)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lightBlue, _cyan, _deepBlue],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Glossy highlight (upper-left of the bulb).
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - r * 0.38, wy - r * 0.32),
          width: r * 0.38,
          height: r * 0.60),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );

    // Face — big, kawaii eyes + a small smile (no cheeks), sitting in the
    // lower bulb.
    final eyePaint = Paint()..color = _faceNavy;
    final eyeR = w * 0.115;
    final eyeY = h * 0.64;
    final eyeDx = w * 0.195;
    canvas.drawCircle(Offset(cx - eyeDx, eyeY), eyeR, eyePaint);
    canvas.drawCircle(Offset(cx + eyeDx, eyeY), eyeR, eyePaint);

    if (detailed) {
      final sparkle = Paint()..color = Colors.white.withValues(alpha: 0.95);
      canvas.drawCircle(Offset(cx - eyeDx + eyeR * 0.32, eyeY - eyeR * 0.38),
          eyeR * 0.42, sparkle);
      canvas.drawCircle(Offset(cx + eyeDx + eyeR * 0.32, eyeY - eyeR * 0.38),
          eyeR * 0.42, sparkle);
    }

    // Small centered smile.
    final smile = Paint()
      ..color = _faceNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.052
      ..strokeCap = StrokeCap.round;
    final smileRect = Rect.fromCenter(
        center: Offset(cx, eyeY + h * 0.075), width: w * 0.26, height: h * 0.085);
    canvas.drawArc(smileRect, 0.2, math.pi - 0.4, false, smile);
  }

  @override
  bool shouldRepaint(covariant _SmilingDropPainter oldDelegate) =>
      oldDelegate.detailed != detailed;
}
