// ============================================================================
// auth_social_button.dart
// Apple / Google sign-in butonları. Outline + provider logosu.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';

enum SocialProvider {
  apple,
  google;

  String get label => switch (this) {
        SocialProvider.apple => 'Continue with Apple',
        SocialProvider.google => 'Continue with Google',
      };

}

/// Leading mark for a social button. Apple uses the system glyph; Google
/// gets a white-circle "G" badge (no brand asset bundled, so we avoid the
/// thin `g_mobiledata` glyph in favour of a clearer Google-blue mark).
class _SocialLeading extends StatelessWidget {
  const _SocialLeading({required this.provider});
  final SocialProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider == SocialProvider.apple) {
      return const Icon(Icons.apple, color: Colors.white, size: 24);
    }
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4), // Google blue
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthSocialButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    final l10n = AppLocalizations.of(context);
    final label = provider == SocialProvider.apple
        ? (l10n?.authContinueWithApple ?? 'Continue with Apple')
        : (l10n?.authContinueWithGoogle ?? 'Continue with Google');

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.2,
              ),
            ),
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
                        _SocialLeading(provider: provider),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: AppTypography.body16.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// "OR" divider — sosyal butonların üstünde
// ============================================================================

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n?.authOrDivider ?? 'or',
            style: AppTypography.caption12.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}
