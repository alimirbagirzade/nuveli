import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../models/ai_insight.dart';

/// The headline insight at the top of the AI Coach screen.
/// Cyan vertical accent on the left ties it visually to the score ring above.
class TodaysInsightCard extends StatelessWidget {
  final AIInsight insight;

  const TodaysInsightCard({super.key, required this.insight});

  Color get _accent {
    switch (insight.tone) {
      case InsightTone.positive:
        return AppColors.primaryCyan;
      case InsightTone.warning:
        return AppColors.warning;
      case InsightTone.neutral:
        return AppColors.primaryCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent stripe
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  bottomLeft: Radius.circular(AppRadius.card),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(insight.icon, size: 22, color: _accent),
                        const SizedBox(width: 8),
                        Text(
                          "Today's Insight",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      insight.headline,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insight.supportingText,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
