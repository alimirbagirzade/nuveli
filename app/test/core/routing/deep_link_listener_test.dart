import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/routing/deep_link_listener.dart';
import 'package:nuveli/core/routing/deep_link_validator.dart';

DeepLinkListener _build({
  Future<Uri?> Function()? getInitial,
  Stream<Uri> Function()? stream,
  void Function(AllowedDeepLink)? onAllowed,
  DeepLinkValidator? validator,
}) {
  return DeepLinkListener(
    validator: validator ?? const DeepLinkValidator(),
    onAllowed: onAllowed,
    getInitialLink: getInitial ?? (() async => null),
    linkStream: stream ?? (() => const Stream<Uri>.empty()),
  );
}

void main() {
  group('cold-start', () {
    test('valid initial link fires onAllowed', () async {
      AllowedDeepLink? received;
      final l = _build(
        getInitial: () async => Uri.parse('nuveli://dashboard'),
        onAllowed: (link) => received = link,
      );

      await l.start();

      expect(received, isNotNull);
      expect(received!.path, equals('/dashboard'));
      await l.dispose();
    });

    test('invalid initial link does NOT fire onAllowed', () async {
      var called = false;
      final l = _build(
        getInitial: () async => Uri.parse('http://attacker.com/dashboard'),
        onAllowed: (_) => called = true,
      );

      await l.start();

      expect(called, isFalse);
      await l.dispose();
    });

    test('null initial link is a no-op', () async {
      var called = false;
      final l = _build(
        getInitial: () async => null,
        onAllowed: (_) => called = true,
      );

      await l.start();

      expect(called, isFalse);
      await l.dispose();
    });

    test('initial-link throw does not propagate', () async {
      final l = _build(
        getInitial: () => Future.error(StateError('platform channel blew up')),
      );

      // Must not throw — startup should survive a broken platform call.
      await l.start();
      await l.dispose();
    });
  });

  group('stream', () {
    test('valid stream link fires onAllowed', () async {
      final controller = StreamController<Uri>();
      AllowedDeepLink? received;
      final l = _build(
        stream: () => controller.stream,
        onAllowed: (link) => received = link,
      );

      await l.start();
      controller.add(Uri.parse('nuveli://meal?meal_id=42'));
      await Future<void>.delayed(Duration.zero);

      expect(received, isNotNull);
      expect(received!.path, equals('/meal'));
      expect(received!.extras['meal_id'], equals('42'));

      await l.dispose();
      await controller.close();
    });

    test('rejected stream link does NOT fire onAllowed', () async {
      final controller = StreamController<Uri>();
      var called = false;
      final l = _build(
        stream: () => controller.stream,
        onAllowed: (_) => called = true,
      );

      await l.start();
      controller.add(Uri.parse('nuveli://admin'));
      await Future<void>.delayed(Duration.zero);

      expect(called, isFalse);

      await l.dispose();
      await controller.close();
    });

    test('stream error does not crash the listener', () async {
      final controller = StreamController<Uri>();
      AllowedDeepLink? received;
      final l = _build(
        stream: () => controller.stream,
        onAllowed: (link) => received = link,
      );

      await l.start();
      controller.addError(StateError('platform stream blew up'));
      await Future<void>.delayed(Duration.zero);

      // Same subscription must still be alive after the error.
      controller.add(Uri.parse('nuveli://dashboard'));
      await Future<void>.delayed(Duration.zero);
      expect(received?.path, equals('/dashboard'));

      await l.dispose();
      await controller.close();
    });

    test('multiple stream links each fire onAllowed', () async {
      final controller = StreamController<Uri>();
      final received = <String>[];
      final l = _build(
        stream: () => controller.stream,
        onAllowed: (link) => received.add(link.path),
      );

      await l.start();
      controller.add(Uri.parse('nuveli://dashboard'));
      controller.add(Uri.parse('nuveli://meal'));
      controller.add(Uri.parse('nuveli://coach'));
      await Future<void>.delayed(Duration.zero);

      expect(received, equals(['/dashboard', '/meal', '/coach']));

      await l.dispose();
      await controller.close();
    });
  });

  group('lifecycle', () {
    test('start() is idempotent — calling twice does not double-subscribe',
        () async {
      var subscriptions = 0;
      Stream<Uri> factory() {
        subscriptions++;
        return const Stream<Uri>.empty();
      }

      final l = _build(stream: factory);
      await l.start();
      await l.start();

      expect(subscriptions, equals(1));
      await l.dispose();
    });

    test('dispose() cancels the subscription', () async {
      final controller = StreamController<Uri>();
      var received = 0;
      final l = _build(
        stream: () => controller.stream,
        onAllowed: (_) => received++,
      );

      await l.start();
      controller.add(Uri.parse('nuveli://dashboard'));
      await Future<void>.delayed(Duration.zero);
      expect(received, equals(1));

      await l.dispose();
      controller.add(Uri.parse('nuveli://meal'));
      await Future<void>.delayed(Duration.zero);
      expect(received, equals(1), reason: 'no more callbacks after dispose');

      await controller.close();
    });

    test('start() after dispose() reattaches', () async {
      final controller = StreamController<Uri>.broadcast();
      var received = 0;
      final l = _build(
        stream: () => controller.stream,
        onAllowed: (_) => received++,
      );

      await l.start();
      await l.dispose();
      await l.start();

      controller.add(Uri.parse('nuveli://dashboard'));
      await Future<void>.delayed(Duration.zero);
      expect(received, equals(1));

      await l.dispose();
      await controller.close();
    });
  });
}
