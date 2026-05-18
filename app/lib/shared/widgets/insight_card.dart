import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'nuveli_card.dart';

/// AI Coach öneri kartı (Görsel 8).
///
/// Örnek:
/// - 💪 Increase protein at lunch | Aiming for 30-40g... | >
/// - 💧 Hydrate earlier in the day | Front-loading water... | >
/// - ⭐ Great consistency this week | You hit your goal 5/7 days. | >
class InsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String description;
  final bool showChevron;
  final VoidCallback? onTap;

  const InsightCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.description,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBackground.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: iconBackground, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showChevron) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ],
        ],
      ),
    );
  }
}
