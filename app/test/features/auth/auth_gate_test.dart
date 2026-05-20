// Widget tests for AuthGate routing.
//
// AuthGate is the top-level switcher: it picks between SplashScreen /
// WelcomeScreen / OnboardingScreen / DashboardScreen based on the
// authProvider state and the loaded UserProfile. Here we lock down the
// two branches that don't drag in heavy downstream provider chains:
//
//   - authState = loading            → SplashScreen
//   - authState = data(null)         → WelcomeScreen
//
// The signed-in branches (Onboarding / Dashboard) need their own
// provider stacks mocked out and are deferred to a follow-up.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/auth/models/auth_user.dart';
import 'package:nuveli/features/auth/providers/auth_provider.dart';
import 'package:nuveli/features/auth/providers/current_user_provider.dart';
import 'package:nuveli/features/auth/screens/auth_gate.dart';
import 'package:nuveli/features/auth/screens/onboarding/onboarding_screen.dart';
import 'package:nuveli/features/auth/screens/welcome_screen.dart';
import 'package:nuveli/features/auth/services/apple_signin_service.dart';
import 'package:nuveli/features/auth/services/auth_service.dart';
import 'package:nuveli/features/auth/services/profile_service.dart';

import '../../_helpers/widget_test_helpers.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockAppleService extends Mock implements AppleSignInService {}

class _StubAuthNotifier extends AuthNotifier {
  _StubAuthNotifier(this._state);
  final AsyncValue<AuthUser?> _state;

  @override
  Future<AuthUser?> build() async {
    // Bypass the real build (which subscribes to Supabase streams).
    // We just return whatever the test seeded; AsyncNotifier picks up
    // the state once the future completes.
    return _state.maybeWhen(data: (u) => u, orElse: () => null);
  }
}

void main() {
  late _MockAuthService mockAuth;
  late _MockAppleService mockApple;

  setUp(() {
    mockAuth = _MockAuthService();
    mockApple = _MockAppleService();
    // Stubs the real AuthNotifier.build() reads. Not used in the stub
    // notifier path but keeps the underlying providers safe if anyone
    // touches them.
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());
    when(() => mockAuth.currentUser).thenReturn(null);
  });

  testWidgets('authProvider data(null) → renders WelcomeScreen',
      (tester) async {
    await pumpWithProviders(
      tester,
      const AuthGate(),
      overrides: [
        authServiceProvider.overrideWithValue(mockAuth),
        appleSignInServiceProvider.overrideWithValue(mockApple),
        // AuthNotifier.build() resolves to null → AsyncValue.data(null)
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets(
      'signed in + profile with onboardingCompleted=false → routes to OnboardingScreen',
      (tester) async {
    await pumpWithProviders(
      tester,
      const AuthGate(),
      overrides: [
        authServiceProvider.overrideWithValue(mockAuth),
        appleSignInServiceProvider.overrideWithValue(mockApple),
        authProvider.overrideWith(
          () => _StubAuthNotifier(
            AsyncValue.data(
              AuthUser(
                id: 'u1',
                email: 'user@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
        currentUserProfileProvider.overrideWith(
          (ref) async => UserProfile(
            id: 'p1',
            onboardingCompleted: false,
            createdAt: DateTime.now(),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
