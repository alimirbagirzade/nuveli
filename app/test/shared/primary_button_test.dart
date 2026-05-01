import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/shared/widgets/primary_button.dart';

import '../_helpers/widget_test_helpers.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('displays the label', (tester) async {
      await pumpScaffoldWithProviders(
        tester,
        PrimaryButton(label: 'Devam Et', onPressed: () {}),
      );

      expect(find.text('Devam Et'), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      var tapped = 0;
      await pumpScaffoldWithProviders(
        tester,
        PrimaryButton(label: 'Giriş Yap', onPressed: () => tapped++),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(tapped, 1);
    });

    testWidgets('does not fire onPressed when disabled (null callback)',
        (tester) async {
      await pumpScaffoldWithProviders(
        tester,
        const PrimaryButton(label: 'Kapalı', onPressed: null),
      );

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('does not fire onPressed when isEnabled: false',
        (tester) async {
      var tapped = 0;
      await pumpScaffoldWithProviders(
        tester,
        PrimaryButton(
          label: 'Disabled',
          isEnabled: false,
          onPressed: () => tapped++,
        ),
      );

      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, 0);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await pumpScaffoldWithProviders(
        tester,
        PrimaryButton(
          label: 'Kaydediliyor',
          isLoading: true,
          onPressed: () {},
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Label loading esnasında gizlenir
      expect(find.text('Kaydediliyor'), findsNothing);
    });

    testWidgets('ignores taps while loading', (tester) async {
      var tapped = 0;
      await pumpScaffoldWithProviders(
        tester,
        PrimaryButton(
          label: 'Yükleniyor',
          isLoading: true,
          onPressed: () => tapped++,
        ),
      );

      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, 0);
    });
  });
}
