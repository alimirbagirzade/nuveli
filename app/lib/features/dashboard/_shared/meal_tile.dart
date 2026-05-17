import 'package:flutter/material.dart';
import '../models/meal.dart';
import 'dashboard_theme.dart';

class MealListTile extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;

  const MealListTile({super.key, required this.meal, this.onTap});

  factory MealListTile.dashboard({
    Key? key,
    required Meal meal,
    VoidCallback? onTap,
  }) =>
      MealListTile(key: key, meal: meal, onTap: onTap);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  meal.type.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      meal.type.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${meal.name} • ${meal.formattedTime}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DashboardColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${meal.calories} kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.cyan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
