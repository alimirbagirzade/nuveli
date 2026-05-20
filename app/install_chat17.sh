#!/usr/bin/env bash
# ============================================================
# Nuveli — Chat 17: Navigation & Routing Installer
# ============================================================
# Kullanım:
#   cd ~/Development/nuveli
#   bash install_chat17.sh
# ============================================================

set -euo pipefail

# Renkli output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
ok()      { echo -e "${GREEN}✓${NC}  $1"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }
err()     { echo -e "${RED}✗${NC}  $1"; }

# ============================================================
# 0) Sanity check
# ============================================================
if [[ ! -f "pubspec.yaml" ]]; then
  err "pubspec.yaml bulunamadı. Bu scripti Flutter projesinin köküde çalıştır:"
  err "  cd ~/Development/nuveli && bash install_chat17.sh"
  exit 1
fi

if ! grep -q "name:" pubspec.yaml; then
  err "pubspec.yaml geçersiz görünüyor."
  exit 1
fi

PROJECT_NAME=$(grep "^name:" pubspec.yaml | awk '{print $2}')
info "Proje: ${PROJECT_NAME}"
info "Hedef dizin: $(pwd)"
echo

# ============================================================
# 1) Yedekle (varsa)
# ============================================================
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=".chat17_backup_${TIMESTAMP}"

if [[ -f "lib/main.dart" ]] || [[ -d "lib/core/routing" ]]; then
  info "Mevcut dosyaları yedekliyorum → ${BACKUP_DIR}/"
  mkdir -p "${BACKUP_DIR}/lib/core"
  [[ -f "lib/main.dart" ]] && cp "lib/main.dart" "${BACKUP_DIR}/lib/main.dart" && ok "lib/main.dart yedeklendi"
  [[ -d "lib/core/routing" ]] && cp -r "lib/core/routing" "${BACKUP_DIR}/lib/core/routing" && ok "lib/core/routing/ yedeklendi"
  echo
fi

# ============================================================
# 2) Dizin yapısı
# ============================================================
mkdir -p lib/core/routing
ok "lib/core/routing/ dizini hazır"
echo

# ============================================================
# 3) route_paths.dart
# ============================================================
info "Yazılıyor: lib/core/routing/route_paths.dart"
cat > lib/core/routing/route_paths.dart << 'EOF'
/// Tüm route URL sabitleri tek bir yerde.
///
/// Kural: Magic string yok. Her `context.go()`, `context.push()` çağrısı
/// burayı kullanmalı. Bu sayede route yapısı değişince tek dosyada
/// güncelleme yeterli olur.
class Routes {
  Routes._();

  static const root = '/';

  // ========== AUTH ==========
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const onboarding = '/onboarding';

  // ========== MAIN TABS (bottom nav) ==========
  static const dashboard = '/dashboard';
  static const meals = '/meals';
  static const analytics = '/analytics';
  static const profile = '/profile';

  // ========== DASHBOARD SUB-PAGES ==========
  static const water = '/dashboard/water';
  static const habits = '/dashboard/habits';
  static const aiCoach = '/dashboard/ai-coach';

  // ========== MEALS SUB-PAGES ==========
  static const mealScan = '/meals/scan';
  static const mealPlanner = '/meals/planner';
  static String mealDetail(String id) => '/meals/$id';
  static String recipeDetail(String id) => '/meals/recipes/$id';

  // ========== ANALYTICS SUB-PAGES ==========
  static const weightLog = '/analytics/weight';
  static const achievements = '/analytics/achievements';

  // ========== PROFILE SUB-PAGES ==========
  static const settings = '/profile/settings';
  static const profileEdit = '/profile/edit';
  static const premium = '/profile/premium';
}
EOF
ok "route_paths.dart yazıldı"

# ============================================================
# 4) auth_redirect.dart
# ============================================================
info "Yazılıyor: lib/core/routing/auth_redirect.dart"
cat > lib/core/routing/auth_redirect.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/profile/providers/current_user_provider.dart';
import 'route_paths.dart';

/// Tüm auth redirect kararlarını tek bir yerde toplar.
///
/// Akış:
/// 1) Reset-password deep link → her zaman geçer (token taşır)
/// 2) Login değilse → `/welcome` (auth sayfasındaysa kalır)
/// 3) Profile yükleniyorsa → bekle (sonsuz redirect döngüsü olmasın)
/// 4) Login ama onboarding yarım → `/onboarding`
/// 5) Login + onboarded ama auth/onboarding'deyse → `/dashboard`
/// 6) `/` köküne gelen → `/dashboard`
class AuthRedirect {
  AuthRedirect(this.ref);

  final Ref ref;

