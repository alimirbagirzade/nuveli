import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/shared/widgets/charts/macro_progress_bar.dart';
import 'package:nuveli/shared/widgets/nuveli_card.dart';

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
                color: AppColors.proteinColor,
              ),
            ),
            _divider(),
            Expanded(
              child: MacroProgressBar(
                label: 'Carbs',
                current: macros.carbsCurrent,
                target: macros.carbsTarget,
                color: AppColors.carbsColor,
              ),
            ),
            _divider(),
            Expanded(
              child: MacroProgressBar(
                label: 'Fat',
                current: macros.fatCurrent,
                target: macros.fatTarget,
                color: AppColors.fatColor,
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
        color: AppColors.secondaryText.withOpacity(0.2),
      );
}
