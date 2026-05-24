// ============================================================================
// email_verification_screen.dart
// Signup'tan sonra gösterilir. "Check your email" + resend butonu.
// Kullanıcı email'i doğrulayınca Supabase onAuthStateChange tetiklenir,
// AuthGate otomatik dashboard'a (veya onboarding'e) yönlendirir.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/nuveli_background.dart';
import '../models/auth_errors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_link_text.dart';
import '../widgets/auth_primary_button.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _resending = false;
  int _resendCooldown = 0;
  Timer? _timer;
  String? _info;
  String? _error;

  void _startCooldown() {
    _resendCooldown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    setState(() {
      _resending = true;
      _error = null;
      _info = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .resendVerificationEmail(widget.email);
      if (mounted) {
        setState(() => _info = AppLocalizations.of(context)?.verifyEmailResent ?? 'Verification email sent again.');
        _startCooldown();
      }
    } on NuveliAuthException catch (e) {
      if (mounted) setState(() => _error = e.userMessage);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _error = NuveliAuthException.fromSupabase(e).userMessage);
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryCyan.withValues(alpha: 0.4),
                          AppColors.primaryCyan.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 48,
                      color: AppColors.primaryCyan,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n?.verifyEmailTitle ?? 'Verify your email',
                  textAlign: TextAlign.center,
                  style:
                      AppTypography.heading32Bold.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.verifyEmailSentLinkTo ?? "We've sent a verification link to",
                  textAlign: TextAlign.center,
                  style: AppTypography.body14.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: AppTypography.body14.copyWith(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.verifyEmailOpenOnDevice ?? 'Open it on this device to continue.',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption12.copyWith(
                    color: AppColors.tertiaryText,
                  ),
                ),
                if (_info != null) ...[
                  const SizedBox(height: 24),
                  _InfoBanner(message: _info!),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 24),
                  AuthErrorBanner(
                    message: _error!,
                    onDismiss: () => setState(() => _error = null),
                  ),
                ],
                const SizedBox(height: 40),
                AuthPrimaryButton(
                  label: _resendCooldown > 0
                      ? (l10n?.verifyEmailResendInSeconds(_resendCooldown) ?? 'Resend in $_resendCooldown s')
                      : (l10n?.verifyEmailResendEmail ?? 'Resend email'),
                  isLoading: _resending,
                  onPressed: _resendCooldown > 0 ? null : _resend,
                ),
                const SizedBox(height: 16),
                AuthLinkText(
                  prefix: l10n?.verifyEmailWrongEmail ?? 'Wrong email?',
                  linkText: l10n?.verifyEmailGoBack ?? 'Go back',
                  onTap: () {
                    // Sign out + welcome
                    ref.read(authProvider.notifier).signOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body14.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
