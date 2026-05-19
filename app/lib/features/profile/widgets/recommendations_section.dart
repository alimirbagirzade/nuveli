import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';

/// Static recommendations until Chat 11 (AI Coach) hooks up
/// `aiInsightsProvider`.
///
/// To swap in real data:
///   1. Add `final List<Recommendation> items` parameter.
///   2. Replace `_defaultItems` with `items`.
///   3. In the screen, watch `aiInsightsProvider` and pass `.recommendations`.
class RecommendationsSection extends StatelessWidget {
  final List<Recommendation>? items;

  const RecommendationsSection({super.key, this.items});

  static const List<Recommendation> _defaultItems = [
    Recommendation(
      icon: Icons.local_drink_rounded,
      title: 'Drink water before meals',
      description: 'Helps with portion control and hydration.',
      accentColor: AppColors.primaryCyan,
    ),
    Recommendation(
      icon: Icons.directions_walk_rounded,
      title: 'Add a 30-min walk',
      description: 'Easy way to hit your daily TDEE.',
      accentColor: AppColors.success,
    ),
    Recommendation(
      icon: Icons.bedtime_rounded,
      title: 'Sleep 7–8 hours',
      description: 'Better recovery, better hunger control.',
      accentColor: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = items ?? _defaultItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates_rounded,
                size: 18,
                color: AppColors.primaryCyan,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'Recommended for You',
                style: AppTypography.cardTitle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Personalized tips to help you reach your goals',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          ...list.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s12),
              child: _RecommendationCard(rec: r),
            ),
          ),
        ],
      ),
    );
  }
}

class Recommendation {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const Recommendation({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation rec;
  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: AppColors.cardBackground,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: rec.accentColor.withValues(alpha: 0.18),
              border: Border.all(
                color: rec.accentColor.withValues(alpha: 0.3),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(rec.icon, size: 22, color: rec.accentColor),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rec.description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
