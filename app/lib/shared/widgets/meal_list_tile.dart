import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'nuveli_card.dart';

/// Yemek listesi satırı.
///
/// İki varyant:
/// - `MealListTile.dashboard(...)` → kalori + saat sağda gösterilir (Görsel 1)
/// - `MealListTile.planner(...)`   → sağda chevron gösterilir (Görsel 6)
///
/// Görsel 1: "Breakfast — Greek Yogurt Bowl — 350 kcal — 7:30 AM"
/// Görsel 6: "Breakfast — 420 kcal — Greek Yogurt Bowl  >"
class MealListTile extends StatelessWidget {
  final String mealType;
  final String? mealTypeIcon; // emoji veya tek karakter; null ise gizlenir
  final String foodName;
  final int calories;
  final String? time; // "7:30 AM"
  final String? imageUrl;
  final bool showChevron;
  final VoidCallback? onTap;

  const MealListTile({
    super.key,
    required this.mealType,
    required this.foodName,
    required this.calories,
    this.mealTypeIcon,
    this.time,
    this.imageUrl,
    this.showChevron = false,
    this.onTap,
  });

  /// Dashboard varyantı: sağda "350 kcal" + "7:30 AM"
  factory MealListTile.dashboard({
    Key? key,
    required String mealType,
    required String foodName,
    required int calories,
    String? time,
    String? imageUrl,
    VoidCallback? onTap,
  }) =>
      MealListTile(
        key: key,
        mealType: mealType,
        foodName: foodName,
        calories: calories,
        time: time,
        imageUrl: imageUrl,
        showChevron: false,
        onTap: onTap,
      );

  /// Planner varyantı: sağda chevron
  factory MealListTile.planner({
    Key? key,
    required String mealType,
    required String foodName,
    required int calories,
    String? mealTypeIcon,
    String? imageUrl,
    VoidCallback? onTap,
  }) =>
      MealListTile(
        key: key,
        mealType: mealType,
        foodName: foodName,
        calories: calories,
        mealTypeIcon: mealTypeIcon,
        imageUrl: imageUrl,
        showChevron: true,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _Thumbnail(imageUrl: imageUrl, mealType: mealType),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (mealTypeIcon != null) ...[
                      Text(mealTypeIcon!,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      mealType,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  foodName,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              size: 22,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$calories kcal',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (time != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    time!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? imageUrl;
  final String mealType;

  const _Thumbnail({required this.imageUrl, required this.mealType});

  IconData _placeholderIcon() {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: AppColors.primaryCyan.withValues(alpha: 0.12),
        border: Border.all(
          color: AppColors.primaryCyan.withValues(alpha: 0.2),
          width: 1,
        ),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Icon(
              _placeholderIcon(),
              color: AppColors.primaryCyan,
              size: 22,
            )
          : null,
    );
  }
}
