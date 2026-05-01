import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_client.dart';

/// Auth durumunu temsil eden enum.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Tüm auth operasyonları bu repository üzerinden yapılır.
class AuthRepository {
  AuthRepository(this._supabase, this._api);

  final SupabaseClient _supabase;
  final dynamic _api; // Dio

  // ---------------------------------------------------------------------------
  // Auth State
  // ---------------------------------------------------------------------------

  /// Mevcut session.
  Session? get currentSession => _supabase.auth.currentSession;

  /// Mevcut user.
  User? get currentUser => _supabase.auth.currentUser;

  /// Auth durumunu stream olarak dinler.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ---------------------------------------------------------------------------
  // Sign Up
  // ---------------------------------------------------------------------------

  /// Email + password ile kayıt.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw AuthException('Kayıt başarısız. Lütfen tekrar dene.');
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Sign In
  // ---------------------------------------------------------------------------

  /// Email + password ile giriş.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw AuthException('Email veya şifre hatalı.');
    }

    return response;
  }

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------

  /// Şifre sıfırlama maili gönderir.
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Oturumu sonlandırır.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Bootstrap
  // ---------------------------------------------------------------------------

  /// Uygulama açılışında kullanıcı profilini + onboarding state'ini çeker.
  Future<Map<String, dynamic>?> getBootstrap() async {
    if (currentUser == null) return null;

    try {
      final response = await _api.get('/app/bootstrap');
      return response.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}

/// Provider: AuthRepository singleton.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    Supabase.instance.client,
    ref.watch(apiClientProvider),
  );
});
