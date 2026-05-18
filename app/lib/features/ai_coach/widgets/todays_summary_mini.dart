import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../models/nutrition_score.dart';

/// Compact 4-cell macro row. Numbers come from the same source as the
/// Dashboard, so the AI Coach screen always stays consistent with the
/// home screen.
class TodaysSummaryMini extends StatelessWidget {
  final TodaysMacros macros;

  const TodaysSummaryMini({super.key, required this.macros});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            "Today's Summary",
            style: AppTypography.cardTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        NuveliCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: _MacroCell(
                  value: _formatNumber(macros.calories),
                  unit: 'kcal',
                  label: 'Calories',
                ),
              ),
              const _Divider(),
              Expanded(
                child: _MacroCell(
                  value: '${macros.proteinG}',
                  unit: 'g',
                  label: 'Protein',
                ),
              ),
              const _Divider(),
              Expanded(
                child: _MacroCell(
                  value: '${macros.carbsG}',
                  unit: 'g',
                  label: 'Carbs',
                ),
              ),
              const _Divider(),
              Expanded(
                child: _MacroCell(
                  value: '${macros.fatG}',
                  unit: 'g',
                  label: 'Fat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 1480 → "1,480"
  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _MacroCell extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const _MacroCell({
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTypography.cardTitle.copyWith(
                  color: AppColors.primaryCyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.0,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.textSecondary.withOpacity(0.15),
    );
  }
}
