import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Horizontal 7-day calendar strip.
///
/// Layout per day: weekday label (Mon/Tue/…) → date number (in a 36px circle,
/// cyan-filled when selected) → daily kcal value.
class WeeklyCalendar extends StatelessWidget {
  final DateTime selectedDate;

  /// Map of date → total kcal. Keys are sorted ascending internally.
  final Map<DateTime, double> weekData;

  final ValueChanged<DateTime> onDateSelected;

  const WeeklyCalendar({
    super.key,
    required this.selectedDate,
    required this.weekData,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final days = weekData.keys.toList()..sort();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: days.map((d) {
          final kcal = weekData[d] ?? 0;
          final isSelected = _isSameDay(d, selectedDate);
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onDateSelected(d),
              child: _DayItem(date: d, kcal: kcal, selected: isSelected),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayItem extends StatelessWidget {
  final DateTime date;
  final double kcal;
  final bool selected;

  const _DayItem({
    required this.date,
    required this.kcal,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('E').format(date); // Mon, Tue, ...
    final kcalText = NumberFormat('#,###').format(kcal);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayLabel,
          style: TextStyle(
            color: selected
                ? const Color(0xFF00D4FF)
                : const Color(0xFFB8C5D6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            shape: BoxShape.circle,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          kcalText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'kcal',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            height: 1,
          ),
        ),
      ],
    );
  }
}
