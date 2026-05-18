import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Compact macro nutrient card used on Dashboard and AI Coach screens.
///
/// Vertical layout: icon → label → "current / target" → thin progress bar.
/// Designed to be placed in a [Row] of three (Protein / Carbs / Fat).
///
/// Example:
/// ```dart
/// MacroProgressBar(
///   label: 'Protein',
///   current: 95,
///   target: 140,
///   icon: Icons.fitness_center,
///   color: AppColors.protein,
/// )
/// ```
class MacroProgressBar extends StatelessWidget {
  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.icon,
    required this.color,
    this.unit = 'g',
    this.animDuration = const Duration(milliseconds: 800),
  });

  final String label;
  final double current;
  final double target;
  final String unit;
  final IconData icon;
  final Color color;
  final Duration animDuration;

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${current.toStringAsFixed(0)}$unit / ${target.toStringAsFixed(0)}$unit',
          style: AppTypography.body.copyWith(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: animDuration,
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.7), color],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
