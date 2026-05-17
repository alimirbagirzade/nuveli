import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '_ring_painter.dart';

/// Large progress ring used on the Dashboard "Today's Summary" card.
///
/// Renders an animated cyan ring with consumed / target calorie values
/// stacked vertically in the center, and a "X kcal left" caption below
/// the ring.
///
/// Example:
/// ```dart
/// CalorieRingChart(consumed: 1480, target: 2100)
/// ```
class CalorieRingChart extends StatelessWidget {
  const CalorieRingChart({
    super.key,
    required this.consumed,
    required this.target,
    this.size = 220,
    this.showGlow = true,
    this.animDuration = const Duration(milliseconds: 800),
  });

  final double consumed;
  final double target;
  final double size;
  final bool showGlow;
  final Duration animDuration;

  @override
  Widget build(BuildContext context) {
    final progress =
        target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).round();
    final remaining = (target - consumed).clamp(0.0, double.infinity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: showGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryCyan.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: animDuration,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                painter: RingPainter(
                  progress: value,
                  color: AppColors.primaryCyan,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatNumber(consumed),
                        style: AppTypography.heroNumber.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/ ${_formatNumber(target)} kcal',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '$percent%',
                        style: AppTypography.sectionTitle.copyWith(
                          color: AppColors.primaryCyan,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${_formatNumber(remaining)} kcal left',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  /// Adds thousands separators (1480 -> "1,480").
  String _formatNumber(double n) {
    final i = n.round();
    return i.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
