import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/l10n/generated/app_localizations.dart';

/// Container that places two equal-height cards side by side.
///
/// In Chat 6 the left slot is the WeightGoalCard and the right slot is the
/// StreakCard. Each parent screen passes already-built widgets so this widget
/// stays layout-only.
class GoalsRow extends StatelessWidget {
  final Widget leftCard;
  final Widget rightCard;

  const GoalsRow({
    super.key,
    required this.leftCard,
    required this.rightCard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: leftCard),
            const SizedBox(width: AppSpacing.s12),
            Expanded(child: rightCard),
          ],
        ),
      ),
    );
  }
}

/// Inline StreakCard for use as the right slot of [GoalsRow].
///
/// Built locally to avoid coupling with `shared/widgets/streak_card.dart`
/// (its exact signature is not verified for this branch).
class StreakDisplayCard extends StatelessWidget {
  final int streakDays;

  const StreakDisplayCard({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: AppColors.cardBackground,
        border: Border.all(
          color: AppColors.streakFire.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakFire.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.streakFire,
                      AppColors.warning,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  l10n?.profileStreak ?? 'Streak',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              style: AppTypography.heroLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
              children: [
                TextSpan(text: '$streakDays'),
                TextSpan(
                  text: streakDays == 1
                      ? ' ${l10n?.profileStreakDay ?? 'day'}'
                      : ' ${l10n?.profileStreakDays ?? 'days'}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            streakDays > 0
                ? (l10n?.profileStreakKeepGoing ?? 'Keep it going!')
                : (l10n?.profileStreakStartToday ??
                    'Log a meal today to start'),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
