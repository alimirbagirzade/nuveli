# Sprint 1 Gün 6-7 — FCM Push + Empty Day Flow

## Paket İçeriği

```
backend/
├── app/services/
│   ├── push_service.py          (REPLACE - mock mode + FCM HTTP v1)
│   └── checkin_service.py       (YENİ)
├── app/api/routes/
│   ├── notifications.py         (REPLACE - token + prefs)
│   └── checkins.py              (YENİ)
└── tests/
    ├── test_push_service.py     (YENİ - 24 test)
    └── test_checkin_service.py  (YENİ - 12 test)

app/lib/
├── core/services/
│   └── fcm_service.dart         (YENİ - FCM init + tap handler)
└── features/empty_day/utils/
    └── empty_day_trigger.dart   (YENİ)
```

## Tasarım Kararı: MOCK MODE

`push_service.py` **şu anda gerçek FCM çağrısı yapmıyor**. `FIREBASE_SERVICE_ACCOUNT_JSON` env değişkeni yoksa otomatik **MOCK MODE**'a geçer:
- Tüm validate / quiet hours / prefs kontrolleri çalışır
- Token register endpoint'i Supabase'e yazar
- "Send" çağrılarında log'a yazılır, gerçek push gitmez
- `result.mock = True` döner

Bu sayede Render'a deploy bozulmaz. Firebase + APNs hesapları kurulduğunda env eklenir, kod aynı kalır, gerçek push'a geçer.

## Backend Entegrasyon

### 1. Router'a yeni route'ları ekle

`backend/app/api/router.py` içinde:

```python
from app.api.routes import checkins, notifications

api_router.include_router(
    notifications.router,
    prefix="/notifications",
    tags=["notifications"],
)
api_router.include_router(
    checkins.router,
    prefix="/checkins",
    tags=["checkins"],
)
```

`notifications` router muhtemelen zaten kayıtlı — sadece içeriği değişti, registration aynı kalır.

### 2. Requirements (gerçek mode için)

`backend/requirements.txt`'e ekle (mock mode'da gerek yok ama önceden hazır olsun):

```
google-auth==2.34.0
```

Bu olmadan `_get_access_token()` çağrılmaz çünkü `mock_mode=True`. Ama Firebase'i bağlayınca bu paket olmazsa lazy import patlar.

### 3. Env vars (Render'a yarın/sonra eklenecek)

Şimdi gerek yok. Firebase setup sonrası Render dashboard → Environment:

```
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"nuveli-app",...}
```

Tek satırlık JSON string. Firebase Console → Project Settings → Service Accounts → Generate New Private Key → indirilen JSON'un tamamı.

### 4. Mevcut routes/notifications.py ne olacak?

Eğer mevcut dosyada `/log` veya başka endpoint'ler varsa, yeni dosyayı **birleştir** — yeni endpoint'leri ekle, eskileri sil. Çakışan endpoint isimleri:
- `POST /notifications/token` (yeni) ← muhtemelen yok mevcut'ta
- `DELETE /notifications/token` (yeni)
- `GET /notifications/preferences` (mevcut'ta da olabilir, yeni format'ta override et)
- `PATCH /notifications/preferences`

## Frontend Entegrasyon

### 1. main.dart — Background handler

En üste, `main()` fonksiyonundan **önce** ekle:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nuveli/core/services/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // fcm_service.dart'taki top-level fonksiyonu kullan
  await firebaseMessagingBackgroundHandler(message);
}
```

`main()` içinde, `Firebase.initializeApp()` sonrasında:

```dart
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
```

### 2. App init — Auth sonrası FCM init

`app/lib/app.dart` içinde, auth state listener'ında:

```dart
ref.listen(authStateProvider, (prev, next) {
  next.whenData((session) async {
    if (session?.user != null) {
      // Premium init (zaten var)
      await ref.read(premiumServiceProvider).initialize(userId: session!.user.id);
      
      // FCM init (YENİ)
      final fcm = ref.read(fcmServiceProvider);
      fcm.onNotificationTap = (deepLink, data) {
        if (deepLink != null) {
          _router.go(deepLink.replaceFirst('nuveli://', '/'));
        }
      };
      fcm.onForegroundMessage = (message) {
        // İsteğe bağlı: in-app banner göster
      };
      await fcm.initialize();
    } else {
      // Logout: FCM token'ı sil
      await ref.read(fcmServiceProvider).unregister();
    }
  });
});
```

### 3. Home screen — Empty Day trigger

`app/lib/features/home/screens/home_screen.dart` initState'inde, premium gift trigger'ın yanına:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;
    
    // Sıralama: önce empty day kontrolü (öncelikli), sonra premium gift
    await EmptyDayTrigger.maybeShow(context, ref);
    
    if (!mounted) return;
    final profile = ref.read(profileProvider).valueOrNull;
    final yesterdayMeals = ref.read(yesterdayMealCountProvider).valueOrNull ?? 0;
    await TrialGiftTrigger.maybeShow(
      context,
      ref,
      userFirstName: profile?.firstName,
      mealsLoggedYesterday: yesterdayMeals,
    );
  });
}
```

