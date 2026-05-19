import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'nuveli_card.dart';

/// Başarım rozeti (Görsel 4 — Analytics).
///
/// Row içinde 3'ü Expanded ile yan yana kullanılır:
/// - 🔥 7 Day Streak | Keep it up! (turuncu)
/// - 🎯 Calorie Goal | 5/7 days (cyan)
/// - ⚖️ 3.5 kg Lost | Great progress! (cyan)
///
/// `isUnlocked: false` → grayscale + %50 opacity.
class AchievementBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isUnlocked;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.isUnlocked = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        isUnlocked ? color : AppColors.textSecondary.withValues(alpha: 0.4);

    final content = NuveliCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: effectiveColor.withValues(alpha: 0.15),
              border: Border.all(
                color: effectiveColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: effectiveColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (!isUnlocked) {
      return Opacity(opacity: 0.5, child: content);
    }
    return content;
  }
}
