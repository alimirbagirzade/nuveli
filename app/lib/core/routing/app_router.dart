import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/coach/screens/coach_chat_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/meal/screens/manual_meal_entry_screen.dart';
import '../../features/meal/screens/meal_analysis_result_screen.dart';
import '../../features/meal/screens/meal_capture_screen.dart';
import '../../features/premium/screens/paywall_screen.dart';
import '../../features/progress/screens/empty_day_screen.dart';
import '../../features/progress/screens/monthly_insight_screen.dart';
import '../../features/progress/screens/weekly_summary_screen.dart';
import '../../features/settings/screens/delete_account_screen.dart';
import '../../features/settings/screens/how_ai_works_screen.dart';
import '../../features/settings/screens/notification_prefs_screen.dart';
import '../../features/settings/screens/privacy_safety_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/support_screen.dart';

part 'app_router.g.dart';

/// Tüm route isimleri burada tanımlıdır.
class AppRoute {
  AppRoute._();

  // Splash & Auth
  static const splash = '/';
  static const login = '/login';

  // Acceptance
  static const acceptanceAgeGate = '/acceptance/age-gate';
  static const acceptanceWellnessScope = '/acceptance/wellness-scope';
  static const acceptanceAiEstimates = '/acceptance/ai-estimates';
  static const acceptanceSpecialCases = '/acceptance/special-cases';
  static const acceptanceTerms = '/acceptance/terms';

  // Onboarding
  static const onboardingGoal = '/onboarding/goal';
  static const onboardingProfileOne = '/onboarding/profile/1';
  static const onboardingProfileTwo = '/onboarding/profile/2';
  static const onboardingCoach = '/onboarding/coach';
  static const onboardingNotification = '/onboarding/notification';
  static const onboardingResult = '/onboarding/result';

  // Main
  static const home = '/home';
  static const mealEntry = '/meal/entry';
  static const mealCapture = '/meal/capture';
  static const mealManual = '/meal/manual';
  static const mealResult = '/meal/result';
  static const coach = '/coach';
  static const progress = '/progress';
  static const weeklySummary = '/progress/weekly';
  static const monthlyInsight = '/progress/monthly';
  static const emptyDay = '/progress/empty';
  static const settings = '/settings';

  // Premium
  static const paywall = '/paywall';

  // Settings sub
  static const notificationPrefs = '/settings/notifications';
  static const support = '/settings/support';
  static const howAiWorks = '/settings/how-ai-works';
  static const privacySafety = '/settings/privacy-safety';
  static const deleteAccount = '/settings/delete-account';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoute.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAtSplash = state.matchedLocation == AppRoute.splash;

      // Splash her zaman geçilebilir — initial boot için
      if (isAtSplash) return null;

      // Auth gerektirmeyen ekranlar
      const publicPaths = [
        AppRoute.login,
        AppRoute.acceptanceAgeGate,
        AppRoute.acceptanceWellnessScope,
        AppRoute.acceptanceAiEstimates,
        AppRoute.acceptanceSpecialCases,
        AppRoute.acceptanceTerms,
      ];
      if (publicPaths.contains(state.matchedLocation)) return null;

      // Auth yoksa → login
      if (session == null) return AppRoute.login;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash,
        builder: (context, state) => const _SplashPlaceholder(),
      ),
      GoRoute(
        path: AppRoute.login,
        builder: (context, state) => const _PlaceholderScreen(title: 'Giriş'),
      ),

      // Home & main
      GoRoute(
        path: AppRoute.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Meal
      GoRoute(
        path: AppRoute.mealCapture,
        builder: (context, state) => const MealCaptureScreen(),
      ),
      GoRoute(
        path: AppRoute.mealManual,
        builder: (context, state) => const ManualMealEntryScreen(),
      ),
      GoRoute(
        path: AppRoute.mealResult,
        builder: (context, state) => const MealAnalysisResultScreen(),
      ),

      // Coach
      GoRoute(
        path: AppRoute.coach,
        builder: (context, state) => const CoachChatScreen(),
      ),

      // Progress
      GoRoute(
        path: '/progress/weekly',
        builder: (context, state) => const WeeklySummaryScreen(),
      ),
      GoRoute(
        path: '/progress/monthly',
        builder: (context, state) => const MonthlyInsightScreen(),
      ),
      GoRoute(
        path: '/progress/empty',
        builder: (context, state) => const EmptyDayScreen(),
      ),

      // Premium
      GoRoute(
        path: AppRoute.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),

      // Settings
      GoRoute(
        path: AppRoute.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoute.notificationPrefs,
        builder: (context, state) => const NotificationPrefsScreen(),
      ),
      GoRoute(
        path: AppRoute.support,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoute.howAiWorks,
        builder: (context, state) => const HowAiWorksScreen(),
      ),
      GoRoute(
        path: AppRoute.privacySafety,
        builder: (context, state) => const PrivacySafetyScreen(),
      ),
      GoRoute(
        path: AppRoute.deleteAccount,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.uri}'),
      ),
    ),
  );
}

// Geçici splash — Prompt 2.x'te gerçek ekranla değiştirilecek
class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'nuveli',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title ekranı geliştiriliyor...')),
    );
  }
}
