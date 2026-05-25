import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Small, neutral "≈ N kcal" pill shown next to a logged activity.
///
/// Wellness boundary: this is **informational / display-only**. It shows the
/// backend's MET estimate of energy used during the activity. It is NEVER
/// framed as calories the user "earned", can "eat back", or should "burn off",
/// and it is never added to the calorie budget/target. The "≈" prefix keeps it
/// explicitly an estimate. When `kcal` is null the caller must not build this
/// widget at all (no placeholder, no guess) — see
/// `docs/protocols/safety-wellness-boundary.md`.
class CalorieBadge extends StatelessWidget {
  final int kcal;

  /// Slightly larger styling for the post-save confirmation context.
  final bool prominent;

  const CalorieBadge({super.key, required this.kcal, this.prominent = false});

  // Warm "energy" tone, deliberately distinct from the green activity accent
  // so it reads as a neutral data chip, not a reward.
  static const Color _amber = Color(0xFFFCD34D);
  static const Color _amberSoft = Color(0xFFFDE68A);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = l10n?.exerciseCalorieBadge(kcal) ?? '≈$kcal kcal';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: prominent ? 10 : 8,
        vertical: prominent ? 5 : 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: _amber.withValues(alpha: 0.14),
        border: Border.all(color: _amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: prominent ? 14 : 12,
            color: _amberSoft,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: _amberSoft,
              fontSize: prominent ? 13 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
