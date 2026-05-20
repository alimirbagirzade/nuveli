import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nuveli/core/notifications/notification_service.dart';
import 'package:nuveli/core/theme/app_theme.dart';
import 'package:nuveli/features/auth/screens/auth_gate.dart';
import 'package:nuveli/features/notifications/providers/notifications_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: dotenv.env['APP_ENV'] != 'production',
  );

  // Chat 18: Local notifications. Wrapped in try/catch so a notification
  // init failure (e.g. emulator quirk) never blocks app startup.
  try {
    await NotificationService.instance.init();
  } catch (e, st) {
    debugPrint('NotificationService init failed: $e\n$st');
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
  @override
  void initState() {
    super.initState();
    // Post-frame: wire notification tap handling once the widget tree is
    // built (so we can navigate from a tap if a router is in place later).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wireNotificationHandlers();
      _reapplyScheduledNotifications();
    });
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nuveli',
      theme: AppTheme.dark(),
      home: const AuthGate(),
    );
  }
}
