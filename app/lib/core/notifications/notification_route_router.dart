// Validates and dispatches `NotificationPayload` routes.
//
// Pairs with `DeepLinkListener` (lib/core/routing/) — together they form
// the single funnel through which ALL navigation-triggering inputs reach
// the router:
//
//   external URI    → DeepLinkListener → DeepLinkValidator → router
//   notification    → here              → DeepLinkValidator → router
//
// Both paths share the same validator, so the allowlist, traversal
// guards, and prefix-confusion rules apply uniformly. A notification
// scheduler that emits a route outside the allowlist (regression, bad
// migration, manual tampering) gets rejected here before anything
// navigates.

import 'package:flutter/foundation.dart';

import '../routing/deep_link_validator.dart';
import 'notification_payload.dart';

class NotificationRouteRouter {
  NotificationRouteRouter({
    required this.validator,
    this.onAllowed,
    void Function(String message)? logger,
  }) : _log = logger ?? ((_) {});

  final DeepLinkValidator validator;

  /// Called when the payload's route passes validation. The original
  /// payload is forwarded so the consumer keeps `type` and any extras
  /// that weren't expressible in the route string.
  final void Function(
    AllowedDeepLink link,
    NotificationPayload payload,
  )? onAllowed;

  final void Function(String) _log;

  /// `source` tags the breadcrumb so Crashlytics shows whether the
  /// payload came from a tap on a live notification ("tap") or from
  /// the OS-cached launch payload ("cold-start").
  void handle(NotificationPayload payload, {required String source}) {
    final result = validator.validateInternalRoute(payload.route);
    if (result is AllowedDeepLink) {
      _log(
        'notification.allowed source=$source path=${result.path} '
        'type=${payload.type.channelId}',
      );
      onAllowed?.call(result, payload);
    } else if (result is RejectedDeepLink) {
      _log(
        'notification.rejected source=$source route=${payload.route} '
        'reason=${result.reason}',
      );
      if (kDebugMode) {
        debugPrint(
          '[notification] REJECTED route="${payload.route}" '
          '→ ${result.reason}',
        );
      }
    }
  }
}
