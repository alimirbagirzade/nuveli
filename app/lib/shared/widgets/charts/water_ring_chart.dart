import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '_ring_painter.dart';

/// Progress ring used on the Water Tracker screen.
///
/// Shares the same visual base as [CalorieRingChart] but displays liter
/// values (e.g. "2.1 L / 3.0 L") and a "X L left to goal" caption.
class WaterRingChart extends StatelessWidget {
  const WaterRingChart({
    super.key,
    required this.consumedLiters,
    required this.targetLiters,
    this.size = 220,
    this.showGlow = true,
    this.animDuration = const Duration(milliseconds: 800),
  });

  final double consumedLiters;
  final double targetLiters;
  final double size;
  final bool showGlow;
  final Duration animDuration;

  @override
  Widget build(BuildContext context) {
    final progress = targetLiters > 0
        ? (consumedLiters / targetLiters).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).round();
    final remaining =
        (targetLiters - consumedLiters).clamp(0.0, double.infinity);

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
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 44,
                            height: 1.0,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: consumedLiters.toStringAsFixed(1),
                            ),
                            TextSpan(
                              text: '  L',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/ ${targetLiters.toStringAsFixed(1)} L',
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
          '${remaining.toStringAsFixed(1)} L left to goal',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
