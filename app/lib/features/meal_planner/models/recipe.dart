import 'package:flutter/foundation.dart';

import 'grocery_item.dart';

/// A recipe planned for a specific [MealType].
@immutable
class Recipe {
  final String id;
  final String name; // "Greek Yogurt Bowl"
  final int calories;
  final String? imageUrl;
  final List<GroceryItem> ingredients;

  const Recipe({
    required this.id,
    required this.name,
    required this.calories,
    this.imageUrl,
    this.ingredients = const [],
  });
}
