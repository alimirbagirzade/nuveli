// lib/core/i18n/language_provider.dart
//
// Dil yonetimi:
// - Sistem dilini otomatik algilar
// - Kullanici manuel sectiyse override eder
// - SharedPreferences ile kaydeder (yeniden acilista hatirlar)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Desteklenen diller
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

/// Sistemde desteklenen tum locale'lar (MaterialApp.supportedLocales)
const List<Locale> kSupportedLocales = [
  Locale('tr'),
  Locale('en'),
  Locale('de'),
  Locale('fr'),
  Locale('es'),
];

/// Default fallback dil (sistem dili desteklenmiyorsa)
const Locale kFallbackLocale = Locale('en');

const String _prefsKey = 'app_language';

class LanguageController extends StateNotifier<AppLanguage> {
  LanguageController() : super(AppLanguage.system) {
    _loadSavedLanguage();
  }

  bool _initialized = false;

  Future<void> _loadSavedLanguage() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null) {
        state = AppLanguage.fromCode(saved);
      }
      _initialized = true;
    } catch (e) {
      // SharedPreferences hatasi durumunda system dili kullan
      _initialized = true;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    _initialized = true;  // manuel set sonrasi initialized say
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, language.code);
    } catch (e) {
      // Save fail olsa bile state degisti
    }
  }

  /// MaterialApp.locale icin kullanilir
  /// null donerse sistem dili kullanilir
  Locale? get effectiveLocale => state.locale;
}

final languageProvider =
    StateNotifierProvider<LanguageController, AppLanguage>((ref) {
  return LanguageController();
});

/// Sistem dilini en uygun supported locale'a maple
/// Mesela: iPhone "tr" ise tr, "de" ise de, "ja" ise en (fallback)
Locale resolveSystemLocale(Locale? deviceLocale, Iterable<Locale> supported) {
  if (deviceLocale == null) return kFallbackLocale;

  // Tam eslesme: tr_TR -> tr
  for (final supportedLocale in supported) {
    if (supportedLocale.languageCode == deviceLocale.languageCode) {
      return supportedLocale;
    }
  }

  // Eslesme yoksa fallback
  return kFallbackLocale;
}
