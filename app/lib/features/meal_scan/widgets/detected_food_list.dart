import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../models/detected_food.dart';

/// "Detected Foods" başlık + N satırlı liste (NuveliCard içinde).
class DetectedFoodList extends StatelessWidget {
  final List<DetectedFood> foods;

  const DetectedFoodList({super.key, required this.foods});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Detected Foods',
            style: AppTypography.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        NuveliCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 4,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              for (var i = 0; i < foods.length; i++) ...[
                _FoodRow(food: foods[i]),
                if (i != foods.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
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

class _FoodRow extends StatelessWidget {
  final DetectedFood food;
  const _FoodRow({required this.food});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              food.icon,
              size: 22,
              color: AppColors.primaryCyan,
            ),
          ),
          const SizedBox(width: 12),
          // Name + portion
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  food.name,
                  style: AppTypography.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  food.portion,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Calories
          Text(
            '${food.calories} kcal',
            style: AppTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryCyan,
            ),
          ),
        ],
      ),
    );
  }
}
