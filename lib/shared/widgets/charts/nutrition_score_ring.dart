import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '_ring_painter.dart';

/// Compact ring chart used on the AI Coach Insights screen.
///
/// Color and label adapt to the score range:
/// - 90-100: Excellent (success green)
/// - 80-89:  Great     (success green)
/// - 70-79:  Good      (primary cyan)
/// - 60-69:  Fair      (primary cyan)
/// - <60:    Needs work (warning / danger)
class NutritionScoreRing extends StatelessWidget {
  const NutritionScoreRing({
    super.key,
    required this.score,
    this.size = 100,
    this.animDuration = const Duration(milliseconds: 800),
  });

  /// Score from 0 to 100. Values outside are clamped.
  final int score;
  final double size;
  final Duration animDuration;

  Color _colorForScore(int s) {
    if (s >= 80) return AppColors.success;
    if (s >= 60) return AppColors.primaryCyan;
    if (s >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  String _labelForScore(int s) {
    if (s >= 90) return 'Excellent';
    if (s >= 80) return 'Great';
    if (s >= 70) return 'Good';
    if (s >= 60) return 'Fair';
    return 'Needs work';
  }

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0, 100);
    final progress = clamped / 100;
    final color = _colorForScore(clamped);
    final label = _labelForScore(clamped);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: animDuration,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: RingPainter(
              progress: value,
              color: color,
              strokeWidth: 8,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$clamped',
                    style: AppTypography.sectionTitle.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
}
