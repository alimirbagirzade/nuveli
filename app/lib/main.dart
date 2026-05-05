import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/notifications/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'core/i18n/language_provider.dart';


Future<void> main() async {
  // Tüm initialization VE runApp aynı Zone içinde çalışmalı.
  // Aksi halde Flutter "Zone mismatch" warning verir ve callback'lerde
  // hard-to-debug Zone-specific davranış farkları oluşabilir.
  // Reference: https://docs.flutter.dev/testing/errors
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Dili ONCEDEN yukle (race condition onleme)
    await preloadLanguage();

  // Notification service'i baslat (hata olursa devam et)
  try {
    await NotificationService.initialize();
  } catch (e) {
    print('⚠️  Notification init failed: $e');
  }
    // Production config validation (non-fatal warning)
    if (AppConfig.isProduction && !AppConfig.isProductionConfigValid) {
      developer.log(
        '⚠️  PRODUCTION CONFIG EKSİK: ${AppConfig.missingConfigKeys.join(", ")}',
        name: 'nuveli.config',
      );
    }

    // Firebase (sadece production/staging)
    if (AppConfig.isFirebaseEnabled) {
      try {
        await Firebase.initializeApp();
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
      } catch (e) {
        // Firebase yoksa uygulama yine çalışsın
        developer.log(
          'Firebase başlatılamadı: $e',
          name: 'nuveli.firebase',
        );
      }
    }

    // Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    runApp(const ProviderScope(child: NuveliApp()));
  }, (error, stack) {
    // Global async error handler — runZonedGuarded yakalanmamış async hatalar için
    if (AppConfig.isFirebaseEnabled) {
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
      } catch (_) {
        // Crashlytics çökerse uygulama devam etsin
      }
    } else {
      // Development: console'a yaz
      developer.log(
        'Uncaught error: $error',
        name: 'nuveli.error',
        error: error,
        stackTrace: stack,
      );
    }
  });
}