  /// `null` döndürürse mevcut navigation'a izin verilir.
  /// String döndürürse o adrese yönlendirilir.
  String? redirect(BuildContext context, GoRouterState state) {
    final authState = ref.read(authProvider);
    final profileState = ref.read(currentUserProvider);

    final isLoggedIn = authState.valueOrNull != null;
    final onboardingDone =
        profileState.valueOrNull?.onboardingCompleted ?? false;
    final location = state.matchedLocation;

    // Sayfa sınıflandırması
    const authPages = {
      Routes.welcome,
      Routes.login,
      Routes.signup,
      Routes.forgotPassword,
      Routes.resetPassword,
    };
    final isOnAuthPage = authPages.contains(location);
    final isOnOnboarding = location == Routes.onboarding;
    final isOnResetPassword = location == Routes.resetPassword;

    // 1) Reset-password deep link — login olmayan kullanıcı da erişebilmeli
    if (isOnResetPassword) return null;

    // 2) Login değil → welcome
    if (!isLoggedIn) {
      return isOnAuthPage ? null : Routes.welcome;
    }

    // 3) Profile yükleniyor → bekle (loading state'te redirect yapma)
    if (profileState.isLoading) return null;

    // 4) Login ama onboarding yarım → onboarding zorunlu
    if (!onboardingDone) {
      return isOnOnboarding ? null : Routes.onboarding;
    }

    // 5) Login + onboarded ama hala auth/onboarding sayfasındaysa → dashboard
    if (isOnAuthPage || isOnOnboarding) {
      return Routes.dashboard;
    }

    // 6) Köke gelen → dashboard
    if (location == Routes.root) {
      return Routes.dashboard;
    }

    return null;
  }
}
EOF
ok "auth_redirect.dart yazıldı"

# ============================================================
# 5) route_observer.dart
# ============================================================
info "Yazılıyor: lib/core/routing/route_observer.dart"
cat > lib/core/routing/route_observer.dart << 'EOF'
import 'package:flutter/material.dart';

// Chat 19'da Firebase Analytics eklenince uncomment:
// import 'package:firebase_analytics/firebase_analytics.dart';

