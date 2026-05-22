// Deep-link listener.
//
// Subscribes to incoming URIs from `app_links` (both cold-start and
// while-running), runs every URI through `DeepLinkValidator`, and:
//   - emits an `AllowedDeepLink` to the optional `onAllowed` callback
//     when the router is ready to navigate;
//   - logs every result via CrashReporter so rejections are visible
//     in Crashlytics breadcrumbs even before a router is wired.
//
// Today no router consumes this — paths #99, #102, and #103 built the
// validator + native config + assetlinks.json, but Flutter still has
// no go_router. When Chat 17 routing lands, wiring becomes a one-liner:
//
//     DeepLinkListener(
//       validator: const DeepLinkValidator(),
//       onAllowed: (link) => router.go(link.path, extra: link.extras),
//     ).start();
//
// Until then, the listener still earns its keep — it tells Crashlytics
// when a user tapped a link and how the validator decided. If we ever
// ship a bad allowlist or a route never reaches the user, the logs
// say so.

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../monitoring/crash_reporter.dart';
import 'deep_link_validator.dart';

class DeepLinkListener {
  DeepLinkListener({
    required this.validator,
    this.onAllowed,
    Future<Uri?> Function()? getInitialLink,
    Stream<Uri> Function()? linkStream,
  })  : _getInitialLink = getInitialLink ?? AppLinks().getInitialLink,
        _linkStream = linkStream ?? (() => AppLinks().uriLinkStream);

  final DeepLinkValidator validator;

  /// Called for each URI that passes validation. Null when the router
  /// isn't wired yet — listener still validates and logs.
  final void Function(AllowedDeepLink link)? onAllowed;

  final Future<Uri?> Function() _getInitialLink;
  final Stream<Uri> Function() _linkStream;

  StreamSubscription<Uri>? _subscription;
  bool _started = false;

  /// Begin listening. Idempotent — calling twice is a no-op.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    // Cold-start link: was the app launched via a URI?
    try {
      final initial = await _getInitialLink();
      if (initial != null) {
        _handle(initial, source: 'cold-start');
      }
    } catch (e, st) {
      // Don't let a busted initial-link query block app startup.
      await CrashReporter.report(
        e,
        st,
        feature: 'deep_link',
        action: 'initial_link',
      );
    }

    _subscription = _linkStream().listen(
      (uri) => _handle(uri, source: 'stream'),
      onError: (Object error, StackTrace st) {
        CrashReporter.report(
          error,
          st,
          feature: 'deep_link',
          action: 'stream',
        );
      },
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
  }

  void _handle(Uri uri, {required String source}) {
    final result = validator.validateExternalUri(uri);
    if (result is AllowedDeepLink) {
      CrashReporter.log(
        'deep_link.allowed source=$source path=${result.path} '
        'extras=${result.extras.length}',
      );
      onAllowed?.call(result);
    } else if (result is RejectedDeepLink) {
      // Rejections are interesting — could be an attack attempt, a
      // misconfigured external link, or our own allowlist drifting
      // out of sync with the routes we actually have.
      CrashReporter.log(
        'deep_link.rejected source=$source uri=$uri '
        'reason=${result.reason}',
      );
      if (kDebugMode) {
        debugPrint('[deep_link] REJECTED: $uri → ${result.reason}');
      }
    }
  }
}
