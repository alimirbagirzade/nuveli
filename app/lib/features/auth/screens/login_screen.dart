// ============================================================================
// login_screen.dart
// Email/password + Apple Sign-In + Google Sign-In + Forgot password.
// ============================================================================

import 'dart:io' show Platform;

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
import '../widgets/auth_social_button.dart';
import '../widgets/auth_text_field.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  bool _appleLoading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).signInWithEmail(
            email: _emailCtl.text.trim(),
            password: _passCtl.text,
          );
      // AuthGate sits at the Navigator root; login screen is pushed on
      // top. Pop back so the gate becomes visible with the new session.
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
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

  Future<void> _signInWithApple() async {
    setState(() {
      _appleLoading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).signInWithApple();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on NuveliAuthException catch (e) {
      if (e.type == AuthErrorType.appleSignInCanceled) return;
      if (mounted) setState(() => _error = e.userMessage);
    } finally {
      if (mounted) setState(() => _appleLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on NuveliAuthException catch (e) {
      if (e.type == AuthErrorType.googleSignInCanceled) return;
      if (mounted) setState(() => _error = e.userMessage);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showApple = Platform.isIOS || Platform.isMacOS;
    final l10n = AppLocalizations.of(context);

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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n?.loginWelcomeBack ?? 'Welcome back',
                    style: AppTypography.heading32Bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.loginSubtitle ?? 'Sign in to continue your journey',
                    style: AppTypography.body14.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    controller: _emailCtl,
                    label: l10n?.loginEmail ?? 'Email',
                    hint: 'you@example.com',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l10n?.authValidatorEmailRequired ?? 'Email is required';
                      final regex = RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
                      if (!regex.hasMatch(v.trim())) return l10n?.authValidatorEmailInvalid ?? 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _passCtl,
                    label: l10n?.loginPassword ?? 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: _login,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n?.authValidatorPasswordRequired ?? 'Password is required';
                      if (v.length < 6) return l10n?.authValidatorPasswordSimpleLength ?? 'At least 6 characters';
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: Text(
                        l10n?.loginForgotPasswordFull ?? 'Forgot password?',
                        style: AppTypography.caption12.copyWith(
                          color: AppColors.primaryCyan,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    AuthErrorBanner(
                      message: _error!,
                      onDismiss: () => setState(() => _error = null),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: l10n?.loginSignIn ?? 'Sign in',
                    isLoading: _loading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 24),
                  const AuthOrDivider(),
                  const SizedBox(height: 24),
                  if (showApple) ...[
                    AuthSocialButton(
                      provider: SocialProvider.apple,
                      isLoading: _appleLoading,
                      onPressed: _signInWithApple,
                    ),
                    const SizedBox(height: 12),
                  ],
                  AuthSocialButton(
                    provider: SocialProvider.google,
                    isLoading: _googleLoading,
                    onPressed: _signInWithGoogle,
                  ),
                  const SizedBox(height: 32),
                  AuthLinkText(
                    prefix: l10n?.loginDontHaveAccount ?? "Don't have an account?",
                    linkText: l10n?.loginSignUp ?? 'Sign up',
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SignupScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
