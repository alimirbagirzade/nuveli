// Deep-link validator.
//
// EVERY consumer of an incoming URL or route string MUST funnel through
// this class before letting it drive navigation. Two entry points:
//
//   1. `validateExternalUri`  — for URIs delivered by app_links / OS
//      intent (the user clicked a `nuveli://...` link in another app,
//      a browser, a malicious web page). These are the highest-risk
//      inputs.
//
//   2. `validateInternalRoute` — for `NotificationPayload.route`
//      strings written by our own scheduler. Lower risk (they came
//      from us) but still validated so a scheduler regression can't
//      navigate to arbitrary in-app screens.
//
// Both return a tagged `DeepLinkResult` so the caller can log a
// rejection reason without branching on exception types.
//
// Allowed-routes is a prefix list. `/dashboard` allows `/dashboard`
// and `/dashboard/water`, but not `/dashboards` (no false positive
// from naive `startsWith`). Path traversal and double-slashes are
// rejected so a hostile link can't escape the whitelist via `..`.

sealed class DeepLinkResult {
  const DeepLinkResult();

  /// Convenience accessors so callers don't always switch on type.
  bool get isAllowed => this is AllowedDeepLink;
  String? get rejectedReason =>
      this is RejectedDeepLink ? (this as RejectedDeepLink).reason : null;
}

class AllowedDeepLink extends DeepLinkResult {
  const AllowedDeepLink(this.path, this.extras);
  final String path;
  final Map<String, String> extras;
}

class RejectedDeepLink extends DeepLinkResult {
  const RejectedDeepLink(this.reason);
  final String reason;
}

class DeepLinkValidator {
  /// The custom URL scheme we accept (e.g. `nuveli://dashboard`).
  final String allowedScheme;

  /// Apex domain trusted for `https://` App Links / Universal Links.
  /// `null` disables https entirely. When set, both the apex and
  /// `www.` subdomain are accepted. Any other host (including
  /// look-alike subdomains like `nuveli.com.tr.attacker.com`) is
  /// rejected.
  final String? trustedHttpsHost;

  /// Exact route prefixes allowed. Paths that equal one of these or
  /// extend with `/segment` pass; anything else is rejected.
  final Set<String> allowedRoutes;

  const DeepLinkValidator({
    this.allowedScheme = 'nuveli',
    this.trustedHttpsHost = 'nuveli.com.tr',
    this.allowedRoutes = defaultAllowedRoutes,
  });

  /// Feature roots that exist in `lib/features/`. Add a new entry
  /// here when a feature ships a deep-link target. Keep this list
  /// tight — every entry is something an attacker can navigate into.
  static const Set<String> defaultAllowedRoutes = {
    '/',
    '/dashboard',
    '/meal',
    '/coach',
    '/premium',
    '/profile',
    '/settings',
    '/notifications',
  };

  /// Validate a URI handed to us by the OS (via app_links).
  DeepLinkResult validateExternalUri(Uri uri) {
    final isCustomScheme = uri.scheme == allowedScheme;
    final isTrustedHttps = uri.scheme == 'https' && _isTrustedHost(uri.host);

    if (!isCustomScheme && !isTrustedHttps) {
      return RejectedDeepLink(
        'disallowed scheme/host: ${uri.scheme}://${uri.host}',
      );
    }
    // Traversal can be hidden in several places:
    //   - `pathSegments` preserves '..' even when toString() normalizes
    //   - percent-encoded `%2e%2e` slips past segment matching
    //   - the original string may contain forms Dart never decoded
    if (uri.pathSegments.contains('..') ||
        uri.pathSegments.contains('.') ||
        _containsTraversal(uri.toString())) {
      return RejectedDeepLink('path traversal: $uri');
    }
    final path = _normalizePath(uri, isHttps: isTrustedHttps);
    return _validatePath(path, uri.queryParameters);
  }

  bool _isTrustedHost(String host) {
    final trusted = trustedHttpsHost;
    if (trusted == null) return false;
    return host == trusted || host == 'www.$trusted';
  }

  /// Validate a route string emitted by our own subsystems
  /// (notification payload, future push notifications, etc.).
  DeepLinkResult validateInternalRoute(String route) {
    if (route.isEmpty) {
      return const RejectedDeepLink('empty route');
    }
    // Raw-string guards before Dart's parser normalizes anything.
    if (_containsTraversal(route)) {
      return RejectedDeepLink('path traversal: $route');
    }
    if (route.startsWith('//')) {
      return RejectedDeepLink('protocol-relative path: $route');
    }
    Uri parsed;
    try {
      parsed = Uri.parse(route);
    } catch (_) {
      return const RejectedDeepLink('unparseable route');
    }
    if (parsed.scheme.isNotEmpty) {
      return RejectedDeepLink('internal route must not carry scheme: ${parsed.scheme}');
    }
    if (parsed.host.isNotEmpty) {
      return RejectedDeepLink('internal route must not carry host: ${parsed.host}');
    }
    final path = parsed.path;
    return _validatePath(path, parsed.queryParameters);
  }

  /// Detects `..` segment markers in either raw or percent-encoded form.
  static bool _containsTraversal(String s) {
    final lowered = s.toLowerCase();
    return lowered.contains('/..') ||
        lowered.contains('..//') ||
        lowered.contains('/%2e%2e') ||
        lowered.contains('%2e%2e/');
  }

  // --- helpers ---

  /// For `nuveli://dashboard/water` Dart's Uri parser puts "dashboard"
  /// in `host` and "/water" in `path` — we re-glue so the in-app
  /// route is `/dashboard/water`.
  ///
  /// For `https://nuveli.com.tr/dashboard/water` the host is a domain,
  /// NOT a route segment — we use the path verbatim.
  String _normalizePath(Uri uri, {required bool isHttps}) {
    if (isHttps) {
      return uri.path.isEmpty ? '/' : uri.path;
    }
    final host = uri.host;
    final path = uri.path;
    if (host.isEmpty) {
      return path.isEmpty ? '/' : path;
    }
    if (path.isEmpty) return '/$host';
    return '/$host$path';
  }

  DeepLinkResult _validatePath(String path, Map<String, String> extras) {
    if (!path.startsWith('/')) {
      return RejectedDeepLink('path must start with /: $path');
    }
    // Reject obvious traversal even though our route matcher would
    // already not find a match — defense in depth.
    if (path.contains('..') || path.contains('//')) {
      return RejectedDeepLink('path traversal: $path');
    }
    // Match by exact equality or "$prefix/" so `/dashboards` does NOT
    // satisfy `/dashboard`.
    final ok = allowedRoutes.any(
      (allowed) => path == allowed || path.startsWith('$allowed/'),
    );
    if (!ok) {
      return RejectedDeepLink('route not in allowlist: $path');
    }
    return AllowedDeepLink(path, Map<String, String>.from(extras));
  }
}
