import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  system('system', null, 'Sistem dili'),
  turkish('tr', Locale('tr'), 'Türkçe'),
  english('en', Locale('en'), 'English'),
  german('de', Locale('de'), 'Deutsch'),
  french('fr', Locale('fr'), 'Français'),
  spanish('es', Locale('es'), 'Español');

  final String code;
  final Locale? locale;
  final String label;
  const AppLanguage(this.code, this.locale, this.label);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.system,
    );
  }
}

const List<Locale> kSupportedLocales = [
  Locale('tr'), Locale('en'), Locale('de'), Locale('fr'), Locale('es'),
];
const Locale kFallbackLocale = Locale('en');
const String _prefsKey = 'app_language';

// ═══════════════════════════════════════════════════════════════════
// GLOBAL ValueNotifier — Riverpod'dan BAGIMSIZ
// Hicbir zaman dispose olmaz, hicbir provider onu sifirlamaz
// ═══════════════════════════════════════════════════════════════════
final ValueNotifier<AppLanguage> globalLanguageNotifier = 
    ValueNotifier<AppLanguage>(AppLanguage.system);

/// main.dart'tan cagirilir (runApp'tan ONCE)
Future<void> preloadLanguage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      globalLanguageNotifier.value = AppLanguage.fromCode(saved);
    }
  } catch (_) {}
}

/// Dil degistir (Settings'ten cagirilir)
Future<void> changeLanguage(AppLanguage language) async {
  globalLanguageNotifier.value = language;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  } catch (_) {}
}

// Riverpod provider (sadece Settings picker icin, opsiyonel)
final languageProvider = Provider<AppLanguage>((ref) {
  return globalLanguageNotifier.value;
});
