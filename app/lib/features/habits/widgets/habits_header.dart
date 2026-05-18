import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Top bar for the Healthy Habits screen.
///
/// Layout: [← back] [— Healthy Habits centered —] [⚙️ settings]
class HabitsHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  const HabitsHeader({
    super.key,
    this.onBack,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _IconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
            onTap: onBack,
            semanticLabel: 'Back',
          ),
          Expanded(
            child: Center(
              child: Text(
                'Healthy Habits',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _IconButton(
            icon: Icons.settings_outlined,
            size: 22,
            color: AppColors.textSecondary,
            onTap: onSettings,
            semanticLabel: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Tap-friendly icon button with a 40x40 hit area.
class _IconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final String semanticLabel;

  const _IconButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.semanticLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: Icon(icon, size: size, color: color)),
        ),
      ),
    );
  }
}
