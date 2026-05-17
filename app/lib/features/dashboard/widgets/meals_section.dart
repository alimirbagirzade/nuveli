import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/shared/widgets/meal_list_tile.dart';
import 'package:nuveli/shared/widgets/nuveli_card.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Meals',
              style: AppTypography.cardTitle.copyWith(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onViewAll ??
                  () => debugPrint(
                      'View all tapped - Chat 9 routes to MealsListScreen'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View all',
                style: AppTypography.body.copyWith(
                  color: AppColors.primaryCyan,
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
                  MealListTile.dashboard(
                    meal: meals[i],
                    onTap: () => onMealTap?.call(meals[i]),
                  ),
                  if (i < meals.length - 1)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: AppColors.secondaryText.withOpacity(0.15),
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
      child: Center(
        child: Text(
          'No meals logged yet.\nTap + Add Food to start.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: AppColors.secondaryText,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
