import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/auth/providers/auth_providers.dart';

import '../../_helpers/test_helpers.dart';

void main() {
  group('Auth state providers', () {
    test('authLoadingProvider defaults to false', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      expect(container.read(authLoadingProvider), false);
    });

    test('authErrorProvider defaults to null', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      expect(container.read(authErrorProvider), isNull);
    });

    test('authLoadingProvider can be set and read', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(authLoadingProvider.notifier).state = true;
      expect(container.read(authLoadingProvider), true);
    });

    test('authErrorProvider holds error message', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      const msg = 'Email veya şifre hatalı.';
      container.read(authErrorProvider.notifier).state = msg;
      expect(container.read(authErrorProvider), msg);
    });

    test('setting error to null clears it', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(authErrorProvider.notifier).state = 'some error';
      container.read(authErrorProvider.notifier).state = null;
      expect(container.read(authErrorProvider), isNull);
    });
  });

  group('onboardingCompletedProvider derived state', () {
    // Not: bootstrap FutureProvider'ı integration test'te gerçek backend
    // üzerinde test edilir. Burada sadece derived mantık zaten
    // bootstrap.when() üzerinden geçtiği için local test yapmıyoruz.
    test('placeholder — gerçek test integration seviyesinde', () {
      // Intentionally empty — documents test coverage boundary.
      expect(true, true);
    });
  });
}
