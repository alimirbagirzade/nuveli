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

    test('success() does not throw and waits for sequence', () async {
      final stopwatch = Stopwatch()..start();
      await AppHaptics.success();
      stopwatch.stop();
      // success() iki impact + 80ms delay yapar
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(80));
    });

    test('error() does not throw and waits for sequence', () async {
      final stopwatch = Stopwatch()..start();
      await AppHaptics.error();
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(60));
    });

    test('warning() does not throw and waits for sequence', () async {
      final stopwatch = Stopwatch()..start();
      await AppHaptics.warning();
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });
  });
}
