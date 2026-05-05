import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/monitoring/crash_reporter.dart';
import '../data/auth_repository.dart';

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
      print('🔴 [AUTH] AuthException: ${e.message}');
      ref.read(authErrorProvider.notifier).state = _translateAuthError(e.message);
      rethrow;
    } catch (e) {
      print('🔴 [AUTH-SIGNUP] Generic error: $e');
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
      print('🔴 [AUTH] AuthException: ${e.message}');
      ref.read(authErrorProvider.notifier).state = _translateAuthError(e.message);
      rethrow;
    } catch (e) {
      print('🔴 [AUTH] Generic error: $e');
      ref.read(authErrorProvider.notifier).state = 'Giris basarisiz. Lutfen tekrar dene.';
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  };
});

/// Sign out action.
final signOutActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    ref.invalidate(bootstrapProvider);
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
