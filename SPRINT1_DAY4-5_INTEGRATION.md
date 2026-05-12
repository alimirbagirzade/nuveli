# Sprint 1 Gün 4-5 — RevenueCat + Premium Wire-Up

## Paket İçeriği

```
backend/
├── app/services/
│   └── premium_service.py             (REPLACE — webhook + sync + day2 + usage)
├── app/api/routes/
│   └── premium.py                     (REPLACE — thin HTTP layer)
├── app/core/
│   └── feature_gating.py              (YENİ — require_feature() dependency)
└── tests/
    └── test_premium_service.py        (YENİ — 23 test)

app/lib/features/premium/
├── data/
│   └── premium_service.dart           (REPLACE — Purchases SDK wrapper)
├── screens/
│   ├── paywall_screen.dart            (REPLACE — value-based UI)
│   └── trial_gift_modal.dart          (REPLACE — Day 2 gift modal)
└── utils/
    └── trial_gift_trigger.dart        (REPLACE — when to show modal)
```

## Önkoşullar

### 1. RevenueCat Dashboard Setup

- Dashboard'a giriş, Nuveli projesi oluştur
- iOS app key + Android app key oluştur → backend'e veya `.env` dosyasına yaz:
  ```
  REVENUECAT_APPLE_KEY=appl_xxxxx
  REVENUECAT_GOOGLE_KEY=goog_xxxxx
  REVENUECAT_WEBHOOK_SECRET=randomly-generated-secret
  ```
- Entitlement adı: **`premium`** (kod bunu bekliyor)
- Offerings:
  - `default` offering içinde `monthly` ve `annual` package
  - Annual package'a 7 günlük free trial intro tanımla
- Webhook URL: `https://nuveli-app.onrender.com/premium/webhook`
  - Authorization header: `Bearer <REVENUECAT_WEBHOOK_SECRET>`

### 2. Apple App Store Connect / Google Play Console

- Subscription product ID'leri (örn `nuveli_yearly_v1`, `nuveli_monthly_v1`)
- App Store: Subscription group oluştur, intro offer (7-day free trial) ekle
- Google Play: Subscription create, base plan + offer (7 days free)
- RevenueCat'te bu product ID'leri bağla

### 3. Backend Env

`backend/.env` dosyasına ekle:
```
REVENUECAT_WEBHOOK_SECRET=<senin secret>
```

`backend/app/core/config.py` içine settings field'ı ekle:
```python
class Settings(BaseSettings):
    ...
    revenuecat_webhook_secret: str = ""
```

### 4. Flutter Env

`app/.env.production` (varsa) içine:
```
REVENUECAT_APPLE_KEY=appl_xxxxx
REVENUECAT_GOOGLE_KEY=goog_xxxxx
```

`app/lib/core/config/app_config.dart` içine getter'lar:
```dart
String get revenueCatAppleKey => _env['REVENUECAT_APPLE_KEY'] ?? '';
String get revenueCatGoogleKey => _env['REVENUECAT_GOOGLE_KEY'] ?? '';
```

## Backend Entegrasyon

### 1. Migration'lar (Sprint 1 Gün 2-3'te zaten ekledik)

`010_premium_and_usage_tables.sql` — `premium_status_cache`, `usage_counters_daily` zaten orada.

### 2. Dependency Injection

`backend/app/core/dependencies.py` içine ekle:

```python
from functools import lru_cache
from app.core.config import settings
from app.db.client import get_supabase_client
from app.services.premium_service import PremiumService

@lru_cache()
def get_premium_service() -> PremiumService:
    return PremiumService(
        db=get_supabase_client(),
        webhook_secret=settings.revenuecat_webhook_secret,
    )
```

### 3. Router Registration

`backend/app/api/router.py` içinde `premium` router zaten kayıtlı görünüyor. Yeni endpoint'lerin (`/sync`, `/webhook`, `/day2-gift-status`, `/day2-gift-claim`, `/usage/today`) çalışması için route dosyasını yeni içerikle değiştir.

### 4. Feature Gating Mevcut Endpoint'lere

`backend/app/api/routes/meals.py` içinde:

```python
from app.core.feature_gating import require_feature, increment_feature_usage

@router.post("/analyze")
async def analyze_meal(
    body: ...,
    user_id: str = Depends(get_current_user_id),
    db = Depends(get_supabase_client),
    _gate = Depends(require_feature("meal_photo_analysis")),
):
    # Limit kontrolü zaten geçti (yoksa 402 atılırdı)
    result = await meal_service.analyze(...)
    # Başarı sonrası sayacı artır
    await increment_feature_usage(user_id, "meal_photo_analysis", db)
    return result
```

`coach_service` kendi içinde `decision_engine.increment_usage()` çağırdığı için coach endpoint'lerinde decorator'a gerek yok — ama tutarlılık için ekleyebilirsin.

## Frontend Entegrasyon

### 1. App Initialize

`app/lib/app.dart` veya `main.dart`'ta auth state değiştiğinde Premium initialize:

