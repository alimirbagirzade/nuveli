import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/settings/data/settings_repository.dart';
import '../../features/streak/data/streak_repository.dart';

/// Lokal bildirim yönetimi.
///
/// Apple Developer hesabı gerektirmez — bildirimler tamamen cihazda
/// schedule edilir. APNs/Firebase Cloud Messaging gibi remote push'a
/// gerek yoktur.
///
/// Schedule edilen bildirimler:
///   1. Sabah hatırlatma (saat 09:00) — "Günaydın! Bugün nasıl gidiyor?"
///   2. Akşam reminder (saat 20:00) — "Bugünkü öğünlerini eklemeyi unutma"
///   3. Streak risk (saat 21:30) — sadece streak aktif ve bugün kayıt yoksa
///   4. Haftalık özet bildirimi (Pazartesi 08:00) — kullanıcı izinli ise
///
/// Sessiz saatler ([NotificationPrefs.quietStart] - [quietEnd]) içine
/// düşen bildirimler hiç schedule edilmez.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification ID'leri (her bildirim için benzersiz tamsayı).
  static const int _idMorning = 1001;
  static const int _idEvening = 1002;
  static const int _idStreakRisk = 1003;
  static const int _idWeekly = 1004;

  /// İlk başlatmada timezone DB ve plugin'i hazırla.
  /// Permission isteme bu adımda yapılmaz — kullanıcı ilk bildirim
  /// schedule'ında veya tercih ekranını açtığında istenir.
  Future<void> initialize() async {
    if (_initialized) return;

    // Timezone DB — flutter_local_notifications tz.TZDateTime kullanır,
    // o yüzden cihazın local timezone'ını runtime'da set etmemiz lazım.
    tz_data.initializeTimeZones();
    try {
      // 'Europe/Istanbul' default — eğer cihazın timezone'ı farklıysa
      // Flutter ortamından okumamız lazım ama paket bunu doğrudan
      // sağlamıyor. UTC offset üzerinden tahmin edelim.
      final now = DateTime.now();
      final offsetHours = now.timeZoneOffset.inHours;
      // Türkiye = UTC+3. Diğer bölgeler için fallback.
      final tzName = offsetHours == 3
          ? 'Europe/Istanbul'
          : 'UTC';
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Timezone setup başarısız olsa bile bildirimler çalışsın
      tz.setLocalLocation(tz.UTC);
    }

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      const InitializationSettings(iOS: iosInit, android: androidInit),
    );

    _initialized = true;
  }

  /// Kullanıcıdan bildirim izni iste.
  /// iOS'ta sistem dialog'u açar, Android 13+'da da sorulur.
  Future<bool> requestPermissions() async {
    await initialize();

    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  /// Tüm planlanmış bildirimleri iptal et — ekran kapama veya
  /// kullanıcı bildirimleri tamamen kapattığında.
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  /// Tek bir bildirim tipini iptal et (id ile).
  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  // ─── Public schedule API ─────────────────────────────────────────

  /// Mealkayıt bildirimleri — sabah & akşam.
  ///
  /// [prefs] kullanıcının tercihleri (sessiz saat, hangi tipler aktif).
  /// Tercihler değiştiğinde tekrar çağrılmalı (eskileri silip yeniden
  /// schedule eder).
  Future<void> scheduleMealReminders(NotificationPrefs prefs) async {
    await initialize();
    await cancel(_idMorning);
    await cancel(_idEvening);

    if (!prefs.mealReminders) return;

    // Sabah 09:00
    final morningTime = const _DailyTime(hour: 9, minute: 0);
    if (!_isWithinQuietHours(morningTime, prefs)) {
      await _scheduleDaily(
        id: _idMorning,
        time: morningTime,
        title: 'Günaydın! 🌅',
        body: 'Bugün nasıl hissediyorsun? Kahvaltı ekleyerek başlayalım.',
      );
    }

    // Akşam 20:00
    final eveningTime = const _DailyTime(hour: 20, minute: 0);
    if (!_isWithinQuietHours(eveningTime, prefs)) {
      await _scheduleDaily(
        id: _idEvening,
        time: eveningTime,
        title: 'Akşam kontrolü 🌙',
        body: 'Bugün eklemeyi unuttuğun öğün var mı?',
      );
    }
  }

  /// Streak risk uyarısı — sadece kullanıcının aktif streak'i varsa
  /// ve bugün öğün eklemediyse, akşam 21:30'da uyar.
  ///
  /// Çağrılması gereken yerler:
  /// 1. Uygulama açılışında (StreakInfo geldiğinde)
  /// 2. Bir öğün eklendiğinde (cancel — risk geçti)
  /// 3. Kullanıcı bildirim tercihlerini değiştirdiğinde
  Future<void> scheduleStreakRisk(
    StreakInfo streak,
    NotificationPrefs prefs,
  ) async {
    await initialize();
    await cancel(_idStreakRisk);

    // Bildirim tercihi kapalıysa veya streak yoksa schedule etme
    if (!prefs.coachNudges) return;
    if (streak.current == 0) return;
    if (streak.todayLogged) return; // bugün hallettik, risk yok

    final riskTime = const _DailyTime(hour: 21, minute: 30);
    if (_isWithinQuietHours(riskTime, prefs)) return;

    // Sadece bugüne özel — yarınki streak hesaplaması farklı olabilir,
    // o yüzden matchDateTimeComponents kullanmıyoruz, tek seferlik.
    final scheduled = _nextOccurrenceToday(riskTime);
    if (scheduled == null) return; // saat geçmiş, bu akşam zaten kaçtık

    await _plugin.zonedSchedule(
      _idStreakRisk,
      'Serin tehlikede! 🔥',
      '${streak.current} günlük seri kırılmak üzere. '
          'Bir öğün ekleyerek devam ettir.',
      scheduled,
      _streakDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Pazartesi 08:00 haftalık özet bildirimi.
  Future<void> scheduleWeeklySummary(NotificationPrefs prefs) async {
    await initialize();
    await cancel(_idWeekly);

    if (!prefs.weeklySummary) return;

    final weeklyTime = const _DailyTime(hour: 8, minute: 0);
    if (_isWithinQuietHours(weeklyTime, prefs)) return;

    // Bir sonraki Pazartesi
    final now = tz.TZDateTime.now(tz.local);
    var monday = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      weeklyTime.hour,
      weeklyTime.minute,
    );
    final daysUntilMonday = (DateTime.monday - monday.weekday + 7) % 7;
    if (daysUntilMonday == 0 && monday.isBefore(now)) {
      // Bugün Pazartesi ama saat geçmiş — gelecek Pazartesi
      monday = monday.add(const Duration(days: 7));
    } else {
      monday = monday.add(Duration(days: daysUntilMonday));
    }

    await _plugin.zonedSchedule(
      _idWeekly,
      'Haftalık özetin hazır 📊',
      'Geçen haftan nasıl geçti, gel bakalım.',
      monday,
      _summaryDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Tercih değişikliği veya streak değişimi sonrası tüm planları
  /// tek seferde yeniler. UI'dan en sık çağrılan giriş noktası.
  Future<void> rescheduleAll({
    required NotificationPrefs prefs,
    StreakInfo? streak,
  }) async {
    await scheduleMealReminders(prefs);
    await scheduleWeeklySummary(prefs);
    if (streak != null) {
      await scheduleStreakRisk(streak, prefs);
    }
  }

  // ─── Internals ───────────────────────────────────────────────────

  Future<void> _scheduleDaily({
    required int id,
    required _DailyTime time,
    required String title,
    required String body,
  }) async {
    final scheduled = _nextOccurrence(time);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Verilen [time] için bir sonraki olası tarihi döndürür.
  /// Eğer bugün için geç olduysa yarınki aynı saati alır.
  tz.TZDateTime _nextOccurrence(_DailyTime time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Bugün için sonraki saati döndürür; geçmişse null.
  tz.TZDateTime? _nextOccurrenceToday(_DailyTime time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) return null;
    return scheduled;
  }

  /// Verilen saat sessiz saatler aralığında mı?
  /// Sessiz saat midnight'ı geçebilir (örn 22:00 → 08:00).
  bool _isWithinQuietHours(_DailyTime time, NotificationPrefs prefs) {
    final start = _DailyTime.parse(prefs.quietStart);
    final end = _DailyTime.parse(prefs.quietEnd);
    if (start == null || end == null) return false;

    final tMin = time.hour * 60 + time.minute;
    final sMin = start.hour * 60 + start.minute;
    final eMin = end.hour * 60 + end.minute;

    if (sMin == eMin) return false; // sessiz dönem 0-uzunluk
    if (sMin < eMin) {
      // Aynı gün içinde (örn 13:00 - 17:00)
      return tMin >= sMin && tMin < eMin;
    }
    // Geceyi geçen aralık (örn 22:00 - 08:00)
    return tMin >= sMin || tMin < eMin;
  }

  // Notification details — iOS + Android için ayar paketi
  NotificationDetails _defaultDetails() {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        'nuveli_meal_reminders',
        'Öğün Hatırlatmaları',
        channelDescription: 'Sabah ve akşam öğün ekleme hatırlatmaları',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
  }

  NotificationDetails _streakDetails() {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        'nuveli_streak',
        'Streak Uyarıları',
        channelDescription: 'Streak risk altındayken bildirim',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  NotificationDetails _summaryDetails() {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        'nuveli_weekly_summary',
        'Haftalık Özet',
        channelDescription: 'Pazartesi sabahları haftalık özetin',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
  }
}

/// Saat:dakika tutar, tarih içermez.
class _DailyTime {
  const _DailyTime({required this.hour, required this.minute});
  final int hour;
  final int minute;

  static _DailyTime? parse(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return _DailyTime(
      hour: math.max(0, math.min(23, h)),
      minute: math.max(0, math.min(59, m)),
    );
  }
}
