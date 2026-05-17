import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/recommendation_card.dart';
import '../models/recommendation.dart';

/// "Personalized Recommendations" section: section title outside the card,
/// then a vertical list of small recommendation cards from Chat 3.
class RecommendationsSection extends StatelessWidget {
  final List<Recommendation> recommendations;

  /// Stub callback fired when any recommendation is tapped. The payload is the
  /// tapped recommendation. In Chat 11 (AI Coach) this will navigate to the
  /// recommendation detail / apply-tip flow.
  final void Function(Recommendation rec)? onRecommendationTap;

  const RecommendationsSection({
    super.key,
    required this.recommendations,
    this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalized Recommendations',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4), // 12
        for (var i = 0; i < recommendations.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm), // 8
          RecommendationCard(
            style: RecommendationCardStyle.simple,
            icon: recommendations[i].icon,
            iconColor: recommendations[i].iconColor,
            description: recommendations[i].description,
            onTap: () {
              final rec = recommendations[i];
              onRecommendationTap?.call(rec);
              debugPrint('Recommendation tapped: ${rec.type}');
            },
          ),
        ],
      ],
    );
  }
}
