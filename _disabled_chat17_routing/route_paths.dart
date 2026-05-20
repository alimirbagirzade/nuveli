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
