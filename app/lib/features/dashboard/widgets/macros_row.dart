import 'package:flutter/material.dart';
import '../_shared/dashboard_theme.dart';
import '../_shared/glass_card.dart';
import '../_shared/macro_bar.dart';
import '../models/macros_data.dart';

class MacrosRow extends StatelessWidget {
  final MacrosData macros;

  const MacrosRow({super.key, required this.macros});

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: const EdgeInsets.all(16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MacroProgressBar(
                label: 'Protein',
                current: macros.proteinCurrent,
                target: macros.proteinTarget,
                color: DashboardColors.protein,
              ),
            ),
            _divider(),
            Expanded(
              child: MacroProgressBar(
                label: 'Carbs',
                current: macros.carbsCurrent,
                target: macros.carbsTarget,
                color: DashboardColors.carbs,
              ),
            ),
            _divider(),
            Expanded(
              child: MacroProgressBar(
                label: 'Fat',
                current: macros.fatCurrent,
                target: macros.fatTarget,
                color: DashboardColors.fat,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: DashboardColors.textSecondary.withOpacity(0.2),
      );
}
