import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/routing/deep_link_validator.dart';

void main() {
  late DeepLinkValidator validator;

  setUp(() {
    validator = const DeepLinkValidator();
  });

  group('validateExternalUri — happy paths', () {
    test('accepts nuveli://dashboard', () {
      final r = validator.validateExternalUri(Uri.parse('nuveli://dashboard'));
      expect(r, isA<AllowedDeepLink>());
      expect((r as AllowedDeepLink).path, equals('/dashboard'));
    });

    test('accepts nested route under a whitelisted prefix', () {
      final r = validator.validateExternalUri(
        Uri.parse('nuveli://dashboard/water'),
      );
      expect(r, isA<AllowedDeepLink>());
      expect((r as AllowedDeepLink).path, equals('/dashboard/water'));
    });

    test('captures query parameters as extras', () {
      final r = validator.validateExternalUri(
        Uri.parse('nuveli://meal?meal_id=abc-123&source=push'),
      );
      expect(r, isA<AllowedDeepLink>());
      final allowed = r as AllowedDeepLink;
      expect(allowed.path, equals('/meal'));
      expect(allowed.extras['meal_id'], equals('abc-123'));
      expect(allowed.extras['source'], equals('push'));
    });

    test('accepts root nuveli:/', () {
      final r = validator.validateExternalUri(Uri.parse('nuveli:/'));
      expect(r, isA<AllowedDeepLink>());
      expect((r as AllowedDeepLink).path, equals('/'));
    });
  });

  group('validateExternalUri — rejections', () {
    test('rejects http scheme (no Universal Links configured yet)', () {
      final r = validator.validateExternalUri(
        Uri.parse('https://attacker.com/dashboard'),
      );
      expect(r, isA<RejectedDeepLink>());
      expect(r.rejectedReason, contains('disallowed scheme'));
    });

    test('rejects an arbitrary custom scheme', () {
      final r = validator.validateExternalUri(Uri.parse('evil://dashboard'));
      expect(r, isA<RejectedDeepLink>());
    });

    test('rejects unknown route prefix', () {
      // The host segment of the URI is what determines the allowlist
      // match — `nuveli://admin` resolves to route `/admin`, which is
      // not in the default allowlist.
      final r = validator.validateExternalUri(Uri.parse('nuveli://admin'));
      expect(r, isA<RejectedDeepLink>());
      expect(r.rejectedReason, contains('allowlist'));
    });

    test('Dart normalises percent-encoded traversal in path component', () {
      // Documenting the actual behaviour: Dart's Uri parser resolves
      // both literal and percent-encoded dot-segments at parse time.
      // The validator's `_containsTraversal` check is defense-in-depth
      // for the day that changes — today, the allowlist is the active
      // guard. This test just pins the parser behaviour we depend on.
      expect(Uri.parse('nuveli://dashboard/../admin').path, equals('/admin'));
      expect(
        Uri.parse('nuveli://dashboard/%2E%2E/admin').path,
        equals('/admin'),
      );
    });

    test('does not allow prefix-confusion (/dashboards leaks)', () {
      // /dashboards should NOT match /dashboard via naive startsWith.
      final r = validator.validateExternalUri(
        Uri.parse('nuveli://dashboards'),
      );
      expect(r, isA<RejectedDeepLink>());
    });
  });

  group('validateInternalRoute — notification payloads', () {
    test('accepts a clean path', () {
      final r = validator.validateInternalRoute('/dashboard/water');
      expect(r, isA<AllowedDeepLink>());
      expect((r as AllowedDeepLink).path, equals('/dashboard/water'));
    });

    test('captures extras from query string', () {
      final r = validator.validateInternalRoute(
        '/meal?meal_id=42&type=lunch',
      );
      expect(r, isA<AllowedDeepLink>());
      final allowed = r as AllowedDeepLink;
      expect(allowed.extras['meal_id'], equals('42'));
      expect(allowed.extras['type'], equals('lunch'));
    });

    test('rejects empty route', () {
      final r = validator.validateInternalRoute('');
      expect(r, isA<RejectedDeepLink>());
      expect(r.rejectedReason, contains('empty'));
    });

    test('rejects route that smuggles a scheme', () {
      // If a scheduler bug emits "nuveli://x" we reject — internal
      // routes are paths only, never URIs.
      final r = validator.validateInternalRoute('nuveli://dashboard');
      expect(r, isA<RejectedDeepLink>());
      expect(r.rejectedReason, contains('scheme'));
    });

    test('rejects route with a foreign host', () {
      final r = validator.validateInternalRoute('//attacker.com/dashboard');
      expect(r, isA<RejectedDeepLink>());
    });

    test('rejects path traversal', () {
      final r = validator.validateInternalRoute('/dashboard/../settings');
      expect(r, isA<RejectedDeepLink>());
      expect(r.rejectedReason, contains('traversal'));
    });

    test('rejects path without leading slash', () {
      final r = validator.validateInternalRoute('dashboard');
      expect(r, isA<RejectedDeepLink>());
    });

    test('rejects unknown route', () {
      final r = validator.validateInternalRoute('/admin');
      expect(r, isA<RejectedDeepLink>());
      expect(r.rejectedReason, contains('allowlist'));
    });
  });

  group('configurable allowlist', () {
    test('respects a custom allowedScheme', () {
      const v = DeepLinkValidator(allowedScheme: 'custom');
      expect(
        v.validateExternalUri(Uri.parse('custom://dashboard')),
        isA<AllowedDeepLink>(),
      );
      expect(
        v.validateExternalUri(Uri.parse('nuveli://dashboard')),
        isA<RejectedDeepLink>(),
      );
    });

    test('respects a custom allowedRoutes set', () {
      const v = DeepLinkValidator(allowedRoutes: {'/only'});
      expect(
        v.validateInternalRoute('/only/x'),
        isA<AllowedDeepLink>(),
      );
      expect(
        v.validateInternalRoute('/dashboard'),
        isA<RejectedDeepLink>(),
      );
    });
  });

  group('DeepLinkResult convenience accessors', () {
    test('isAllowed flag is correct', () {
      expect(
        const AllowedDeepLink('/x', {}).isAllowed,
        isTrue,
      );
      expect(
        const RejectedDeepLink('nope').isAllowed,
        isFalse,
      );
    });

    test('rejectedReason returns reason only when rejected', () {
      expect(const AllowedDeepLink('/x', {}).rejectedReason, isNull);
      expect(const RejectedDeepLink('nope').rejectedReason, equals('nope'));
    });
  });
}
