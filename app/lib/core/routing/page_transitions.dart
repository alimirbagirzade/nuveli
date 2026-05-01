import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// GoRouter için custom page transitions.
///
/// Kullanım:
/// ```dart
/// GoRoute(
///   path: AppRoute.paywall,
///   pageBuilder: (context, state) => slideUpPage(const PaywallScreen()),
/// )
/// ```
class AppPageTransitions {
  AppPageTransitions._();

  /// Aşağıdan yukarı slide — modal ekranlar için (paywall, meal capture).
  static CustomTransitionPage<T> slideUp<T>(Widget child) {
    return CustomTransitionPage<T>(
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  /// Fade — subtle geçiş, ana akış ekranları için.
  static CustomTransitionPage<T> fade<T>(Widget child) {
    return CustomTransitionPage<T>(
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Sağdan kayma — subflow (settings → notification prefs vb.).
  static CustomTransitionPage<T> slideRight<T>(Widget child) {
    return CustomTransitionPage<T>(
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Scale + fade — onboarding başarı ekranı gibi celebration momentleri için.
  static CustomTransitionPage<T> scaleFade<T>(Widget child) {
    return CustomTransitionPage<T>(
      child: child,
      transitionDuration: const Duration(milliseconds: 380),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(curve),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
