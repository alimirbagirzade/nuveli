import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Merkezi analytics wrapper.
///
/// Tüm event'ler bu sınıfın metotları üzerinden gönderilir — string'ler
/// serbest bırakılmaz. Yeni event eklendiğinde burada metot eklenir.
///
/// Debug mode'da gerçek event gönderilmez, console'a yazılır.
class AnalyticsService {
  AnalyticsService._();

  static final _analytics = FirebaseAnalytics.instance;

  // --------------------------------------------------------------------------
  // Lifecycle
  // --------------------------------------------------------------------------

  /// Auth state'e bağlı çağır — sonraki event'ler user ID ile ilişkilenir.
  static Future<void> setUser(String? userId) async {
    if (kDebugMode) return;
    try {
      await _analytics.setUserId(id: userId);
    } catch (_) {}
  }

  /// Premium tier → user property olarak tag'le (cohort analizi için).
  static Future<void> setPremiumTier(String tier) async {
    if (kDebugMode) return;
    try {
      await _analytics.setUserProperty(name: 'premium_tier', value: tier);
    } catch (_) {}
  }

  static Future<void> _log(String name, [Map<String, Object>? params]) async {
    if (kDebugMode) {
      debugPrint('📊 [$name] ${params ?? ''}');
      return;
    }
    try {
      await _analytics.logEvent(name: name, parameters: params);
    } catch (_) {
      // Analytics fail etmemeli — sessizce swallow
    }
  }

  // --------------------------------------------------------------------------
  // AUTH EVENTS
  // --------------------------------------------------------------------------

  static Future<void> signupStarted() => _log('signup_started');

  static Future<void> signupCompleted() => _log('signup_completed');

  static Future<void> loginCompleted() => _log('login_completed');

  static Future<void> logout() => _log('logout');

  // --------------------------------------------------------------------------
  // ONBOARDING EVENTS
  // --------------------------------------------------------------------------

  /// Her onboarding adımında çağrılır — funnel analizi için.
  static Future<void> onboardingStepCompleted(String step) =>
      _log('onboarding_step_completed', {'step': step});

  static Future<void> onboardingCompleted({
    required String goal,
    required String coachPersona,
    required int calorieTarget,
  }) =>
      _log('onboarding_completed', {
        'goal': goal,
        'coach_persona': coachPersona,
        'calorie_target': calorieTarget,
      });

  // --------------------------------------------------------------------------
  // MEAL EVENTS
  // --------------------------------------------------------------------------

  /// Kullanıcı kamera veya galeri seçti mi?
  static Future<void> mealCaptureStarted({required String source}) =>
      _log('meal_capture_started', {'source': source}); // camera | gallery | text

  /// AI analizi başarıyla tamamlandı.
  static Future<void> mealAnalyzed({required String confidence}) =>
      _log('meal_analyzed', {'confidence': confidence}); // high | medium | low

  /// Kullanıcı AI sonucunu düzenlemeden kabul etti.
  static Future<void> mealConfirmed({required String mealType}) =>
      _log('meal_confirmed', {'meal_type': mealType});

  /// Kullanıcı AI sonucunu düzenleyip kaydetti.
  static Future<void> mealEdited({required String mealType}) =>
      _log('meal_edited', {'meal_type': mealType});

  /// Manuel giriş tercih edildi (genelde low-confidence sonrası).
  static Future<void> mealManualEntered() => _log('meal_manual_entered');

  static Future<void> mealDeleted() => _log('meal_deleted');

  // --------------------------------------------------------------------------
  // COACH EVENTS
  // --------------------------------------------------------------------------

  static Future<void> coachMessageSent({required int lengthChars}) =>
      _log('coach_message_sent', {'length_chars': lengthChars});

  /// Koç sesli yanıtını kullanıcı oynattı.
  static Future<void> coachAudioPlayed() => _log('coach_audio_played');

  /// Safety service crisis/distress detected.
  /// NOT: mesaj içeriğini GÖNDERME. Sadece risk seviyesi.
  static Future<void> coachSafetyTriggered({required String riskMode}) =>
      _log('coach_safety_triggered', {'risk_mode': riskMode});

  // --------------------------------------------------------------------------
  // PREMIUM EVENTS
  // --------------------------------------------------------------------------

  /// Paywall ekranı gösterildi — source = home | meal_limit | coach_limit | settings.
  static Future<void> paywallShown({required String source}) =>
      _log('paywall_shown', {'source': source});

  /// Kullanıcı paket satın alma akışına girdi.
  static Future<void> purchaseInitiated({required String productId}) =>
      _log('purchase_initiated', {'product_id': productId});

  static Future<void> purchaseCompleted({required String productId}) =>
      _log('purchase_completed', {'product_id': productId});

  static Future<void> purchaseCancelled() => _log('purchase_cancelled');

  static Future<void> purchaseFailed({required String reason}) =>
      _log('purchase_failed', {'reason': reason});

  static Future<void> trialClaimed() => _log('trial_claimed');

  static Future<void> restorePurchasesCompleted({required bool success}) =>
      _log('restore_purchases_completed', {'success': success});

  // --------------------------------------------------------------------------
  // FEATURE GATE EVENTS
  // --------------------------------------------------------------------------

  /// Free tier kullanıcısı günlük limite takıldı.
  static Future<void> limitReached({required String feature}) =>
      _log('limit_reached', {'feature': feature}); // meal_analysis | coach_message

  // --------------------------------------------------------------------------
  // SETTINGS EVENTS
  // --------------------------------------------------------------------------

  static Future<void> notificationPrefsChanged({
    required bool mealReminders,
    required bool coachNudges,
    required bool weeklySummary,
  }) =>
      _log('notification_prefs_changed', {
        'meal_reminders': mealReminders ? 1 : 0,
        'coach_nudges': coachNudges ? 1 : 0,
        'weekly_summary': weeklySummary ? 1 : 0,
      });

  static Future<void> accountDeleted() => _log('account_deleted');

  // --------------------------------------------------------------------------
  // SCREEN VIEWS (otomatik değil, manuel çağrılır)
  // --------------------------------------------------------------------------

  static Future<void> screenView(String screenName) async {
    if (kDebugMode) {
      debugPrint('📊 [screen:$screenName]');
      return;
    }
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (_) {}
  }
}
