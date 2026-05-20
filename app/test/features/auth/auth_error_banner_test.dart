// Widget tests for AuthErrorBanner — the inline error chip shown on
// login/signup screens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/auth/widgets/auth_link_text.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('AuthErrorBanner', () {
    testWidgets('renders the message text + the error icon', (tester) async {
      await tester.pumpWidget(
        wrap(const AuthErrorBanner(message: 'Something went wrong.')),
      );

      expect(find.text('Something went wrong.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('without onDismiss: no close affordance is rendered',
        (tester) async {
      await tester.pumpWidget(
        wrap(const AuthErrorBanner(message: 'Read-only error')),
      );

      // No close icon (Icons.close) when there's no dismiss handler.
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('with onDismiss: tapping the close icon fires the callback',
        (tester) async {
      var dismissed = 0;
      await tester.pumpWidget(
        wrap(
          AuthErrorBanner(
            message: 'Closeable',
            onDismiss: () => dismissed++,
          ),
        ),
      );

      // The dismiss tap target is a GestureDetector with an Icon child.
      final closeIcon = find.byIcon(Icons.close);
      expect(closeIcon, findsOneWidget);

      await tester.tap(closeIcon);
      await tester.pump();

      expect(dismissed, 1);
    });
  });
}
