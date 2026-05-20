// ============================================================================
// auth_link_text.dart
// "Don't have an account? Sign up" şeklinde prefix + tıklanabilir link metni.
// ============================================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AuthLinkText extends StatelessWidget {
  final String prefix;
  final String linkText;
  final VoidCallback onTap;
  final TextAlign textAlign;

  const AuthLinkText({
    super.key,
    required this.prefix,
    required this.linkText,
    required this.onTap,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$prefix ',
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          TextSpan(
            text: linkText,
            style: AppTypography.body14.copyWith(
              color: AppColors.primaryCyan,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

// ============================================================================
// ErrorBanner — Auth form'larında hata gösterimi
// ============================================================================

class AuthErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const AuthErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body14.copyWith(color: Colors.white),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close,
                color: AppColors.danger,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
