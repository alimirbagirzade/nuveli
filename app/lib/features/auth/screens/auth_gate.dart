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
              SizedBox(
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

// ============================================================================
// DASHBOARD PLACEHOLDER
// TODO Chat 22 sonrası: ölü kod, silinebilir (artık DashboardScreen kullanılıyor).
// ============================================================================

class _DashboardPlaceholder extends ConsumerWidget {
  const _DashboardPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthUserProvider);
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;

    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  '👋 Welcome to Nuveli',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile?.displayName ?? user?.email ?? 'User',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142346).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('Calorie target',
                          '${profile?.dailyCalorieTarget ?? "—"} kcal'),
                      _row('Water target',
                          '${profile?.dailyWaterMl ?? "—"} ml'),
                      _row('Goal', profile?.goalType?.label ?? '—'),
                      _row('Activity',
                          profile?.activityLevel?.label ?? '—'),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Chat 16+: Dashboard, AI Scan, Analytics, Water, '
                  'Meal Planner, Habits, AI Coach will be wired here.',
                  style: TextStyle(
                    color: AppColors.tertiaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Sign out',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () =>
                        ref.read(authProvider.notifier).signOut(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.secondaryText)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
