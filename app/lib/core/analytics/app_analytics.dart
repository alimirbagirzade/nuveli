import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';

import '../config/app_config.dart';

/// Centralized analytics tracking.
///
/// Production'da Firebase Analytics'e gönderir.
/// Development'ta console'a log atar (Firebase init edilmediği için).
///
/// Kullanım:
/// ```dart
/// AppAnalytics.track(AppEvent.mealLogged, props: {
///   'meal_type': 'breakfast',
///   'method': 'photo',
/// });
/// ```
class AppAnalytics {
  AppAnalytics._();

  static FirebaseAnalytics? _instance;

  /// Firebase Analytics instance — sadece Firebase enable ise.
  static FirebaseAnalytics? get _analytics {
    if (!AppConfig.isFirebaseEnabled) return null;
    try {
      _instance ??= FirebaseAnalytics.instance;
      return _instance;
    } catch (_) {
      return null;
    }
  }

  /// Event tracking — name + props.
  ///
  /// Firebase event name 40 karakter max, props key'leri snake_case olmalı.
  /// AppEvent enum'ındaki sabitleri kullan.
  static Future<void> track(
    String eventName, {
    Map<String, Object>? props,
  }) async {
    try {
      // Production: Firebase'e gönder
      if (_analytics != null) {
        await _analytics!.logEvent(
          name: eventName,
          parameters: props,
        );
      } else {
        // Development: console'a
        developer.log(
          '📊 [analytics] $eventName ${props ?? ""}',
          name: 'nuveli.analytics',
        );
      }
    } catch (e) {
      developer.log(
        'Analytics error: $e',
        name: 'nuveli.analytics',
      );
    }
  }

  /// Screen view tracking — sayfa geçişleri için.
  static Future<void> trackScreen(String screenName) async {
    try {
      if (_analytics != null) {
        await _analytics!.logScreenView(screenName: screenName);
      } else {
        developer.log(
          '📺 [screen] $screenName',
          name: 'nuveli.analytics',
        );
      }
    } catch (e) {
      developer.log(
        'Screen tracking error: $e',
        name: 'nuveli.analytics',
      );
    }
  }

  /// User identification — kullanıcı login olunca çağrılır.
  ///
  /// Hassas PII gönderme — sadece anonim user_id.
  static Future<void> identifyUser(String userId) async {
    try {
      if (_analytics != null) {
        await _analytics!.setUserId(id: userId);
      }
    } catch (e) {
      developer.log(
        'User identify error: $e',
        name: 'nuveli.analytics',
      );
    }
  }

  /// User properties — kalıcı kullanıcı meta data.
  static Future<void> setUserProperty(String name, String? value) async {
    try {
      if (_analytics != null) {
        await _analytics!.setUserProperty(name: name, value: value);
      }
    } catch (e) {
      developer.log(
        'User property error: $e',
        name: 'nuveli.analytics',
      );
    }
  }

  /// Logout — user reset.
  static Future<void> reset() async {
    try {
      if (_analytics != null) {
        await _analytics!.setUserId(id: null);
      }
    } catch (_) {}
  }
}

/// Standard event names — type-safe tracking.
///
/// Firebase event name kuralları:
/// - max 40 karakter
/// - sadece harf, rakam, alt çizgi
/// - rakamla başlayamaz
class AppEvent {
  AppEvent._();

  // Auth
  static const signupStarted = 'signup_started';
  static const signupCompleted = 'signup_completed';
  static const loginCompleted = 'login_completed';
  static const logoutCompleted = 'logout_completed';
  static const accountDeleted = 'account_deleted';

  // Onboarding
  static const onboardingStarted = 'onboarding_started';
  static const onboardingStepCompleted = 'onboarding_step_completed';
  static const onboardingCompleted = 'onboarding_completed';
  static const onboardingAbandoned = 'onboarding_abandoned';

  // Meal tracking
  static const mealCaptureOpened = 'meal_capture_opened';
  static const mealPhotoTaken = 'meal_photo_taken';
  static const mealAnalysisStarted = 'meal_analysis_started';
  static const mealAnalysisCompleted = 'meal_analysis_completed';
  static const mealAnalysisFailed = 'meal_analysis_failed';
  static const mealLogged = 'meal_logged';
  static const mealDeleted = 'meal_deleted';
  static const mealEdited = 'meal_edited';
  static const manualEntryUsed = 'manual_entry_used';

  // Coach
  static const coachOpened = 'coach_opened';
  static const coachMessageSent = 'coach_message_sent';
  static const coachAudioPlayed = 'coach_audio_played';
  static const crisisDetected = 'crisis_detected';

  // Premium
  static const paywallOpened = 'paywall_opened';
  static const paywallTrigger = 'paywall_trigger';
  static const trialOffered = 'trial_offered';
  static const trialAccepted = 'trial_accepted';
  static const trialDeclined = 'trial_declined';
  static const purchaseStarted = 'purchase_started';
  static const purchaseCompleted = 'purchase_completed';
  static const purchaseFailed = 'purchase_failed';
  static const purchaseRestored = 'purchase_restored';

  // Settings
  static const notificationPrefsChanged = 'notification_prefs_changed';
  static const supportContacted = 'support_contacted';

  // Errors / boundaries
  static const limitExceeded = 'limit_exceeded';
  static const errorScreenShown = 'error_screen_shown';
}

/// Standard prop keys — consistent naming.
class AppEventProp {
  AppEventProp._();

  static const mealType = 'meal_type';
  static const method = 'method';  // 'photo' | 'manual'
  static const success = 'success';
  static const errorCode = 'error_code';
  static const trigger = 'trigger';  // 'meal_limit' | 'coach_limit' | 'cta'
  static const persona = 'persona';  // 'compassionate' | 'gentle' | 'serious' | 'humor'
  static const stepName = 'step_name';
  static const productId = 'product_id';
  static const calories = 'calories';
  static const screenName = 'screen_name';
}
