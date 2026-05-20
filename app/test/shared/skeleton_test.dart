// Widget tests for SkeletonBox / SkeletonCircle — make sure the
// shimmer wrapper actually renders and the size props are honoured.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/shared/widgets/skeleton.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );

  group('SkeletonBox', () {
    testWidgets('renders inside a Shimmer wrapper', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonBox(width: 100, height: 20)));
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('honours the supplied width + height', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonBox(width: 120, height: 32)));
      final inner = tester.widget<Container>(
        find.descendant(
          of: find.byType(Shimmer),
          matching: find.byType(Container),
        ),
      );
      // Container.constraints captures the explicit size.
      expect(inner.constraints?.maxWidth, 120);
      expect(inner.constraints?.maxHeight, 32);
    });

    testWidgets('null width is fine inside a Row (does not crash)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 200,
            child: Row(
              children: [
                Expanded(child: SkeletonBox(height: 16)),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('SkeletonCircle', () {
    testWidgets('is a square SkeletonBox with size/2 radius', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonCircle(size: 40)));
      final inner = tester.widget<Container>(
        find.descendant(
          of: find.byType(Shimmer),
          matching: find.byType(Container),
        ),
      );
      expect(inner.constraints?.maxWidth, 40);
      expect(inner.constraints?.maxHeight, 40);

      final decoration = inner.decoration! as BoxDecoration;
      final radius = decoration.borderRadius as BorderRadius;
      expect(radius.topLeft.x, 20);
    });
  });
}
