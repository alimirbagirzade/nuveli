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
