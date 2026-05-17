import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/features/analytics/models/analytics_data.dart';
import 'package:nuveli/shared/widgets/nuveli_card.dart';
import 'package:nuveli/shared/widgets/charts/macro_donut_chart.dart';

/// Günlük makro dağılımını gösteren kart.
///
/// Sol: Donut chart (ortasında toplam kcal).
/// Sağ: 3 satırlık legend (Protein / Carbs / Fat — gram & yüzde).
class MacroBreakdownCard extends StatelessWidget {
  final MacroBreakdown macros;
  final VoidCallback? onDailyAverageTap;

  const MacroBreakdownCard({
    super.key,
    required this.macros,
    this.onDailyAverageTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalKcal = macros.totalKcal.round();

    return NuveliCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: Title + "Daily Average >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Macro Breakdown',
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onDailyAverageTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Daily Average',
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          color: AppColors.primaryCyan,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.primaryCyan,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md), // 16px

          // Row: Donut + Legend
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sol: Donut chart
              SizedBox(
                width: 140,
                height: 140,
                child: MacroDonutChart(
                  proteinG: macros.proteinG,
                  carbsG: macros.carbsG,
                  fatG: macros.fatG,
                  centerText: _formatNumber(totalKcal),
                  centerSubtext: 'kcal',
                ),
              ),

              const SizedBox(width: 20),

              // Sağ: Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendItem(
                      color: AppColors.macroProtein,
                      label: 'Protein',
                      detail:
                          '${macros.proteinG.toStringAsFixed(0)}g / ${macros.proteinPercent}%',
                    ),
                    const SizedBox(height: 14),
                    _LegendItem(
                      color: AppColors.macroCarbs,
                      label: 'Carbs',
                      detail:
                          '${macros.carbsG.toStringAsFixed(0)}g / ${macros.carbsPercent}%',
                    ),
                    const SizedBox(height: 14),
                    _LegendItem(
                      color: AppColors.macroFat,
                      label: 'Fat',
                      detail:
                          '${macros.fatG.toStringAsFixed(0)}g / ${macros.fatPercent}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "1480" → "1,480" formatına çevirir.
  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// Tek bir legend satırı: [● Label] / [değer-yüzde]
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String detail;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text(
            detail,
            style: AppTypography.body.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
