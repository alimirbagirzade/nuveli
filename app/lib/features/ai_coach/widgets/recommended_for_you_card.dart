import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_button.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../models/coach_recommendation.dart';

/// "Recommended for You" actionable card.
///
/// Shows an image (or fallback colored icon) + descriptive text + two CTAs.
/// Apply Tip optimistically transitions to an "Applied ✓" disabled state
/// with a short fade — the provider already mutated state, so this is
/// purely visual confirmation.
class RecommendedForYouCard extends StatelessWidget {
  final CoachRecommendation recommendation;
  final VoidCallback? onApply;
  final VoidCallback? onSeeDetails;

  const RecommendedForYouCard({
    super.key,
    required this.recommendation,
    this.onApply,
    this.onSeeDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Recommended for You',
            style: AppTypography.cardTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        NuveliCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hero(recommendation: recommendation),
              const SizedBox(height: 16),
              Text(
                recommendation.title,
                style: AppTypography.cardTitle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recommendation.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: recommendation.applied
                          ? _AppliedPill(key: const ValueKey('applied'))
                          : NuveliButton.primary(
                              key: const ValueKey('apply'),
                              label: 'Apply Tip',
                              onPressed: onApply,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NuveliButton.secondary(
                      label: 'See Details',
                      onPressed: onSeeDetails,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final CoachRecommendation recommendation;

  const _Hero({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              recommendation.iconColor.withOpacity(0.22),
              recommendation.iconColor.withOpacity(0.08),
            ],
          ),
        ),
        child: recommendation.imageUrl != null
            ? Image.network(
                recommendation.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Center(
      child: Icon(
        recommendation.fallbackIcon,
        size: 48,
        color: recommendation.iconColor,
      ),
    );
  }
}

/// Replaces the Apply Tip button after the user taps it.
/// Same height as the button so the layout doesn't jump.
class _AppliedPill extends StatelessWidget {
  const _AppliedPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(
          color: AppColors.success.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            'Applied',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
