# Nuveli — Session Handoff (last updated 2026-05-24, ~13:30 TRT)

> **Bu doküman**: bir Claude Code oturumundan diğerine geçişi temiz tutar.
> Yeni chat açıldığında okunur, "neredeyiz, sırada ne var" net olur.
>
> **Devamlılık komutu (yeni chat):**
> ```
> Read docs/SESSION_HANDOFF.md and continue from "Sırada ne var" section.
> ```

---

## Şu anda neredeyiz

**Sprint A + canlı QA + Coach pipeline + Profile edit hepsi shipped.** Backend & infrastructure prod-ready. UI tarafında F1/F2/F4 + profile edit + 11 kritik bug fix main'de. v1.0.0+2 → v1.1.0+15.

### Önceki sesyonda shipped (2026-05-23 PM)

```
PR #129  feat(planner): meal planner v0 (F4)        squash-merged
PR #128  feat(coach): AI Coach daily-insight (F2)   squash-merged
PR #127  docs: session handoff Sprint A             squash-merged
PR #124  feat(meal): AI meal scan UI (F1)           squash-merged
```

### Bu sesyonda (2026-05-23 → 2026-05-24, ~17 saat) shipped

**Schema drift / production fixes:**
- PR #130 `fix(auth)` — Supabase SMTP bypass (`POST /auth/signup` admin API auto-confirm). Mail SMTP rate-limit'i artık launch blocker değil.
- RC iOS native fatal guard'ları (`Purchases.*` calls `_initialized` check)
- Auth screens `popUntil(isFirst)` (AuthGate görünmüyordu)
- Habits adapter (`title`/`display_order`/`schedule_type`/`days_of_week`/`habit_type` drift)
- Habits enum normalize (`target_type='check'` not in Literal)
- `insights_generation_service` habits.name → habits.id
- Meals POST `notes` column drift strip
- Weight goals `status='cancelled'` → `'abandoned'` (check constraint)
- Coach `ai_insights.daily_recap` NOT NULL → dump payload as placeholder
- Dashboard TodaySummary field names (`consumed_*` vs `calories_*`)
- Water portion-picker freeze fix (TextField removed, 11 presets)

**Yeni özellikler:**
- Profile edit screen (PATCH /me, settings gear wire)
- Coach pipeline cron (APScheduler 02:00 UTC daily) + FCM push backend
- `services/fcm_service.py` (FCM v1 + token pruning)
- `/me/device-tokens` POST + DELETE endpoints
- Flutter `fcm_token_register.dart` glue (auth listener wire)
- `docs/ops/cron.md` (Render Cron Service alternative + FCM env setup)

**Render env eklendi (Ali, 2026-05-24 öğle):**
- `FIREBASE_PROJECT_ID=nuveli`
- `FIREBASE_SERVICE_ACCOUNT_JSON_B64=<3145 chars>`

**Live state son log (Render, 2026-05-24 10:15 UTC):**
```
GET /me 200, /analytics/dashboard 200, /coach/today 200,
/habits 200, /meals?date=... 200, /water/weekly 200,
/weight/goal 200, /analytics/weekly 200, /me/onboarding 200
```
Tüm critical endpoint'ler artık 200.

**Test counts**: 410 → 460 host tests passing. analyze: pre-existing 4 warning (main_integration_snippet noise).

**Versions**: pubspec `1.0.0+2 → 1.1.0+15`. CHANGELOG `app/CHANGELOG.md` tüm bu sesyonun fix'lerini kategorize eder.

### F2 Coach mimari notu