```dart
class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    ref.listen(authStateProvider, (prev, next) {
      next.whenData((session) async {
        if (session?.user != null) {
          await ref.read(premiumServiceProvider).initialize(
            userId: session!.user.id,
          );
        }
      });
    });
  }
  ...
}
```

### 2. Home'da Trial Gift Trigger

`app/lib/features/home/screens/home_screen.dart` initState'inde:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final profile = ref.read(profileProvider).valueOrNull;
    final yesterdayMeals = ref.read(yesterdayMealCountProvider).valueOrNull ?? 0;
    TrialGiftTrigger.maybeShow(
      context,
      ref,
      userFirstName: profile?.firstName,
      mealsLoggedYesterday: yesterdayMeals,
    );
  });
}
```

### 3. Premium State Dinleme

Herhangi bir widget premium durumu okuyabilir:

```dart
class CoachCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumStateProvider);
    return premium.when(
      data: (state) {
        if (state.isPremium) {
          return _PremiumCoachCard();
        }
        if (state.isInTrial) {
          return _TrialBadgeCoachCard();
        }
        return _FreeCoachCard(onUpgrade: () => context.push('/paywall'));
      },
      loading: () => const ShimmerCoachCard(),
      error: (_, __) => _FreeCoachCard(),
    );
  }
}
```

### 4. Day 0 Paywall (PRD §6.4)

İlk öğün ve ilk başarı ekranından sonra paywall göster. Onboarding flow'unun sonunda:

```dart
Future<void> _onFirstSuccessShown() async {
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;
  context.push('/paywall?source=day0_post_log');
}
```

## Tests

```bash
cd backend && /tmp/nuveli_venv/bin/python -m pytest tests/test_premium_service.py -v
# Beklenen: 23 passed
```

Tüm pipeline:
```bash
cd backend && /tmp/nuveli_venv/bin/python -m pytest tests/ -v
# Beklenen: 55 passed (32 AI pipeline + 23 premium)
```

## Smoke Test (Production)

```bash
TOKEN="<JWT>"
BASE="https://nuveli-app.onrender.com"

# 1. Free user status
curl -H "Authorization: Bearer $TOKEN" $BASE/premium/status
# {"status":"free", ...}

# 2. Features
curl -H "Authorization: Bearer $TOKEN" $BASE/premium/features
# {"status":"free", "features":{"coach_text_per_day":3,...}}

# 3. Usage today
curl -H "Authorization: Bearer $TOKEN" $BASE/premium/usage/today
# {"date":"2026-05-01","status":"free","usage":{...}}

# 4. Day2 eligibility
curl -H "Authorization: Bearer $TOKEN" $BASE/premium/day2-gift-status
# {"eligible":true|false}

# 5. Webhook (RevenueCat sandbox event ile test)
curl -X POST $BASE/premium/webhook \
  -H "Authorization: Bearer $REVENUECAT_WEBHOOK_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"event":{"type":"INITIAL_PURCHASE","app_user_id":"test-user-uuid",...}}'
```

## Done Kriteri

- [ ] RevenueCat dashboard'da Nuveli projesi + offerings + webhook konfigure
- [ ] App Store Connect + Play Console subscription product ID'leri canlı
- [ ] Backend env'lerde `REVENUECAT_WEBHOOK_SECRET` set
- [ ] App env'lerde `REVENUECAT_APPLE_KEY` + `REVENUECAT_GOOGLE_KEY` set
- [ ] `pytest tests/` 55 yeşil
- [ ] Auth sonrası `Purchases.configure(...)` çalışıyor (debug log'la doğrula)
- [ ] Paywall ekranı offerings'i listeliyor, fiyatları gösteriyor
- [ ] Sandbox satın alma test edildi (Apple sandbox tester / Google test track)
- [ ] Webhook event geldikten sonra `/premium/status` premium dönüyor
- [ ] Day 2 gift modal Day 1 hesabıyla otomatik açılıyor
- [ ] `meals/analyze` 1/gün limit dolduktan sonra 402 atıyor

## Bilinen Pürüzler / Sonra Halledilecek

1. **TTSService entegrasyonu**: `coach_service.py` TTS opsiyonel olarak çağırıyor ama tts_service.py'nin gerçek implementasyonunu görmedim — Sprint 1 Gün 6'da FCM ile beraber halledilecek.
2. **Webhook idempotency**: Aynı event ID iki kez gelirse aynı işlem iki kez yapılır. Production'da `webhook_events` tablosu eklenip event_id unique check yapılması iyi olur. Sprint 2.
3. **Usage counter timezone**: Şu an UTC `date.today()` kullanılıyor. Kullanıcı timezone'undan reset etmek için profil'e `timezone` alanı + sayaç sorgu zamanını user-local'a çevirme gerek. Sprint 2.
4. **Restore on app open**: App her açıldığında `Purchases.getCustomerInfo()` zaten initialize'da çağrılıyor. Eski cihazdan yeni cihaza geçişte kullanıcı paywall'da "Geri yükle" butonuna basmalı.

---

Sıradaki adım: bu paketi entegre et + RevenueCat dashboard kur → `pytest tests/` yeşil → Sprint 1 Gün 6-7 (FCM + Empty Day) için kod paketini hazırlıyorum.
