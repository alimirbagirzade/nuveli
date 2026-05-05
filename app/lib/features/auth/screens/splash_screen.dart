import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/auth_repository.dart';

/// Splash ekranı. Oturum durumunu kontrol eder ve yönlendirir.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _resolveRoute();
  }

  Future<void> _resolveRoute() async {
    // Kısa görsel bekleme (branding)
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final repo = ref.read(authRepositoryProvider);

    // Oturum yok → login
    if (repo.currentSession == null) {
      context.go(AppRoute.login);
      return;
    }

    // Oturum var → bootstrap çek
    try {
      final bootstrap = await repo.getBootstrap();
      if (!mounted) return;

      final onboardingDone = bootstrap?['onboarding_completed'] == true;

      if (onboardingDone) {
        context.go(AppRoute.home);
      } else {
        context.go(AppRoute.acceptanceAgeGate);
      }
    } catch (_) {
      // Network/backend hatası → login'e geri at
      if (mounted) context.go(AppRoute.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'nuveli',
              style: AppTextStyles.displayLarge.copyWith(
                letterSpacing: -1,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI Calorie Coach',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
