// ============================================================================
// auth_gate.dart
// App'in en başında çalışan widget. Auth state + profile state'e göre
// doğru ekrana yönlendirir:
//
//   - loading                 → splash
//   - logged out              → WelcomeScreen
//   - logged in, no profile   → OnboardingScreen
//   - logged in, profile incomplete → OnboardingScreen
//   - logged in, complete     → DashboardScreen (main app)
//
// main.dart'ta `home: const AuthGate()` olarak kullanılır.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nuveli_background.dart';
import '../../dashboard/dashboard_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/current_user_provider.dart';
import 'onboarding/onboarding_screen.dart';
import 'welcome_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const _SplashScreen(),
      error: (e, _) => WelcomeScreen(error: e.toString()),
      data: (user) {
        // 1. Logged out
        if (user == null) {
          return const WelcomeScreen();
        }

        // 2. Logged in → profile fetch et
        final profileAsync = ref.watch(currentUserProfileProvider);
        return profileAsync.when(
          loading: () => const _SplashScreen(),
          error: (e, _) {
            // Backend ulaşılamıyor → kullanıcıyı onboarding'e götür,
            // backend gelince orada hata gösterebilir.
            // Alternatif: hata ekranı + retry button. Şimdilik onboarding.
            return const OnboardingScreen();
          },
          data: (profile) {
            // 3. Profile yok ya da onboarding tamamlanmamış
            if (profile == null || !profile.onboardingCompleted) {
              return const OnboardingScreen();
            }
            // 4. Ana app
            return const DashboardScreen();
          },
        );
      },
    );
  }
}

// ============================================================================
// SPLASH — Auth state belirlenirken kısa bir loading
// ============================================================================

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryCyan.withValues(alpha: 0.6),
                      AppColors.primaryCyan.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

