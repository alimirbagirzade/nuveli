// ============================================================================
// auth_service.dart
// Supabase Auth'un üstüne ince bir wrapper.
// - Email/password sign in/up
// - Password reset
// - Sign out
// - Auth state stream
// Tüm hataları NuveliAuthException olarak normalize eder.
// ============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_errors.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  // --------------------------------------------------------------------------
  // SIGN IN / UP
  // --------------------------------------------------------------------------
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        throw const NuveliAuthException(
          type: AuthErrorType.unknown,
          userMessage: 'Sign-in failed. Please try again.',
        );
      }
      return response;
    } catch (e) {
      if (e is NuveliAuthException) rethrow;
      throw NuveliAuthException.fromSupabase(e);
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: 'com.nuveli.app://email-confirmed',
      );
      if (response.user == null) {
        throw const NuveliAuthException(
          type: AuthErrorType.unknown,
          userMessage: 'Sign-up failed. Please try again.',
        );
      }
      return response;
    } catch (e) {
      if (e is NuveliAuthException) rethrow;
      throw NuveliAuthException.fromSupabase(e);
    }
  }

  // --------------------------------------------------------------------------
  // PASSWORD RESET
  // --------------------------------------------------------------------------
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'com.nuveli.app://reset-password',
      );
    } catch (e) {
      throw NuveliAuthException.fromSupabase(e);
    }
  }

  /// Magic-link sonrası yeni şifre kaydet.
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw NuveliAuthException.fromSupabase(e);
    }
  }

  /// E-posta doğrulama mailini tekrar gönder.
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
        emailRedirectTo: 'com.nuveli.app://email-confirmed',
      );
    } catch (e) {
      throw NuveliAuthException.fromSupabase(e);
    }
  }

  // --------------------------------------------------------------------------
  // SIGN OUT
  // --------------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw NuveliAuthException.fromSupabase(e);
    }
  }

  // --------------------------------------------------------------------------
  // GETTERS
  // --------------------------------------------------------------------------
  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;
  String? get accessToken => currentSession?.accessToken;
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
  bool get isSignedIn => currentSession != null;
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;
}
