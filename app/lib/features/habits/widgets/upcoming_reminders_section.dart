import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../../../shared/widgets/reminder_toggle_tile.dart';
import '../models/habit_reminder.dart';

/// Section: "Upcoming Reminders" header + a card listing reminder toggles.
class UpcomingRemindersSection extends StatelessWidget {
  final List<HabitReminder> reminders;
  final void Function(String id, bool value)? onToggle;

  const UpcomingRemindersSection({
    super.key,
    required this.reminders,
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
            'Upcoming Reminders',
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
            children: List.generate(reminders.length, (i) {
              final reminder = reminders[i];
              final isLast = i == reminders.length - 1;
              return Column(
                children: [
                  ReminderToggleTile(
                    icon: reminder.icon,
                    title: reminder.title,
                    subtitle: reminder.timeText,
                    initialValue: reminder.isEnabled,
                    onChanged: (v) => onToggle?.call(reminder.id, v),
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
