// Widget tests for AppErrorView — locks the per-AppError-subclass
// icon + title mapping so polish work elsewhere doesn't drift it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/network/app_error.dart';
import 'package:nuveli/shared/widgets/app_error_view.dart';

void main() {
  Widget _wrap(AppError error, {VoidCallback? onRetry}) => MaterialApp(
        home: Scaffold(
          body: AppErrorView(error: error, onRetry: onRetry),
        ),
      );

  group('AppErrorView — icon + title mapping per subclass', () {
    final cases = <(AppError, IconData, String)>[
      (AppError.network(), Icons.wifi_off_outlined, 'İnternet yok'),
      (AppError.coldStart(), Icons.cloud_outlined, 'Sunucu uyanıyor'),
      (AppError.auth(), Icons.lock_outline, 'Oturum gerekli'),
      (AppError.forbidden(), Icons.block_outlined, 'Yetkin yok'),
      (AppError.notFound(), Icons.search_off_outlined, 'Bulunamadı'),
      (AppError.validation(), Icons.warning_amber_outlined, 'Bilgileri kontrol et'),
      (AppError.limitExceeded('hi'), Icons.hourglass_bottom_outlined, 'Limit aşıldı'),
      (AppError.server(), Icons.cloud_off_outlined, 'Sunucu hatası'),
      (AppError.unknown(), Icons.error_outline, 'Bir şey ters gitti'),
    ];

    for (final (error, icon, title) in cases) {
      testWidgets('${error.runtimeType} → $icon + "$title"', (tester) async {
        await tester.pumpWidget(_wrap(error));
        expect(find.byIcon(icon), findsOneWidget);
        expect(find.text(title), findsOneWidget);
      });
    }
  });

  group('AppErrorView — retry behaviour', () {
    testWidgets('no retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(_wrap(AppError.network()));
      expect(find.text('Tekrar dene'), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('retry button visible + fires callback when onRetry provided',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(AppError.server(), onRetry: () => taps++),
      );
      final retry = find.text('Tekrar dene');
      expect(retry, findsOneWidget);

      await tester.tap(retry);
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('AppErrorView — body message', () {
    testWidgets('LimitExceededError surfaces the backend message verbatim',
        (tester) async {
      await tester.pumpWidget(
        _wrap(AppError.limitExceeded('Günde 3 analiz hakkın bitti.')),
      );
      expect(find.text('Günde 3 analiz hakkın bitti.'), findsOneWidget);
    });

    testWidgets('ValidationError uses provided detail message', (tester) async {
      await tester.pumpWidget(
        _wrap(AppError.validation('value is not a valid email')),
      );
      expect(find.text('value is not a valid email'), findsOneWidget);
    });
  });
}
