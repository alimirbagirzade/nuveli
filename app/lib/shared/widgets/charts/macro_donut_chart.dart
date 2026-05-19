import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Macro nutrient colors used by [MacroDonutChart] and (optionally)
/// [MacroProgressBar].
///
/// Kept local to the charts layer for now. If you later want to expose
/// them globally, move them into [AppColors] and update both files.
class MacroColors {
  MacroColors._();
  static const Color protein = Color(0xFF3DDC97); // teal-green
  static const Color carbs = Color(0xFF6BCB77); // green
  static const Color fat = Color(0xFFFF9F45); // orange
}

/// Donut chart showing macro nutrient breakdown by calorie share.
///
/// Used on Analytics screen (Görsel 4 — "Macro Breakdown – Daily Average").
///
/// Calorie math:
/// - protein_kcal = grams × 4
/// - carbs_kcal   = grams × 4
/// - fat_kcal     = grams × 9
///
/// Example:
/// ```dart
/// MacroDonutChart(
///   proteinGrams: 95,
///   carbsGrams: 160,
///   fatGrams: 48,
/// )
/// ```
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

    final pPct = totalKcal > 0 ? (proteinKcal / totalKcal * 100).round() : 0;
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
                      color: MacroColors.protein,
                      radius: size * 0.18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: carbsKcal == 0 ? 1 : carbsKcal,
                      color: MacroColors.carbs,
                      radius: size * 0.18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: fatKcal == 0 ? 1 : fatKcal,
                      color: MacroColors.fat,
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
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(
                MacroColors.protein,
                'Protein',
                '${proteinGrams.toStringAsFixed(0)}g',
                '$pPct%',
              ),
              const SizedBox(height: 8),
              _legendItem(
                MacroColors.carbs,
                'Carbs',
                '${carbsGrams.toStringAsFixed(0)}g',
                '$cPct%',
              ),
              const SizedBox(height: 8),
              _legendItem(
                MacroColors.fat,
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$grams · $pct',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
