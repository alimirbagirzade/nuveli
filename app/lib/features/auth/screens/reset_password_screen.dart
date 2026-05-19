// ============================================================================
// reset_password_screen.dart
// Magic link sonrası user buraya gelir. Yeni password girer → kayıt.
// Deep link router (go_router Chat 17'de) bu ekrana yönlendirir.
// Şu an için Supabase onAuthStateChange event'inden manuel açılabilir.
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
import '../widgets/password_strength_indicator.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  String _liveTypedPass = '';
  bool _loading = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _passCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).updatePassword(_passCtl.text);
      if (mounted) setState(() => _done = true);
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _done ? _success() : _form(),
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
          const SizedBox(height: 32),
          Text(
            'Set new password',
            style: AppTypography.heading32Bold.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a strong password for your account.',
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 32),
          AuthTextField(
            controller: _passCtl,
            label: 'New password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: AuthValidators.password,
            onChanged: (v) => setState(() => _liveTypedPass = v),
          ),
          PasswordStrengthIndicator(password: _liveTypedPass),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmCtl,
            label: 'Confirm password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: _submit,
            validator: AuthValidators.confirmPassword(_passCtl),
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
            label: 'Update password',
            isLoading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _success() {
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
                  AppColors.success.withValues(alpha: 0.4),
                  AppColors.success.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Password updated',
          textAlign: TextAlign.center,
          style: AppTypography.heading32Bold.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'You can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: AppTypography.body14.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 32),
        AuthPrimaryButton(
          label: 'Continue',
          onPressed: () {
            // AuthGate logged-in user'ı otomatik Dashboard'a alır.
            // Stack'i temizle.
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }
}
