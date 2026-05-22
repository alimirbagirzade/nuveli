import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/notifications/notification_payload.dart';
import 'package:nuveli/core/notifications/notification_route_router.dart';
import 'package:nuveli/core/notifications/notification_types.dart';
import 'package:nuveli/core/routing/deep_link_validator.dart';

NotificationPayload _payload(String route, {Map<String, dynamic>? extras}) {
  return NotificationPayload(
    type: NotificationType.fromString('water'),
    route: route,
    extras: extras ?? const {},
  );
}

void main() {
  group('allowed routes', () {
    test('valid route fires onAllowed with the validator path and the payload',
        () {
      AllowedDeepLink? receivedLink;
      NotificationPayload? receivedPayload;
      final router = NotificationRouteRouter(
        validator: const DeepLinkValidator(),
        onAllowed: (link, payload) {
          receivedLink = link;
          receivedPayload = payload;
        },
      );

      final payload = _payload('/dashboard/water');
      router.handle(payload, source: 'tap');

      expect(receivedLink?.path, equals('/dashboard/water'));
      expect(receivedPayload, same(payload));
    });

    test('routes with query strings carry extras through to the link', () {
      AllowedDeepLink? received;
      final router = NotificationRouteRouter(
        validator: const DeepLinkValidator(),
        onAllowed: (link, _) => received = link,
      );

      router.handle(_payload('/meal?meal_id=42'), source: 'cold-start');

      expect(received?.extras['meal_id'], equals('42'));
    });

    test('logger receives a structured allowed breadcrumb', () {
      final logs = <String>[];
      final router = NotificationRouteRouter(
        validator: const DeepLinkValidator(),
        logger: logs.add,
      );

      router.handle(_payload('/meal'), source: 'tap');

      expect(logs, hasLength(1));
      expect(logs.first, contains('notification.allowed'));
      expect(logs.first, contains('source=tap'));
      expect(logs.first, contains('path=/meal'));
    });
  });

  group('rejected routes', () {
    test('route outside allowlist does NOT fire onAllowed', () {
      var called = false;
      final router = NotificationRouteRouter(
        validator: const DeepLinkValidator(),
        onAllowed: (_, __) => called = true,
      );

      router.handle(_payload('/admin'), source: 'tap');

      expect(called, isFalse);
    });

    test('rejected route surfaces reason in the breadcrumb', () {
      final logs = <String>[];
      final router = NotificationRouteRouter(
        validator: const DeepLinkValidator(),
        logger: logs.add,
      );

      router.handle(_payload('/admin'), source: 'tap');

      expect(logs, hasLength(1));
      expect(logs.first, contains('notification.rejected'));
      expect(logs.first, contains('allowlist'));
    });

    test('scheme-smuggling route is rejected', () {
      var called = false;
      final logs = <String>[];
      final router = NotificationRouteRouter(
        validator: const DeepLinkValidator(),
        onAllowed: (_, __) => called = true,
        logger: logs.add,
      );

      // A scheduler regression that emits a full URI in `route` must
      // not be allowed to bypass validation.
      router.handle(_payload('nuveli://dashboard'), source: 'tap');

      expect(called, isFalse);
      expect(logs.single, contains('rejected'));
    });

    test('empty route is rejected', () {
      var called = false;
      final router = NotificationRouteRouter(
        validator: const DeepLinkValidator(),
        onAllowed: (_, __) => called = true,
      );
      router.handle(_payload(''), source: 'tap');
      expect(called, isFalse);
    });

    test('traversal route is rejected', () {
      var called = false;
      final router = NotificationRouteRouter(
        validator: const DeepLinkValidator(),
        onAllowed: (_, __) => called = true,
      );
      router.handle(_payload('/dashboard/../settings'), source: 'tap');
      expect(called, isFalse);
    });
  });

  test('default logger is a no-op (does not crash)', () {
    final router = NotificationRouteRouter(
      validator: const DeepLinkValidator(),
    );
    router.handle(_payload('/dashboard'), source: 'tap');
  });
}
