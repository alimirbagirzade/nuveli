// GoogleSignInService tests — Google + Supabase clients both mocked.
// Pin the behaviour around:
//   - happy path: ID token reaches signInWithIdToken with the right provider
//   - user dismissed account picker (signIn returns null) → googleCanceled
//   - Google returned no ID token → googleFailed
//   - unexpected exceptions get wrapped as NuveliAuthException

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/auth/models/auth_errors.dart';
import 'package:nuveli/features/auth/services/google_signin_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockGoogleAccount extends Mock implements GoogleSignInAccount {}

class _MockGoogleAuth extends Mock implements GoogleSignInAuthentication {}

class _FakeUser extends Fake implements User {
  @override
  String get id => 'fake-google-user';
}

class _FakeSession extends Fake implements Session {
  @override
  String get accessToken => 'fake-token';
}

void main() {
  late _MockSupabaseClient supabase;
  late _MockGoTrueClient auth;
  late _MockGoogleSignIn google;
  late GoogleSignInService service;

  setUpAll(() {
    // mocktail needs a fallback for enum-typed named args used with any().
    registerFallbackValue(OAuthProvider.google);
  });

  setUp(() {
    supabase = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    google = _MockGoogleSignIn();
    when(() => supabase.auth).thenReturn(auth);
    service = GoogleSignInService(client: supabase, googleSignIn: google);
  });

  AuthResponse okResponse() => AuthResponse(session: _FakeSession(), user: _FakeUser());

  group('GoogleSignInService.signInWithGoogle', () {
    test('happy path: ID token reaches Supabase via signInWithIdToken', () async {
      final account = _MockGoogleAccount();
      final googleAuth = _MockGoogleAuth();
      when(() => googleAuth.idToken).thenReturn('id-token-123');
      when(() => googleAuth.accessToken).thenReturn('access-token-456');
      when(() => account.authentication).thenAnswer((_) async => googleAuth);
      when(() => google.signIn()).thenAnswer((_) async => account);
      when(
        () => auth.signInWithIdToken(
          provider: any(named: 'provider'),
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
        ),
      ).thenAnswer((_) async => okResponse());

      final response = await service.signInWithGoogle();

      expect(response.user, isNotNull);
      verify(
        () => auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'id-token-123',
          accessToken: 'access-token-456',
        ),
      ).called(1);
    });

    test('user dismissed picker → throws googleCanceled', () async {
      when(() => google.signIn()).thenAnswer((_) async => null);

      expect(
        service.signInWithGoogle(),
        throwsA(
          isA<NuveliAuthException>().having(
            (e) => e.type,
            'type',
            AuthErrorType.googleSignInCanceled,
          ),
        ),
      );
    });

    test('Google returned account but no ID token → googleFailed', () async {
      final account = _MockGoogleAccount();
      final googleAuth = _MockGoogleAuth();
      when(() => googleAuth.idToken).thenReturn(null);
      when(() => googleAuth.accessToken).thenReturn('a');
      when(() => account.authentication).thenAnswer((_) async => googleAuth);
      when(() => google.signIn()).thenAnswer((_) async => account);

      expect(
        service.signInWithGoogle(),
        throwsA(
          isA<NuveliAuthException>().having(
            (e) => e.type,
            'type',
            AuthErrorType.googleSignInFailed,
          ),
        ),
      );
    });

    test('unexpected exception gets wrapped as googleFailed', () async {
      when(() => google.signIn()).thenThrow(Exception('network unreachable'));

      expect(
        service.signInWithGoogle(),
        throwsA(
          isA<NuveliAuthException>().having(
            (e) => e.type,
            'type',
            AuthErrorType.googleSignInFailed,
          ),
        ),
      );
    });
  });

  group('GoogleSignInService.signOut', () {
    test('calls GoogleSignIn.signOut', () async {
      when(() => google.signOut()).thenAnswer((_) async => null);

      await service.signOut();

      verify(() => google.signOut()).called(1);
    });

    test('swallows errors so Supabase signOut can still run', () async {
      when(() => google.signOut()).thenThrow(Exception('idle network'));

      // Should not rethrow.
      await service.signOut();
    });
  });
}
