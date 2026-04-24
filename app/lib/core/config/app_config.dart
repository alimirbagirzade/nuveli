/// Uygulama konfigürasyonu.
/// Gerçek değerler .env veya --dart-define ile enjekte edilir.
class AppConfig {
  AppConfig._();

  // Supabase
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  // Backend API
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // RevenueCat
  static const revenueCatAppleKey = String.fromEnvironment(
    'RC_APPLE_KEY',
    defaultValue: '',
  );
  static const revenueCatGoogleKey = String.fromEnvironment(
    'RC_GOOGLE_KEY',
    defaultValue: '',
  );

  // App
  static const appVersion = '1.0.0';
  static const supportEmail = 'support@nuveli.com.tr';
}
