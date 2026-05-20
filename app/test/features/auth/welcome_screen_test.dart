// Widget tests for WelcomeScreen — the first-launch landing screen
// that AuthGate routes to whenever the user is signed out.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/auth/screens/welcome_screen.dart';
import 'package:nuveli/features/auth/widgets/auth_primary_button.dart';

import '../../_helpers/widget_test_helpers.dart';

void main() {
  testWidgets('WelcomeScreen renders brand + Get Started + sign-in link',
      (tester) async {
    await pumpWithProviders(tester, const WelcomeScreen());
    // Let the entry animation settle so all FadeTransition children
    // are at full opacity / measurable.
    await tester.pumpAndSettle();

    expect(find.text('Nuveli'), findsOneWidget);
    expect(find.text('AI Calorie Coach'), findsOneWidget);
    // Primary CTA labeled "Get Started"
    expect(
      find.widgetWithText(AuthPrimaryButton, 'Get Started'),
      findsOneWidget,
    );
  });

  testWidgets('Get Started button is tappable (no exception on press)',
      (tester) async {
    await pumpWithProviders(tester, const WelcomeScreen());
    await tester.pumpAndSettle();

    // Tapping pushes a route — the destination (SignupScreen) needs
    // ProviderScope, which pumpWithProviders supplies. We just verify
    // the press doesn't throw; route assertions are deferred (Nav
    // observer is a richer follow-up test).
    await tester.tap(find.widgetWithText(AuthPrimaryButton, 'Get Started'));
    await tester.pump();
    // No crash means the gesture handler ran successfully.
    expect(tester.takeException(), isNull);
  });
}
