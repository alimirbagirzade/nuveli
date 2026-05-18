import 'package:flutter/material.dart';

import '../models/habit_reminder.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _secondaryText = Color(0xFFB8C5D6);

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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Upcoming Reminders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: List.generate(reminders.length, (i) {
              final r = reminders[i];
              final isLast = i == reminders.length - 1;
              return Column(
                children: [
                  _ReminderTile(
                    reminder: r,
                    onChanged: (v) => onToggle?.call(r.id, v),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.06),
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

class _ReminderTile extends StatelessWidget {
  final HabitReminder reminder;
  final ValueChanged<bool>? onChanged;

  const _ReminderTile({required this.reminder, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _cyan.withOpacity(0.12),
              border: Border.all(color: _cyan.withOpacity(0.35), width: 1),
            ),
            child: Icon(reminder.icon, size: 20, color: _cyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reminder.timeText,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: reminder.isEnabled,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _cyan,
            inactiveTrackColor: Colors.white.withOpacity(0.15),
            inactiveThumbColor: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
