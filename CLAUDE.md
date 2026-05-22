# CLAUDE.md — Nuveli Agent Memory

Bu dosya Cursor, Claude Code ve benzeri coding agent'lar için sabit bağlam kaynağıdır.
Her büyük promptun başında bu dosyanın içeriği aktif tutulmalıdır.

---

## Proje Kimliği

- **Uygulama adı:** Nuveli
- **Tagline:** AI Calorie Coach
- **Destek:** support@nuveli.com.tr
- **Platform:** Flutter (iOS + Android, tek kod tabanı)

---

## Sabit Üst Kurallar

1. **Wellness uygulamasıdır.** Tıbbi teşhis, tedavi, klinik diyet planı veya doktor/diyetisyen yerine geçen yönlendirme üretme.
2. **V2/V3 özellik ekleme.** Sadece `docs/product/mvp-scope.md` içindeki özellikler geliştirilebilir.
3. **Wellness sınırı kırılamaz.** `docs/protocols/safety-wellness-boundary.md` her zaman geçerlidir.
4. **Kod sade olacak.** Gereksiz abstraction ekleme. Test edilebilirlik önceliklidir.
5. **Her görev sonunda** şunları yaz: değişen dosyalar, eksikler, test adımları.

---

## Stack Özeti

```
Flutter          → Mobile (iOS + Android)
FastAPI          → Backend
Supabase         → Auth, PostgreSQL DB, Storage
RevenueCat       → Subscription yönetimi
FCM              → Push notification
Firebase Analytics / Crashlytics → Analytics & crash
OpenAI Vision    → Yemek fotoğrafı analizi
OpenAI TTS       → Koç sesli yanıtı (kısa)
```

---

## Klasör Yapısı — Flutter

```
app/lib/
├── core/
│   ├── config/
│   ├── monitoring/       # CrashReporter (Crashlytics wrapper)
│   ├── network/          # ApiClient (Dio), AppError
│   ├── providers/        # Supabase, RevenueCat, Firebase init
│   ├── routing/          # GoRouter + page transitions
│   └── theme/
├── features/
│   ├── auth/             # login, signup, splash, forgot password
│   ├── onboarding/       # age gate, acceptance, goal, profile, coach persona
│   ├── home/
│   ├── meal/             # capture, manual entry, AI analysis result
│   ├── coach/            # chat, audio playback, crisis banner
│   ├── premium/          # paywall, trial gift modal
│   └── settings/         # notification prefs, delete account
└── shared/widgets/       # PrimaryButton, AppScaffold, Skeleton, EmptyStateView
```

## Klasör Yapısı — Backend

```
backend/
├── main.py               # FastAPI app entry + middleware + lifespan
├── config.py             # Pydantic Settings (env vars)
├── routers/              # auth, meals, water, habits, weight, meal_planner,
│                         #   ai_coach, analytics, achievements, premium, profiles
├── services/             # Business logic (openai_vision, insights_generation,
│                         #   revenuecat, streak, achievement, nutrition_score, ...)
├── core/                 # auth (JWT), supabase_client, exceptions, logging,
│                         #   rate_limit (H-2)
├── models/               # Pydantic request/response (Chat 25 audit calls
│                         #   these "schemas" — terms are interchangeable)
├── migrations/           # SQL migration files mirroring supabase/migrations/
├── prompts/              # System prompts for OpenAI calls
├── cron/                 # Scheduled jobs (apscheduler)
├── scripts/              # One-shot ops scripts (seed_reviewer_account, ...)
└── tests/                # pytest suite (38 tests as of 2026-05-21)
```

## Test Dosyaları

```
app/test/                 # 372 Dart test (host-side)
app/integration_test/     #   5 device-level tests (real Keychain)
backend/tests/            # 136 Python test (active) + 8 skipped
```

Suite koşumu:
```bash
flutter test                                              # host
flutter test integration_test/ -d <booted-simulator>      # device
cd backend && source .venv311/bin/activate && pytest      # backend
```

---

## Kritik Protokol Dosyaları

| Dosya | Konu |
|-------|------|
| `docs/protocols/coach-ai-protocol.md` | Koç AI davranış kuralları |
| `docs/protocols/meal-analysis-ai-protocol.md` | Yemek analizi AI kuralları |
| `docs/protocols/nutrition-guidance-protocol.md` | Beslenme rehberliği sınırları |
| `docs/protocols/safety-wellness-boundary.md` | Güvenlik ve wellness sınırı |

---

## Premium Model Özeti

- **Free:** Günlük sınırlı meal analizi, temel koç
- **Trial:** 7 gün tam özellik
- **Premium:** Sınırsız analiz, gelişmiş koç, haftalık/aylık özet

Feature gating detayı: `docs/product/feature-gating.md`

---

## Yasaklı Davranışlar

- `calori deficit` sonuçlarını dramatize etme
- Kullanıcıyı kötü gün için suçlayan dil üretme
- Tıbbi referans verme (doktor, diyetisyen, klinik)
- 800 kcal altı hedef önerme
- Telafi davranışı (purging, aşırı egzersiz) ima etme

## gstack (REQUIRED — global install)

**Before doing ANY work, verify gstack is installed:**

```bash
test -d ~/.claude/skills/gstack/bin && echo "GSTACK_OK" || echo "GSTACK_MISSING"
```

If GSTACK_MISSING: STOP. Do not proceed. Tell the user:

> gstack is required for all AI-assisted work in this repo.
> Install it:
> ```bash
> git clone --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
> cd ~/.claude/skills/gstack && ./setup --team
> ```
> Then restart your AI coding tool.

Do not skip skills, ignore gstack errors, or work around missing gstack.

Using gstack skills: After install, skills like /qa, /ship, /review, /investigate,
and /browse are available. Use /browse for all web browsing.
Use ~/.claude/skills/gstack/... for gstack file paths (the global path).
