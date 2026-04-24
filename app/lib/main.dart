import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Global async error handler
  runZonedGuarded(
    () => runApp(const ProviderScope(child: NuveliApp())),
    (error, stack) {
      if (AppConfig.isFirebaseEnabled) {
        try {
          FirebaseCrashlytics.instance
              .recordError(error, stack, fatal: false);
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
    },
  );
}
