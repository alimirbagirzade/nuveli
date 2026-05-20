// Integration-style widget tests for the multi-screen auth flow.
//
// These wire several screens together (Welcome → Signup → ...) and
// assert that the navigation pushes the right widget into the route
// stack. Supabase calls are stubbed via the providers AuthNotifier
// already supports — no real network, no real persistence.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/auth/providers/auth_provider.dart';
import 'package:nuveli/features/auth/screens/login_screen.dart';
import 'package:nuveli/features/auth/screens/signup_screen.dart';
import 'package:nuveli/features/auth/screens/welcome_screen.dart';
import 'package:nuveli/features/auth/services/apple_signin_service.dart';
import 'package:nuveli/features/auth/services/auth_service.dart';
import 'package:nuveli/features/auth/widgets/auth_primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockAppleSignInService extends Mock implements AppleSignInService {}

class _FakeUser extends Fake implements User {
  @override
  String get id => 'fake-user';
}

class _FakeSession extends Fake implements Session {}

Future<void> _pumpApp(
  WidgetTester tester,
  Widget home, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: home),
    ),
  );
}

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

  testWidgets('Welcome → Get Started → lands on SignupScreen',
      (tester) async {
    await _pumpApp(tester, const WelcomeScreen(), overrides: overrides);
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(SignupScreen), findsNothing);

    await tester.tap(
      find.widgetWithText(AuthPrimaryButton, 'Get Started'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SignupScreen), findsOneWidget);
  });

  testWidgets('Signup full happy path: fills form → calls signUpWithEmail',
      (tester) async {
    when(
      () => mockAuth.signUpWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => AuthResponse(session: _FakeSession(), user: _FakeUser()),
    );

    await _pumpApp(tester, const SignupScreen(), overrides: overrides);

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
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.byType(AuthPrimaryButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(
      () => mockAuth.signUpWithEmail(
        email: 'new@example.com',
        password: 'hunter12',
      ),
    ).called(1);
  });

  testWidgets('Login screen full happy path: enters creds → signInWithEmail',
      (tester) async {
    when(
      () => mockAuth.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => AuthResponse(session: _FakeSession(), user: _FakeUser()),
    );

    await _pumpApp(tester, const LoginScreen(), overrides: overrides);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'hunter12',
    );

    await tester.tap(find.widgetWithText(AuthPrimaryButton, 'Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(
      () => mockAuth.signInWithEmail(
        email: 'user@example.com',
        password: 'hunter12',
      ),
    ).called(1);
  });
}
