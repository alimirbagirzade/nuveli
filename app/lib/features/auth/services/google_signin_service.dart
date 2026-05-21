// ============================================================================
// google_signin_service.dart
// Sign in with Google → Supabase ID token bridge.
//
// Setup notes (out-of-band, see launch_audit/FAZ_8_GO_NOGO/known_issues_v1.md
// for the exact dashboard steps):
//   1. iOS — drop GIDClientID + reversed-client-id URL scheme into
//      Info.plist (Firebase Console download already gives them).
//   2. Android — google-services.json is wired by firebase_core; just
//      make sure the Play Console SHA-1/SHA-256 fingerprints are added
//      to the Firebase Android app.
//   3. Supabase — enable Google provider in Auth → Providers and paste
//      the Web Client ID (NOT iOS/Android) as the OAuth client.
//
// Like Apple Sign-In, the heavy lifting is on the IdP side; this service
// just shuttles the ID token to Supabase.
// ============================================================================

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_errors.dart';

class GoogleSignInService {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;

  GoogleSignInService({
    SupabaseClient? client,
    GoogleSignIn? googleSignIn,
  })  : _supabase = client ?? Supabase.instance.client,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              // Scopes we actually need — email + profile is the bare
              // minimum to populate display_name + avatar. Anything beyond
              // these triggers a stricter Google consent screen review.
              scopes: const ['email', 'profile'],
            );

  /// Open the Google account picker, exchange the resulting ID token for
  /// a Supabase session. Returns the same `AuthResponse` shape as the
  /// email/password flow so [AuthNotifier] can swap branches without
  /// caring which provider was used.
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User dismissed the account picker — treat as cancel, not error.
        throw NuveliAuthException.googleCanceled();
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw NuveliAuthException.googleFailed(
          'No ID token returned from Google.',
        );
      }

      // Supabase verifies the ID token's signature against Google's JWKS
      // and matches the `aud` claim to the OAuth client configured in the
      // dashboard. accessToken is optional but lets Supabase populate
      // the user's profile-picture URL on first sign-in.
      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: auth.accessToken,
      );
    } catch (e) {
      if (e is NuveliAuthException) rethrow;
      throw NuveliAuthException.googleFailed(e.toString());
    }
  }

  /// Local-only sign-out — clears the cached Google account so the next
  /// signInWithGoogle call shows the picker again instead of silently
  /// picking the last-used account. Doesn't touch Supabase.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Best effort — Supabase signOut still clears the actual session.
    }
  }
}
