import 'package:flutter/material.dart';

import '../models/meal_plan.dart';
import '../models/recipe.dart';

/// One row in the meal plan list — used by [MealsListCard] x4 per day.
///
/// Visual: [colored circle icon] [Type / kcal] [recipe thumb] [name (expanded)] [chevron]
class MealPlanCard extends StatelessWidget {
  final MealPlan plan;
  final VoidCallback? onTap;

  /// Whether to render a 1px hairline divider below this row (used when
  /// stacking multiple cards inside a single wrapper).
  final bool showDivider;

  const MealPlanCard({
    super.key,
    required this.plan,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 12,
              ),
              child: Row(
                children: [
                  _MealTypeIcon(type: plan.type),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 76,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          plan.type.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${plan.recipe.calories} kcal',
                          style: const TextStyle(
                            color: Color(0xFF00D4FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RecipeThumb(recipe: plan.recipe),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      plan.recipe.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.4),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: Colors.white.withOpacity(0.06),
          ),
      ],
    );
  }
}

class _MealTypeIcon extends StatelessWidget {
  final MealType type;
  const _MealTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconAndColor(type);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 20),
    );
  }

  (IconData, Color) _iconAndColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return (Icons.wb_sunny_outlined, const Color(0xFFFFC857));
      case MealType.lunch:
        return (Icons.wb_sunny, const Color(0xFF6BCB77));
      case MealType.dinner:
        return (Icons.wb_twilight, const Color(0xFFFF9F45));
      case MealType.snack:
        return (Icons.nightlight_round, const Color(0xFFB088F9));
    }
  }
}

class _RecipeThumb extends StatelessWidget {
  final Recipe recipe;
  const _RecipeThumb({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final hasImage = recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              recipe.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.restaurant,
        color: Colors.white.withOpacity(0.55),
        size: 20,
      ),
    );
  }
}
