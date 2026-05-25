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

import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_error_view.dart';
import '../../../shared/widgets/nuveli_background.dart';
import '../../../shared/widgets/smiling_drop.dart';
import '../../main/main_shell_screen.dart';
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
            // Profile fetch failed for a LOGGED-IN user — this is a transient
            // backend/network error or an expired session, NOT a new user
            // (a missing profile comes back as `data: null`, handled below).
            // Never drop them into onboarding here: re-onboarding over an
            // existing account corrupts data. Show retry instead; the retry
            // re-evaluates auth too, so a truly-expired session falls back to
            // the welcome/login screen.
            return Scaffold(
              backgroundColor: const Color(0xFF050A1F),
              body: Center(
                child: AppErrorView(
                  error: AppError.from(e),
                  onRetry: () {
                    ref.invalidate(currentUserProfileProvider);
                    ref.invalidate(authProvider);
                  },
                ),
              ),
            );
          },
          data: (profile) {
            // 3. Profile yok ya da onboarding tamamlanmamış
            if (profile == null || !profile.onboardingCompleted) {
              return const OnboardingScreen();
            }
            // 4. Ana app
            return const MainShellScreen();
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
                child: const SmilingDrop(size: 44),
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

