import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ═══ AUTH SCREENS (Chat 15 — mevcut) ═══
import 'package:nuveli/features/auth/screens/welcome_screen.dart';
import 'package:nuveli/features/auth/screens/login_screen.dart';
import 'package:nuveli/features/auth/screens/signup_screen.dart';
import 'package:nuveli/features/auth/screens/forgot_password_screen.dart';
import 'package:nuveli/features/auth/screens/reset_password_screen.dart';
import 'package:nuveli/features/auth/screens/email_verification_screen.dart';
import 'package:nuveli/features/auth/screens/onboarding/onboarding_screen.dart';

// ═══ TAB SCREENS (mevcut olanlar) ═══
import 'package:nuveli/features/dashboard/dashboard_screen.dart';
import 'package:nuveli/features/profile/goals_profile_screen.dart';

// ═══ ROUTING INTERNALS ═══
import 'auth_redirect.dart';
import 'error_screen.dart';
import 'main_scaffold.dart';
import 'placeholder_screen.dart';
import 'route_observer.dart';
import 'route_paths.dart';

/// Root navigator key — bottom nav'ın ÜSTÜNDE göstermek istediğin
/// modal/fullscreen sayfalar için `parentNavigatorKey` olarak kullan.
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _dashKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _mealsKey = GlobalKey<NavigatorState>(debugLabel: 'meals');
final _analyticsKey = GlobalKey<NavigatorState>(debugLabel: 'analytics');
final _profileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final routerProvider = Provider<GoRouter>((ref) {
  const guard = AuthRedirect();

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.dashboard,
    debugLogDiagnostics: true,
    observers: [NuveliRouteObserver()],
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: guard.redirect,
    errorBuilder: (_, state) => ErrorScreen(
      error: state.error?.toString() ?? 'Bilinmeyen hata',
    ),
    routes: [
      // ─────── AUTH FLOW (bottom nav yok) ───────
      GoRoute(path: Routes.welcome, name: 'welcome',
          builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: Routes.login, name: 'login',
          builder: (_, __) => const LoginScreen()),
      GoRoute(path: Routes.signup, name: 'signup',
          builder: (_, __) => const SignupScreen()),
      GoRoute(path: Routes.forgotPassword, name: 'forgotPassword',
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: Routes.resetPassword,
        name: 'resetPassword',
        builder: (_, state) {
          // Deep link: nuveli://reset-password?token=xxx
          // ResetPasswordScreen'in constructor'ı token alıyorsa burada geçir.
          // Şu an parametresiz çağırıyorum — gerekirse düzelt:
          //   final token = state.uri.queryParameters['token'];
          //   return ResetPasswordScreen(token: token);
          return const ResetPasswordScreen();
        },
      ),
      GoRoute(path: Routes.verifyEmail, name: 'verifyEmail',
          builder: (_, __) => const EmailVerificationScreen()),
      GoRoute(path: Routes.onboarding, name: 'onboarding',
          builder: (_, __) => const OnboardingScreen()),

      // ─────── MAIN APP (4 sekmeli shell) ───────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainScaffold(navigationShell: shell),
        branches: [
          // TAB 0: Dashboard ✓ (mevcut)
          StatefulShellBranch(
            navigatorKey: _dashKey,
            routes: [
              GoRoute(
                path: Routes.dashboard,
                name: 'dashboard',
                pageBuilder: (_, __) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
                // TODO(chat-8/10/11): water, habits, ai-coach sub-route'ları
                // ekran yapıldıkça buraya gelecek
              ),
            ],
          ),

          // TAB 1: Meals — henüz yapılmadı, placeholder
          StatefulShellBranch(
            navigatorKey: _mealsKey,
            routes: [
              GoRoute(
                path: Routes.meals,
                name: 'meals',
                pageBuilder: (_, __) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Öğünler',
                    icon: Icons.restaurant_rounded,
                    chatHint: 'Chat 5 + 9 ile gelecek',
                  ),
                ),
                // TODO(chat-5/9): MealsListScreen, MealScanScreen, MealPlannerScreen
              ),
            ],
          ),

          // TAB 2: Analytics — henüz yapılmadı, placeholder
          StatefulShellBranch(
            navigatorKey: _analyticsKey,
            routes: [
              GoRoute(
                path: Routes.analytics,
                name: 'analytics',
                pageBuilder: (_, __) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Analizler',
                    icon: Icons.show_chart_rounded,
                    chatHint: 'Chat 7 ile gelecek',
                  ),
                ),
                // TODO(chat-7): AnalyticsScreen
              ),
            ],
          ),

          // TAB 3: Profile ✓ (mevcut — GoalsProfileScreen)
          StatefulShellBranch(
            navigatorKey: _profileKey,
            routes: [
              GoRoute(
                path: Routes.profile,
                name: 'profile',
                pageBuilder: (_, __) => const NoTransitionPage(
                  child: GoalsProfileScreen(),
                ),
                // TODO: SettingsScreen, ProfileEditScreen, PremiumPaywallScreen
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Stream → ChangeNotifier köprüsü.
/// Supabase auth state değişince GoRouter redirect'i yeniden değerlendirir.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
