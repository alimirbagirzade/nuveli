import 'package:flutter/material.dart';

import '../../../shared/widgets/primary_button.dart';
import '../models/coach_recommendation.dart';

const Color _success = Color(0xFF1AA38C);
const Color _secondaryText = Color(0xFFB8C5D6);

/// "Recommended for You" actionable card.
///
/// Image/icon header + descriptive text + two CTAs (PrimaryButton +
/// SecondaryButton from the shared widget library).
/// Apply Tip optimistically transitions to an "Applied ✓" pill with a
/// 250ms fade — the provider has already mutated state, this is purely
/// visual confirmation.
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
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Recommended for You',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hero(recommendation: recommendation),
              const SizedBox(height: 16),
              Text(
                recommendation.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recommendation.description,
                style: const TextStyle(
                  color: _secondaryText,
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
                          ? const _AppliedPill(key: ValueKey('applied'))
                          : PrimaryButton(
                              key: const ValueKey('apply'),
                              label: 'Apply Tip',
                              onPressed: onApply,
                              height: 48,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: 'See Details',
                      onPressed: onSeeDetails,
                      height: 48,
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
      borderRadius: BorderRadius.circular(12),
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
        color: _success.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _success.withOpacity(0.5),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 18, color: _success),
          SizedBox(width: 6),
          Text(
            'Applied',
            style: TextStyle(
              color: _success,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
