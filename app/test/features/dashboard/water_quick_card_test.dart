import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/dashboard/widgets/water_quick_card.dart';

WaterQuickCard _build({
  required int consumed,
  required int target,
  required Future<void> Function(int) onAdd,
}) {
  return WaterQuickCard(
    consumedMl: consumed,
    targetMl: target,
    onAddWater: onAdd,
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  testWidgets('quick-add button calls onAddWater with 250 ml', (tester) async {
    int? receivedAmount;
    await _pump(
      tester,
      _build(
        consumed: 0,
        target: 2500,
        onAdd: (ml) async {
          receivedAmount = ml;
        },
      ),
    );

    // Tap the "+250 ml" quick-add chip
    await tester.tap(find.text('250 ml').first);
    await tester.pump();

    expect(receivedAmount, equals(250));
  });

  testWidgets('chevron opens portion picker with preset chips',
      (tester) async {
    await _pump(
      tester,
      _build(
        consumed: 0,
        target: 2500,
        onAdd: (_) async {},
      ),
    );

    // Chevron icon — open the picker
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    // All preset chips visible
    expect(find.text('100 ml'), findsOneWidget);
    expect(find.text('200 ml'), findsOneWidget);
    // 250 ml appears in both the card AND the picker — accept >= 1
    expect(find.text('250 ml'), findsWidgets);
    expect(find.text('330 ml'), findsOneWidget);
    expect(find.text('500 ml'), findsOneWidget);
    expect(find.text('750 ml'), findsOneWidget);
    expect(find.text('Custom (ml)'), findsOneWidget);
  });

  testWidgets('selecting a preset chip calls onAddWater with that amount',
      (tester) async {
    int? receivedAmount;
    await _pump(
      tester,
      _build(
        consumed: 0,
        target: 2500,
        onAdd: (ml) async {
          receivedAmount = ml;
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    // Tap the "500 ml" chip
    await tester.tap(find.text('500 ml'));
    await tester.pumpAndSettle();

    expect(receivedAmount, equals(500));
  });

  testWidgets('custom amount calls onAddWater with the entered value',
      (tester) async {
    int? receivedAmount;
    await _pump(
      tester,
      _build(
        consumed: 0,
        target: 2500,
        onAdd: (ml) async {
          receivedAmount = ml;
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    expect(receivedAmount, equals(400));
  });

  testWidgets('custom input rejects non-positive numbers', (tester) async {
    int? receivedAmount;
    await _pump(
      tester,
      _build(
        consumed: 0,
        target: 2500,
        onAdd: (ml) async {
          receivedAmount = ml;
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    expect(receivedAmount, isNull);
    expect(find.textContaining('between 1 and 5000'), findsOneWidget);
  });

  testWidgets('custom input rejects values > 5000 ml', (tester) async {
    int? receivedAmount;
    await _pump(
      tester,
      _build(
        consumed: 0,
        target: 2500,
        onAdd: (ml) async {
          receivedAmount = ml;
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '9999');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    expect(receivedAmount, isNull);
  });
}
