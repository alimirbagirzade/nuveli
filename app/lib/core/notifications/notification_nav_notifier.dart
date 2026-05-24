import 'package:flutter/foundation.dart';

/// Minimal notification-tap → bottom-nav tab bridge.
///
/// When a notification is tapped the payload carries a `route` string
/// (e.g. `/coach`, `/dashboard`). `NotificationRouteRouter.handle`
/// validates the route, then calls [navigateToTab] with the resolved
/// tab index. `MainShellScreen` listens to [tabIndex] and switches the
/// active tab accordingly.
///
/// Intentionally lightweight — one `ValueNotifier`, no Riverpod, no
/// go_router. The only thing it does is switch tabs. Unknown routes are
/// no-ops. Fully reversible: remove `_notificationNavNotifier.navigateToTab`
/// call from `NotificationRouteRouter` to disable the feature.
///
/// Tab mapping (mirrors `MainShellScreen` `IndexedStack` order):
///   0 → /dashboard
///   1 → /scan  (MealScanScreen)
///   2 → /coach
///   3 → /analytics
///   4 → /profile
///   5 → /settings
class NotificationNavNotifier {
  NotificationNavNotifier._();

  static final NotificationNavNotifier instance =
      NotificationNavNotifier._();

  /// Emits a non-null value when a notification tap requests a tab switch.
  /// Resets to `null` after `MainShellScreen` consumes the value so it
  /// doesn't re-trigger on rebuild.
  final ValueNotifier<int?> tabIndex = ValueNotifier<int?>(null);

  static const Map<String, int> _routeToTab = {
    '/dashboard': 0,
    '/scan': 1,
    '/coach': 2,
    '/analytics': 3,
    '/profile': 4,
    '/settings': 5,
  };

  /// Called by `NotificationRouteRouter` after a route passes validation.
  /// Maps the route path to a tab index and emits it. No-ops if the
  /// route is not in [_routeToTab].
  void navigateToTab(String path) {
    // Normalise: strip trailing slash, match on prefix (e.g. /dashboard/water → tab 0)
    for (final entry in _routeToTab.entries) {
      if (path == entry.key || path.startsWith('${entry.key}/')) {
        tabIndex.value = entry.value;
        return;
      }
    }
    // Unknown route — no-op as specified.
  }

  /// Called by `MainShellScreen` after consuming the tab-switch request.
  void consume() => tabIndex.value = null;
}
