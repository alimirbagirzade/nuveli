import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../analytics/app_analytics.dart';
import '../config/app_config.dart';

/// Push notification + local scheduled notification yönetimi.
///
/// İki modu var:
/// 1. **Push (FCM)** — Backend'den server-side gönderilen anlık bildirimler
///    (premium hatırlatma, koç mesajı, vs.)
/// 2. **Local scheduled** — Cihazda planlanmış hatırlatmalar
///    (öğün hatırlatması, koç check-in, ilerleme özeti)
///
/// Kullanım:
/// ```dart
/// await NotificationService.initialize();
/// final token = await NotificationService.getFcmToken();
/// // Token'ı backend'e kaydet
///
/// // Lokal bildirim
/// await NotificationService.scheduleDailyReminder(
///   id: 1,
///   title: 'Öğle yemeği zamanı',
///   body: 'Bugün ne yedin?',
///   hour: 12,
///   minute: 30,
/// );
/// ```
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  static FirebaseMessaging? _fcm;
  static bool _initialized = false;

  /// Ana initialization — main.dart'ta Firebase'den sonra çağrılır.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Timezone init (scheduled notification için kritik)
      tz_data.initializeTimeZones();

      // Local notifications init
      await _initializeLocalNotifications();

      // FCM init (Firebase varsa)
      if (AppConfig.isFirebaseEnabled) {
        await _initializeFcm();
      }

      developer.log('Notifications initialized', name: 'nuveli.notif');
    } catch (e) {
      developer.log('Notification init failed: $e', name: 'nuveli.notif');
    }
  }

  // --------------------------------------------------------------------------
  // Local Notifications
  // --------------------------------------------------------------------------

  static Future<void> _initializeLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,  // explicit izin alacağız
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    developer.log(
      'Notification tapped: ${response.payload}',
      name: 'nuveli.notif',
    );
    // Routing burada handle edilecek (örn. payload="meal_reminder" → meal capture)
  }

  /// İzin iste — iOS için kritik (Android 13+ için de).
  static Future<bool> requestPermission() async {
    try {
      // iOS
      final iosImpl = _local.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final granted = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      // Android 13+
      final androidImpl = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        return granted ?? false;
      }

      return true;  // Eski Android: izin gerekmez
    } catch (e) {
      developer.log('Permission request failed: $e', name: 'nuveli.notif');
      return false;
    }
  }

  /// Anlık lokal bildirim göster (test/debug için).
  static Future<void> showInstant({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    try {
      await _local.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nuveli_general',
            'Genel',
            channelDescription: 'Genel bildirimler',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      developer.log('Show notification failed: $e', name: 'nuveli.notif');
    }
  }

  /// Günlük tekrar eden hatırlatma (örn. her gün 12:30'da).
  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      final scheduled = _nextInstanceOfTime(hour, minute);

      await _local.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nuveli_reminders',
            'Hatırlatmalar',
            channelDescription: 'Öğün ve koç hatırlatmaları',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte
      );

      developer.log(
        'Daily reminder scheduled: id=$id at $hour:$minute',
        name: 'nuveli.notif',
      );
    } catch (e) {
      developer.log('Schedule failed: $e', name: 'nuveli.notif');
    }
  }

  /// Belirli bir tarih/saatte tek seferlik bildirim.
  static Future<void> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    try {
      await _local.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nuveli_reminders',
            'Hatırlatmalar',
            channelDescription: 'Öğün ve koç hatırlatmaları',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      developer.log('Schedule one-time failed: $e', name: 'nuveli.notif');
    }
  }

  /// Belirli ID'li bildirimi iptal.
  static Future<void> cancel(int id) async {
    await _local.cancel(id);
  }

  /// Tüm planlanmış bildirimleri iptal.
  static Future<void> cancelAll() async {
    await _local.cancelAll();
  }

  /// Saat hesaplama — timezone-aware.
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Geçmişe denk geldiyse ertesi güne kaydır
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // --------------------------------------------------------------------------
  // FCM (Push Notifications)
  // --------------------------------------------------------------------------

  static Future<void> _initializeFcm() async {
    _fcm = FirebaseMessaging.instance;

    // Foreground'da gelen mesajları lokal notification olarak göster
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Notification'a tıklanınca uygulama açıldığında
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    developer.log('FCM listener registered', name: 'nuveli.notif');
  }

  static void _onForegroundMessage(RemoteMessage message) {
    developer.log(
      'FCM foreground: ${message.notification?.title}',
      name: 'nuveli.notif',
    );

    // Foreground'da otomatik gösterilmez, manuel çağır
    final notif = message.notification;
    if (notif != null) {
      showInstant(
        title: notif.title ?? 'Nuveli',
        body: notif.body ?? '',
        payload: message.data['type'] as String?,
      );
    }
  }

  static void _onMessageOpenedApp(RemoteMessage message) {
    AppAnalytics.track('notification_opened', props: {
      'type': (message.data['type'] as String?) ?? 'unknown',
    });
    developer.log(
      'FCM opened: ${message.data}',
      name: 'nuveli.notif',
    );
    // Burada deeplink/route handle edilecek
  }

  /// FCM token al — backend'e kaydedilmek üzere.
  static Future<String?> getFcmToken() async {
    try {
      if (_fcm == null) return null;
      return await _fcm!.getToken();
    } catch (e) {
      developer.log('Get FCM token failed: $e', name: 'nuveli.notif');
      return null;
    }
  }

  /// Backend'e token gönder — kullanıcıya push gönderebilmek için.
  /// TODO: backend endpoint'i tamamlandığında bağla
  static Future<void> registerTokenWithBackend(String userId) async {
    final token = await getFcmToken();
    if (token == null) return;

    developer.log(
      'FCM token: ${token.substring(0, 20)}... (would register for $userId)',
      name: 'nuveli.notif',
    );
    // await api.post('/notifications/register', body: {'token': token});
  }
}

/// Standardize notification ID'leri — çakışma olmasın.
class NotificationId {
  NotificationId._();

  static const breakfastReminder = 1001;
  static const lunchReminder = 1002;
  static const dinnerReminder = 1003;
  static const coachCheckIn = 2001;
  static const weeklyReview = 3001;
  static const trialEnding = 4001;
}
