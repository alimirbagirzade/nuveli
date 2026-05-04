import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NuveliThemeMode {
  system,
  dark;

  ThemeMode get materialMode {
    switch (this) {
      case NuveliThemeMode.system:
        return ThemeMode.system;
      case NuveliThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  String get label {
    switch (this) {
      case NuveliThemeMode.system:
        return 'Sistem ayari';
      case NuveliThemeMode.dark:
        return 'Koyu (Gece)';
    }
  }

  IconData get icon {
    switch (this) {
      case NuveliThemeMode.system:
        return Icons.brightness_auto;
      case NuveliThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}

class ThemeNotifier extends StateNotifier<NuveliThemeMode> {
  ThemeNotifier() : super(NuveliThemeMode.dark) {
    _load();
  }

  static const _key = 'nuveli_theme_mode';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null) {
        state = NuveliThemeMode.values.firstWhere(
          (m) => m.name == saved,
          orElse: () => NuveliThemeMode.dark,
        );
      }
    } catch (_) {}
  }

  Future<void> setMode(NuveliThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {}
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, NuveliThemeMode>(
  (ref) => ThemeNotifier(),
);
