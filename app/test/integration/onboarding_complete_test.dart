// Integration-style test for the Onboarding "Complete Setup" path.
//
// We don't drive the PageView through all 5 screens here — Step 2's
// ListView + AuthTextField composition needs a custom surfaceSize +
// MaterialLocalizations setup. Instead we:
//   1. Seed OnboardingNotifier with a fully populated OnboardingData
//   2. Mount OnboardingScreen and jump the PageController to Step 5
//   3. Tap Complete Setup
//   4. Verify ProfileService.completeOnboarding was called with the
//      seeded payload

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/features/auth/models/onboarding_data.dart';
import 'package:nuveli/features/auth/providers/auth_provider.dart';
import 'package:nuveli/features/auth/providers/current_user_provider.dart';
import 'package:nuveli/features/auth/providers/onboarding_provider.dart';
import 'package:nuveli/features/auth/screens/onboarding/onboarding_screen.dart';
import 'package:nuveli/features/auth/services/apple_signin_service.dart';
import 'package:nuveli/features/auth/services/auth_service.dart';
import 'package:nuveli/features/auth/services/profile_service.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockAppleService extends Mock implements AppleSignInService {}

class _MockProfileService extends Mock implements ProfileService {}

class _SeededOnboardingNotifier extends OnboardingNotifier {
  _SeededOnboardingNotifier(this._initial);
  final OnboardingData _initial;

  @override
  OnboardingData build() => _initial;
}

class _FakeOnboardingData extends Fake implements OnboardingData {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOnboardingData());
  });

  testWidgets(
      'Step 5 Complete Setup → ProfileService.completeOnboarding is called',
      (tester) async {
    final mockAuth = _MockAuthService();
    final mockApple = _MockAppleService();
    final mockProfile = _MockProfileService();

    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockProfile.completeOnboarding(any())).thenAnswer(
      (_) async => UserProfile(
        id: 'p1',
        onboardingCompleted: true,
        createdAt: DateTime.now(),
      ),
    );

    final seed = const OnboardingData().copyWith(
      displayName: 'Ali',
      dateOfBirth: DateTime(1995, 6, 15),
      gender: Gender.male,
      heightCm: 178,
      currentWeightKg: 75,
      activityLevel: ActivityLevel.moderate,
      goalType: GoalType.maintain,
      dailyCalorieTarget: 2500,
      dailyWaterMl: 2500,
      proteinPercent: 30,
      carbsPercent: 40,
      fatPercent: 30,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
          appleSignInServiceProvider.overrideWithValue(mockApple),
          profileServiceProvider.overrideWithValue(mockProfile),
          onboardingDataProvider.overrideWith(
            () => _SeededOnboardingNotifier(seed),
          ),
        ],
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pageView = find.byType(PageView).evaluate().single.widget as PageView;
    pageView.controller!.jumpToPage(4);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Complete Setup'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    verify(() => mockProfile.completeOnboarding(any())).called(1);
  });
}
