import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/config/app_config.dart';

void main() {
  group('AppConfig environment detection', () {
    test('default env is development', () {
      // Default dart-define olmadan 'development' dönmeli
      expect(AppConfig.env, 'development');
      expect(AppConfig.isDevelopment, true);
      expect(AppConfig.isProduction, false);
      expect(AppConfig.isStaging, false);
    });

    test('Firebase disabled in development', () {
      expect(AppConfig.isFirebaseEnabled, false);
    });

    test('Debug features enabled in development', () {
      expect(AppConfig.showDebugBanner, true);
      expect(AppConfig.logNetworkRequests, true);
    });

    test('Crisis detection always on', () {
      // Güvenlik feature'ı - her ortamda aktif
      expect(AppConfig.enableCrisisDetection, true);
    });
  });

  group('AppConfig static values', () {
    test('app version is set', () {
      expect(AppConfig.appVersion, '1.0.0');
      expect(AppConfig.appBuildNumber, '1');
    });

    test('URLs are configured', () {
      expect(AppConfig.supportEmail, 'support@nuveli.com.tr');
      expect(AppConfig.websiteUrl, 'https://nuveli.com.tr');
      expect(AppConfig.privacyUrl, contains('gizlilik'));
      expect(AppConfig.termsUrl, contains('sartlar'));
    });
  });

  group('AppConfig validation', () {
    test('development config always valid', () {
      // Dev modunda her zaman valid (placeholder değerler kabul edilir)
      expect(AppConfig.isProductionConfigValid, true);
    });

    test('missingConfigKeys in development shows placeholder warnings', () {
      // Dev'de hangi değerlerin placeholder olduğunu göstermeli
      final missing = AppConfig.missingConfigKeys;
      expect(missing, contains('SUPABASE_URL'));
      expect(missing, contains('SUPABASE_ANON_KEY'));
    });
  });
}
