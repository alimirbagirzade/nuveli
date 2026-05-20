// AuthService tests — Supabase client is mocked via mocktail. We
// constructor-inject the mock so no real network/Supabase init is
// needed. These tests pin the behaviour around:
//   - happy path returning the AuthResponse
//   - null-session defence (Supabase sometimes returns 200 with no session)
//   - exception wrapping into NuveliAuthException

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/auth/models/auth_errors.dart';
import 'package:nuveli/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _FakeUser extends Fake implements User {
  @override
  String get id => 'fake-user-id';
}

class _FakeSession extends Fake implements Session {
  @override
  String get accessToken => 'fake-access-token';
}

class _FakeUserResponse extends Fake implements UserResponse {}

class _FakeResendResponse extends Fake implements ResendResponse {}

void main() {
  late _MockSupabaseClient mockClient;
  late _MockGoTrueClient mockAuth;
  late AuthService service;

  setUp(() {
    mockClient = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    service = AuthService(client: mockClient);
  });

  group('AuthService.signInWithEmail', () {
    test('happy path: returns AuthResponse when session is present', () async {
      final response = AuthResponse(session: _FakeSession(), user: _FakeUser());
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => response);

      final result = await service.signInWithEmail(
        email: 'user@example.com',
        password: 'hunter12',
      );

      expect(result, same(response));
      verify(
        () => mockAuth.signInWithPassword(
          email: 'user@example.com',
          password: 'hunter12',
        ),
      ).called(1);
    });

    test('trims surrounding whitespace from email before calling Supabase', () async {
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => AuthResponse(session: _FakeSession(), user: _FakeUser()),
      );

      await service.signInWithEmail(
        email: '  user@example.com  ',
        password: 'hunter12',
      );

      verify(
        () => mockAuth.signInWithPassword(
          email: 'user@example.com', // trimmed
          password: 'hunter12',
        ),
      ).called(1);
    });

    test('null session in response throws NuveliAuthException(unknown)', () async {
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse(session: null, user: _FakeUser()));

      expect(
        () => service.signInWithEmail(
          email: 'user@example.com',
          password: 'hunter12',
        ),
        throwsA(
          isA<NuveliAuthException>()
              .having((e) => e.type, 'type', AuthErrorType.unknown),
        ),
      );
    });

    test('Supabase AuthException wraps into NuveliAuthException', () async {
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException('Invalid login credentials'));

      expect(
        () => service.signInWithEmail(
          email: 'user@example.com',
          password: 'wrong',
        ),
        throwsA(
          isA<NuveliAuthException>()
              .having((e) => e.type, 'type', AuthErrorType.invalidCredentials),
        ),
      );
    });

    test('local NuveliAuthException is rethrown unchanged (not re-wrapped)', () async {
      // The null-session branch throws NuveliAuthException; the outer
      // catch must re-throw it instead of wrapping it in another
      // NuveliAuthException with a generic message.
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse(session: null, user: _FakeUser()));

      try {
        await service.signInWithEmail(
          email: 'user@example.com',
          password: 'hunter12',
        );
        fail('expected throw');
      } on NuveliAuthException catch (e) {
        // Must carry the explicit "Sign-in failed" message, not the
        // generic "Something went wrong" fallback.
        expect(e.userMessage, contains('Sign-in failed'));
      }
    });
  });

  group('AuthService.signUpWithEmail', () {
    test('happy path: returns AuthResponse with deep-link redirect set', () async {
      final response = AuthResponse(session: _FakeSession(), user: _FakeUser());
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenAnswer((_) async => response);

      final result = await service.signUpWithEmail(
        email: 'new@example.com',
        password: 'hunter12',
      );

      expect(result, same(response));
      verify(
        () => mockAuth.signUp(
          email: 'new@example.com',
          password: 'hunter12',
          emailRedirectTo: 'com.nuveli.app://email-confirmed',
        ),
      ).called(1);
    });

    test('null user → NuveliAuthException(unknown)', () async {
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenAnswer((_) async => AuthResponse(session: null, user: null));

      expect(
        () => service.signUpWithEmail(
          email: 'new@example.com',
          password: 'hunter12',
        ),
        throwsA(isA<NuveliAuthException>()),
      );
    });

    test('"User already registered" wraps as emailAlreadyRegistered', () async {
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenThrow(const AuthException('User already registered'));

      expect(
        () => service.signUpWithEmail(
          email: 'taken@example.com',
          password: 'hunter12',
        ),
        throwsA(
          isA<NuveliAuthException>().having(
            (e) => e.type,
            'type',
            AuthErrorType.emailAlreadyRegistered,
          ),
        ),
      );
    });
  });

  group('AuthService.signOut', () {
    test('happy path: completes without throwing', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      await expectLater(service.signOut(), completes);
      verify(() => mockAuth.signOut()).called(1);
    });

    test('Supabase error wraps into NuveliAuthException', () async {
      when(() => mockAuth.signOut()).thenThrow(const AuthException('Network down'));

      expect(
        () => service.signOut(),
        throwsA(isA<NuveliAuthException>()),
      );
    });
  });

  group('AuthService.sendPasswordResetEmail', () {
    test('calls Supabase with trimmed email + reset deep link', () async {
      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenAnswer((_) async {});

      await service.sendPasswordResetEmail('  user@example.com  ');

      verify(
        () => mockAuth.resetPasswordForEmail(
          'user@example.com',
          redirectTo: 'com.nuveli.app://reset-password',
        ),
      ).called(1);
    });

    test('Supabase error wraps into NuveliAuthException', () async {
      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenThrow(const AuthException('Reset failed'));

      expect(
        () => service.sendPasswordResetEmail('user@example.com'),
        throwsA(isA<NuveliAuthException>()),
      );
    });
  });

  group('AuthService.updatePassword', () {
    setUpAll(() {
      registerFallbackValue(UserAttributes(password: 'placeholder'));
    });

    test('happy path forwards the new password to Supabase', () async {
      when(() => mockAuth.updateUser(any())).thenAnswer(
        (_) async => _FakeUserResponse(),
      );

      await expectLater(service.updatePassword('newPass123'), completes);

      verify(() => mockAuth.updateUser(any())).called(1);
    });

    test('Supabase error wraps into NuveliAuthException', () async {
      when(() => mockAuth.updateUser(any())).thenThrow(
        const AuthException('Password should be at least 6 characters'),
      );

      expect(
        () => service.updatePassword('short'),
        throwsA(
          isA<NuveliAuthException>().having(
            (e) => e.type,
            'type',
            AuthErrorType.weakPassword,
          ),
        ),
      );
    });
  });

  group('AuthService.resendVerificationEmail', () {
    setUpAll(() {
      registerFallbackValue(OtpType.signup);
    });

    test('calls Supabase resend with signup OTP + trimmed email', () async {
      when(
        () => mockAuth.resend(
          type: any(named: 'type'),
          email: any(named: 'email'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenAnswer((_) async => _FakeResendResponse());

      await service.resendVerificationEmail('  user@example.com  ');

      verify(
        () => mockAuth.resend(
          type: OtpType.signup,
          email: 'user@example.com',
          emailRedirectTo: 'com.nuveli.app://email-confirmed',
        ),
      ).called(1);
    });
  });
}
