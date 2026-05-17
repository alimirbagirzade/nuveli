import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';

/// "✓ Scan Complete | 3 foods detected" + sağda "520 kcal | Est. Total"
class ScanCompleteBanner extends StatelessWidget {
  final int foodsDetected;
  final int totalCalories;

  const ScanCompleteBanner({
    super.key,
    required this.foodsDetected,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: const EdgeInsets.all(AppSpacing.md - 2),
      child: Row(
        children: [
          // Sol: check + metinler
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 20,
              color: AppColors.primaryCyan,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan Complete',
                  style: AppTypography.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$foodsDetected foods detected',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Sağ: total kalori
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$totalCalories kcal',
                style: AppTypography.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryCyan,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Est. Total',
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
