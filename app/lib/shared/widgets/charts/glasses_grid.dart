import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Horizontal row of glass icons used on the Water Tracker screen (Görsel 5).
///
/// Each glass is a trapezoidal shape (slightly wider at top).
/// Filled glasses show an aqua water gradient with a subtle highlight at
/// the surface; empty glasses show just an outline.
///
/// Tapping any glass invokes [onGlassTap] (typically used to log +1 glass).
///
/// Example:
/// ```dart
/// GlassesGrid(
///   filledCount: 7,
///   totalCount: 10,
///   onGlassTap: () => addGlass(),
/// )
/// ```
class GlassesGrid extends StatelessWidget {
  const GlassesGrid({
    super.key,
    required this.filledCount,
    required this.totalCount,
    this.glassSizeMl = 250,
    this.onGlassTap,
  });

  final int filledCount;
  final int totalCount;
  final int glassSizeMl;
  final VoidCallback? onGlassTap;

  @override
  Widget build(BuildContext context) {
    final filledLiters = (filledCount * glassSizeMl) / 1000.0;
    final totalLiters = (totalCount * glassSizeMl) / 1000.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: totalCount,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final isFilled = i < filledCount;
              return GestureDetector(
                onTap: onGlassTap,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 30,
                  height: 48,
                  child: CustomPaint(
                    painter: _GlassPainter(filled: isFilled),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '$filledCount of $totalCount glasses · '
          '${filledLiters.toStringAsFixed(1)} L / ${totalLiters.toStringAsFixed(1)} L',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Internal painter for a single glass shape.
/// Draws a slightly tapered trapezoid with optional water fill.
class _GlassPainter extends CustomPainter {
  _GlassPainter({required this.filled});

  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Slight inward taper at the bottom for a glass silhouette.
    final topInset = w * 0.05;
    final bottomInset = w * 0.18;

    final glassPath = Path()
      ..moveTo(topInset, 2)
      ..lineTo(w - topInset, 2)
      ..lineTo(w - bottomInset, h - 2)
      ..lineTo(bottomInset, h - 2)
      ..close();

    if (filled) {
      // Water fill with aqua gradient.
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accent.withOpacity(0.95),
            AppColors.primary,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawPath(glassPath, fillPaint);

      // Highlight line at the water surface.
      final surfacePaint = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(topInset + 1, 5),
        Offset(w - topInset - 1, 5),
        surfacePaint,
      );
    }

    // Outline on top of fill so it's always visible.
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(glassPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _GlassPainter old) => old.filled != filled;
}