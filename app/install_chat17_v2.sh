#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════
# Nuveli — Chat 17: Navigation & Routing | Installer v2
# ════════════════════════════════════════════════════════════
# Gerçek proje yapısına göre uyarlandı:
# - Mevcut: auth (7 screen), dashboard, profile (GoalsProfileScreen)
# - Yok: meals/analytics tab'ları, tüm sub-page'ler → placeholder
# - Auth: Supabase direkt (provider varsayımı yok)
#
# Kullanım:
#   cd ~/Development/nuveli/app    ← DİKKAT: 'app' alt klasörü!
#   bash install_chat17_v2.sh
# ════════════════════════════════════════════════════════════

set -euo pipefail

G='\033[0;32m'; Y='\033[0;33m'; B='\033[0;34m'; R='\033[0;31m'; N='\033[0m'
info() { echo -e "${B}ℹ${N}  $1"; }
ok()   { echo -e "${G}✓${N}  $1"; }
warn() { echo -e "${Y}⚠${N}  $1"; }
err()  { echo -e "${R}✗${N}  $1"; }

# ─── Sanity ─────────────────────────────────────────────
[[ -f "pubspec.yaml" ]] || { err "pubspec.yaml yok. cd ~/Development/nuveli/app çalıştır."; exit 1; }
grep -q "^name: nuveli" pubspec.yaml || warn "pubspec.yaml'da 'name: nuveli' bulunamadı — import yolları kırık olabilir."

# Kritik dosyaları doğrula (varsa devam, yoksa uyar)
declare -a REQUIRED=(
  "lib/features/auth/screens/welcome_screen.dart"
  "lib/features/auth/screens/login_screen.dart"
  "lib/features/auth/screens/signup_screen.dart"
  "lib/features/auth/screens/forgot_password_screen.dart"
  "lib/features/auth/screens/reset_password_screen.dart"
  "lib/features/auth/screens/email_verification_screen.dart"
  "lib/features/auth/screens/onboarding/onboarding_screen.dart"
  "lib/features/dashboard/dashboard_screen.dart"
  "lib/features/profile/goals_profile_screen.dart"
  "lib/shared/widgets/nuveli_background.dart"
  "lib/shared/widgets/nuveli_button.dart"
  "lib/shared/widgets/nuveli_bottom_nav.dart"
)
MISSING=0
for f in "${REQUIRED[@]}"; do
  if [[ ! -f "$f" ]]; then
    err "Eksik: $f"
    MISSING=1
  fi
done
[[ $MISSING -eq 1 ]] && { err "Yukarıdaki eksik dosyalar olmadan router derlenmez. Lütfen kontrol et."; exit 1; }
ok "Tüm gerekli ekranlar mevcut"

# ─── Yedek ──────────────────────────────────────────────
TS=$(date +%Y%m%d_%H%M%S)
BAK=".chat17_backup_${TS}"
mkdir -p "$BAK/lib/core"
[[ -f lib/main.dart ]] && cp lib/main.dart "$BAK/lib/main.dart"
[[ -d lib/core/routing ]] && cp -r lib/core/routing "$BAK/lib/core/routing"
ok "Yedek alındı → $BAK/"

# Eski .bak'i temizle (kullanıcının önceki denemesi)
if [[ -f lib/core/routing/app_router.dart.bak ]]; then
  mv lib/core/routing/app_router.dart.bak "$BAK/lib/core/routing/app_router.dart.bak"
  ok "Eski app_router.dart.bak yedeklenip kaldırıldı"
fi

mkdir -p lib/core/routing

# ════════════════════════════════════════════════════════════
# 1) route_paths.dart
# ════════════════════════════════════════════════════════════
cat > lib/core/routing/route_paths.dart << 'EOF'
/// Tüm route URL sabitleri tek bir yerde.
/// Magic string yerine `Routes.dashboard` kullan.
class Routes {
  Routes._();

  static const root = '/';

  // Auth
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const verifyEmail = '/verify-email';
  static const onboarding = '/onboarding';