### 4. Empty Day Screen route

Router config (`app_router.dart`)'a ekle:

```dart
GoRoute(
  path: '/empty-day',
  builder: (context, state) => const EmptyDayScreen(),
),
```

`EmptyDayScreen` zaten `app/lib/features/progress/screens/empty_day_screen.dart`'ta var (önceki kontrol görüldü). PRD §6.4 ile uyumlu olduğunu doğrula:
- Yargılayıcı dil **yok**
- "Bugün hiç log yok" değil; "Yoğun gün, anladım. Yarın yine buradayız."
- 3 buton: "Bugünü kapat" (acknowledged), "Yarın hatırlat" (tomorrow), "Şimdi log'la" (close → meal capture)

## Testler

```bash
cd backend && /tmp/nuveli_venv/bin/python -m pytest tests/test_push_service.py tests/test_checkin_service.py -v
```

**Beklenen:** `36 passed`

Sprint 1 tüm testler:
```bash
cd backend && /tmp/nuveli_venv/bin/python -m pytest tests/ -v
```

**Beklenen:** `91 passed` (32 AI + 23 premium + 24 push + 12 checkin)

## Smoke Tests (Render Deploy Sonrası)

```bash
TOKEN="<JWT>"
BASE="https://nuveli-api.onrender.com"

# 1. Token register
curl -X POST $BASE/notifications/token \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fcm_token":"test-token-12345","platform":"ios"}'
# {"ok":true,"registered":true}

# 2. Prefs
curl -H "Authorization: Bearer $TOKEN" $BASE/notifications/preferences
# Default prefs döner

# 3. Empty-day status
curl -H "Authorization: Bearer $TOKEN" $BASE/checkins/empty-day-status
# {"is_empty_day":true,"already_acknowledged":false,"should_show_screen":true}

# 4. Mood checkin
curl -X POST $BASE/checkins \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type":"mood","value":"okay"}'

# 5. Today's checkins
curl -H "Authorization: Bearer $TOKEN" $BASE/checkins/today
```

## Done Kriteri

- [ ] Migration 010-012 Supabase'de aktif (zaten yapıldı)
- [ ] Backend deploy yeşil
- [ ] `pytest tests/` 91 yeşil
- [ ] `/notifications/token` POST 200 dönüyor
- [ ] `/notifications/preferences` GET default dönüyor
- [ ] `/checkins` POST 200 dönüyor
- [ ] `/checkins/empty-day-status` GET dönüyor
- [ ] Mock mode aktif (Render log'larında "MOCK PUSH" görülüyor)
- [ ] Frontend build hatasız
- [ ] FCM service auth sonrası initialize oluyor (debug log)
- [ ] Empty day trigger 24h aktivite yokken /empty-day'e route'luyor

## Sprint 2'ye Bırakılan

1. **Firebase + APNs setup** — Apple Developer'a APNs key/certificate yükleme, Google Play Console FCM bağlama, Firebase Console proje oluşturma + service account JSON üretme.
2. **Cron jobs** — meal_reminder, weekly_summary, empty_day_nudge schedule. Render Cron Job veya pg_cron kullan.
3. **In-app foreground banner** — Foreground'da uygulamada custom banner.
4. **Notification action buttons** — "Snooze 1h", "Mark done" gibi.
5. **APNs sandbox vs production** — TestFlight için sandbox, production için ayrı.
6. **Webhook idempotency** — Aynı RC event ID iki kez gelirse skip.
7. **Usage counter timezone** — User-local day reset.

---

Bu paketten sonra Sprint 1 tamamlanmış olur. Sprint 2'de Onboarding revision + Recovery day flow + 30-day Insight screen başlar.
