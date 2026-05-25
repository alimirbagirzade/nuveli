import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/exercise_summary.dart';
import 'calorie_badge.dart';

/// Compact 7-day activity bar chart that sits under the [ExerciseQuickCard]
/// on the dashboard. Mirrors `WaterWeeklyChart` — pure layout, no chart dep.
///
/// Each bar height scales by that day's minutes relative to the week's busiest
/// day (clamped), so the shape reflects relative effort. Today's bar is
/// highlighted. Shows week total minutes and, when present, an informational
/// week-total "≈ kcal" badge.
///
/// Wellness boundary: minutes + an informational calorie estimate only. NO
/// calorie-budget framing — the kcal figure is display-only and never tied to
/// what the user can eat. See `docs/protocols/safety-wellness-boundary.md`.
class ExerciseWeeklyChart extends StatelessWidget {
  final ExerciseWeekly weekly;

  const ExerciseWeeklyChart({super.key, required this.weekly});

  static const _bgColor = Color(0xFF142346);
  static const _barColor = Color(0xFF4ADE80);
  static const _barColorToday = Color(0xFF86EFAC);
  static const _barColorMissed = Color(0xFF2A3855);
  static const _labelColor = Color(0xFFB8C5D6);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (weekly.days.isEmpty) return const SizedBox.shrink();

    final maxMinutes = weekly.days
        .map((d) => d.totalMinutes)
        .fold<int>(0, (a, b) => b > a ? b : a);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _bgColor.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n?.exerciseThisWeek ?? 'This week',
                style: const TextStyle(
                  color: _labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                l10n?.exerciseWeekTotalMinutes(weekly.weekTotalMinutes) ??
                    '${weekly.weekTotalMinutes} min total',
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
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekly.days
                  .map((d) => Expanded(
                        child: _Bar(day: d, maxMinutes: maxMinutes),
                      ))
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
                        _weekdayLabel(context, d.day),
                        style: TextStyle(
                          color: d.isToday
                              ? _barColorToday
                              : _labelColor.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight:
                              d.isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          // Informational week-total calorie estimate — only when present.
          if (weekly.weekTotalCalories != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                CalorieBadge(kcal: weekly.weekTotalCalories!, prominent: true),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.exerciseWeekCaloriesNote ??
                        'Estimated energy used this week',
                    style: const TextStyle(
                      color: Color(0xFF6E7B91),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _weekdayLabel(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.E(locale).format(d);
  }
}

class _Bar extends StatelessWidget {
  final ExerciseDayTotal day;
  final int maxMinutes;
  const _Bar({required this.day, required this.maxMinutes});

  @override
  Widget build(BuildContext context) {
    final fraction =
        maxMinutes <= 0 ? 0.0 : (day.totalMinutes / maxMinutes).clamp(0.0, 1.0);
    final empty = day.totalMinutes <= 0;
    final color = empty
        ? ExerciseWeeklyChart._barColorMissed
        : day.isToday
            ? ExerciseWeeklyChart._barColorToday
            : ExerciseWeeklyChart._barColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          // Always render at least 4px so empty days show a visible floor.
          final h = empty ? 4.0 : (4 + (maxH - 4) * fraction);
          return Container(
            width: double.infinity,
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: empty
                  ? null
                  : LinearGradient(
                      colors: [color, color.withValues(alpha: 0.55)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              color: empty ? color : null,
            ),
          );
        },
      ),
    );
  }
}
