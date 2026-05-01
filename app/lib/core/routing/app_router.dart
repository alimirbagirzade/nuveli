import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/coach/screens/coach_chat_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/meal/data/meal_models.dart';
import '../../features/meal/screens/manual_meal_entry_screen.dart';
import '../../features/meal/screens/meal_analysis_result_screen.dart';
import '../../features/meal/screens/meal_capture_screen.dart';
import '../../features/onboarding/screens/acceptance_screens.dart';
import '../../features/onboarding/screens/onboarding_screens.dart';
import '../../features/onboarding/screens/welcome_age_gate_screen.dart';
import '../../features/premium/screens/paywall_screen.dart';
import 'page_transitions.dart';
import '../../features/progress/screens/empty_day_screen.dart';
import '../../features/progress/screens/day_detail_screen.dart';
import '../../features/progress/screens/monthly_insight_screen.dart';
import '../../features/progress/screens/weekly_summary_screen.dart';
import '../../features/settings/screens/about_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/delete_account_screen.dart';
import '../../features/settings/screens/how_ai_works_screen.dart';
import '../../features/settings/screens/notification_prefs_screen.dart';
import '../../features/settings/screens/privacy_safety_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/support_screen.dart';
import '../../features/shared/screens/error_screen.dart';
import '../../features/tracking/screens/water_history_screen.dart';
import '../../features/tracking/screens/weight_history_screen.dart';

/// Tüm route isimleri burada tanımlıdır.
class AppRoute {
  AppRoute._();

  // Splash & Auth
  static const splash = '/';
  static const login = '/login';
  static const signUp = '/signup';
  static const forgotPassword = '/forgot-password';

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
  static const dayDetail = '/progress/day';
  static const settings = '/settings';
  static const profile = '/profile';

  // Tracking history
  static const waterHistory = '/tracking/water-history';
  static const weightHistory = '/tracking/weight-history';

  // Premium
  static const paywall = '/paywall';

  // Settings sub
  static const notificationPrefs = '/settings/notifications';
  static const support = '/settings/support';
  static const about = '/settings/about';
  static const howAiWorks = '/settings/how-ai-works';
  static const privacySafety = '/settings/privacy-safety';
  static const deleteAccount = '/settings/delete-account';
}

/// GoRouter provider — code generation'a gerek kalmadan çalışır.
final appRouterProvider = Provider<GoRouter>((ref) {
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
        AppRoute.signUp,
        AppRoute.forgotPassword,
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
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoute.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Acceptance (5 ekran)
      GoRoute(
        path: AppRoute.acceptanceAgeGate,
        builder: (context, state) => const WelcomeAgeGateScreen(),
      ),
      GoRoute(
        path: AppRoute.acceptanceWellnessScope,
        builder: (context, state) => const WellnessScopeScreen(),
      ),
      GoRoute(
        path: AppRoute.acceptanceAiEstimates,
        builder: (context, state) => const AiEstimatesScreen(),
      ),
      GoRoute(
        path: AppRoute.acceptanceSpecialCases,
        builder: (context, state) => const SpecialCasesScreen(),
      ),
      GoRoute(
        path: AppRoute.acceptanceTerms,
        builder: (context, state) => const TermsPrivacyScreen(),
      ),

      // Onboarding (6 ekran)
      GoRoute(
        path: AppRoute.onboardingGoal,
        builder: (context, state) => const GoalSelectionScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingProfileOne,
        builder: (context, state) => const ProfileStepOneScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingProfileTwo,
        builder: (context, state) => const ProfileStepTwoScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingCoach,
        builder: (context, state) => const CoachSelectionScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingNotification,
        builder: (context, state) => const NotificationOptInScreen(),
      ),
      GoRoute(
        path: AppRoute.onboardingResult,
        builder: (context, state) => const OnboardingResultScreen(),
      ),

      // Home & main
      GoRoute(
        path: AppRoute.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Meal — modal hissi için slide-up
      GoRoute(
        path: AppRoute.mealCapture,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(const MealCaptureScreen()),
      ),
      GoRoute(
        path: AppRoute.mealManual,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(const ManualMealEntryScreen()),
      ),
      GoRoute(
        path: AppRoute.mealResult,
        pageBuilder: (context, state) {
          final analysis = state.extra as MealAnalysisResult?;
          final screen = analysis == null
              ? const MealCaptureScreen()
              : MealAnalysisResultScreen(analysis: analysis);
          return AppPageTransitions.fade(screen);
        },
      ),

      // Coach
      GoRoute(
        path: AppRoute.coach,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const CoachChatScreen()),
      ),

      // Progress
      GoRoute(
        path: '/progress/weekly',
        builder: (context, state) => const WeeklySummaryScreen(),
      ),
      GoRoute(
        path: '/progress/day/:date',
        builder: (context, state) {
          final dateParam = state.pathParameters['date'] ?? '';
          return DayDetailScreen(localDay: dateParam);
        },
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
        pageBuilder: (context, state) =>
            AppPageTransitions.slideUp(const PaywallScreen()),
      ),

      // Tracking history
      GoRoute(
        path: AppRoute.waterHistory,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const WaterHistoryScreen()),
      ),
      GoRoute(
        path: AppRoute.weightHistory,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const WeightHistoryScreen()),
      ),

      // Settings
      GoRoute(
        path: AppRoute.settings,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoute.profile,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoute.notificationPrefs,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const NotificationPrefsScreen()),
      ),
      GoRoute(
        path: AppRoute.support,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const SupportScreen()),
      ),
      GoRoute(
        path: AppRoute.about,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const AboutScreen()),
      ),
      GoRoute(
        path: AppRoute.howAiWorks,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const HowAiWorksScreen()),
      ),
      GoRoute(
        path: AppRoute.privacySafety,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const PrivacySafetyScreen()),
      ),
      GoRoute(
        path: AppRoute.deleteAccount,
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRight(const DeleteAccountScreen()),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(
      title: 'Sayfa bulunamadı',
      message:
          'Aradığın sayfa burada değil. ${state.uri} adresine ulaşılamadı.',
    ),
  );
});

