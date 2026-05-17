import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/nuveli_card.dart';
import '../models/user_goals.dart';

/// Small card showing the user's weight goal (signed kg change, target date,
/// and a slim progress bar with "X kg left" caption).
class WeightGoalCard extends StatelessWidget {
  final WeightGoal weightGoal;

  const WeightGoalCard({super.key, required this.weightGoal});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM d, yyyy').format(weightGoal.targetDate);

    // Signed display: -5.0 kg for loss, +5.0 kg for gain.
    final signedAmount = weightGoal.targetChangeKg;
    final signedLabel =
        '${signedAmount > 0 ? '+' : ''}${signedAmount.toStringAsFixed(1)} kg';

    final remainingLabel =
        '${weightGoal.remainingKg.toStringAsFixed(1)} kg left';

    return NuveliCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Weight Goal',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            signedLabel,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 24,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target by $formattedDate',
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 4), // 12
          _ProgressBar(value: weightGoal.progressRatio),
          const SizedBox(height: AppSpacing.sm),
          Text(
            remainingLabel,
            style: AppTypography.caption.copyWith(
              color: AppColors.primaryCyan,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Slim 4px-tall progress bar with a cyan gradient fill.
class _ProgressBar extends StatelessWidget {
  final double value;

  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: 4,
        color: AppColors.primaryText.withOpacity(0.10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.cyanGlow, AppColors.primaryCyan],
                ),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.50),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
