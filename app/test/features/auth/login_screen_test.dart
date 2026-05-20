// Widget tests for LoginScreen.
//
// AuthNotifier.build() reads authServiceProvider + appleSignInServiceProvider
// during construction and subscribes to onAuthStateChange. Both providers
// are overridden to mocks so the widget tree builds without touching
// real Supabase.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/auth/models/auth_errors.dart';
import 'package:nuveli/features/auth/providers/auth_provider.dart';
import 'package:nuveli/features/auth/screens/login_screen.dart';
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
    // AuthNotifier.build() reads these synchronously.
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());
    when(() => mockAuth.currentUser).thenReturn(null);
    overrides = [
      authServiceProvider.overrideWithValue(mockAuth),
      appleSignInServiceProvider.overrideWithValue(mockApple),
    ];
  });

  group('LoginScreen — rendering', () {
    testWidgets('shows Welcome back title + email/password + Sign in button',
        (tester) async {
      await pumpWithProviders(tester, const LoginScreen(), overrides: overrides);

      expect(find.text('Welcome back'), findsOneWidget);
      // Two text fields visible (email + password)
      expect(find.byType(TextFormField), findsNWidgets(2));
      // The submit button
      expect(
        find.widgetWithText(AuthPrimaryButton, 'Sign in'),
        findsOneWidget,
      );
      // Forgot-password + sign-up secondary actions
      // Forgot is a plain TextButton with Text. Sign up is inside an
      // AuthLinkText (RichText with TextSpan), which find.text doesn't
      // traverse — match by widget type instead.
      expect(find.text('Forgot password?'), findsOneWidget);
      // Import is implicit via package; using string-find via the rich-
      // text-aware finder.
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == 'AuthLinkText',
        ),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen — form validation gates submit', () {
    testWidgets('empty form: tapping Sign in does NOT call signInWithEmail',
        (tester) async {
      await pumpWithProviders(tester, const LoginScreen(), overrides: overrides);

      // Don't enter anything — just submit.
      await tester.tap(find.widgetWithText(AuthPrimaryButton, 'Sign in'));
      await tester.pump(); // process tap + setState

      verifyNever(
        () => mockAuth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
      // Validation messages should be visible.
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('invalid email: validator fires, no call to AuthService',
        (tester) async {
      await pumpWithProviders(tester, const LoginScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'not-an-email',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'hunter12',
      );

      await tester.tap(find.widgetWithText(AuthPrimaryButton, 'Sign in'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
      verifyNever(
        () => mockAuth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });
  });

  group('LoginScreen — happy path submit', () {
    testWidgets('valid form invokes AuthService.signInWithEmail with inputs',
        (tester) async {
      when(
        () => mockAuth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => AuthResponse(session: _FakeSession(), user: _FakeUser()),
      );

      await pumpWithProviders(tester, const LoginScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'hunter12',
      );

      await tester.tap(find.widgetWithText(AuthPrimaryButton, 'Sign in'));
      await tester.pump(); // start the future
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockAuth.signInWithEmail(
          email: 'user@example.com',
          password: 'hunter12',
        ),
      ).called(1);
    });
  });

  group('LoginScreen — error surface', () {
    testWidgets(
        'AuthException("Invalid login credentials") surfaces as the banner',
        (tester) async {
      when(
        () => mockAuth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NuveliAuthException(
        type: AuthErrorType.invalidCredentials,
        userMessage: 'Incorrect email or password.',
      ));

      await pumpWithProviders(tester, const LoginScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'wrongpass',
      );

      await tester.tap(find.widgetWithText(AuthPrimaryButton, 'Sign in'));
      // Multiple pumps to let the async throw propagate + setState run.
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });
  });
}
