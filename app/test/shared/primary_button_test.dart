import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/shared/widgets/primary_button.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('PrimaryButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(wrap(
        PrimaryButton(label: 'Devam Et', onPressed: () {}),
      ));
      expect(find.text('Devam Et'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(wrap(
        PrimaryButton(label: 'Tap', onPressed: () => pressed = true),
      ));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(pressed, true);
    });

    testWidgets('shows loading spinner when isLoading', (tester) async {
      await tester.pumpWidget(wrap(
        PrimaryButton(label: 'Submit', onPressed: () {}, isLoading: true),
      ));
      expect(find.text('Submit'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not call onPressed when isLoading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(wrap(
        PrimaryButton(
          label: 'Submit',
          onPressed: () => pressed = true,
          isLoading: true,
        ),
      ));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(pressed, false);
    });

    testWidgets('disabled when isEnabled is false', (tester) async {
      var pressed = false;
      await tester.pumpWidget(wrap(
        PrimaryButton(
          label: 'Disabled',
          onPressed: () => pressed = true,
          isEnabled: false,
        ),
      ));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(pressed, false);
    });

    testWidgets('renders icon if provided', (tester) async {
      await tester.pumpWidget(wrap(
        PrimaryButton(
          label: 'With Icon',
          onPressed: () {},
          icon: const Icon(Icons.check),
        ),
      ));
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });
  });

  group('SecondaryButton', () {
    testWidgets('renders label and is tappable', (tester) async {
      var pressed = false;
      await tester.pumpWidget(wrap(
        SecondaryButton(label: 'Vazgeç', onPressed: () => pressed = true),
      ));
      expect(find.text('Vazgeç'), findsOneWidget);
      await tester.tap(find.byType(SecondaryButton));
      await tester.pump();
      expect(pressed, true);
    });
  });
}
