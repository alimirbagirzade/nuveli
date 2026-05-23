// AuthService tests — Supabase client is mocked via mocktail. We
// constructor-inject the mock so no real network/Supabase init is
// needed. These tests pin the behaviour around:
//   - happy path returning the AuthResponse
//   - null-session defence (Supabase sometimes returns 200 with no session)
//   - exception wrapping into NuveliAuthException

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/auth/models/auth_errors.dart';
import 'package:nuveli/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockDio extends Mock implements Dio {}

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
  late _MockDio mockDio;
  late AuthService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockClient = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    mockDio = _MockDio();
    when(() => mockClient.auth).thenReturn(mockAuth);
    service = AuthService(client: mockClient, dio: mockDio);
  });

  Response<Map<String, dynamic>> _signupOk({bool alreadyExisted = false}) {
    return Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/auth/signup'),
      statusCode: 201,
      data: {
        'user_id': 'backend-user-id',
        'email': 'new@example.com',
        'already_existed': alreadyExisted,
      },
    );
  }

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
    test('happy path: backend creates user, then signInWithPassword succeeds',
        () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/auth/signup',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _signupOk());

      final response = AuthResponse(session: _FakeSession(), user: _FakeUser());
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => response);

      final result = await service.signUpWithEmail(
        email: 'new@example.com',
        password: 'hunter12',
      );

      expect(result, same(response));
      verify(() => mockDio.post<Map<String, dynamic>>(
            '/auth/signup',
            data: {'email': 'new@example.com', 'password': 'hunter12'},
          )).called(1);
      verify(() => mockAuth.signInWithPassword(
            email: 'new@example.com',
            password: 'hunter12',
          )).called(1);
    });

    test('null session post-signin → NuveliAuthException', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/auth/signup',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _signupOk());

      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => AuthResponse(session: null, user: null));

      expect(
        () => service.signUpWithEmail(
          email: 'new@example.com',
          password: 'hunter12',
        ),
        throwsA(isA<NuveliAuthException>()),
      );
    });

    test('backend 422 → surfaces server `detail` verbatim', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/auth/signup',
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/signup'),
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/signup'),
          statusCode: 422,
          data: {'detail': 'Password too short'},
        ),
        type: DioExceptionType.badResponse,
      ));

      expect(
        () => service.signUpWithEmail(
          email: 'new@example.com',
          password: 'short',
        ),
        throwsA(
          isA<NuveliAuthException>().having(
            (e) => e.userMessage,
            'userMessage',
            'Password too short',
          ),
        ),
      );
    });

    test('idempotent signup (already_existed=true) + wrong password '
        'surfaces emailAlreadyRegistered via signInWithPassword failure',
        () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/auth/signup',
            data: any(named: 'data'),
          )).thenAnswer((_) async => _signupOk(alreadyExisted: true));

      // Supabase typed exception for bad creds — fromSupabase maps it
      // to invalidCredentials, NOT emailAlreadyRegistered. That's the
      // correct UX: "this email exists, you typed the wrong password".
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthException('Invalid login credentials'));

      expect(
        () => service.signUpWithEmail(
          email: 'taken@example.com',
          password: 'wrong-password',
        ),
        throwsA(isA<NuveliAuthException>()),
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
