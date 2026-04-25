# Nuveli — AI Calorie Coach

[![CI](https://github.com/alimirbagirzade/nuveli_test/actions/workflows/ci.yml/badge.svg)](https://github.com/alimirbagirzade/nuveli_test/actions/workflows/ci.yml)

Fotoğraf tabanlı yemek analizi, AI koç ve davranışsal destek sunan bir wellness uygulaması.

> ⚠️ Nuveli bir wellness aracıdır. Tıbbi teşhis, klinik diyet planı veya doktor/diyetisyen yerine geçen yönlendirme sunmaz. Kritik sınırlar için bkz. `docs/protocols/safety-wellness-boundary.md`.

---

## Stack

| Katman | Teknoloji |
|---|---|
| Mobile | Flutter 3.24 (iOS + Android, tek kod tabanı) |
| State | Riverpod 2 |
| Routing | go_router |
| Backend | FastAPI (Python 3.11) |
| Auth / DB / Storage | Supabase |
| Subscription | RevenueCat |
| Push | Firebase Cloud Messaging |
| Analytics | Firebase Analytics |
| Crash | Firebase Crashlytics |
| AI Vision | OpenAI GPT-4o mini |
| AI TTS | OpenAI TTS-1 (nova voice) |
| Test | flutter_test + mocktail, pytest |
| CI/CD | GitHub Actions |

## Proje Yapısı

```
nuveli/
├── app/                      # Flutter uygulaması
│   ├── lib/
│   │   ├── core/             # Config, routing, network, theme, monitoring
│   │   ├── features/         # auth, onboarding, home, meal, coach, premium, settings
│   │   └── shared/widgets/   # PrimaryButton, AppScaffold, EmptyStateView, Skeleton
│   ├── test/                 # 98 test (unit + widget)
│   └── .env.production.example
│
├── backend/                  # FastAPI backend
│   ├── app/
│   │   ├── api/routes/       # Endpoint'ler (auth, meals, coach, premium, ...)
│   │   ├── services/         # Business logic
│   │   ├── schemas/          # Pydantic modelleri
│   │   └── core/             # Config, security, deps, logging
│   ├── tests/                # 29 pytest (ApiResponse, feature matrix, safety)
│   └── .env.production.example
│
├── docs/
│   ├── product/              # Ürün kapsamı, branding
│   ├── protocols/            # AI protokolleri (koç, vision, safety)
│   └── architecture/         # Mimari, DB, API
│
├── scripts/                  # build-ios.sh, build-android.sh, pre-commit, install-hooks
├── .github/workflows/ci.yml  # CI: flutter analyze + test, pytest, protocol docs check
├── CLAUDE.md                 # AI agent'lar için sabit bağlam
└── README.md
```

## Hızlı Başlangıç

### 1. Gereksinimler

- **Flutter** 3.24+ (`flutter --version`)
- **Python** 3.11+ (`python3 --version`)
- **Xcode** (iOS için), **Android Studio** (Android için)
- Şu servislerde hesaplar: Supabase, OpenAI, RevenueCat, Firebase

### 2. Backend setup

```bash
cd backend
python3 -m venv venv
source venv/bin/activate       # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Env dosyası hazırla
cp .env.production.example .env
# .env'i aç ve değerleri doldur (Supabase, OpenAI, RevenueCat)

# Migration'ları Supabase SQL Editor'de çalıştır
# → migrations/001_initial_user_tables.sql
# → migrations/002_meal_tables.sql
# → migrations/003_coach_tables.sql

# Çalıştır
uvicorn app.main:app --reload --port 8000

# Test: curl http://localhost:8000/health
```

### 3. Frontend setup

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Firebase config dosyalarını koy:
# → android/app/google-services.json (Firebase Console'dan)
# → ios/Runner/GoogleService-Info.plist (Firebase Console'dan)

# Env dosyası hazırla
cp .env.production.example .env.development
# Değerleri doldur — geliştirme için:
# API_BASE_URL=http://10.0.2.2:8000  (Android emulator)
# API_BASE_URL=http://localhost:8000 (iOS simulator)

# Çalıştır
flutter run --dart-define-from-file=.env.development
```

## Geliştirme Akışı

### Günlük komutlar

```bash
# Frontend
cd app
flutter analyze                   # Static analysis
flutter test                      # Tüm testler
flutter test --coverage           # Coverage raporu
flutter run                       # Emulator'de başlat

# Backend
cd backend
source venv/bin/activate
pytest tests/ -v                  # Tüm testler
uvicorn app.main:app --reload     # Dev server
```

### Git hooks kur (bir kerelik)

```bash
./scripts/install-hooks.sh
```

Pre-commit hook otomatik çalışır:
- `.env` / Firebase config leak koruması
- Dart değişikliğinde `flutter analyze`
- Python değişikliğinde `pytest`
- Safety protokol dosyası silme uyarısı

### Branch stratejisi

- `main` → production
- `develop` → staging (CI her PR'da çalışır)
- `feature/*` → PR açarken `develop`'a merge

## Test Stratejisi

### Frontend (98 test)

```bash
cd app
flutter test
```

| Kategori | Konum | Sayı |
|---|---|---|
| Error mapping | `test/core/` | 7 |
| Auth providers | `test/features/auth/` | 18 |
| Onboarding controller | `test/features/onboarding/` | 12 |
| Meal repository + providers + screen | `test/features/meal/` | 28 |
| Settings repository | `test/features/settings/` | 11 |
| Premium status | `test/features/premium/` | 9 |
| Home widgets | `test/features/home/` | 5 |
| Shared widgets (button, empty state) | `test/shared/` | 11 |

### Backend (29 test)

```bash
cd backend
pytest tests/ -v
```

| Kategori | Konum | Sayı |
|---|---|---|
| ApiResponse contract | `tests/test_api_response.py` | 6 |
| Feature matrix | `tests/test_feature_matrix.py` | 7 |
| **Safety service (KRİTİK)** | `tests/test_safety_service.py` | 16 |

### CI

Her PR'da `.github/workflows/ci.yml` 3 job paralel:

1. **flutter-test** — analyze + test + coverage upload
2. **backend-test** — pytest
3. **protocol-check** — `docs/protocols/*.md` dosyalarının varlığı

## Production Build

### iOS → TestFlight

```bash
./scripts/build-ios.sh
# Sonra: Xcode → Archive → Distribute App → App Store Connect
```

### Android → Play Store

```bash
./scripts/build-android.sh
# Sonra: Play Console → Internal Testing → Upload .aab
```

### Build öncesi checklist

- [ ] `app/.env.production` dolu
- [ ] `backend/.env.production` dolu (deployment env vars olarak set)
- [ ] `android/app/google-services.json` yerinde
- [ ] `ios/Runner/GoogleService-Info.plist` yerinde
- [ ] `android/key.properties` + keystore (Android için)
- [ ] CI green (PR'lar merge edilmiş)
- [ ] `flutter test` ve `pytest` local'de de geçiyor
- [ ] Version bump (`pubspec.yaml` → `version: 1.0.1+2`)

## Mimari Prensipleri

1. **Wellness sınırları asla kırılamaz** — `docs/protocols/safety-wellness-boundary.md` her AI yanıtında enforce edilir.
2. **Backend source of truth** — premium tier RevenueCat değil, backend `premium_status_cache`'tir. Frontend RevenueCat webhook'a güvenmez.
3. **Riverpod state, Dio transport** — her feature: `data/repository.dart` + `providers/*.dart` + `screens/*.dart` + `widgets/*.dart`.
4. **Cache invalidation açık** — meal kaydedilince hem `todayMealsProvider` hem `homePayloadProvider` invalidate edilir.
5. **Error mapping typed** — `AppError.fromDio(e)` → `AuthError` / `LimitExceededError` / `NetworkError` / `ServerError` / `UnknownError`. Frontend bu tiplere göre UI karar verir (örn. `LimitExceededError` → paywall).

## Uçtan Uca Flow'lar

```
Signup
  → Acceptance (5 ekran, wellness onayları)
  → Onboarding (goal → profile → persona → notifications)
  → Result (backend submit, Mifflin-St Jeor kalori hedefi)
  → Home
    ├─ Trial gift modal (ilk açılışta free tier için, 7 gün hediye)
    ├─ Daily summary + meal list + coach card
    ├─ Meal capture / manual
    │   ├─ AI analizi → Result (edit/confirm) → kaydet
    │   ├─ Low/failed confidence → manuel giriş redirect
    │   └─ LimitExceededError → paywall modal
    ├─ Coach chat
    │   ├─ Thread persistence + audio playback (just_audio)
    │   ├─ Crisis/distress banner (tel:182 + TTB linki)
    │   └─ LimitExceededError → paywall modal
    └─ Settings
        ├─ Notification prefs (backend'e bağlı)
        ├─ Logout
        ├─ Delete account (backend + auth cleanup + login redirect)
        └─ Paywall (purchase, restore, trial claim)
```

## Monitoring

- **Crashlytics** — `core/monitoring/crash_reporter.dart` üzerinden feature+action custom keys
- **Auth state** → otomatik user ID tagging (beklenmeyen crash'lerde kullanıcı bağlanır)
- **Breadcrumb** — `CrashReporter.log('meal_analysis_started')` son 64 olayı tutar

## Güvenlik

- **`.env` ve Firebase config dosyaları git'te yok** (pre-commit + .gitignore koruması)
- **JWT validation** — backend her istekte Supabase JWT'yi doğrular
- **RevenueCat webhook signature** — `x-rc-signature` header'ı HMAC ile doğrulanır
- **Delete account** — GDPR/KVKK uyumlu, tüm tabloları + auth user'ı temizler
- **Safety service** — kriz tespit eden sabit metinler (AI üretimi değil, hard-coded)

## Ortak Problemler

### "Firebase init failed"
`google-services.json` / `GoogleService-Info.plist` eksik. Firebase Console'dan indir, yerleştir, yeniden derle. `main.dart` try/catch ile fallback'e düşer, uygulama çalışır ama analytics/crash yok.

### "Android emulator backend'e bağlanamıyor"
`API_BASE_URL=http://10.0.2.2:8000` kullan, `localhost` değil. 10.0.2.2 Android emulator'den host'a giden özel IP.

### "Riverpod provider generate edilmedi"
`dart run build_runner build --delete-conflicting-outputs` çalıştır. Değişiklik olduğunda tekrar.

### "LimitExceededError hiç çıkmıyor"
Free tier rate limit'i kontrol et: `backend/.env`'de `FREE_MEAL_ANALYSES_PER_DAY=3` olmalı. Premium status cache temizle: `ref.invalidate(premiumStatusProvider)`.

### "Pre-commit hook fail ediyor"
`git commit --no-verify` ile bypass edebilirsin ama altındaki sorunu da çöz. Hata mesajları hangi kontrolün fail olduğunu söyler.

## Lisans

Proprietary. Tüm hakları saklıdır.

## İletişim

- Support: support@nuveli.com.tr
- Dev: docs/ klasöründeki protokoller ve CLAUDE.md