  // Main tabs (bottom nav)
  static const dashboard = '/dashboard';
  static const meals = '/meals';
  static const analytics = '/analytics';
  static const profile = '/profile';

  // Sub-pages — sonraki chat'lerde aktif olunca burası dolacak
  // static const water = '/dashboard/water';
  // static const habits = '/dashboard/habits';
  // ...
}
EOF
ok "route_paths.dart"

# ════════════════════════════════════════════════════════════
# 2) auth_redirect.dart — Supabase direkt, provider yok
# ════════════════════════════════════════════════════════════
cat > lib/core/routing/auth_redirect.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'route_paths.dart';

/// Tüm auth redirect kararları tek bir yerde.
///
/// Auth state'i doğrudan Supabase'den okur — Chat 15'teki authProvider
/// pattern'i geldiğinde bu sınıfı `Ref` alacak şekilde refactor edebilirsin.
///
/// Onboarding tamamlanma kontrolü: `user.userMetadata['onboarding_completed']`.
/// Onboarding ekranının son adımında bu metadata'yı set et:
///   await Supabase.instance.client.auth.updateUser(
///     UserAttributes(data: {'onboarding_completed': true}),
///   );
class AuthRedirect {
  const AuthRedirect();

  String? redirect(BuildContext context, GoRouterState state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    final onboardingDone =
        user?.userMetadata?['onboarding_completed'] == true;
    final emailConfirmed = user?.emailConfirmedAt != null;
    final loc = state.matchedLocation;

    const authPages = {
      Routes.welcome,
      Routes.login,
      Routes.signup,
      Routes.forgotPassword,
      Routes.resetPassword,
      Routes.verifyEmail,
    };
    final onAuth = authPages.contains(loc);
    final onOnboarding = loc == Routes.onboarding;
    final onResetPassword = loc == Routes.resetPassword;

    // 1) Reset-password deep link → her zaman geçer (token taşır)
    if (onResetPassword) return null;

    // 2) Login değil → welcome (auth sayfasındaysa kalır)
    if (!isLoggedIn) return onAuth ? null : Routes.welcome;

    // 3) Login ama email doğrulanmadı → verify-email
    if (!emailConfirmed && loc != Routes.verifyEmail) {
      return Routes.verifyEmail;
    }

    // 4) Login + email OK ama onboarding yarım → onboarding
    if (!onboardingDone) return onOnboarding ? null : Routes.onboarding;

    // 5) Tamamlandı ama hala auth/onboarding'deyse → dashboard
    if (onAuth || onOnboarding) return Routes.dashboard;

    // 6) Köke gelen → dashboard
    if (loc == Routes.root) return Routes.dashboard;

    return null;
  }
}
EOF
ok "auth_redirect.dart"

# ════════════════════════════════════════════════════════════
# 3) route_observer.dart
# ════════════════════════════════════════════════════════════
cat > lib/core/routing/route_observer.dart << 'EOF'
import 'package:flutter/material.dart';

// TODO(chat-19): Firebase Analytics eklenince uncomment:
// import 'package:firebase_analytics/firebase_analytics.dart';

/// Navigation event'lerini hem debug log'lar hem analytics'e gönderir.
class NuveliRouteObserver extends NavigatorObserver {
  // final _analytics = FirebaseAnalytics.instance;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('PUSH', route);
    _send(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('POP', route);
    if (previousRoute != null) _send(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _log('REPLACE', newRoute);
      _send(newRoute);
    }
  }

  void _log(String action, Route<dynamic> route) {
    final name = route.settings.name ?? route.runtimeType.toString();
    debugPrint('[Router] $action: $name');
  }

  void _send(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    // _analytics.logScreenView(screenName: name);  // chat-19
  }
}
EOF
ok "route_observer.dart"

# ════════════════════════════════════════════════════════════
# 4) main_scaffold.dart
# ════════════════════════════════════════════════════════════
cat > lib/core/routing/main_scaffold.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/nuveli_background.dart';
import '../../shared/widgets/nuveli_bottom_nav.dart';

