import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/shared/widgets/charts/glasses_grid.dart';

/// Bardak ızgarası bölümü:
/// `[▮▮▮▮▮▮▮▯▯▯]` + altında özet metin.
///
/// Bardağa tap edildiğinde `+250ml` ekler (`onGlassTap` callback'i ile).
class GlassesSection extends StatelessWidget {
  final int filledCount;
  final int totalCount;
  final double consumedLiters;
  final double targetLiters;
  final VoidCallback? onGlassTap;

  const GlassesSection({
    super.key,
    required this.filledCount,
    required this.totalCount,
    required this.consumedLiters,
    required this.targetLiters,
    this.onGlassTap,
  });

  String _fmt(double l) => l.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassesGrid(
          filledCount: filledCount,
          totalCount: totalCount,
          glassSizeMl: 250,
          onGlassTap: onGlassTap,
        ),
        const SizedBox(height: 8),
        Text(
          '$filledCount of $totalCount glasses  •  ${_fmt(consumedLiters)} L / ${_fmt(targetLiters)} L',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
