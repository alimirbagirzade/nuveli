// ============================================================================
// forgot_password_screen.dart
// Email girip "Send reset link" → Supabase magic link → ResetPasswordScreen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_background.dart';
import '../models/auth_errors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_link_text.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_emailCtl.text.trim());
      if (mounted) setState(() => _sent = true);
    } on NuveliAuthException catch (e) {
      if (mounted) setState(() => _error = e.userMessage);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _error = NuveliAuthException.fromSupabase(e).userMessage);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _sent ? _SuccessState(email: _emailCtl.text.trim()) : _form(),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Reset password',
            style: AppTypography.heading32Bold.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter your email and we'll send you a link to reset your password.",
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            controller: _emailCtl,
            label: 'Email',
            hint: 'you@example.com',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: _send,
            validator: AuthValidators.email,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            AuthErrorBanner(
              message: _error!,
              onDismiss: () => setState(() => _error = null),
            ),
          ],
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: 'Send reset link',
            isLoading: _loading,
            onPressed: _send,
          ),
          const SizedBox(height: 24),
          AuthLinkText(
            prefix: 'Remember your password?',
            linkText: 'Sign in',
            onTap: () => Navigator.maybePop(context),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUCCESS STATE
// ============================================================================

class _SuccessState extends StatelessWidget {
  final String email;
  const _SuccessState({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),
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
              Icons.mark_email_read_outlined,
              size: 48,
              color: AppColors.primaryCyan,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: AppTypography.heading32Bold.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          "We've sent a password reset link to\n$email",
          textAlign: TextAlign.center,
          style: AppTypography.body14.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 32),
        AuthPrimaryButton(
          label: 'Back to sign in',
          onPressed: () => Navigator.maybePop(context),
        ),
      ],
    );
  }
}
