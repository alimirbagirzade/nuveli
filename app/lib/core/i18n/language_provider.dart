import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  system('system', null, 'Sistem dili'),
  turkish('tr', Locale('tr'), 'Türkçe'),
  english('en', Locale('en'), 'English'),
  german('de', Locale('de'), 'Deutsch'),
  french('fr', Locale('fr'), 'Français'),
  spanish('es', Locale('es'), 'Español'),
  russian('ru', Locale('ru'), 'Русский'),
  italian('it', Locale('it'), 'Italiano');

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
  Locale('tr'), Locale('en'), Locale('de'), Locale('fr'), Locale('es'), Locale('ru'), Locale('it'),
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

/// Fire-and-forget backend PATCH for a language code. Injected by the
/// Settings screen so this file stays free of Dio/Riverpod imports.
/// Errors are swallowed — local state (globalLanguageNotifier) is the
/// source of truth; the backend update is best-effort.
typedef PatchLanguageCallback = Future<void> Function(String languageCode);

/// Dil degistir (Settings'ten cagirilir).
///
/// [patchBackend] is optional. When provided the resolved language code
/// is sent to PATCH /me {"language": code} as a fire-and-forget call.
/// Pass it from the Settings screen via [ref.read(authedDioProvider)].
/// For AppLanguage.system the device locale code is sent (or the call
/// is skipped if the device locale cannot be resolved).
Future<void> changeLanguage(
  AppLanguage language, {
  PatchLanguageCallback? patchBackend,
}) async {
  globalLanguageNotifier.value = language;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  } catch (_) {}

  if (patchBackend != null) {
    // For system locale we send the actual device locale code (e.g. "en").
    // If it can't be resolved we skip the backend call.
    final code = language != AppLanguage.system
        ? language.code
        : _resolvedSystemCode();
    if (code != null) {
      // Fire-and-forget — ignore all errors; local notifier stays SoT.
      patchBackend(code).catchError((_) {});
    }
  }
}

/// Returns the two-letter language code of the current device locale, or
/// null if it can't be determined.
String? _resolvedSystemCode() {
  try {
    final tag = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return tag.isNotEmpty ? tag : null;
  } catch (_) {
    return null;
  }
}

// Riverpod provider (sadece Settings picker icin, opsiyonel)
final languageProvider = Provider<AppLanguage>((ref) {
  return globalLanguageNotifier.value;
});
