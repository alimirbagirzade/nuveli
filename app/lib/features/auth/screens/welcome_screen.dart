// ============================================================================
// welcome_screen.dart
// App'in ilk açılış ekranı. Logo + slogan + Get Started + Sign in link.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/nuveli_background.dart';
import '../../../shared/widgets/smiling_drop.dart';
import '../widgets/auth_link_text.dart';
import '../widgets/auth_primary_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  /// AuthGate, hata durumunda buraya error parametresiyle yönlendirebilir.
  final String? error;

  const WelcomeScreen({super.key, this.error});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _ctl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic));
    _ctl.forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Surfaces the optional `error` parameter that AuthGate
                // passes when authProvider lands in AsyncValue.error.
                // Previously the parameter existed but was silently
                // dropped — the user just saw the welcome screen with
                // no hint of what failed.
                if (widget.error != null && widget.error!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AuthErrorBanner(message: widget.error!),
                ],
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      children: [
                        const _Logo(),
                        const SizedBox(height: 24),
                        // Brand wordmark — the designed glossy water "Nuveli"
                        // lockup (assets/icons/nuveli_wordmark.png). Rounded
                        // corners soften the asset's own deep-blue panel against
                        // the welcome background.
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/icons/nuveli_wordmark.png',
                            width: 248,
                            fit: BoxFit.contain,
                            semanticLabel: 'Nuveli',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.appTagline ?? 'AI Calorie Coach',
                          style: AppTypography.body18.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      AuthPrimaryButton(
                        label: l10n?.welcomeGetStarted ?? 'Get Started',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthLinkText(
                        prefix: l10n?.signupAlreadyHaveAccount ?? 'Already have an account?',
                        linkText: l10n?.signupSignIn ?? 'Sign in',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOGO — a cute, smiling water-drop brand mark inside a glow halo.
// Drawn in code (CustomPaint) so it stays crisp at any size and needs no
// raster asset. Replaces the old splash_logo.png box render.
// ============================================================================

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryCyan.withValues(alpha: 0.6),
            AppColors.primaryCyan.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(child: SmilingDrop(size: 58)),
    );
  }
}

// (Smiling-drop mark now lives in shared/widgets/smiling_drop.dart)
