// ============================================================================
// auth_provider.dart
// Auth state'in tek doğruluk kaynağı.
// - AsyncNotifier<AuthUser?> — null = logged out, AuthUser = logged in
// - Supabase auth state stream'ini dinler, otomatik günceller
// - signIn / signUp / signInWithApple / signOut metodları
// ============================================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/auth_errors.dart';
import '../models/auth_user.dart';
import '../services/apple_signin_service.dart';
import '../services/auth_service.dart';

// ============================================================================
// SERVICE PROVIDERS — DI için, test'te override edilebilir
// ============================================================================

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final appleSignInServiceProvider =
    Provider<AppleSignInService>((ref) => AppleSignInService());

// ============================================================================
// AUTH NOTIFIER
// ============================================================================

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  late final AuthService _authService;
  late final AppleSignInService _appleService;
  StreamSubscription<sb.AuthState>? _sub;

  @override
  Future<AuthUser?> build() async {
    _authService = ref.read(authServiceProvider);
    _appleService = ref.read(appleSignInServiceProvider);

    // Supabase auth state stream'ini dinle.
    // Token refresh, başka tab'tan logout vs. otomatik yansır.
    _sub = _authService.onAuthStateChange.listen((sb.AuthState authState) {
      final user = authState.session?.user;
      state = AsyncValue.data(
        user == null ? null : AuthUser.fromSupabase(user),
      );
    });

    // Build temizliği
    ref.onDispose(() {
      _sub?.cancel();
    });

    // İlk değer
    final user = _authService.currentUser;
    return user == null ? null : AuthUser.fromSupabase(user);
  }

  // --------------------------------------------------------------------------
  // SIGN IN — Email
  // --------------------------------------------------------------------------
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      final user = response.user;
      state = AsyncValue.data(
        user == null ? null : AuthUser.fromSupabase(user),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // SIGN UP — Email
  // --------------------------------------------------------------------------
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      final user = response.user;
      // Email confirmation açıksa session null gelebilir.
      // O zaman state'i yine null tut (logged out), UI verification ekranını
      // gösterir.
      if (response.session == null) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.data(
          user == null ? null : AuthUser.fromSupabase(user),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // SIGN IN — Apple
  // --------------------------------------------------------------------------
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final response = await _appleService.signInWithApple();
      final user = response.user;
      state = AsyncValue.data(
        user == null ? null : AuthUser.fromSupabase(user),
      );
    } catch (e, st) {
      // Kullanıcı iptal ettiyse hata gibi göstermeyelim — eski state'e dön.
      if (e is NuveliAuthException &&
          e.type == AuthErrorType.appleSignInCanceled) {
        final current = _authService.currentUser;
        state = AsyncValue.data(
          current == null ? null : AuthUser.fromSupabase(current),
        );
        return;
      }
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // SIGN OUT
  // --------------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);

/// Convenience selector — direkt User? almak için.
/// `final user = ref.watch(currentAuthUserProvider);`
final currentAuthUserProvider = Provider<AuthUser?>((ref) {
  final asyncUser = ref.watch(authProvider);
  return asyncUser.maybeWhen(data: (u) => u, orElse: () => null);
});

/// Convenience selector — kullanıcı login mi?
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(currentAuthUserProvider) != null;
});
