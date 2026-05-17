import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/shared/widgets/nuveli_card.dart';

import '../models/water_insight.dart';

/// "📈 Insights" kartı — AI içgörüsü.
///
/// Üst satır: trending_up ikonu + "Insights" başlığı.
/// İçerik: sol tarafta büyük cyan damla ikonu, sağda ana metin + alt metin.
class WaterInsightsCard extends StatelessWidget {
  final WaterInsight insight;

  const WaterInsightsCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üst satır: 📈 + "Insights".
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Insights',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // İçerik: ikon + metin.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Büyük cyan damla.
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCyan.withOpacity(0.12),
                ),
                child: Icon(
                  insight.icon,
                  color: AppColors.primaryCyan,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Metinler.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      insight.mainText,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (insight.subText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        insight.subText!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
