import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../models/meal.dart';

/// "Today's meals" section with a section header + list + empty state.
///
/// Each meal row is rendered with [_MealTile] (self-contained) so this
/// section doesn't depend on a specific `MealListTile` API surface.
/// You can swap [_MealTile] for `MealListTile(meal: m)` from
/// `lib/shared/widgets/meal_list_tile.dart` once Chat 3's API is verified.
class MealsSection extends StatelessWidget {
  final List<Meal> meals;
  final VoidCallback? onSeeAll;

  const MealsSection({super.key, required this.meals, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n?.homeTodayMeals ?? "Today's meals",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (meals.isNotEmpty)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text(
                    l10n?.homeSeeAll ?? 'See all',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4DDBFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (meals.isEmpty)
            EmptyStateView(
              icon: Icons.restaurant_outlined,
              title: l10n?.homeNoMealsTitle ?? 'No meals logged yet',
              message: l10n?.homeNoMealsScanHint ??
                  'Tap "Add Food" below to log your first meal',
              compact: true,
            )
          else
            ...meals.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MealTile(meal: m),
                )),
        ],
      ),
    );
  }
}


class _MealTile extends StatelessWidget {
  final Meal meal;
  const _MealTile({required this.meal});

  IconData _iconForType(String type) {
    switch (type) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
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

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon / image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: meal.imageUrl != null
                ? Image.network(
                    meal.imageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _iconFallback(),
                  )
                : _iconFallback(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  meal.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${meal.mealTypeLabel} · ${_formatTime(meal.consumedAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E7B91),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${meal.totalCalories} kcal',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4DDBFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconFallback() {
    return Container(
      width: 44,
      height: 44,
      color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
      child: Icon(
        _iconForType(meal.mealType),
        color: const Color(0xFF4DDBFF),
        size: 22,
      ),
    );
  }
}
