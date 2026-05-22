// Pin test — every route the notification scheduler emits today MUST
// pass the validator. Without this, the next time someone adds a new
// scheduler route they discover their notifications silently break
// only at runtime, in production, after the router wires up.
//
// If this test ever fails, the fix is one of:
//   1. Add the new scheduler route to DeepLinkValidator.defaultAllowedRoutes
//   2. Change the scheduler to emit an existing allowlisted route
// — NOT to skip or weaken this test.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/routing/deep_link_validator.dart';

void main() {
  // Routes harvested by grep on notification_service.dart on 2026-05-22.
  // Source of truth: every `route: '...'` literal inside a
  // NotificationPayload(...) construction site.
  const schedulerEmittedRoutes = {
    '/water',
    '/meals/scan',
    '/habits',
    '/ai-coach',
    '/analytics',
  };

  test('every scheduler route is accepted by the default validator', () {
    const validator = DeepLinkValidator();
    final rejected = <String>[];
    for (final route in schedulerEmittedRoutes) {
      final result = validator.validateInternalRoute(route);
      if (result is RejectedDeepLink) {
        rejected.add('$route → ${result.reason}');
      }
    }
    expect(
      rejected,
      isEmpty,
      reason: 'Scheduler emits routes the validator rejects. '
          'Either expand DeepLinkValidator.defaultAllowedRoutes or fix '
          'the scheduler. Do not weaken this test.',
    );
  });

  test('nested scheduler routes (prefix match) work too', () {
    const validator = DeepLinkValidator();
    // /meals/scan should match /meals as a prefix, not require an
    // explicit /meals/scan allowlist entry.
    expect(
      validator.validateInternalRoute('/meals/scan'),
      isA<AllowedDeepLink>(),
    );
  });
}
