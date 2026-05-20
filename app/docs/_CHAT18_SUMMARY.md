# Chat 18 — Notifications & Reminders ✅

**Tamamlanma:** 18 Mayıs 2026
**Süre:** 1 chat
**FCM:** Yapılmadı (Chat 19'a ertelendi — App Store önceliği)

---

## 📦 Üretilen Dosyalar

### Core (`lib/core/notifications/`)
| Dosya | Satır | Sorumluluk |
|---|---|---|
| `notification_types.dart` | 50 | Enum: 8 reminder türü + id range |
| `notification_payload.dart` | 50 | JSON deep-link payload model |
| `notification_channels.dart` | 65 | Android channel kayıtları |
| `permission_handler.dart` | 90 | iOS/Android permission + status |
| `notification_service.dart` | 380 | Singleton ana servis, schedule API |

### Features (`lib/features/notifications/`)
| Dosya | Satır | Sorumluluk |
|---|---|---|
| `providers/notifications_provider.dart` | 200 | Riverpod state + persistence |
| `settings_screen.dart` | 380 | UI: toggle'lar, permission banner, debug |

### Updated (`lib/features/water_tracker/widgets/`)
| Dosya | Satır | Değişiklik |
|---|---|---|
| `reminder_toggle_tile.dart` | 100 | Stub → gerçek provider'a bağlı toggle |

### Setup Dosyaları (`_setup/`)
- `pubspec_additions.yaml` — 4 yeni paket
- `AndroidManifest_additions.xml` — 6 permission + 2 receiver
- `Info_plist_additions.xml` — Background modes
- `main_dart_snippet.dart` — Init + tap handler bağlantısı
- `habits_integration_example.dart` — Habits feature ile resync

**Toplam:** ~1,300 satır production-ready kod.

---

## 🛠️ Kurulum Adımları

```bash
cd ~/Development/nuveli

# 1. Paketleri ekle
flutter pub add flutter_local_notifications timezone flutter_timezone permission_handler

# 2. iOS pods
cd ios && pod install && cd ..

# 3. Android manifest düzenle
# _setup/AndroidManifest_additions.xml içeriğini
# android/app/src/main/AndroidManifest.xml'e ekle

# 4. iOS plist düzenle (gerekirse)
# _setup/Info_plist_additions.xml içeriğini
# ios/Runner/Info.plist'e ekle

# 5. main.dart'ı güncelle
# _setup/main_dart_snippet.dart'a göre init kodlarını ekle

# 6. Çalıştır
flutter run
```

---

## ✅ Implement Edilen Reminder Türleri

| # | Tür | Zaman | Mesaj | Schedule Kaynağı |
|---|---|---|---|---|
| 1 | Water Morning | 09:00 | "Time to hydrate" | User toggle |
| 2 | Water Afternoon | 13:00 | "Time to hydrate" | User toggle |
| 3 | Water Evening | 18:30 | "Time to hydrate" | User toggle |
| 4 | Lunch | 12:30 | "Lunch time" | User toggle (combined) |
| 5 | Dinner | 19:00 | "Dinner time" | User toggle (combined) |
| 6 | Habit reminders | Her habit'in saati | "{icon} {title}" | Habit'in `reminderTime` |
| 7 | Sleep (wind-down) | bedtime - 30dk | "Wind down" | User bedtime |
| 8 | Streak warning | 21:00 | "Don't break your streak" | User toggle |
| 9 | AI insight ready | 06:30 | "Your coaching is ready" | User toggle |
| 10 | Weekly recap | Pazar 20:00 | "Your week in Nuveli" | User toggle |

---

## 🧪 Test Senaryoları

### Manuel test (önerilen sıra)

1. **Permission akışı:**
   - Settings ekranı → ilk açılışta banner görünür → "Allow" tıkla
   - Reddedince banner kalır → tekrar "Allow" deneyebilir
   - iOS'ta permanently denied olursa → "Settings" → sistem ayarları açılır

2. **Test notification:**
   - Debug build'de Settings ekranı en altında "Send test notification (10s)" butonu
   - Tıkla → 10 saniye sonra notification gelmeli
   - Tap et → konsola payload düşmeli ("Notification tapped → /water")

3. **Master switch:**
   - Tüm toggle'lar açıkken master'ı kapat
   - Sub-toggle'lar gri olmalı + tıklanamaz
   - Tekrar açınca eski durumlarına dönmeli

4. **Su reminder cross-screen sync:**
   - Water tracker ekranındaki toggle ile Settings ekranındaki toggle aynı state
   - Birinde değiştir → diğerinde anında yansımalı

5. **Cihaz reboot testi (Android):**
   - Bazı notification'ları schedule et
   - Cihazı reboot et
   - Notification'lar hâlâ scheduled mı? (manifest receiver bunu sağlar)

### Test cihazı uyarıları
- **Xiaomi/Huawei/OPPO:** Battery saver agresif. Settings → Battery → app'i "No restrictions" yap
- **Android 12+:** Exact alarm permission'ı sistemden onaylı olmalı (USE_EXACT_ALARM declare ettiğimiz için sorunsuz)
- **iOS DND/Focus Mode:** Time-sensitive interruption level kullandığımız için streak warning bypass edebilir, water vs aktif sessizlikte beklenir

---

## 🔌 Diğer Feature'lara Entegrasyon Noktaları

### Chat 10 (Habits)
- Habit ekle/sil/güncelle sonrası `service.scheduleHabitReminders(specs)` çağır
- Detay: `_setup/habits_integration_example.dart`

### Chat 14 (Backend)
- `PATCH /me` endpoint'i `notification_settings` JSON kabul etsin
- Provider'da `_update`'den sonra backend sync ekle:
  ```dart
  await ref.read(profileRepoProvider).updateNotificationSettings(next.toJson());
  ```

### Chat 12 (Routing)
- `main.dart`'taki `setOnTap` ve `consumeLaunchPayload` çağrılarında
  router'ı bağla. Şu an `debugPrint` ile log atıyor.

### Chat 11 (AI Coach)
- Cron job sabah 06:00'da insight üretir → app açılınca 06:30 notification
- Eğer backend insight üretemezse → notification yine gider ama "today coming soon" mesajı göstermek gerekirse `aiInsightReady` özel mesaj logic'i eklenebilir

### Chat 18.5 (eğer FCM eklenecekse)
- `firebase_messaging` paketi
- `lib/core/notifications/push_notification_service.dart` (server-driven)
- Achievement unlock, real-time AI insight ready → backend'den push
- FCM token'ı user_profiles tablosunda sakla

---

## ⚠️ Bilinen Limitasyonlar

1. **iOS pending limit (64):** Habit reminders 20 ile cap'leniyor. Kullanıcı 30+ habit eklerse en eski 20'si schedule olur. v2'de "priority habit" konsepti eklenebilir.

2. **Time zone değişimi:** Kullanıcı seyahat edip TZ değişirse mevcut scheduled notification'lar eski TZ'da kalır. `app_lifecycle` listener'ı ile `didChangeAppLifecycleState.resumed`'da `reapplyOnStartup` çağrılabilir — ileri optimizasyon.

3. **Streak warning naif:** Şu an 21:00'da her zaman gönderiyor. Akıllısı backend'den "today logged?" kontrolü; çünkü kullanıcı sabah loglamışsa rahatsız etmemeli. **Workaround:** v1'de göndermeye devam, "You logged today ✅" mesajını streak yazıyla başlat. Backend silent-push ile bastırılabilir.

4. **Web platform:** `Platform.isIOS/isAndroid` kontrolü var ama web'de full crash riskini önlemek için `supportsLocalNotifications` getter'ı eklendi. Web build için Settings ekranını gizle.

---

## 📋 Post-Chat Checklist

- [ ] `flutter pub get` çalıştı, error yok
- [ ] AndroidManifest permission satırları eklendi
- [ ] iOS Info.plist (gerekiyorsa) güncellendi
- [ ] main.dart'a init kodu eklendi
- [ ] Permission flow iOS'ta çalışıyor (gerçek cihaz)
- [ ] Permission flow Android 13+ cihazda çalışıyor
- [ ] Test notification 10sn sonra geliyor
- [ ] Tap notification → log'a payload düşüyor
- [ ] Su toggle'ı water tracker + settings ekranında senkron
- [ ] Master switch tüm toggle'ları kontrol ediyor
- [ ] Habit reminder example'ı Chat 10 koduna entegre edildi (varsa)
- [ ] GitHub'a push:
  ```bash
  git checkout -b feature/chat-18-notifications
  git add lib/core/notifications lib/features/notifications lib/features/water_tracker/widgets/reminder_toggle_tile.dart
  git commit -m "feat(notifications): Chat 18 — local notifications + settings screen"
  git push origin feature/chat-18-notifications
  ```

---

## 🎯 Master Plan Güncelleme

`nuveli_master_plan.md` içinde **Faz 3: Integration** bölümünde:

```diff
- [ ] Chat 17: Notifications
+ [x] Chat 17: Notifications ✅
+     - Local notifications (water, meal, habit, sleep, streak, AI, weekly)
+     - Permission flow (iOS + Android 13+)
+     - Settings screen + provider
+     - FCM ertelendi → Chat 19'a
```

> **Not:** Master plan'da bu chat "Chat 17" olarak listelenmişti (Notifications), hazırlık dosyasında "Chat 18" demişiz. Numaralandırma farkı — içerik aynı. Master plan tarafında 17 olarak ✅ işaretle.

---

## 🚀 Sıradaki Adım

**Chat 19: App Store & Play Store Preparation** (master planda Chat 18 → Premium, Chat 19 → App Store sırası vardı; ama notification bittiğine göre App Store hazırlığı sırada olabilir)

Yeni chat açtığında master plan + bu summary'yi project files'a yükle.

Başarılar! 🌊
