import 'package:flutter/material.dart';
import '../_shared/dashboard_theme.dart';
import '../_shared/glass_card.dart';
import '../_shared/meal_tile.dart';
import '../models/meal.dart';

class MealsSection extends StatelessWidget {
  final List<Meal> meals;
  final VoidCallback? onViewAll;
  final void Function(Meal)? onMealTap;

  const MealsSection({
    super.key,
    required this.meals,
    this.onViewAll,
    this.onMealTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Meals',
              style: TextStyle(
                color: DashboardColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onViewAll ?? () => debugPrint('View all tapped'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View all',
                style: TextStyle(
                  color: DashboardColors.cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (meals.isEmpty)
          const _EmptyState()
        else
          NuveliCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < meals.length; i++) ...[
                  MealListTile(
                    meal: meals[i],
                    onTap: () => onMealTap?.call(meals[i]),
                  ),
                  if (i < meals.length - 1)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: DashboardColors.textSecondary.withOpacity(0.15),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: const Center(
        child: Text(
          'No meals logged yet.\nTap + Add Food to start.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DashboardColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
