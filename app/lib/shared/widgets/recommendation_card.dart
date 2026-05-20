import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'nuveli_card.dart';

/// Visual layout style for a [RecommendationCard].
///
/// Currently only [simple] is implemented — a single-row card with a colored
/// icon, body text, and a trailing chevron. Additional styles (e.g. detailed,
/// action-button) can be added later without breaking the call sites.
enum RecommendationCardStyle {
  /// Compact one-liner: icon · description · chevron.
  simple,
}

/// Glass card used in the "Personalized Recommendations" section.
///
/// Renders an icon tile, a description string, and a trailing chevron that
/// indicates the card is tappable. Wraps [NuveliCard] for consistent glass
/// styling.
///
/// Example:
/// ```dart
/// RecommendationCard(
///   style: RecommendationCardStyle.simple,
///   icon: Icons.water_drop_rounded,
///   iconColor: AppColors.primaryCyan,
///   description: 'Try drinking a glass of water before lunch.',
///   onTap: () {},
/// )
/// ```
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.style,
    required this.icon,
    required this.iconColor,
    required this.description,
    this.onTap,
  });

  /// Visual variant. See [RecommendationCardStyle].
  final RecommendationCardStyle style;

  /// Leading icon shown in a tinted square tile.
  final IconData icon;

  /// Tint color for the icon and its background tile.
  final Color iconColor;

  /// Body text. Wraps to multiple lines if needed.
  final String description;

  /// Tap handler. When null, the chevron still renders but the card has no
  /// ripple and no interaction.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4, // 12
      ),
      child: switch (style) {
        RecommendationCardStyle.simple => _SimpleLayout(
            icon: icon,
            iconColor: iconColor,
            description: description,
            showChevron: onTap != null,
          ),
      },
    );
  }
}

class _SimpleLayout extends StatelessWidget {
  const _SimpleLayout({
    required this.icon,
    required this.iconColor,
    required this.description,
    required this.showChevron,
  });

  final IconData icon;
  final Color iconColor;
  final String description;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon tile — tinted square with rounded corners
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.sm + 4), // 12
        // Description — fills available space
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ),
        if (showChevron) ...[
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ],
    );
  }
}
