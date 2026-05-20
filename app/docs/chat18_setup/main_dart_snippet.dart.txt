// lib/main.dart — Chat 18 entegrasyonu
//
// AŞAĞIDAKİ snippet'leri mevcut main.dart'a entegre et.
// Tam dosyayı değiştirmiyoruz — sadece eklemeler.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/notifications/notification_service.dart';
import 'features/notifications/providers/notifications_provider.dart';
// import 'core/routing/app_router.dart'; // Chat 12

void main() async {
  // 1. Flutter binding'i ÖNCE init et — async iş yapacağız.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Notification service — timezone + plugin init.
  //    Hata olursa app açılışı bloklamasın; logla ve devam et.
  try {
    await NotificationService.instance.init();
  } catch (e, st) {
    debugPrint('NotificationService init failed: $e\n$st');
  }

  // 3. SharedPreferences — settings provider için.
  final prefs = await SharedPreferences.getInstance();

  // 4. Run app, prefs'i Riverpod'a inject et.
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
    // Post-frame: router hazır olunca tap handler'ı bağla ve cold-start
    // payload varsa onu da çalıştır.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wireNotificationHandlers();
      _reapplyScheduledNotifications();
    });
  }

  void _wireNotificationHandlers() {
    final service = ref.read(notificationServiceProvider);

    // Foreground/background tap → route'a git.
    service.setOnTap((payload) {
      // Replace with AppRouter.router.push(...) once Chat 12 lands.
      debugPrint('Notification tapped → ${payload.route} (${payload.extras})');
      // AppRouter.router.go(payload.route, extra: payload.extras);
    });

    // Cold start: app notification tap ile açıldıysa ilgili sayfaya git.
    final launch = service.consumeLaunchPayload();
    if (launch != null) {
      debugPrint('Cold start from notification → ${launch.route}');
      // AppRouter.router.go(launch.route, extra: launch.extras);
    }
  }

  /// Cihaz reboot veya app reinstall sonrası pending alarmlar kaybolur.
  /// Settings state'ini yeniden uygulayarak schedule'ları geri kur.
  Future<void> _reapplyScheduledNotifications() async {
    await ref
        .read(notificationSettingsProvider.notifier)
        .reapplyOnStartup();
  }

  @override
  Widget build(BuildContext context) {
    // Chat 12 sonrası burası MaterialApp.router olacak.
    return MaterialApp(
      title: 'Nuveli',
      // theme: NuveliTheme.dark, // Chat 1
      // routerConfig: AppRouter.router, // Chat 12
      home: const Scaffold(
        body: Center(child: Text('Wire your home screen here')),
      ),
    );
  }
}