Backend `/coach/today` insight-only (chat/TTS yok — sen istemedin, mood-bubble ayrı). Cron her gün 02:00 UTC GPT-4o ile fresh insight üretir. APScheduler in-process (Render free tier sleep'te miss edebilir → Render Cron Service alternatif kurulumu `docs/ops/cron.md`).

FCM push backend HAZIR + Render env LIVE. **iOS Simulator FCM destek**lemez (APNS yok) → gerçek push test için iPhone gerek. Real device + Apple Developer enrollment ($99) gelince zero-code-change çalışır.

---

## Sırada ne var (yeni sesyonda öncelik)

### 1. Lokal mood-bubble katmanı (sen 2 kez ertelendin, en üst öncelik)
- Persona × situation copy-bank (gentle/direct/funny/calm × under-target/over/streak-broken/water-low/...)
- LOKAL (no-OpenAI), anlık feedback meal log save / water low / streak milestone'da
- ~yarım gün iş
- Memory: `project_mood_bubble_planned.md`
- Sıfır OpenAI maliyet — Coach AI daily insight üstüne katman

### 2. Debug exception leak revert (PR sonra)
- `backend/main.py` 500 handler şu an `_debug_exc` (exception class + truncated message) leak ediyor — QA için intentional
- Production submit ÖNCESİ revert şart (memory'de: feedback_version_bump_per_fix + task #43)
- 2 satır revert + version bump + CHANGELOG

### 3. Settings tab QA (sen 3 kez sordun, hiç screenshot atmadın)
- Senin "Settings çalışmıyor" iddian → ben investigator agent ile dosyayı audit ettim, gerçek bug bulunmadı
- Sim'de Settings tab açıp screenshot atarsan diagnose ederim
- Risk: Coach offline + meal save errors gibi UI'da bir şey olabilir, log lazım

### 4. Cihaz QA (real iPhone)
- Sim ile yapamadığımız:
  - FCM push real-end-to-end (APNS only on device)
  - Camera shot for Meal Scan (sim no camera)
  - Apple Sign In (sim limited)
  - Performance / battery / animations real frame rate
- iOS App Store submission gelince: Apple Developer enrollment ($99) → TestFlight build → real device QA

### 5. Render Cron Service kurulumu (opsiyonel)
- Şu an APScheduler in-process (`APP_ENABLE_INTERNAL_CRON=true` default)
- Render free tier 15dk sleep → cron miss edebilir
- Reliable trigger için: `docs/ops/cron.md` Option B (web UI'da Cron Job kurma, 5dk)

### 6. F4 v0.1 — Meal Planner write side
- Add-meal-to-plan modal (manual POST /meal-plans)
- AI generate dietary preferences sheet (repo metodu hazır)
- Recipe browser
- Edit/delete plan entries

### 7. Açık issue'lar (memory'de mevcut)
- Schema drift endemic (`project_schema_drift_endemic.md`) — yeni endpoint yazınca prod cols verify et
- weight_goals onboarding insert race (duplicate idx_weight_goals_one_active) — geri planda warning, UX etkisiz, ileride fix

---

## Memory state (önemli sesyon karşılaşmaları)

| Memory | Özet |
|---|---|
| `user_ali.md` | Solo dev, Android-first launch, iOS paused |
| `feedback_version_bump_per_fix.md` | **Her fix sonrası version bump + CHANGELOG + agent kullan** (bugün öğrendi) |
| `feedback_squash_merge.md` | `... (#NN)` convention |
| `feedback_no_bash_confirmation.md` | Komutu çalıştır, "should I" sorma |
| `project_coach_backend_insight_only.md` | `/coach/chat` ve `/coach/audio` YOK; backend insight-only |
| `project_mood_bubble_planned.md` | Lokal katman, OpenAI'siz, ayrı sesyon |
| `project_schema_drift_endemic.md` | Prod migration ≠ repo migration; her zaman `information_schema` doğrula |
| `project_launch_state_real.md` | "PR merged" ≠ "production ready"; cihaz QA olmadan asla "bitti" deme |

---

## Yeni sesyon ilk komutu

```
Read docs/SESSION_HANDOFF.md and pick the next task from "Sırada ne var".
Default to #1 (mood-bubble) unless I say otherwise.
```

Ya da spesifik:
```
docs/SESSION_HANDOFF.md'i oku. Mood-bubble katmanını uygula —
persona × situation copy bank, no-OpenAI, anlık feedback hooks.
```

---

## Açık riskler

1. **Schema drift hâlâ devam edebilir** — bu sesyonda 4 farklı tablo'da drift bulduk (habits, meals, weight_goals, ai_insights). Başka tablolarda da olabilir. **Her yeni endpoint için ilk `information_schema.columns` ile doğrula**, sonra kod yaz.

2. **Debug exc leak hala live** — `backend/main.py` 500 handler `_debug_exc` field'ı production response'a koyuyor. Launch öncesi revert.

3. **iOS not staged** — Apple enrollment $99 paused. iOS shipped olmayacak ama kod hazır. FCM push iOS sim'de test edilemiyor (APNS yok).

4. **Cron miss riski** — APScheduler in-process Render free tier 15min sleep'inde miss edebilir. Eğer "kullanıcı her sabah insight görmeli" critical ise, Render Cron Service ($7/ay) gerek.

5. **AuthGate `error → OnboardingScreen` fallback yanlış** — JWT expired olunca user onboarding step 1'de başlıyor. Doğrusu: hatayı surface et + retry / re-login butonu. Yeni sesyon küçük UX fix olabilir.

---

**Hazırlandı:** 2026-05-24 (öğle, Coach pipeline live + Render env eklendi sonrası)
**Bir sonraki güncelleme:** mood-bubble shipped olunca veya prod launch'tan önce
