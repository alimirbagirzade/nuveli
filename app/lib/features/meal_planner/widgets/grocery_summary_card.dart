import 'package:flutter/material.dart';

import '../models/grocery_item.dart';

/// Bottom summary card listing 4 preview grocery items + total count badge.
class GrocerySummaryCard extends StatelessWidget {
  /// Items to preview (typically 4, displayed evenly across the row).
  final List<GroceryItem> items;

  /// Total count of all grocery items for the week (shown as "12 items").
  final int totalCount;

  const GrocerySummaryCard({
    super.key,
    required this.items,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 14),
          _itemsRow(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF00D4FF).withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.25)),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.shopping_cart_outlined,
            size: 16,
            color: Color(0xFF00D4FF),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Grocery Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          '$totalCount items',
          style: const TextStyle(
            color: Color(0xFF00D4FF),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _itemsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Expanded(child: _GroceryItemView(item: item)))
          .toList(),
    );
  }
}

class _GroceryItemView extends StatelessWidget {
  final GroceryItem item;
  const _GroceryItemView({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
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
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(height: 8),
        Text(
          item.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.amount,
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        item.fallbackIcon,
        color: Colors.white.withOpacity(0.7),
        size: 22,
      ),
    );
  }
}
