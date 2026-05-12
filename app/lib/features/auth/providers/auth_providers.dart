import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/monitoring/crash_reporter.dart';
import '../data/auth_repository.dart';
import '../../../features/coach/data/coach_repository.dart';
import '../../../features/home/data/home_repository.dart';
import '../../../features/meal/providers/meal_providers.dart';
import '../../../features/onboarding/providers/onboarding_controller.dart';
import '../../../features/premium/data/premium_service.dart';
import '../../../features/profile/data/profile_repository.dart';
import '../../../features/progress/data/progress_repository.dart';
import '../../../features/settings/providers/settings_providers.dart';
import '../../../features/streak/data/streak_repository.dart';
import '../../../features/tracking/data/tracking_repository.dart';

/// Kullanıcının mevcut auth durumunu stream olarak sağlar.
/// Router redirect logic buna bağlıdır.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Mevcut kullanıcının oturum bilgisi.
final currentSessionProvider = Provider<Session?>((ref) {
  return ref.watch(authRepositoryProvider).currentSession;
});

/// Mevcut kullanıcı objesi.
/// Auth değiştiğinde Crashlytics'e user ID otomatik tag'lenir (debug'da no-op).
final currentUserProvider = Provider<User?>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  // Fire-and-forget tagging — auth hatalarını engellememesi için async
  CrashReporter.setUser(user?.id);
  return user;
});

/// Bootstrap verisi — uygulama açılışında profil + onboarding durumu.
final bootstrapProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getBootstrap();
});

/// Onboarding tamamlandı mı?
final onboardingCompletedProvider = Provider<bool>((ref) {
  final bootstrap = ref.watch(bootstrapProvider);
  return bootstrap.maybeWhen(
    data: (data) => data?['onboarding_completed'] == true,
    orElse: () => false,
  );
});

/// Auth işlemi sırasında loading state.
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// Auth hata mesajı.
final authErrorProvider = StateProvider<String?>((ref) => null);

/// Signup sonrası verify-email ekranına email+password taşımak için.
/// Sadece bellekte tutulur, app restart'ta kaybolur (güvenli).
class PendingSignupCredentials {
  final String email;
  final String password;
  const PendingSignupCredentials({required this.email, required this.password});
}

final pendingSignupCredentialsProvider =
    StateProvider<PendingSignupCredentials?>((ref) => null);

// ---------------------------------------------------------------------------
// Auth Actions
// ---------------------------------------------------------------------------

/// Sign up action.
final signUpActionProvider = Provider<Future<void> Function({
  required String email,
  required String password,
})>((ref) {
  return ({required email, required password}) async {
    final repo = ref.read(authRepositoryProvider);
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      await repo.signUp(email: email, password: password);
    } on AuthException catch (e) {
      developer.log('🔴 [AUTH] AuthException: ${e.message}');
      ref.read(authErrorProvider.notifier).state = _translateAuthError(e.message);
      rethrow;
    } catch (e) {
      developer.log('🔴 [AUTH-SIGNUP] Generic error: $e');
      ref.read(authErrorProvider.notifier).state = 'Bir sorun olustu. Lutfen tekrar dene.';
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  };
});

/// Sign in action.
final signInActionProvider = Provider<Future<void> Function({
  required String email,
  required String password,
})>((ref) {
  return ({required email, required password}) async {
    final repo = ref.read(authRepositoryProvider);
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      await repo.signIn(email: email, password: password);
      // Bootstrap'i yenile
      ref.invalidate(bootstrapProvider);
    } on AuthException catch (e) {
      developer.log('🔴 [AUTH] AuthException: ${e.message}');
      ref.read(authErrorProvider.notifier).state = _translateAuthError(e.message);
      rethrow;
    } catch (e) {
      developer.log('🔴 [AUTH] Generic error: $e');
      ref.read(authErrorProvider.notifier).state = 'Giris basarisiz. Lutfen tekrar dene.';
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  };
});

/// Logout veya delete account sonrası TÜM kullanıcıya özel cache'i temizler.
/// Yeni kullanıcı girince eski hesabın verisi sızmaz.
final _clearAllUserStateProvider = Provider<void Function()>((ref) {
  return () {
    // Bootstrap
    ref.invalidate(bootstrapProvider);
    // Home & meals
    ref.invalidate(homePayloadProvider);
    ref.invalidate(todayMealsProvider);
    // Streak
    ref.invalidate(streakProvider);
    // Progress
    ref.invalidate(weeklySummaryProvider);
    ref.invalidate(monthlyInsightProvider);
    // Profile
    ref.invalidate(userProfileProvider);
    // Coach
    ref.invalidate(coachThreadProvider);
    // Notification prefs
    ref.invalidate(notificationPrefsProvider);
    // Tracking
    ref.invalidate(waterHistoryProvider);
    ref.invalidate(weightHistoryProvider);
    // Premium status
    ref.invalidate(premiumStatusProvider);
    // Onboarding form state — reset notifier
    ref.read(onboardingControllerProvider.notifier).reset();
  };
});

/// Sign out action.
final signOutActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    // Tüm kullanıcıya özel cache'i temizle (state leak fix)
    ref.read(_clearAllUserStateProvider)();
  };
});

/// Password reset action.
final resetPasswordActionProvider = Provider<Future<void> Function(String email)>((ref) {
  return (email) async {
    final repo = ref.read(authRepositoryProvider);
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      await repo.resetPassword(email);
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = 'Sıfırlama maili gönderilemedi.';
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  };
});

// ---------------------------------------------------------------------------
// Auth Error Translation - Supabase'in Ingilizce hatalarini Turkce'ye cevirir
// ---------------------------------------------------------------------------

String _translateAuthError(String englishMessage) {
  final msg = englishMessage.toLowerCase();

  // Login hatalari
  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid email or password')) {
    return 'E-posta veya sifre yanlis. Lutfen tekrar dene.';
  }
  if (msg.contains('email not confirmed')) {
    return 'E-postani henuz dogrulamadin. Gelen kutuni kontrol et.';
  }
  if (msg.contains('user not found')) {
    return 'Bu e-posta ile kayitli kullanici bulunamadi.';
  }

  // Signup hatalari
  if (msg.contains('user already registered') ||
      msg.contains('already exists')) {
    return 'Bu e-posta zaten kayitli. Giris yapmayi dene.';
  }
  if (msg.contains('weak password') ||
      msg.contains('password should be at least')) {
    return 'Sifre cok zayif. En az 6 karakter olmali.';
  }
  if (msg.contains('unable to validate email') ||
      msg.contains('invalid email')) {
    return 'E-posta formati gecersiz.';
  }

  // Rate limit
  if (msg.contains('rate limit') ||
      msg.contains('too many requests') ||
      msg.contains('for security purposes')) {
    return 'Cok hizli denedin. Lutfen birkac saniye bekle.';
  }

  // Network
  if (msg.contains('network') ||
      msg.contains('connection') ||
      msg.contains('timeout')) {
    return 'Internet baglantini kontrol et.';
  }

  // Session
  if (msg.contains('session expired') ||
      msg.contains('jwt expired')) {
    return 'Oturumun suresi doldu. Lutfen tekrar giris yap.';
  }

  // Genel
  return 'Bir sorun olustu. Lutfen tekrar dene.';
}
