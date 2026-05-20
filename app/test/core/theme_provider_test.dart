// Unit tests for NuveliThemeMode + ThemeNotifier (SharedPreferences-
// backed). Uses SharedPreferences.setMockInitialValues so we don't
// touch the platform plugin.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NuveliThemeMode enum', () {
    test('materialMode maps each value to the right ThemeMode', () {
      expect(NuveliThemeMode.system.materialMode, ThemeMode.system);
      expect(NuveliThemeMode.dark.materialMode, ThemeMode.dark);
    });

    test('label is non-empty and unique', () {
      final labels = NuveliThemeMode.values.map((m) => m.label).toList();
      expect(labels.length, 2);
      expect(labels.toSet().length, 2, reason: 'labels collide');
      for (final l in labels) {
        expect(l, isNotEmpty);
      }
    });

    test('icon is set for every value', () {
      for (final m in NuveliThemeMode.values) {
        expect(m.icon, isA<IconData>());
      }
    });
  });

  group('ThemeNotifier persistence', () {
    setUp(() {
      // Start every test with a clean prefs slate.
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('default initial state is dark (until _load completes)', () {
      final notifier = ThemeNotifier();
      // Synchronous part of the constructor: dark.
      expect(notifier.state, NuveliThemeMode.dark);
    });

    test('setMode persists the value + flips state', () async {
      final notifier = ThemeNotifier();
      await notifier.setMode(NuveliThemeMode.system);
      expect(notifier.state, NuveliThemeMode.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('nuveli_theme_mode'), 'system');
    });

    test('_load picks up a previously-saved value', () async {
      SharedPreferences.setMockInitialValues({
        'nuveli_theme_mode': 'system',
      });
      final notifier = ThemeNotifier();
      // Allow the async _load() to complete.
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state, NuveliThemeMode.system);
    });

    test('_load with garbage value falls back to dark', () async {
      SharedPreferences.setMockInitialValues({
        'nuveli_theme_mode': 'sparkles_mode_that_does_not_exist',
      });
      final notifier = ThemeNotifier();
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state, NuveliThemeMode.dark);
    });
  });
}
