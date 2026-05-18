import 'package:flutter/material.dart';

import '../models/habit.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _cyanGlow = Color(0xFF4DDBFF);
const Color _secondaryText = Color(0xFFB8C5D6);

/// Section: "Today's Habits" header + a card containing habit tiles.
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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Today's Habits",
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
            children: List.generate(habits.length, (i) {
              final habit = habits[i];
              final isLast = i == habits.length - 1;
              return Column(
                children: [
                  _HabitTile(
                    habit: habit,
                    onChanged: (v) => onToggle?.call(habit.id, v),
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

/// One habit row: icon + title/subtitle + check toggle (solid cyan when on).
class _HabitTile extends StatelessWidget {
  final Habit habit;
  final ValueChanged<bool>? onChanged;

  const _HabitTile({required this.habit, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onChanged?.call(!habit.isCompleted),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Round icon background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: habit.iconColor.withOpacity(0.15),
                border: Border.all(
                  color: habit.iconColor.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Icon(habit.icon, size: 20, color: habit.iconColor),
            ),
            const SizedBox(width: 12),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habit.subtitle,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Animated check circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: habit.isCompleted
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_cyan, _cyanGlow],
                      )
                    : null,
                color: habit.isCompleted ? null : Colors.transparent,
                border: Border.all(
                  color: habit.isCompleted
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: habit.isCompleted
                    ? [
                        BoxShadow(
                          color: _cyan.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: habit.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Colors.white,
                        key: ValueKey('checked'),
                      )
                    : const SizedBox.shrink(key: ValueKey('unchecked')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
