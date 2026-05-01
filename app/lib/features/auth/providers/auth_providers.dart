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
      ref.read(authErrorProvider.notifier).state = e.message;
      rethrow;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = 'Bir hata oluştu. Tekrar dene.';
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
      ref.read(authErrorProvider.notifier).state = e.message;
      rethrow;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = 'Giriş başarısız. Tekrar dene.';
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
