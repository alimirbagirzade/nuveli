import 'package:flutter/material.dart';

import 'package:nuveli/shared/widgets/quick_add_button.dart';

/// Hızlı su ekleme: [+250ml] [+500ml] [+1L]
///
/// Üç buton da `Expanded` ile eşit genişlikte; aralarında 12px gap.
/// Boyut hiyerarşisi (small/medium/large) `QuickAddButton`'ın `size`
/// parametresi üzerinden yönetilir (Chat 3'te tanımlandı).
class QuickAddRow extends StatelessWidget {
  final ValueChanged<int> onAddWater;

  const QuickAddRow({super.key, required this.onAddWater});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickAddButton(
            icon: Icons.local_drink,
            label: '+250 ml',
            size: QuickAddButtonSize.small,
            onPressed: () => onAddWater(250),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickAddButton(
            icon: Icons.local_drink,
            label: '+500 ml',
            size: QuickAddButtonSize.medium,
            onPressed: () => onAddWater(500),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickAddButton(
            icon: Icons.water_drop,
            label: '+1 L',
            size: QuickAddButtonSize.large,
            onPressed: () => onAddWater(1000),
          ),
        ),
      ],
    );
  }
}
