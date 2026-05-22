import 'package:flutter/material.dart';

import '../models/water_weekly.dart';

/// Compact 7-day water bar chart that sits under the WaterQuickCard
/// on the dashboard. Pure CustomPaint — no fl_chart dep — because we
/// only need vertical bars with a target line; pulling in a charts
/// package for that would be overkill.
///
/// Each bar height = totalMl / targetMl, clamped [0, 1] so over-drink
/// days don't blow the layout. Today's bar is highlighted.
class WaterWeeklyChart extends StatelessWidget {
  final WaterWeekly weekly;

  const WaterWeeklyChart({super.key, required this.weekly});

  static const _bgColor = Color(0xFF142346);
  static const _barColor = Color(0xFF4DDBFF);
  static const _barColorToday = Color(0xFF00D4FF);
  static const _barColorMissed = Color(0xFF2A3855);
  static const _labelColor = Color(0xFFB8C5D6);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _bgColor.withValues(alpha: 0.5),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'This week',
                style: TextStyle(
                  color: _labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${weekly.daysHittingTarget}/7 days on target',
                style: const TextStyle(
                  color: Color(0xFF6E7B91),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekly.days
                  .map((d) => Expanded(child: _Bar(day: d)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: weekly.days
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        _weekdayLabel(d.day),
                        style: TextStyle(
                          color: d.isToday
                              ? _barColorToday
                              : _labelColor.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: d.isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  static String _weekdayLabel(DateTime d) {
    // Use the host locale's short-weekday convention. Days are 1=Mon..7=Sun.
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[(d.weekday - 1).clamp(0, 6)];
  }
}

class _Bar extends StatelessWidget {
  final WaterDayTotal day;
  const _Bar({required this.day});

  @override
  Widget build(BuildContext context) {
    final fraction = day.fractionOfTarget;
    // Always render at least 4px so empty days show a visible "floor"
    // bar instead of disappearing.
    final filled = fraction <= 0;
    final color = filled
        ? WaterWeeklyChart._barColorMissed
        : day.isToday
            ? WaterWeeklyChart._barColorToday
            : WaterWeeklyChart._barColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          final h = filled ? 4.0 : (4 + (maxH - 4) * fraction);
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Bar
              Container(
                width: double.infinity,
                height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: filled
                      ? null
                      : LinearGradient(
                          colors: [color, color.withValues(alpha: 0.55)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  color: filled ? color : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
