// ============================================================================
// auth_primary_button.dart
// Auth flow'unun ana CTA butonu. Loading state'i destekler.
// Chat 1'deki NuveliButton'a benzer ama auth ekranlarında özel davranış lazım
// (loading spinner inline). Eğer NuveliButton zaten loading destekliyorsa
// onu da kullanabilirsin — bu widget kendi kendine yeterlidir.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_haptics.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 56,
      decoration: BoxDecoration(
        gradient: disabled
            ? null
            : LinearGradient(
                colors: [
                  AppColors.primaryCyan,
                  AppColors.glowCyan,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: disabled ? AppColors.disabled : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled
              ? null
              : () {
                  AppHaptics.light();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTypography.body16.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    final wrapped = fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;

    // Semantic label so VoiceOver / TalkBack announce the button by its
    // text and reflect the busy/disabled states. App Store reviewers
    // (and humans) hit this with screen readers — keep it informative.
    return Semantics(
      label: label,
      button: true,
      enabled: !disabled,
      excludeSemantics: true,
      // Let assistive tech also pick up the busy spinner.
      hint: isLoading ? 'Loading' : null,
      child: wrapped,
    );
  }
}
