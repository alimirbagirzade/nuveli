// ============================================================================
// signup_screen.dart
// Email + password + confirm + terms checkbox.
// Signup başarılıysa email verification ekranına yönlendirir.
// ============================================================================

import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
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
import '../widgets/password_strength_indicator.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  String _liveTypedPass = '';
  bool _acceptTerms = false;
  bool _loading = false;
  bool _appleLoading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      final l10n = AppLocalizations.of(context);
      setState(() => _error = l10n?.signupAcceptTermsError ?? 'Please accept the Terms to continue.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).signUpWithEmail(
            email: _emailCtl.text.trim(),
            password: _passCtl.text,
          );
      // Signup now returns a real session (backend auto-confirms then we
      // signInWithPassword). AuthGate lives at the Navigator root and
      // will swap to OnboardingScreen the moment authProvider's data
      // changes, but the signup screen sits *on top* of it in the stack —
      // so we have to pop back to the root before the gate becomes
      // visible. Without this, signup looks like it does nothing.
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
                    l10n?.signupCreateAccount ?? 'Create account',
                    style: AppTypography.heading32Bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.signupNutritionJourney ?? "Let's start your nutrition journey",
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
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n?.authValidatorPasswordRequired ?? 'Password is required';
                      if (v.length < 8) return l10n?.authValidatorPasswordLength ?? 'At least 8 characters';
                      if (!v.contains(RegExp(r'\d'))) return l10n?.authValidatorPasswordNumber ?? 'Include at least one number';
                      return null;
                    },
                    onChanged: (v) => setState(() => _liveTypedPass = v),
                  ),
                  PasswordStrengthIndicator(password: _liveTypedPass),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _confirmCtl,
                    label: l10n?.signupConfirmPassword ?? 'Confirm password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: _signup,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n?.authValidatorConfirmRequired ?? 'Please confirm password';
                      if (v != _passCtl.text) return l10n?.authValidatorPasswordsNoMatch ?? 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _TermsCheckbox(
                    value: _acceptTerms,
                    onChanged: (v) =>
                        setState(() => _acceptTerms = v ?? false),
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
                    label: l10n?.signupCreateAccount ?? 'Create account',
                    isLoading: _loading,
                    onPressed: _signup,
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
                    prefix: l10n?.signupAlreadyHaveAccount ?? 'Already have an account?',
                    linkText: l10n?.signupSignIn ?? 'Sign in',
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
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

// ============================================================================
// Terms checkbox
// ============================================================================

class _TermsCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  State<_TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<_TermsCheckbox> {
  // The TapGestureRecognizers below have to be retained on State (not
  // rebuilt every frame) and disposed when the widget goes away — that's
  // why this is a StatefulWidget. The previous implementation rendered
  // the Terms / Privacy strings as styled text but never wired the taps,
  // so users got a link-looking surface that only toggled the checkbox.
  // Apple App Review 5.1.1(i) wants the policy URL reachable from any
  // consent surface; this fixes that.
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    // URLs live in AppConfig so paywall, settings, marketing pages all
    // point at the same canonical Turkish-domain legal docs.
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _open(AppConfig.termsUrl);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _open(AppConfig.privacyUrl);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    // mode: externalApplication so the link opens in Safari/Chrome instead
    // of an in-app webview that could trap the user. Best-effort: if the
    // launch fails (jailbroken phone with no browser?) we swallow rather
    // than crash the signup screen.
    await launchUrl(uri, mode: LaunchMode.externalApplication)
        .catchError((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: widget.value,
            onChanged: widget.onChanged,
            activeColor: AppColors.primaryCyan,
            checkColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              // Tapping outside the link spans still toggles the checkbox
              // — same UX as before, just no longer the ONLY action.
              recognizer: TapGestureRecognizer()
                ..onTap = () => widget.onChanged(!widget.value),
              children: [
                TextSpan(
                  text: l10n?.signupTermsAgree ?? 'I agree to the ',
                  style: AppTypography.caption12.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                TextSpan(
                  text: l10n?.signupTermsOfService ?? 'Terms of Service',
                  style: AppTypography.caption12.copyWith(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: _termsRecognizer,
                ),
                TextSpan(
                  text: l10n?.signupTermsAnd ?? ' and ',
                  style: AppTypography.caption12.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                TextSpan(
                  text: l10n?.signupPrivacyPolicy ?? 'Privacy Policy',
                  style: AppTypography.caption12.copyWith(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: _privacyRecognizer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
