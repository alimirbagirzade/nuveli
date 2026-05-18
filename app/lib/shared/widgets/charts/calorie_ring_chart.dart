import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '_ring_painter.dart';

/// Large progress ring used on the Dashboard "Today's Summary" card.
///
/// Renders an animated aqua ring with consumed / target calorie values
/// stacked vertically in the center, and a "X kcal left" caption below.
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
                      color: AppColors.primary.withOpacity(0.4),
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
                  color: AppColors.primary,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatNumber(consumed),
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 44,
                          height: 1.0,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/ ${_formatNumber(target)} kcal',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$percent%',
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.primary,
                          fontSize: 26,
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
        const SizedBox(height: 16),
        Text(
          '${_formatNumber(remaining)} kcal left',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
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
