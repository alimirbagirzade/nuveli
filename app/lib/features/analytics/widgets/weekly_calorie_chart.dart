import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/weekly_analytics.dart';

/// 7-day calorie bars with a target line. Green when within ±15% of
/// the user's daily target, amber otherwise. Today highlighted.
class WeeklyCalorieChart extends StatelessWidget {
  final WeeklyAnalytics analytics;

  const WeeklyCalorieChart({super.key, required this.analytics});

  static const _barWithin = Color(0xFF3DDC97);
  static const _barOutside = Color(0xFFFFB454);
  static const _barEmpty = Color(0xFF2A3855);
  static const _targetLineColor = Color(0xFF4DDBFF);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = analytics.days;
    if (days.isEmpty) {
      return _EmptyState(l10n: l10n);
    }

    final maxValForScale = days
        .map((d) => d.calories)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final target = days.first.target;
    final scaleMax = (maxValForScale * 1.15)
        .clamp(target.toDouble(), double.infinity)
        .toInt();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n?.analyticsLast7Days ?? 'Last 7 days',
                style: const TextStyle(
                  color: Color(0xFFB8C5D6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                l10n?.analyticsDaysOnTarget(analytics.daysWithinTarget) ??
                    '${analytics.daysWithinTarget}/7 days on target',
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
            height: 100,
            child: Stack(
              children: [
                // Target reference line
                if (target > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 100 * (1 - target / scaleMax),
                    child: const _DashedLine(color: _targetLineColor),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: days.map((d) {
                    return Expanded(
                      child: _CalorieBar(day: d, scaleMax: scaleMax),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: days
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        _weekdayLabel(d.day),
                        style: TextStyle(
                          color: d.isToday
                              ? const Color(0xFF4DDBFF)
                              : const Color(0xFF6E7B91),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                l10n?.analyticsKcalAvg(
                        analytics.avgDailyCalories.toStringAsFixed(0)) ??
                    '${analytics.avgDailyCalories.toStringAsFixed(0)} kcal avg',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.analyticsTarget(target) ?? '· target $target',
                style: const TextStyle(
                  color: Color(0xFF6E7B91),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _weekdayLabel(DateTime d) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[(d.weekday - 1).clamp(0, 6)];
  }
}

class _CalorieBar extends StatelessWidget {
  final WeeklyCalorieDay day;
  final int scaleMax;

  const _CalorieBar({required this.day, required this.scaleMax});

  @override
  Widget build(BuildContext context) {
    final empty = day.calories <= 0;
    final color = empty
        ? WeeklyCalorieChart._barEmpty
        : day.withinTarget
            ? WeeklyCalorieChart._barWithin
            : WeeklyCalorieChart._barOutside;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          final fraction = scaleMax > 0
              ? (day.calories / scaleMax).clamp(0.0, 1.0)
              : 0.0;
          final h = empty ? 4.0 : (4 + (maxH - 4) * fraction);
          return Container(
            alignment: Alignment.bottomCenter,
            child: Container(
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
            ),
          );
        },
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: Row(
        children: List.generate(40, (i) {
          return Container(
            width: 4,
            margin: const EdgeInsets.only(right: 3),
            height: 1,
            color: color.withValues(alpha: 0.4),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations? l10n;
  const _EmptyState({this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Center(
        child: Text(
          l10n?.analyticsWeeklyEmpty ??
              'Log a few meals to see your weekly trend',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB8C5D6),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
