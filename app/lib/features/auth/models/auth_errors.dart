// ============================================================================
// auth_errors.dart
// Supabase Auth hata kodlarını kullanıcı dostu Türkçe/İngilizce mesajlara çevirir.
// Hazırlık dosyası: nuveli_chat15_hazirlik.md → models/auth_errors.dart
// ============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth flow'unda oluşabilecek hata tipleri.
enum AuthErrorType {
  invalidCredentials,
  emailAlreadyRegistered,
  weakPassword,
  emailNotConfirmed,
  userNotFound,
  rateLimited,
  networkError,
  appleSignInCanceled,
  appleSignInFailed,
  unknown,
}

/// Auth hatası — `try/catch` içinde fırlatılır,
/// `UI.errorMessage = e.userMessage` şeklinde gösterilir.
class NuveliAuthException implements Exception {
  final AuthErrorType type;
  final String userMessage;
  final String? originalMessage;

  const NuveliAuthException({
    required this.type,
    required this.userMessage,
    this.originalMessage,
  });

  @override
  String toString() =>
      'NuveliAuthException(type: $type, message: $userMessage)';

  // --------------------------------------------------------------------------
  // Factory — Supabase AuthException'ı bizim tipimize çevirir.
  // --------------------------------------------------------------------------
  factory NuveliAuthException.fromSupabase(Object error) {
    if (error is AuthException) {
      return _mapSupabaseAuth(error);
    }
    if (error is AuthApiException) {
      return _mapSupabaseAuth(error);
    }
    // Network ya da bilinmeyen hata
    final msg = error.toString().toLowerCase();
    if (msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('network')) {
      return const NuveliAuthException(
        type: AuthErrorType.networkError,
        userMessage:
            'No internet connection. Check your network and try again.',
      );
    }
    return NuveliAuthException(
      type: AuthErrorType.unknown,
      userMessage: 'Something went wrong. Please try again.',
      originalMessage: error.toString(),
    );
  }

  static NuveliAuthException _mapSupabaseAuth(AuthException e) {
    final msg = e.message.toLowerCase();
    final code = e.statusCode;

    // Supabase mesajları İngilizce — pattern match ile çevir.
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return NuveliAuthException(
        type: AuthErrorType.invalidCredentials,
        userMessage: 'Incorrect email or password.',
        originalMessage: e.message,
      );
    }
    if (msg.contains('user already registered') ||
        msg.contains('already exists') ||
        msg.contains('email_exists')) {
      return NuveliAuthException(
        type: AuthErrorType.emailAlreadyRegistered,
        userMessage: 'This email is already registered. Try signing in.',
        originalMessage: e.message,
      );
    }
    if (msg.contains('password should be') || msg.contains('weak password')) {
      return NuveliAuthException(
        type: AuthErrorType.weakPassword,
        userMessage:
            'Password is too weak. Use at least 8 characters with a number.',
        originalMessage: e.message,
      );
    }
    if (msg.contains('email not confirmed') ||
        msg.contains('email_not_confirmed')) {
      return NuveliAuthException(
        type: AuthErrorType.emailNotConfirmed,
        userMessage: 'Please verify your email before signing in.',
        originalMessage: e.message,
      );
    }
    if (msg.contains('user not found') || msg.contains('no user found')) {
      return NuveliAuthException(
        type: AuthErrorType.userNotFound,
        userMessage: 'No account found with this email.',
        originalMessage: e.message,
      );
    }
    if (code == '429' || msg.contains('too many') || msg.contains('rate')) {
      return NuveliAuthException(
        type: AuthErrorType.rateLimited,
        userMessage: 'Too many attempts. Please wait a minute and try again.',
        originalMessage: e.message,
      );
    }

    return NuveliAuthException(
      type: AuthErrorType.unknown,
      userMessage: e.message,
      originalMessage: e.message,
    );
  }

  // --------------------------------------------------------------------------
  // Apple Sign-In hataları
  // --------------------------------------------------------------------------
  factory NuveliAuthException.appleCanceled() => const NuveliAuthException(
        type: AuthErrorType.appleSignInCanceled,
        userMessage: 'Apple Sign-In was canceled.',
      );

  factory NuveliAuthException.appleFailed([String? originalMessage]) =>
      NuveliAuthException(
        type: AuthErrorType.appleSignInFailed,
        userMessage: 'Apple Sign-In failed. Please try again.',
        originalMessage: originalMessage,
      );
}
