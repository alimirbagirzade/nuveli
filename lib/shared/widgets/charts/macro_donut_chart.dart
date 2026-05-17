import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Donut chart showing macro nutrient breakdown by calorie share.
///
/// Used on Analytics screen ("Macro Breakdown – Daily Average").
///
/// Calorie math:
/// - protein_kcal = grams × 4
/// - carbs_kcal   = grams × 4
/// - fat_kcal     = grams × 9
class MacroDonutChart extends StatelessWidget {
  const MacroDonutChart({
    super.key,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.size = 160,
  });

  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double size;

  @override
  Widget build(BuildContext context) {
    final proteinKcal = proteinGrams * 4;
    final carbsKcal = carbsGrams * 4;
    final fatKcal = fatGrams * 9;
    final totalKcal = proteinKcal + carbsKcal + fatKcal;

    final pPct =
        totalKcal > 0 ? (proteinKcal / totalKcal * 100).round() : 0;
    final cPct = totalKcal > 0 ? (carbsKcal / totalKcal * 100).round() : 0;
    final fPct = totalKcal > 0 ? (fatKcal / totalKcal * 100).round() : 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 2,
                  centerSpaceRadius: size * 0.32,
                  sections: [
                    PieChartSectionData(
                      value: proteinKcal == 0 ? 1 : proteinKcal,
                      color: AppColors.protein,
                      radius: size * 0.18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: carbsKcal == 0 ? 1 : carbsKcal,
                      color: AppColors.carbs,
                      radius: size * 0.18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: fatKcal == 0 ? 1 : fatKcal,
                      color: AppColors.fat,
                      radius: size * 0.18,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    totalKcal.toStringAsFixed(0),
                    style: AppTypography.sectionTitle.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(
                AppColors.protein,
                'Protein',
                '${proteinGrams.toStringAsFixed(0)}g',
                '$pPct%',
              ),
              const SizedBox(height: 8),
              _legendItem(
                AppColors.carbs,
                'Carbs',
                '${carbsGrams.toStringAsFixed(0)}g',
                '$cPct%',
              ),
              const SizedBox(height: 8),
              _legendItem(
                AppColors.fat,
                'Fat',
                '${fatGrams.toStringAsFixed(0)}g',
                '$fPct%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label, String grams, String pct) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          '$grams · $pct',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
