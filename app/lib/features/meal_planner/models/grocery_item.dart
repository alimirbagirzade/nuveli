import 'package:flutter/material.dart';

/// A single ingredient/item in the user's weekly grocery summary.
///
/// Used by [GrocerySummaryCard] and aggregated from each [Recipe.ingredients].
@immutable
class GroceryItem {
  final String name;
  final String amount; // human-readable, e.g. "1.2 kg", "250 g"
  final String? imageUrl;
  final IconData fallbackIcon;

  const GroceryItem({
    required this.name,
    required this.amount,
    this.imageUrl,
    required this.fallbackIcon,
  });
}
