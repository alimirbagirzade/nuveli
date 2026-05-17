import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/streak_card.dart';
import '../models/user_goals.dart';
import 'weight_goal_card.dart';

/// Side-by-side row of [WeightGoalCard] and a small [StreakCard].
///
/// Uses [IntrinsicHeight] so both cards stretch to the same height regardless
/// of their natural content height.
class GoalsRow extends StatelessWidget {
  final WeightGoal weightGoal;
  final int streakDays;

  const GoalsRow({
    super.key,
    required this.weightGoal,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: WeightGoalCard(weightGoal: weightGoal)),
          const SizedBox(width: AppSpacing.sm + 4), // 12
          Expanded(
            child: StreakCard(
              size: StreakCardSize.small,
              streakDays: streakDays,
              title: 'Daily Streak',
              subtitle: 'Keep it up!',
              // Mockup shows 5 lit flames + 1 empty water drop slot → 6 visible.
              totalSlots: 6,
            ),
          ),
        ],
      ),
    );
  }
}
