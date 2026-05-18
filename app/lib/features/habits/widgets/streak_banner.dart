import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../../../shared/widgets/streak_card.dart';

/// Top banner combining a streak headline with today's progress bar.
///
/// Composite of:
///   - Top:    StreakCard (.large) — 🔥 18 day streak + motivational subtitle
///   - Middle: 1px divider @ 10% white
///   - Bottom: "4 of 5 habits completed" + animated cyan progress bar
class StreakBanner extends StatelessWidget {
  final int streakDays;
  final int habitsCompleted;
  final int habitsTotal;

  const StreakBanner({
    super.key,
    required this.streakDays,
    required this.habitsCompleted,
    required this.habitsTotal,
  });

  double get _progress =>
      habitsTotal <= 0 ? 0.0 : (habitsCompleted / habitsTotal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top — streak headline (uses the shared StreakCard widget at .large size,
          // rendered without its own decoration so it lives inside this banner cleanly).
          StreakCard(
            streakDays: streakDays,
            size: StreakCardSize.large,
            decorated: false,
            subtitle: "Keep it up! You're doing great.",
          ),
          const SizedBox(height: AppSpacing.md),
          // Divider
          Container(
            height: 1,
            color: AppColors.textSecondary.withOpacity(0.10),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          // Progress label
          Text(
            '$habitsCompleted of $habitsTotal habits completed',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 4),
          // Progress bar
          _ProgressBar(value: _progress),
        ],
      ),
    );
  }
}

/// Animated cyan progress bar (6px high, fully rounded).
class _ProgressBar extends StatelessWidget {
  final double value;

  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            // Track
            Container(
              height: 6,
              width: width,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            // Fill (animated)
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: 6,
              width: width * value,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                gradient: const LinearGradient(
                  colors: [AppColors.primaryCyan, AppColors.cyanGlow],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.35),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
