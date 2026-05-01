import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bir widget'ı tam uygulama context'i ile test etmek için yardımcı.
/// MaterialApp + ProviderScope wrapping'ini her testte tekrar yazmayı engeller.
Future<void> pumpWithProviders(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme,
        home: widget,
        // TR locale — test'ler TR metinleri doğrular
        locale: const Locale('tr'),
      ),
    ),
  );
}

/// Scaffold gerektiren bir widget'ı (örneğin AppBar) test ederken
/// Scaffold wrapping yapar.
Future<void> pumpScaffoldWithProviders(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: widget),
      ),
    ),
  );
}
