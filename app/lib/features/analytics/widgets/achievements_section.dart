import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/features/analytics/models/analytics_data.dart';
import 'package:nuveli/shared/widgets/achievement_badge.dart';

/// "Achievements" başlık + "View all" + 3'lü rozet grid.
class AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;
  final VoidCallback? onViewAll;
  final void Function(Achievement)? onAchievementTap;

  const AchievementsSection({
    super.key,
    required this.achievements,
    this.onViewAll,
    this.onAchievementTap,
  });

  @override
  Widget build(BuildContext context) {
    // İlk 3 rozeti göster (View all başkalarını gösterecek)
    final visible = achievements.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Üst satır: "Achievements" + "View all"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: AppTypography.sectionTitle.copyWith(
                fontSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 4),
                child: Text(
                  'View all',
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.sm + 4), // 12px

        // 3'lü rozet grid (eşit dağılım)
        Row(
          children: [
            for (int i = 0; i < visible.length; i++) ...[
              Expanded(
                child: AchievementBadge(
                  icon: visible[i].icon,
                  iconColor: visible[i].color,
                  title: visible[i].title,
                  subtitle: visible[i].subtitle,
                  isUnlocked: visible[i].isUnlocked,
                  onTap: onAchievementTap != null
                      ? () => onAchievementTap!(visible[i])
                      : null,
                ),
              ),
              if (i < visible.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}
