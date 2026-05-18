import 'package:flutter/material.dart';

/// Top-level view mode for the Meal Planner screen.
enum PlannerView { today, week }

/// Pill-shaped segmented control between "Today" and "Week".
///
/// Smoothly animates the cyan-gradient selection background between
/// segments (200ms easeOutCubic) per the design spec.
class TodayWeekToggle extends StatelessWidget {
  final PlannerView currentView;
  final ValueChanged<PlannerView> onChanged;

  const TodayWeekToggle({
    super.key,
    required this.currentView,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = (constraints.maxWidth - 8) / 2;
          final isWeek = currentView == PlannerView.week;
          return SizedBox(
            height: 40,
            child: Stack(
              children: [
                // Sliding selection background.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: isWeek ? segmentWidth : 0,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _segment(
                        label: 'Today',
                        selected: currentView == PlannerView.today,
                        onTap: () => onChanged(PlannerView.today),
                      ),
                    ),
                    Expanded(
                      child: _segment(
                        label: 'Week',
                        selected: currentView == PlannerView.week,
                        onTap: () => onChanged(PlannerView.week),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _segment({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFFB8C5D6),
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
