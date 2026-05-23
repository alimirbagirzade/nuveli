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

  testWidgets('chevron opens portion picker with the widened preset chip set',
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

    // Preset chips visible. The previous "Custom (ml)" TextField was
    // removed because it consistently froze iOS Simulator (infinite
    // BoxConstraints assertion), so the preset list was widened
    // instead.
    expect(find.text('100 ml'), findsOneWidget);
    expect(find.text('150 ml'), findsOneWidget);
    expect(find.text('200 ml'), findsOneWidget);
    // 250 ml appears in both the card AND the picker — accept >= 1
    expect(find.text('250 ml'), findsWidgets);
    expect(find.text('300 ml'), findsOneWidget);
    expect(find.text('500 ml'), findsOneWidget);
    expect(find.text('750 ml'), findsOneWidget);
    expect(find.text('1000 ml'), findsOneWidget);
    // The custom-input form is gone.
    expect(find.text('Custom (ml)'), findsNothing);
    expect(find.byType(TextField), findsNothing);
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

  testWidgets('selecting the 1000 ml chip calls onAddWater with 1000',
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

    await tester.tap(find.text('1000 ml'));
    await tester.pumpAndSettle();

    expect(receivedAmount, equals(1000));
  });
}
