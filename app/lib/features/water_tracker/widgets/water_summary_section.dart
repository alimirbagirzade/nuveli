import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/shared/widgets/charts/water_ring_chart.dart';

/// "Today" + büyük halka ortasında 4 satır metin:
/// `2.1 L`, `/ 3.0 L`, `70%`, `0.9 L left to goal`.
///
/// Halka grafiği `WaterRingChart` (Chat 2) ile çizilir; metinler `Stack`
/// üzerinden overlay edilir — chart kendi metnini gösterse bile bizim
/// metnimiz üstte kalır.
class WaterSummarySection extends StatelessWidget {
  final double consumedLiters;
  final double targetLiters;
  final double ringSize;

  const WaterSummarySection({
    super.key,
    required this.consumedLiters,
    required this.targetLiters,
    this.ringSize = 220,
  });

  double get _progressRatio =>
      targetLiters == 0 ? 0 : (consumedLiters / targetLiters).clamp(0.0, 1.0);

  int get _percent => (_progressRatio * 100).round();

  double get _litersLeft =>
      (targetLiters - consumedLiters).clamp(0.0, targetLiters);

  String _formatLiters(double l) {
    // 2.1 / 3.0 → ondalıkta 1 hane yeterli.
    return l.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "Today" üst başlık.
        Text(
          'Today',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        // Halka + ortada metin (Stack overlay).
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Asıl halka (Chat 2'den).
              WaterRingChart(
                consumedLiters: consumedLiters,
                targetLiters: targetLiters,
                size: ringSize,
              ),
              // Ortada 4 satır metin.
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "2.1 L" — büyük + "L" küçük (baseline align).
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatLiters(consumedLiters),
                        style: AppTypography.displaySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'L',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // "/ 3.0 L"
                  Text(
                    '/ ${_formatLiters(targetLiters)} L',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // "70%" — cyan, bold.
                  Text(
                    '$_percent%',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primaryCyan,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // "0.9 L left to goal"
                  Text(
                    '${_formatLiters(_litersLeft)} L left to goal',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
