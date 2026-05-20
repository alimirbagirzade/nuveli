import 'package:flutter/material.dart';

// TODO(chat-19): Firebase Analytics eklenince uncomment:
// import 'package:firebase_analytics/firebase_analytics.dart';

/// Navigation event'lerini hem debug log'lar hem analytics'e gönderir.
class NuveliRouteObserver extends NavigatorObserver {
  // final _analytics = FirebaseAnalytics.instance;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('PUSH', route);
    _send(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('POP', route);
    if (previousRoute != null) _send(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _log('REPLACE', newRoute);
      _send(newRoute);
    }
  }

  void _log(String action, Route<dynamic> route) {
    final name = route.settings.name ?? route.runtimeType.toString();
    debugPrint('[Router] $action: $name');
  }

  void _send(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    // _analytics.logScreenView(screenName: name);  // chat-19
  }
}
