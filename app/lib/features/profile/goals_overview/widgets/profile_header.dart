import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Top header of the Profile screen:
/// `[ N logo ]  Your Goals                              [ ⚙ ]`
class ProfileHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;

  const ProfileHeader({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, // 16
        AppSpacing.sm, // 8
        AppSpacing.xs, // 4 — IconButton has its own padding on the right
        AppSpacing.sm, // 8
      ),
      child: Row(
        children: [
          // Brand mark (small "N" disc).
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.cyanGlow, AppColors.primaryCyan],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withOpacity(0.35),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'N',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.primaryBackground,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Your Goals',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onSettingsTap ??
                () {
                  // Stub: wired up in a later chat.
                  debugPrint('Settings tapped');
                },
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.secondaryText,
              size: 22,
            ),
            tooltip: 'Settings',
            splashRadius: 22,
          ),
        ],
      ),
    );
  }
}
