import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../providers/habits_providers.dart';

/// Dashboard "Today's habits" panel. Loads /habits and renders each
/// as a tappable check tile that POSTs the completion. Tap is
/// optimistic — the row's check state flips before the network call
/// resolves so the user doesn't feel a delay.
class HabitsTodaySection extends ConsumerWidget {
  const HabitsTodaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF142346).withValues(alpha: 0.5),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: habitsAsync.when(
          loading: () => const _Skeleton(),
          // Quietly hide the section on error rather than showing
          // a scary red banner — habits aren't critical to the
          // primary dashboard read.
          error: (_, __) => const SizedBox.shrink(),
          data: (habits) {
            if (habits.isEmpty) return const _Empty();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                const SizedBox(height: 8),
                ...habits.map((h) => _HabitRow(habit: h)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final done = habitsAsync.maybeWhen(
      data: (list) => list.where((h) => h.completedToday).length,
      orElse: () => 0,
    );
    final total = habitsAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    return Row(
      children: [
        const Text(
          "Today's habits",
          style: TextStyle(
            color: Color(0xFFB8C5D6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (total > 0)
          Text(
            '$done/$total',
            style: const TextStyle(
              color: Color(0xFF6E7B91),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _HabitRow extends ConsumerStatefulWidget {
  final Habit habit;
  const _HabitRow({required this.habit});

  @override
  ConsumerState<_HabitRow> createState() => _HabitRowState();
}

class _HabitRowState extends ConsumerState<_HabitRow> {
  late bool _checked;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checked = widget.habit.completedToday;
  }

  @override
  void didUpdateWidget(_HabitRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habit.completedToday != widget.habit.completedToday) {
      _checked = widget.habit.completedToday;
    }
  }

  Future<void> _toggle() async {
    if (_isSubmitting) return;
    final next = !_checked;
    setState(() {
      _checked = next; // Optimistic
      _isSubmitting = true;
    });
    try {
      await ref.read(toggleHabitProvider)(widget.habit.id, next);
    } catch (e) {
      if (mounted) {
        setState(() => _checked = !next); // Rollback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update habit')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
          children: [
            Text(
              _displayIcon(widget.habit.icon),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.habit.name.isEmpty ? 'Habit' : widget.habit.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.habit.currentStreak > 0)
                    Text(
                      '🔥 ${widget.habit.currentStreak}-day streak',
                      style: const TextStyle(
                        color: Color(0xFF6E7B91),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            _CheckMark(checked: _checked),
          ],
        ),
      ),
    );
  }

  /// Maps the icon key (could be emoji, Material icon name, or null)
  /// to a printable string for the row. Keeps Habit UI dep-free.
  static String _displayIcon(String? raw) {
    if (raw == null || raw.isEmpty) return '•';
    // Emoji → use as-is.
    final firstRune = raw.runes.first;
    if (firstRune > 127) return raw;
    // Material icon name → friendly emoji fallback.
    const map = {
      'rice_bowl': '🍚',
      'water_drop': '💧',
      'directions_run': '🏃',
      'fitness_center': '💪',
      'nightlight_round': '🌙',
      'self_improvement': '🧘',
      'local_fire_department': '🔥',
    };
    return map[raw] ?? '✨';
  }
}

class _CheckMark extends StatelessWidget {
  final bool checked;
  const _CheckMark({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked
            ? const Color(0xFF00D4FF)
            : Colors.transparent,
        border: Border.all(
          color: checked
              ? const Color(0xFF00D4FF)
              : const Color(0xFFB8C5D6).withValues(alpha: 0.4),
          width: 1.6,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
                Colors.white.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'No habits yet — defaults will appear on first login',
        style: TextStyle(color: Color(0xFFB8C5D6), fontSize: 13),
      ),
    );
  }
}
