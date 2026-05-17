import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Kamera viewfinder üzerine 4 köşeli L-şekli + 3x3 grid çizer.
class ScanFramePainter extends CustomPainter {
  final Color cornerColor;
  final double cornerLength;
  final double cornerStroke;

  const ScanFramePainter({
    this.cornerColor = AppColors.primary,
    this.cornerLength = 30.0,
    this.cornerStroke = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = cornerColor
      ..strokeWidth = cornerStroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(Offset(0, cornerLength), Offset.zero, cornerPaint);
    canvas.drawLine(Offset.zero, Offset(cornerLength, 0), cornerPaint);

    // Top-right
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height),
      cornerPaint,
    );

    // 3x3 grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    final w = size.width / 3;
    final h = size.height / 3;
    canvas.drawLine(Offset(w, 0), Offset(w, size.height), gridPaint);
    canvas.drawLine(Offset(w * 2, 0), Offset(w * 2, size.height), gridPaint);
    canvas.drawLine(Offset(0, h), Offset(size.width, h), gridPaint);
    canvas.drawLine(Offset(0, h * 2), Offset(size.width, h * 2), gridPaint);
  }

  @override
  bool shouldRepaint(covariant ScanFramePainter old) =>
      old.cornerColor != cornerColor ||
      old.cornerLength != cornerLength ||
      old.cornerStroke != cornerStroke;
}