/// Navigation event'lerini gözlemler: hem debug log, hem analytics.
///
/// Şu an sadece `debugPrint` yapıyor. Chat 19'da Firebase Analytics aktif
/// edilince `_sendAnalytics` içindeki TODO'yu uncomment et — `_logRoute`'a
/// dokunmaya gerek yok.
class NuveliRouteObserver extends NavigatorObserver {
  // final _analytics = FirebaseAnalytics.instance;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('PUSH', route);
    _sendAnalytics(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('POP', route);
    if (previousRoute != null) _sendAnalytics(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _logRoute('REPLACE', newRoute);
      _sendAnalytics(newRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('REMOVE', route);
  }

  void _logRoute(String action, Route<dynamic> route) {
    final name = route.settings.name ?? route.runtimeType.toString();
    debugPrint('[Router] $action: $name');
  }

  void _sendAnalytics(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;

    // TODO(chat-19): Firebase Analytics aktif edilince uncomment:
    // _analytics.logScreenView(screenName: name);
  }
}
EOF
ok "route_observer.dart yazıldı"

# ============================================================
# 6) main_scaffold.dart
# ============================================================
info "Yazılıyor: lib/core/routing/main_scaffold.dart"
cat > lib/core/routing/main_scaffold.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/nuveli_background.dart';
import '../../shared/widgets/nuveli_bottom_nav.dart';

/// 4 ana sekmeyi (Dashboard, Meals, Analytics, Profile) Nuveli arka planı +
/// kalıcı bottom navigation ile sarmalar.
///
/// `StatefulShellRoute.indexedStack` sayesinde her sekme kendi navigation
/// stack'ini korur — bir sekmede alt sayfaya girip başka sekmeye geçip
/// geri döndüğünde kaldığın yerden devam edersin.
///
/// Aynı sekmeye iki kez basınca o sekmenin köküne pop yapar.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: NuveliBackground(
        child: navigationShell,
      ),
      bottomNavigationBar: NuveliBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(index),
      ),
    );
  }

  void _onTap(int index) {
    // Aktif sekmeye tekrar basılırsa o sekmenin köküne dön.
    // initialLocation: true → branch'i initial route'a reset eder.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
EOF
ok "main_scaffold.dart yazıldı"

# ============================================================
# 7) error_screen.dart
# ============================================================
info "Yazılıyor: lib/core/routing/error_screen.dart"
cat > lib/core/routing/error_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/nuveli_background.dart';
import '../../shared/widgets/nuveli_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'route_paths.dart';

/// Bilinmeyen route veya yönlendirme hatasında gösterilen 404 ekranı.
///
/// `GoRouter.errorBuilder` tarafından çağrılır.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NuveliBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sayfa Bulunamadı',
                    style: AppTypography.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aradığın sayfa mevcut değil veya taşınmış olabilir.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 32),
                  NuveliButton(
                    text: 'Ana Sayfaya Dön',
                    onPressed: () => context.go(Routes.dashboard),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
EOF
ok "error_screen.dart yazıldı"

# ============================================================
# 8) app_router.dart (en uzunu)
# ============================================================
info "Yazılıyor: lib/core/routing/app_router.dart"
cat > lib/core/routing/app_router.dart << 'EOF'
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ========== AUTH SCREENS ==========
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';

// ========== TAB 0: DASHBOARD ==========
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/water_tracker/water_tracker_screen.dart';
import '../../features/habits/habits_screen.dart';
import '../../features/ai_coach/ai_coach_screen.dart';

// ========== TAB 1: MEALS ==========
import '../../features/meals/meals_list_screen.dart';
import '../../features/meal_scan/meal_scan_screen.dart';
import '../../features/meal_planner/meal_planner_screen.dart';
import '../../features/meals/meal_detail_screen.dart';
import '../../features/meals/recipe_detail_screen.dart';

// ========== TAB 2: ANALYTICS ==========
import '../../features/analytics/analytics_screen.dart';
import '../../features/analytics/weight_log_screen.dart';
import '../../features/analytics/achievements_screen.dart';

// ========== TAB 3: PROFILE ==========
import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/profile/profile_edit_screen.dart';
import '../../features/profile/premium_paywall_screen.dart';

import 'auth_redirect.dart';
import 'error_screen.dart';
import 'main_scaffold.dart';
import 'route_observer.dart';
import 'route_paths.dart';

/// Root navigator key — modal/dialog gibi bottom nav'ın ÜSTÜNDE göstermek
/// istediğin sayfalar için `parentNavigatorKey` olarak kullanılır.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Sekme branch'leri için ayrı navigator key'leri.
/// Her sekmenin kendi stack'i olduğu için.
final _dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _mealsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'meals');
final _analyticsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'analytics');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// Uygulama router'ı. `main.dart` içinde `MaterialApp.router(routerConfig: ...)`
/// olarak verilir.
final routerProvider = Provider<GoRouter>((ref) {
  final authRedirect = AuthRedirect(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.dashboard,
    debugLogDiagnostics: true,
    observers: [NuveliRouteObserver()],

    // Supabase auth state değişince router yeniden değerlendirir
    // (login/logout sonrası otomatik redirect tetiklenir).
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),

    redirect: authRedirect.redirect,
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error?.toString() ?? 'Bilinmeyen hata',
    ),

    routes: [
      // ╔══════════════════════════════════════════════════════════╗
      // ║              AUTH FLOW (bottom nav YOK)                  ║
      // ╚══════════════════════════════════════════════════════════╝
      GoRoute(
        path: Routes.welcome,
        name: 'welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        name: 'signup',
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        name: 'resetPassword',
        builder: (_, state) {
          // Deep link: nuveli://reset-password?token=xxx
          final token = state.uri.queryParameters['token'];
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: Routes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ╔══════════════════════════════════════════════════════════╗
      // ║         MAIN APP (4 sekmeli ShellRoute)                  ║
      // ║  StatefulShellRoute.indexedStack — her sekmenin kendi    ║
      // ║  stack'i var, state korunur.                             ║
      // ╚══════════════════════════════════════════════════════════╝
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          // ───────── TAB 0: DASHBOARD ─────────
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.dashboard,
                name: 'dashboard',
                pageBuilder: (_, __) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'water',
                    name: 'water',
                    builder: (_, __) => const WaterTrackerScreen(),
                  ),
                  GoRoute(
                    path: 'habits',
                    name: 'habits',
                    builder: (_, __) => const HabitsScreen(),
                  ),
                  GoRoute(
                    path: 'ai-coach',
                    name: 'aiCoach',
                    builder: (_, __) => const AICoachScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ───────── TAB 1: MEALS ─────────
          StatefulShellBranch(
            navigatorKey: _mealsNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.meals,
                name: 'meals',
                pageBuilder: (_, __) => const NoTransitionPage(
                  child: MealsListScreen(),
                ),
                routes: [
                  // Modal — bottom nav'ı kapatıp tam ekran açılır
                  GoRoute(
                    path: 'scan',
                    name: 'mealScan',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (_, __) => const MaterialPage(
                      fullscreenDialog: true,
                      child: MealScanScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'planner',
                    name: 'mealPlanner',
                    builder: (_, __) => const MealPlannerScreen(),
                  ),
                  // SIRA ÖNEMLI: recipes/:id mealDetail :id'den önce
                  // yoksa "recipes" string'i meal id sanılır.
                  GoRoute(
                    path: 'recipes/:recipeId',
                    name: 'recipeDetail',
                    builder: (_, state) => RecipeDetailScreen(
                      recipeId: state.pathParameters['recipeId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':mealId',
                    name: 'mealDetail',
                    builder: (_, state) => MealDetailScreen(
                      mealId: state.pathParameters['mealId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ───────── TAB 2: ANALYTICS ─────────
          StatefulShellBranch(
            navigatorKey: _analyticsNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.analytics,
                name: 'analytics',
                pageBuilder: (_, __) => const NoTransitionPage(
                  child: AnalyticsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'weight',
                    name: 'weightLog',
                    builder: (_, __) => const WeightLogScreen(),
                  ),
                  GoRoute(
                    path: 'achievements',
                    name: 'achievements',
                    builder: (_, __) => const AchievementsScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ───────── TAB 3: PROFILE ─────────
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.profile,
                name: 'profile',
                pageBuilder: (_, __) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (_, __) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'profileEdit',
                    builder: (_, __) => const ProfileEditScreen(),
                  ),
                  // Premium paywall — bottom nav'ı kapatıp tam ekran açılır
                  GoRoute(
                    path: 'premium',
                    name: 'premium',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (_, __) => const MaterialPage(
                      fullscreenDialog: true,
                      child: PremiumPaywallScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Bir Stream'i `ChangeNotifier`'a köprüler.
///
/// GoRouter `refreshListenable` parametresi `Listenable` bekler, ama
/// Supabase auth state değişiklikleri Stream olarak gelir. Bu sınıf
/// köprü görevi görür — stream her tetiklendiğinde notifyListeners()
/// çağırır, GoRouter da redirect'i yeniden değerlendirir.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
EOF
ok "app_router.dart yazıldı"

# ============================================================
# 9) lib/main.dart (üzerine yazılır)
# ============================================================
info "Yazılıyor: lib/main.dart (üzerine yazılıyor)"
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Env vars yükle (.env dosyası proje köküde olmalı, .gitignore'da)
  await dotenv.load(fileName: '.env');

  // Supabase init
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: NuveliApp()));
}

class NuveliApp extends ConsumerWidget {
  const NuveliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Nuveli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
EOF
ok "lib/main.dart yazıldı"

echo
# ============================================================
# 10) pubspec.yaml — go_router var mı kontrol
# ============================================================
if grep -q "^  go_router:" pubspec.yaml; then
  ok "go_router zaten pubspec.yaml'da var"
else
  warn "go_router pubspec.yaml'da yok — eklemen gerek:"
  echo ""
  echo "    dependencies:"
  echo "      go_router: ^13.0.0"
  echo ""
  warn "Manuel ekle, sonra: flutter pub get"
fi

echo
ok "Tüm dosyalar yazıldı! 🎉"
echo
echo "═══════════════════════════════════════════════════════════"
echo "  SONRAKİ ADIMLAR"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "1. pubspec.yaml'a go_router ekle (yoksa):"
echo -e "   ${GREEN}flutter pub add go_router${NC}"
echo ""
echo -e "2. Eski AuthGate widget'ını sil (varsa):"
echo -e "   ${GREEN}rm -f lib/features/auth/widgets/auth_gate.dart${NC}"
echo ""
echo -e "3. Stub butonları gerçek navigation'a çevir:"
echo -e "   ${BLUE}Dashboard → '+ Add Food' → context.push(Routes.mealScan)${NC}"
echo -e "   ${BLUE}AI Coach → 'Apply Tip' → context.push(Routes.habits)${NC}"
echo -e "   ${BLUE}Profile → ⚙️ Settings → context.push(Routes.settings)${NC}"
echo -e "   ${BLUE}(detaylar için bir önceki Claude chat'inin README'sine bak)${NC}"
echo ""
echo -e "4. iOS deep link config — ios/Runner/Info.plist:"
echo -e "   ${BLUE}<key>CFBundleURLTypes</key> + nuveli:// scheme${NC}"
echo ""
echo -e "5. Android deep link config — AndroidManifest.xml:"
echo -e "   ${BLUE}<intent-filter> + nuveli:// scheme${NC}"
echo ""
echo -e "6. Test et:"
echo -e "   ${GREEN}flutter run${NC}"
echo ""
echo "═══════════════════════════════════════════════════════════"
if [[ -d "${BACKUP_DIR}" ]]; then
  echo "  Yedek: ${BACKUP_DIR}/"
  echo "  Sorun olursa: rm -rf lib/core/routing lib/main.dart && cp -r ${BACKUP_DIR}/lib/* lib/"
  echo "═══════════════════════════════════════════════════════════"
fi
