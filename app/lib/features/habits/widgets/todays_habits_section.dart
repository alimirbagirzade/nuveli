import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/habit_check_tile.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../models/habit.dart';

/// Section: "Today's Habits" header + a card containing the 5 habit tiles
/// separated by hairline dividers.
class TodaysHabitsSection extends StatelessWidget {
  final List<Habit> habits;
  final void Function(String id, bool value)? onToggle;

  const TodaysHabitsSection({
    super.key,
    required this.habits,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            "Today's Habits",
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        NuveliCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(habits.length, (i) {
              final habit = habits[i];
              final isLast = i == habits.length - 1;
              return Column(
                children: [
                  HabitCheckTile(
                    icon: habit.icon,
                    iconColor: habit.iconColor,
                    title: habit.title,
                    subtitle: habit.subtitle,
                    initialChecked: habit.isCompleted,
                    onChanged: (v) => onToggle?.call(habit.id, v),
                  ),
                  if (!isLast)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Container(
                        height: 1,
                        color: AppColors.textSecondary.withOpacity(0.10),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
