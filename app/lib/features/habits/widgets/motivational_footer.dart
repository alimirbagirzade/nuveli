import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';

/// Footer card encouraging the user to keep going.
///
/// Layout: ⭐ icon (glowing cyan) | "Small actions build lasting results."
/// + italic secondary subtitle "Keep showing up for yourself."
class MotivationalFooter extends StatelessWidget {
  const MotivationalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: const EdgeInsets.all(AppSpacing.sm + 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _GlowingStar(),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Small actions build lasting results.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Keep showing up for yourself.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 36x36 rounded square holding a 22px cyan star with a soft glow.
class _GlowingStar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryCyan.withOpacity(0.20),
            AppColors.primaryCyan.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withOpacity(0.25),
            blurRadius: 14,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.star_rounded,
          size: 22,
          color: AppColors.cyanGlow,
        ),
      ),
    );
  }
}
