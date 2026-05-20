import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/utils/app_haptics.dart';

void main() {
  // Haptic feedback test ortamında SystemChannels.platform mock'lanmazsa
  // exception fırlatabilir. Try-catch ile saramazsak test başarısız olur.
  // Bizim implementation zaten try-catch ile sarılı, hatasız tamamlanır.

  group('AppHaptics', () {
    test('light() does not throw', () async {
      await expectLater(AppHaptics.light(), completes);
    });

    test('medium() does not throw', () async {
      await expectLater(AppHaptics.medium(), completes);
    });

    test('heavy() does not throw', () async {
      await expectLater(AppHaptics.heavy(), completes);
    });

    test('selection() does not throw', () async {
      await expectLater(AppHaptics.selection(), completes);
    });

    // Sequence helpers (success/error/warning) chain multiple HapticFeedback
    // calls with Future.delayed gaps in between. In a test environment the
    // platform channel for HapticFeedback isn't mocked, so the implementation's
    // own try/catch swallows the call and the delays don't run — stopwatch
    // reads ~0ms. The right shape of test here is "this never throws"; an
    // on-device golden test would assert the timing.
    test('success() does not throw', () async {
      await expectLater(AppHaptics.success(), completes);
    });

    test('error() does not throw', () async {
      await expectLater(AppHaptics.error(), completes);
    });

    test('warning() does not throw', () async {
      await expectLater(AppHaptics.warning(), completes);
    });
  });
}
