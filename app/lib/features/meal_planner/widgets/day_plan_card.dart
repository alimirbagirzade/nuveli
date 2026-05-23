import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/weekly_plan.dart';

/// One day of the weekly plan view. Header is the date + day total,
/// body is one row per planned meal (recipe name + meal type + kcal).
class DayPlanCard extends StatelessWidget {
  const DayPlanCard({
    super.key,
    required this.day,
    required this.plans,
  });

  final DailyPlanTotal day;
  final List<MealPlanEntry> plans;

  bool get _isToday {
    final now = DateTime.now();
    return day.planDate.year == now.year &&
        day.planDate.month == now.month &&
        day.planDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isToday ? AppColors.primary : AppColors.border,
          width: _isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (_isToday
                            ? AppColors.primary
                            : const Color(0xFFB8D4D2))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      day.planDate.day.toString(),
                      style: TextStyle(
                        color:
                            _isToday ? AppColors.primary : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _weekdayLabel(day.planDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${day.mealCount} planned · ${day.totalCalories} kcal',
                        style: const TextStyle(
                          color: Color(0xFFB8D4D2),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (plans.isNotEmpty) ...[
            Container(
              height: 1,
              color: AppColors.border,
            ),
            for (final entry in plans)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: _MealRow(entry: entry),
              ),
          ],
        ],
      ),
    );
  }

  static String _weekdayLabel(DateTime d) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[d.weekday - 1];
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.entry});
  final MealPlanEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            entry.mealTypeLabel,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.servings != 1.0)
                Text(
                  '${entry.servings.toStringAsFixed(1)} servings',
                  style: const TextStyle(
                    color: Color(0xFFB8D4D2),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        Text(
          '${entry.totalCalories} kcal',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
