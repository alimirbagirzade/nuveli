/// Uygulama konfigürasyonu.
/// Değerler --dart-define-from-file veya --dart-define ile enjekte edilir.
///
/// Çalıştırma örnekleri:
///   Development: flutter run --dart-define-from-file=.env.development
///   Staging:     flutter run --dart-define-from-file=.env.staging
///   Production:  flutter build ipa --dart-define-from-file=.env.production
class AppConfig {
  AppConfig._();

  // ─────────────────────────────────────────────────────────────
  // Environment
  // ─────────────────────────────────────────────────────────────

  /// development | staging | production
  static const env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => env == 'development';
  static bool get isStaging => env == 'staging';
  static bool get isProduction => env == 'production';

  // ─────────────────────────────────────────────────────────────
  // Supabase
  // ─────────────────────────────────────────────────────────────

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  // ─────────────────────────────────────────────────────────────
  // Backend API
  // ─────────────────────────────────────────────────────────────

  // Default points at the real production backend so a bare
  // `flutter run` (no --dart-define-from-file) still produces a
  // working app talking to the deployed API. Override with
  // --dart-define-from-file=.env.development when iterating against
  // a local FastAPI instance.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://nuveli-api.onrender.com',
  );

  // ─────────────────────────────────────────────────────────────
  // RevenueCat
  // ─────────────────────────────────────────────────────────────

  static const revenueCatAppleKey = String.fromEnvironment(
    'RC_APPLE_KEY',
    defaultValue: '',
  );

  static const revenueCatGoogleKey = String.fromEnvironment(
    'RC_GOOGLE_KEY',
    defaultValue: '',
  );

  // ─────────────────────────────────────────────────────────────
  // Firebase (runtime config)
  // ─────────────────────────────────────────────────────────────

  /// Firebase analytics/crashlytics production'da aktif.
  /// Development'ta yanlış telemetri oluşmasın diye kapalı.
  static bool get isFirebaseEnabled => isProduction || isStaging;

  // ─────────────────────────────────────────────────────────────
  // App meta
  // ─────────────────────────────────────────────────────────────

  static const appVersion = '1.0.0';
  static const appBuildNumber = '1';
  static const supportEmail = 'support@nuveli.com.tr';
  static const websiteUrl = 'https://nuveli.com.tr';
  static const privacyUrl = 'https://nuveli.com.tr/gizlilik.html';
  static const termsUrl = 'https://nuveli.com.tr/sartlar.html';

  // ─────────────────────────────────────────────────────────────
  // Feature flags
  // ─────────────────────────────────────────────────────────────

  /// Debug banner'ları göster (development only).
  static bool get showDebugBanner => isDevelopment;

  /// Ağ isteklerini logla (development only).
  static bool get logNetworkRequests => isDevelopment;

  /// Crisis detection for coach (always on).
  static bool get enableCrisisDetection => true;

  // ─────────────────────────────────────────────────────────────
  // Validation
  // ─────────────────────────────────────────────────────────────

  /// Production'da zorunlu olan değerler set edilmiş mi?
  ///
  /// Android-first launch: iOS paused, so we don't hard-require the Apple
  /// RC key. At least one RevenueCat key must be present (the platform's
  /// key is selected at runtime in RevenueCatService); requiring BOTH would
  /// crash an Android-only release build that legitimately ships no Apple
  /// key.
  static bool get isProductionConfigValid {
    if (!isProduction) return true;
    return supabaseUrl != 'https://your-project.supabase.co' &&
        supabaseAnonKey != 'your-anon-key' &&
        (revenueCatAppleKey.isNotEmpty || revenueCatGoogleKey.isNotEmpty);
  }

  /// Hangi değerlerin eksik olduğunu göster (debug için).
  static List<String> get missingConfigKeys {
    final missing = <String>[];
    if (supabaseUrl == 'https://your-project.supabase.co') {
      missing.add('SUPABASE_URL');
    }
    if (supabaseAnonKey == 'your-anon-key') {
      missing.add('SUPABASE_ANON_KEY');
    }
    // Only a problem if BOTH are empty — a single-platform release ships
    // one key (see isProductionConfigValid).
    if (isProduction &&
        revenueCatAppleKey.isEmpty &&
        revenueCatGoogleKey.isEmpty) {
      missing.add('RC_APPLE_KEY or RC_GOOGLE_KEY');
    }
    return missing;
  }
}
