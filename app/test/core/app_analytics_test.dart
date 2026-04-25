import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/analytics/app_analytics.dart';

void main() {
  group('AppEvent constants', () {
    test('all event names are valid Firebase format', () {
      // Firebase kuralı: max 40 karakter, snake_case, harf ile başlar
      const events = [
        AppEvent.signupStarted,
        AppEvent.signupCompleted,
        AppEvent.loginCompleted,
        AppEvent.logoutCompleted,
        AppEvent.accountDeleted,
        AppEvent.onboardingStarted,
        AppEvent.onboardingStepCompleted,
        AppEvent.onboardingCompleted,
        AppEvent.onboardingAbandoned,
        AppEvent.mealCaptureOpened,
        AppEvent.mealPhotoTaken,
        AppEvent.mealAnalysisStarted,
        AppEvent.mealAnalysisCompleted,
        AppEvent.mealAnalysisFailed,
        AppEvent.mealLogged,
        AppEvent.mealDeleted,
        AppEvent.mealEdited,
        AppEvent.manualEntryUsed,
        AppEvent.coachOpened,
        AppEvent.coachMessageSent,
        AppEvent.coachAudioPlayed,
        AppEvent.crisisDetected,
        AppEvent.paywallOpened,
        AppEvent.paywallTrigger,
        AppEvent.trialOffered,
        AppEvent.trialAccepted,
        AppEvent.trialDeclined,
        AppEvent.purchaseStarted,
        AppEvent.purchaseCompleted,
        AppEvent.purchaseFailed,
        AppEvent.purchaseRestored,
        AppEvent.notificationPrefsChanged,
        AppEvent.supportContacted,
        AppEvent.limitExceeded,
        AppEvent.errorScreenShown,
      ];

      for (final event in events) {
        // 40 karakter sınırı
        expect(
          event.length,
          lessThanOrEqualTo(40),
          reason: '$event > 40 chars',
        );

        // Sadece alfanumerik + underscore
        expect(
          RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(event),
          true,
          reason: '$event invalid format',
        );

        // Uppercase yasak
        expect(
          event.toLowerCase(),
          event,
          reason: '$event has uppercase',
        );
      }
    });

    test('all event names are unique', () {
      const events = {
        AppEvent.signupStarted,
        AppEvent.signupCompleted,
        AppEvent.loginCompleted,
        AppEvent.logoutCompleted,
        AppEvent.mealLogged,
        AppEvent.coachMessageSent,
        AppEvent.paywallOpened,
        AppEvent.trialAccepted,
        AppEvent.purchaseCompleted,
      };

      // Set'te unique olduğu için aynı sayıda eleman olmalı
      expect(events.length, 9);
    });
  });

  group('AppEventProp constants', () {
    test('all prop keys are snake_case', () {
      const props = [
        AppEventProp.mealType,
        AppEventProp.method,
        AppEventProp.success,
        AppEventProp.errorCode,
        AppEventProp.trigger,
        AppEventProp.persona,
        AppEventProp.stepName,
        AppEventProp.productId,
        AppEventProp.calories,
        AppEventProp.screenName,
      ];

      for (final prop in props) {
        expect(
          RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(prop),
          true,
          reason: '$prop invalid format',
        );
      }
    });
  });

  group('AppAnalytics methods', () {
    test('track() does not throw without Firebase', () async {
      // Firebase init edilmediği test ortamında, fallback console olmalı
      await expectLater(
        AppAnalytics.track('test_event'),
        completes,
      );
    });

    test('track() with props does not throw', () async {
      await expectLater(
        AppAnalytics.track(
          'test_event',
          props: {
            'meal_type': 'breakfast',
            'calories': 500,
          },
        ),
        completes,
      );
    });

    test('trackScreen() does not throw', () async {
      await expectLater(
        AppAnalytics.trackScreen('test_screen'),
        completes,
      );
    });

    test('identifyUser() does not throw', () async {
      await expectLater(
        AppAnalytics.identifyUser('test-user-id'),
        completes,
      );
    });

    test('setUserProperty() does not throw', () async {
      await expectLater(
        AppAnalytics.setUserProperty('persona', 'compassionate'),
        completes,
      );
    });

    test('reset() does not throw', () async {
      await expectLater(AppAnalytics.reset(), completes);
    });
  });
}
