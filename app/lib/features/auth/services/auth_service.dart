// ============================================================================
// auth_service.dart
// Supabase Auth'un üstüne ince bir wrapper.
// - Email/password sign in/up
// - Password reset
// - Sign out
// - Auth state stream
// Tüm hataları NuveliAuthException olarak normalize eder.
// ============================================================================

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../models/auth_errors.dart';

class AuthService {
  final SupabaseClient _supabase;
  final Dio _dio;

  AuthService({SupabaseClient? client, Dio? dio})
      : _supabase = client ?? Supabase.instance.client,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Content-Type': 'application/json'},
            ));

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

  /// Signup goes through our backend, NOT directly through Supabase.
  ///
  /// Why: Supabase's built-in SMTP rate-limits hard (~2/hour) and silently
  /// drops verification mail, leaving users permanently stuck on a
  /// "verify your email" screen. The backend `POST /auth/signup` uses the
  /// service-role admin API to mint a user with `email_confirmed_at`
  /// already set, then we immediately sign in with the same password
  /// to obtain a normal session — RLS works exactly as if the user had
  /// clicked a verification link.
  ///
  /// When custom SMTP (Resend/Postmark/SES) is wired up in production,
  /// swap this back to `Supabase.auth.signUp` and remove the backend
  /// endpoint (or gate it behind a flag).
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      // 1) Backend creates the user with email_confirm=true. Idempotent —
      // already_existed=true means we drop straight into sign-in below.
      await _dio.post<Map<String, dynamic>>(
        '/auth/signup',
        data: {'email': cleanEmail, 'password': password},
      );
    } on DioException catch (e) {
      // 422 from the backend usually means weak password / invalid email.
      // Surface the server's message verbatim so the user sees why.
      final body = e.response?.data;
      final detail = body is Map && body['detail'] is String
          ? body['detail'] as String
          : 'Sign-up failed. Please try again.';
      throw NuveliAuthException(
        type: AuthErrorType.unknown,
        userMessage: detail,
      );
    }

    // 2) Now sign in with the same credentials. The user is already
    // confirmed so this returns a full session — no verify screen.
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );
      if (response.session == null) {
        throw const NuveliAuthException(
          type: AuthErrorType.unknown,
          userMessage: 'Account created but sign-in failed. Please log in.',
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
