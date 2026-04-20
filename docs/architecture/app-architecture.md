# Uygulama Mimarisi

## Genel Görünüm

```
┌─────────────────────────────────────┐
│          Flutter App                │
│  (iOS + Android, tek kod tabanı)    │
└──────────────┬──────────────────────┘
               │ HTTPS / REST
┌──────────────▼──────────────────────┐
│         FastAPI Backend             │
│  (Auth middleware, service layer)   │
└──────┬───────────┬──────────────────┘
       │           │
┌──────▼──┐  ┌─────▼──────────────────┐
│Supabase │  │  OpenAI API            │
│Auth/DB  │  │  Vision + TTS          │
│Storage  │  └────────────────────────┘
└─────────┘
```

---

## Flutter Katmanları

```
Presentation Layer  →  Screens + Widgets
State Layer         →  Riverpod providers (veya Bloc)
Data Layer          →  Repository pattern
Network Layer       →  Dio + interceptors
Local Cache         →  Hive / SharedPreferences
```

### Klasör Yapısı

```
app/lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/         # AppConfig, env
│   ├── routing/        # GoRouter
│   └── theme/          # AppTheme, AppColors, AppTextStyles
├── features/
│   ├── auth/
│   ├── onboarding/
│   ├── meal/
│   ├── home/
│   ├── coach/
│   ├── progress/
│   ├── premium/
│   └── settings/
└── shared/
    ├── widgets/
    └── utils/
```

---

## Backend Katmanları

```
Router Layer    →  FastAPI routes (ince, sadece HTTP işleme)
Service Layer   →  İş mantığı buradadır
DB Layer        →  Supabase client wrappers
Schema Layer    →  Pydantic request/response modeller
```

### Klasör Yapısı

```
backend/app/
├── main.py
├── core/
│   ├── config.py
│   ├── security.py
│   ├── logging.py
│   └── dependencies.py
├── api/
│   ├── router.py
│   └── routes/
│       ├── health.py
│       ├── profile.py
│       ├── meals.py
│       ├── coach.py
│       ├── home.py
│       ├── premium.py
│       └── ...
├── services/
│   ├── meal_service.py
│   ├── coach_service.py
│   ├── decision_engine.py
│   ├── prompt_engine.py
│   └── tts_service.py
├── db/
│   └── client.py
└── schemas/
    └── common.py
```

---

## Auth Akışı

1. Kullanıcı Supabase Auth ile giriş yapar (email/magic link veya Apple/Google OAuth)
2. Supabase JWT token alır
3. Flutter her API isteğinde `Authorization: Bearer <token>` header'ı gönderir
4. FastAPI `dependencies.py` içindeki `get_current_user` dependency token'ı doğrular

---

## Offline & Cache Stratejisi

- Home payload: 5 dakika local cache (Hive)
- Meal listesi: Günlük local cache, pull-to-refresh ile yenile
- Koç yanıtı: Cache yok, her seferinde fresh
- Bootstrap data: Uygulama açılışında fetch, local'e yaz

---

## Üçüncü Taraf Servisler

| Servis | Kullanım | SDK |
|--------|---------|-----|
| Supabase | Auth, DB, Storage | `supabase_flutter` |
| RevenueCat | Subscription | `purchases_flutter` |
| FCM | Push | `firebase_messaging` |
| Firebase Analytics | Event tracking | `firebase_analytics` |
| Crashlytics | Crash log | `firebase_crashlytics` |
| OpenAI | Vision + TTS | REST API (backend'den) |
