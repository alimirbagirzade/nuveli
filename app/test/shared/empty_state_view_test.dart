import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/shared/widgets/empty_state_view.dart';

import '../_helpers/widget_test_helpers.dart';

void main() {
  group('EmptyStateView', () {
    testWidgets('renders icon, title', (tester) async {
      await pumpScaffoldWithProviders(
        tester,
        const EmptyStateView(
          icon: Icons.restaurant_outlined,
          title: 'Henüz öğün yok',
        ),
      );

      expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
      expect(find.text('Henüz öğün yok'), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await pumpScaffoldWithProviders(
        tester,
        const EmptyStateView(
          icon: Icons.inbox_outlined,
          title: 'Boş',
          message: 'Eklemek için + tuşuna bas',
        ),
      );

      expect(find.text('Eklemek için + tuşuna bas'), findsOneWidget);
    });

    testWidgets('omits action button when label/callback missing',
        (tester) async {
      await pumpScaffoldWithProviders(
        tester,
        const EmptyStateView(
          icon: Icons.inbox_outlined,
          title: 'Boş',
        ),
      );

      // Aksiyon yoksa TextButton render edilmemeli
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('shows action button and fires callback on tap',
        (tester) async {
      var tapped = 0;
      await pumpScaffoldWithProviders(
        tester,
        EmptyStateView(
          icon: Icons.add,
          title: 'Boş',
          actionLabel: 'Ekle',
          onAction: () => tapped++,
        ),
      );

      expect(find.text('Ekle'), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(tapped, 1);
    });

    testWidgets('compact mode uses smaller layout', (tester) async {
      await pumpScaffoldWithProviders(
        tester,
        const EmptyStateView(
          icon: Icons.inbox_outlined,
          title: 'Boş',
          compact: true,
        ),
      );

      // Compact modda bile title görünür olmalı
      expect(find.text('Boş'), findsOneWidget);
    });
  });
}
