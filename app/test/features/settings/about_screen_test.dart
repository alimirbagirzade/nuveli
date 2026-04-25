import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/config/app_config.dart';
import 'package:nuveli/features/settings/screens/about_screen.dart';

void main() {
  group('AboutScreen', () {
    testWidgets('renders Nuveli title and version', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutScreen()),
      );

      expect(find.text('Nuveli'), findsOneWidget);
      expect(find.text('AI Calorie Coach'), findsOneWidget);
      expect(
        find.textContaining('Sürüm ${AppConfig.appVersion}'),
        findsOneWidget,
      );
    });

    testWidgets('renders all required sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutScreen()),
      );

      // Section başlıkları (uppercase görünüyor)
      expect(find.text('UYGULAMA'), findsOneWidget);
      expect(find.text('BAĞLANTILAR'), findsOneWidget);
      expect(find.text('TEKNİK'), findsOneWidget);
    });

    testWidgets('shows wellness disclaimer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutScreen()),
      );

      // Wellness vs medical ayrımı kritik — testle güvenceye al
      expect(
        find.textContaining('wellness'),
        findsOneWidget,
      );
      expect(
        find.textContaining('tıbbi tedavi yerine geçmez'),
        findsOneWidget,
      );
    });

    testWidgets('renders contact links', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutScreen()),
      );

      expect(find.text('Web sitesi'), findsOneWidget);
      expect(find.text('Gizlilik Politikası'), findsOneWidget);
      expect(find.text('Kullanım Şartları'), findsOneWidget);
      expect(find.text('Destek'), findsOneWidget);
    });

    testWidgets('shows copyright notice', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutScreen()),
      );

      expect(
        find.textContaining('© 2026 Nuveli'),
        findsOneWidget,
      );
    });
  });
}
