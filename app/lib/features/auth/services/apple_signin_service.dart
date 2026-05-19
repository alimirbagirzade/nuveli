// ============================================================================
// apple_signin_service.dart
// Sign in with Apple → Supabase ID token bridge.
// Nonce + SHA256 hash güvenlik için gerekli (replay attack koruması).
// Sadece iOS'ta çalışır; Android'de SignInWithApple.isAvailable() false döner.
// ============================================================================

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_errors.dart';

class AppleSignInService {
  final SupabaseClient _supabase;

  AppleSignInService({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  /// Platform Apple Sign-In destekliyor mu?
  /// iOS 13+ ve macOS 10.15+ destekliyor. Android'de false döner.
  Future<bool> get isAvailable async {
    if (!Platform.isIOS && !Platform.isMacOS) return false;
    return SignInWithApple.isAvailable();
  }

  /// Apple ile giriş yap.
  /// - Raw nonce üret → SHA256 hash'i Apple'a gönder
  /// - Apple'dan ID token al
  /// - Raw nonce + ID token'ı Supabase'e ver, Supabase doğrular
  Future<AuthResponse> signInWithApple() async {
    try {
      // 1. Nonce üret (raw + hashed)
      final rawNonce = _supabase.auth.generateRawNonce();
      final hashedNonce =
          sha256.convert(utf8.encode(rawNonce)).toString();

      // 2. Apple credential iste
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw NuveliAuthException.appleFailed(
          'No identity token returned from Apple.',
        );
      }

      // 3. Supabase'e bildir
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      // 4. Apple ad-soyadı SADECE ilk girişte gönderir.
      //    Bu bilgi varsa user_metadata'ya yazalım, sonradan profilde
      //    fallback olarak kullanılır.
      final fullName = _composeFullName(
        credential.givenName,
        credential.familyName,
      );
      if (fullName != null && response.user != null) {
        try {
          await _supabase.auth.updateUser(
            UserAttributes(
              data: {
                'full_name': fullName,
                if (credential.givenName != null) 'given_name': credential.givenName,
                if (credential.familyName != null) 'family_name': credential.familyName,
              },
            ),
          );
        } catch (_) {
          // Metadata update başarısız olsa bile giriş işi tamamlandı,
          // sessiz yut (kritik değil).
        }
      }

      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      // Kullanıcı iptal etti vs.
      if (e.code == AuthorizationErrorCode.canceled) {
        throw NuveliAuthException.appleCanceled();
      }
      throw NuveliAuthException.appleFailed(e.message);
    } catch (e) {
      if (e is NuveliAuthException) rethrow;
      throw NuveliAuthException.appleFailed(e.toString());
    }
  }

  String? _composeFullName(String? given, String? family) {
    final parts = [given, family]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }
}