/// 4 ana sekmeyi Nuveli arka planı + kalıcı bottom nav ile sarmalar.
///
/// StatefulShellRoute.indexedStack sayesinde her sekme kendi navigation
/// stack'ini korur — sekmeler arasında geçince scroll/state kaybolmaz.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: NuveliBackground(child: navigationShell),
      bottomNavigationBar: NuveliBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Aktif sekmeye tekrar basılırsa o sekmenin köküne dön
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
EOF
ok "main_scaffold.dart"

# ════════════════════════════════════════════════════════════
# 5) error_screen.dart — theme'e dokunmadan sade
# ════════════════════════════════════════════════════════════
cat > lib/core/routing/error_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/nuveli_background.dart';
import '../../shared/widgets/nuveli_button.dart';
import 'route_paths.dart';

/// 404 / yönlendirme hatası ekranı.
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
                    color: Color(0xFFFF5C5C),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sayfa Bulunamadı',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aradığın sayfa mevcut değil veya taşınmış olabilir.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB8C5D6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6E7B91),
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
ok "error_screen.dart"

# ════════════════════════════════════════════════════════════
# 6) placeholder_screen.dart — gelmemiş tab'lar için
# ════════════════════════════════════════════════════════════
cat > lib/core/routing/placeholder_screen.dart << 'EOF'
import 'package:flutter/material.dart';

/// Henüz inşa edilmemiş ekranlar için geçici "Yakında" görünümü.
///
/// İlgili Chat tamamlanınca bu placeholder yerine gerçek screen import
/// edilmeli (app_router.dart içindeki TODO yorumlarına bak).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle = 'Yakında geliyor',
    this.chatHint,
  });

  final String title;
  final IconData icon;
  final String subtitle;
  final String? chatHint;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: const Color(0xFF00D4FF).withOpacity(0.6)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFB8C5D6),
              ),
            ),
            if (chatHint != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  chatHint!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E7B91),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
EOF
ok "placeholder_screen.dart"

# ════════════════════════════════════════════════════════════
# 7) app_router.dart — GERÇEK proje yapısına göre
# ════════════════════════════════════════════════════════════
cat > lib/core/routing/app_router.dart << 'EOF'
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
EOF
ok "app_router.dart"

# ════════════════════════════════════════════════════════════
# 8) main.dart — AuthGate import'unu kaldır, router'a geç
# ════════════════════════════════════════════════════════════
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nuveli/core/routing/app_router.dart';
import 'package:nuveli/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: dotenv.env['APP_ENV'] != 'production',
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
ok "main.dart (AuthGate kaldırıldı)"

echo
echo "═══════════════════════════════════════════════════════════"
echo -e "  ${G}KURULUM TAMAMLANDI${N}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${B}1.${N} Derlenebilir mi kontrol et:"
echo -e "   ${G}flutter analyze${N}"
echo ""
echo -e "${B}2.${N} Sıcak çalıştır:"
echo -e "   ${G}flutter run${N}"
echo ""
echo -e "${B}3.${N} Eğer ResetPasswordScreen constructor'ı 'token' alıyorsa,"
echo "   app_router.dart içindeki ilgili route'u düzelt (yorum satırı var)."
echo ""
echo -e "${B}4.${N} AppTheme.dark çağrısı patlarsa, theme dosyandaki gerçek"
echo "   API'ye göre main.dart'taki 'theme:' satırını düzelt."
echo ""
echo -e "${Y}NOT:${N} AuthGate widget'ı main.dart'tan kaldırıldı ama dosya silinmedi."
echo "   Test sonrası şununla temizleyebilirsin:"
echo -e "   ${G}rm lib/features/auth/screens/auth_gate.dart${N}"
echo ""
echo -e "${Y}NOT:${N} Onboarding'in son adımına şunu ekle (yoksa redirect döner):"
echo "   await Supabase.instance.client.auth.updateUser("
echo "     UserAttributes(data: {'onboarding_completed': true}),"
echo "   );"
echo ""
echo -e "${B}Yedek:${N} $BAK/"
echo "═══════════════════════════════════════════════════════════"
