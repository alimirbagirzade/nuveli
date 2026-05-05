import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nuveli/core/config/app_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App startup smoke tests', () {
    testWidgets('AppConfig is in development mode', (tester) async {
      // Test ortamında her zaman development olmalı
      expect(AppConfig.isDevelopment, true);
      expect(AppConfig.isProduction, false);
    });

    testWidgets('Critical URLs are configured', (tester) async {
      expect(AppConfig.supportEmail, contains('@'));
      expect(AppConfig.privacyUrl, startsWith('https://'));
      expect(AppConfig.termsUrl, startsWith('https://'));
      expect(AppConfig.websiteUrl, startsWith('https://'));
    });

    testWidgets('Firebase is disabled in development', (tester) async {
      expect(AppConfig.isFirebaseEnabled, false);
    });

    testWidgets('Crisis detection always enabled', (tester) async {
      // Güvenlik feature'ı her ortamda aktif olmalı
      expect(AppConfig.enableCrisisDetection, true);
    });
  });

  group('Theme & basic rendering', () {
    testWidgets('MaterialApp renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
