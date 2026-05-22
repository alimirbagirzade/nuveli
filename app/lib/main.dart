import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nuveli/core/auth/secure_session_storage.dart';
import 'package:nuveli/core/config/app_config.dart';
import 'package:nuveli/core/monitoring/crash_reporter.dart';
import 'package:nuveli/core/notifications/notification_service.dart';
import 'package:nuveli/core/theme/app_theme.dart';
import 'package:nuveli/features/auth/screens/auth_gate.dart';
import 'package:nuveli/features/notifications/providers/notifications_provider.dart';
import 'package:nuveli/features/premium/services/revenue_cat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chat 24: Wire global error handlers BEFORE any other init so that
  // an exception inside Supabase init still gets reported. In debug
  // builds CrashReporter just logs to console; in release builds it
  // forwards to Firebase Crashlytics.
  CrashReporter.installGlobalHandlers();

  // Fail fast if a release build ships with placeholder credentials —
  // better to crash on launch than ship a broken-but-running app.
  if (kReleaseMode && !AppConfig.isProductionConfigValid) {
    throw StateError(
      'Production config missing values: ${AppConfig.missingConfigKeys}. '
      'Rebuild with --dart-define-from-file=.env.production',
    );
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: !AppConfig.isProduction,
    // JWT and PKCE code verifier are held in Keychain (iOS) /
    // EncryptedSharedPreferences (Android) instead of plaintext
    // SharedPreferences. SecureSessionStorage.initialize() also
    // migrates any pre-existing plaintext session into secure storage,
    // so users upgrading from a prior build stay signed in.
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(
        persistSessionKey: supabasePersistSessionKey,
      ),
      pkceAsyncStorage: SecureGotrueAsyncStorage(),
    ),
  );

  // Chat 18: Local notifications. Wrapped in try/catch so a notification
  // init failure (e.g. emulator quirk) never blocks app startup.
  try {
    await NotificationService.instance.init();
  } catch (e, st) {
    debugPrint('NotificationService init failed: $e\n$st');
  }

  // Chat 19: RevenueCat. Init only if a session is already present (auto-login).
  // Otherwise we wait until the user signs in (see auth listener in NuveliApp).
  // Wrapped in try/catch — RC init failure (e.g. missing .env keys on dev
  // machine) should NOT block app startup; paywall will simply show an error.
  try {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await RevenueCatService.instance.init(userId: session.user.id);
    }
  } catch (e, st) {
    debugPrint('RevenueCatService init skipped: $e\n$st');
  }

  // SharedPreferences needs to be ready before Riverpod scope so the
  // notification settings provider can read persisted toggles synchronously.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const NuveliApp(),
    ),
  );
}

class NuveliApp extends ConsumerStatefulWidget {
  const NuveliApp({super.key});

  @override
  ConsumerState<NuveliApp> createState() => _NuveliAppState();
}

class _NuveliAppState extends ConsumerState<NuveliApp> {
  /// Chat 19: Auth state subscription — keeps RevenueCat user in sync
  /// with Supabase session. Cancelled in [dispose].
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _wireAuthRevenueCatSync();

    // Post-frame: wire notification tap handling once the widget tree is
    // built (so we can navigate from a tap if a router is in place later).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wireNotificationHandlers();
      _reapplyScheduledNotifications();
    });
  }

  /// Chat 19: Listen to Supabase auth changes and mirror them in RC.
  /// - signedIn  → RC.init(userId) so purchases attach to the right account
  /// - signedOut → RC.logOut() so the next anonymous user doesn't inherit
  ///   the previous user's entitlement cache.
  void _wireAuthRevenueCatSync() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) async {
        final event = data.event;
        final session = data.session;

        try {
          if (event == AuthChangeEvent.signedIn && session != null) {
            await RevenueCatService.instance.init(userId: session.user.id);
          } else if (event == AuthChangeEvent.signedOut) {
            await RevenueCatService.instance.logOut();
          }
        } catch (e, st) {
          debugPrint('RC auth sync failed: $e\n$st');
        }
      },
    );
  }

  void _wireNotificationHandlers() {
    final service = ref.read(notificationServiceProvider);

    // Foreground/background notification tap → currently just logs.
    // When Chat 17 (routing) is merged, replace debugPrint with the actual
    // router.go(payload.route, extra: payload.extras) call.
    service.setOnTap((payload) {
      debugPrint(
        'Notification tapped → ${payload.route} (extras: ${payload.extras})',
      );
    });

    // Cold start: was the app launched by a notification tap? If so,
    // capture the payload and route to it. Same router caveat as above.
    final launch = service.consumeLaunchPayload();
    if (launch != null) {
      debugPrint(
        'Cold start from notification → ${launch.route} '
        '(extras: ${launch.extras})',
      );
    }
  }

  /// Cihaz reboot veya app reinstall sonrası pending alarmlar OS tarafında
  /// silinir. Settings state'ini re-apply ederek schedule'ları geri kur.
  Future<void> _reapplyScheduledNotifications() async {
    try {
      await ref
          .read(notificationSettingsProvider.notifier)
          .reapplyOnStartup();
    } catch (e) {
      debugPrint('Failed to reapply notifications: $e');
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nuveli',
      theme: AppTheme.dark(),
      home: const AuthGate(),
    );
  }
}
