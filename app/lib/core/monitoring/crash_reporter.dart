import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Structured crash reporting wrapper.
///
/// - Debug mode'da sadece console'a yazar (Crashlytics'i kirletmemek için)
/// - Release'de Crashlytics'e gönderir, custom keys ile feature/action etiketler
/// - User ID set edilebilir (auth'la otomatik bağlanması için [setUser] kullan)
class CrashReporter {
  CrashReporter._();

  static final _crashlytics = FirebaseCrashlytics.instance;

  /// Yakalanmamış/beklenmeyen hataları rapor eder.
  ///
  /// [feature] = 'meal' | 'coach' | 'onboarding' | 'auth' | 'premium'
  /// [action] = 'analyze' | 'send_message' | 'submit' vb.
  /// [context] = fatal olmayan durumlarda ek bilgi (user-specific değil)
  static Future<void> report(
    Object error,
    StackTrace? stackTrace, {
    required String feature,
    required String action,
    Map<String, dynamic>? context,
    bool fatal = false,
  }) async {
    // Debug: sadece log, release'de Crashlytics'e git
    if (kDebugMode) {
      debugPrint('═══ CRASH REPORT [$feature/$action] ═══');
      debugPrint('Error: $error');
      if (context != null) debugPrint('Context: $context');
      if (stackTrace != null) debugPrint('Stack: $stackTrace');
      debugPrint('═══════════════════════════════════════');
      return;
    }

    try {
      // Custom keys — Crashlytics dashboard'unda filtreleme için
      await _crashlytics.setCustomKey('feature', feature);
      await _crashlytics.setCustomKey('action', action);
      if (context != null) {
        for (final entry in context.entries) {
          await _crashlytics.setCustomKey(
            'ctx_${entry.key}',
            entry.value.toString(),
          );
        }
      }

      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: fatal,
        reason: '$feature/$action',
      );
    } catch (_) {
      // Crashlytics init edilmemiş veya başka bir hata — sessizce devam et
      // Error'u raporlayamamak, kullanıcıyı etkilememeli
    }
  }

  /// Auth'ta çağır — tüm sonraki hata raporları user ID ile ilişkilenir.
  static Future<void> setUser(String? userId) async {
    if (kDebugMode) return;
    try {
      await _crashlytics.setUserIdentifier(userId ?? '');
    } catch (_) {}
  }

  /// İnsan-okur olay log'u (hata değil — sadece breadcrumb).
  /// Crashlytics'te son 64 olay saklanır, crash olduğunda context sağlar.
  static Future<void> log(String message) async {
    if (kDebugMode) {
      debugPrint('[log] $message');
      return;
    }
    try {
      await _crashlytics.log(message);
    } catch (_) {}
  }
}
