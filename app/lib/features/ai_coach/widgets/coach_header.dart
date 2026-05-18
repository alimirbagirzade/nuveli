import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Top header for the AI Coach screen.
/// Layout mirrors the other in-app screen headers (Habits, Profile, etc.).
class CoachHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  const CoachHeader({
    super.key,
    this.onBack,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          _IconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
            semanticLabel: 'Back',
          ),
          Expanded(
            child: Text(
              'AI Coach',
              textAlign: TextAlign.center,
              style: AppTypography.cardTitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _IconButton(
            icon: Icons.settings_outlined,
            onTap: onSettings,
            semanticLabel: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
