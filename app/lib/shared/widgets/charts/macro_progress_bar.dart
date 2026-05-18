import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Macro nutrient colors used by [MacroProgressBar] and [MacroDonutChart].
///
/// These are kept local (not in AppColors) so the chart layer remains
/// self-contained. If you later decide to expose them globally, move
/// them into AppColors and update both files.
class MacroColors {
  MacroColors._();
  static const Color protein = Color(0xFF3DDC97); // green-teal
  static const Color carbs = Color(0xFF6BCB77);   // green
  static const Color fat = Color(0xFFFF9F45);     // orange
}

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
///   color: MacroColors.protein,
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
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${current.toStringAsFixed(0)}$unit / ${target.toStringAsFixed(0)}$unit',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
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
