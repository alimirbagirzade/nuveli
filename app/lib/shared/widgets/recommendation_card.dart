import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'nuveli_card.dart';

enum RecommendationCardStyle { simple, actionable }

/// Öneri kartı, 2 stil:
///
/// **Simple (Görsel 3 — Personalized Recommendations):**
/// Yatay layout: [Icon] [Description] [Chevron]
///
/// **Actionable (Görsel 8 — Recommended for You):**
/// Üstte: [Icon] [Title + Description], altta: [Apply Tip] [See Details] yan yana
class RecommendationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? title;
  final String description;
  final RecommendationCardStyle style;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onTap;

  const RecommendationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.description,
    this.title,
    this.style = RecommendationCardStyle.simple,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.primaryActionLabel,
    this.secondaryActionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (style == RecommendationCardStyle.simple) {
      return _buildSimple();
    }
    return _buildActionable();
  }

  // ─────────────────────────────────────────────────────
  // SIMPLE
  // ─────────────────────────────────────────────────────
  Widget _buildSimple() {
    return NuveliCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconCircle(icon: icon, color: iconColor, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              description,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // ACTIONABLE
  // ─────────────────────────────────────────────────────
  Widget _buildActionable() {
    return NuveliCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconCircle(icon: icon, color: iconColor, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (title != null) const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _PrimaryActionButton(
                  label: primaryActionLabel ?? 'Apply Tip',
                  onPressed: onPrimaryAction,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SecondaryActionButton(
                  label: secondaryActionLabel ?? 'See Details',
                  onPressed: onSecondaryAction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconCircle({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryActionButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryCyan,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCyan.withValues(alpha: 0.4),
                blurRadius: 14,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF051824),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryActionButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.primaryCyan.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryCyan,
            ),
          ),
        ),
      ),
    );
  }
}
