// Widget tests for SignupScreen.
//
// Covers the form-gating + signup happy path. The widget reads
// authServiceProvider / appleSignInServiceProvider via AuthNotifier
// during build, so both are mocked here too.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/auth/models/auth_errors.dart';
import 'package:nuveli/features/auth/providers/auth_provider.dart';
import 'package:nuveli/features/auth/screens/signup_screen.dart';
import 'package:nuveli/features/auth/services/apple_signin_service.dart';
import 'package:nuveli/features/auth/services/auth_service.dart';
import 'package:nuveli/features/auth/widgets/auth_primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../_helpers/widget_test_helpers.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockAppleSignInService extends Mock implements AppleSignInService {}

class _FakeUser extends Fake implements User {
  @override
  String get id => 'fake-user';
}

class _FakeSession extends Fake implements Session {}

void main() {
  late _MockAuthService mockAuth;
  late _MockAppleSignInService mockApple;
  late List<Override> overrides;

  setUp(() {
    mockAuth = _MockAuthService();
    mockApple = _MockAppleSignInService();
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());
    when(() => mockAuth.currentUser).thenReturn(null);
    overrides = [
      authServiceProvider.overrideWithValue(mockAuth),
      appleSignInServiceProvider.overrideWithValue(mockApple),
    ];
  });

  group('SignupScreen — rendering', () {
    testWidgets(
        'shows three text fields (email/password/confirm) + Create account button',
        (tester) async {
      await pumpWithProviders(tester, const SignupScreen(), overrides: overrides);

      // 3 form fields total
      expect(find.byType(TextFormField), findsNWidgets(3));
      // Submit button — actual label may be localized; assert by widget type
      expect(find.byType(AuthPrimaryButton), findsOneWidget);
      // Terms checkbox
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });

  group('SignupScreen — form validation', () {
    testWidgets('empty form: Create account does NOT call signUpWithEmail',
        (tester) async {
      await pumpWithProviders(tester, const SignupScreen(), overrides: overrides);

      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();

      verifyNever(
        () => mockAuth.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('mismatched passwords: validation blocks submit',
        (tester) async {
      await pumpWithProviders(tester, const SignupScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'new@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'hunter12',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'hunter13', // mismatch
      );

      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(
        () => mockAuth.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets(
        'valid form WITHOUT terms checked: shows "accept the Terms" error',
        (tester) async {
      await pumpWithProviders(tester, const SignupScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'new@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'hunter12',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'hunter12',
      );

      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();

      // Looks for the start of the message — exact wording in source is
      // "Please accept the Terms to continue."
      expect(
        find.textContaining('accept the Terms'),
        findsOneWidget,
      );
      verifyNever(
        () => mockAuth.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });
  });

  group('SignupScreen — happy path', () {
    testWidgets(
        'valid form + terms checked: invokes signUpWithEmail with trimmed inputs',
        (tester) async {
      when(
        () => mockAuth.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => AuthResponse(session: _FakeSession(), user: _FakeUser()),
      );

      await pumpWithProviders(tester, const SignupScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        '  new@example.com  ',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'hunter12',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'hunter12',
      );
      // Accept terms.
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockAuth.signUpWithEmail(
          email: 'new@example.com', // trimmed by handler
          password: 'hunter12',
        ),
      ).called(1);
    });
  });

  group('SignupScreen — error surface', () {
    testWidgets('"User already registered" surfaces as banner', (tester) async {
      when(
        () => mockAuth.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NuveliAuthException(
        type: AuthErrorType.emailAlreadyRegistered,
        userMessage: 'This email is already registered. Try signing in.',
      ));

      await pumpWithProviders(tester, const SignupScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'taken@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'hunter12',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'hunter12',
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('This email is already registered. Try signing in.'),
        findsOneWidget,
      );
    });
  });
}
