# Nuveli Changelog

## [1.4.1+21] - 2026-05-24 - Fix release-build black screen (Android-first config)

### Fix
- **P0 launch crash:** `AppConfig.isProductionConfigValid` required *both*
  `RC_APPLE_KEY` and `RC_GOOGLE_KEY` to be non-empty. The Android-first
  release ships no Apple key (iOS paused), so the guard failed and `main()`
  threw a `StateError` before `runApp` → **black screen on launch**. Now it
  needs only the current platform's RC key (at least one present). The
  per-platform key is still selected at runtime in `RevenueCatService`.

## [1.4.0+20] - 2026-05-24 - Meal history + placeholder polish + i18n slice

### Features
- **Meal history screen** — the dashboard "See all" now opens a full meal
  history (was a "Chat 17 coming soon" toast). `GET /meals` paginated
  (newest first), grouped by day with per-day totals, swipe-to-delete with
  a confirm dialog and dashboard refresh. New repo `getMealHistory`.

### Polish
- **Welcome logo** uses the real brand mark (`assets/icons/splash_logo.png`)
  instead of the water-drop placeholder (graceful fallback if it can't load).
- **Google sign-in button** gets a clean white-circle "G" badge instead of
  the thin `g_mobiledata` glyph.

### i18n (incremental)
- Localized the new meal-history screen across all 7 locales (4 new
  `mealHistory*`/`historyYesterday` keys; delete dialog + Today reuse
  existing keys). First slice of the broader hardcoded-string migration now
  that l10n is active — meal-planner sheets, settings, and dashboard remain
  hardcoded EN and are the next incremental targets.

### Tests
- +4 host tests: `getMealHistory` pagination contract + `groupMealsByDay`.
  493 → 497 passing.

## [1.3.0+19] - 2026-05-24 - Meal Planner write side (F4 v0.1)

### Features
- **Manual add-to-plan** — a "+" on each day (and an "Add manually" CTA on
  the empty state) opens a sheet to add a custom meal: meal type, date,
  name, calories (entry total), optional macros, servings, note →
  `POST /meal-plans`.
- **Edit entry** — tap an entry → Edit name/note (`PATCH /meal-plans/{id}`).
  Servings/calorie changes go through delete + re-add, because the backend
  PATCH path does not recompute totals on a servings change (documented in
  the repo + edit sheet).
- **Delete entry** — tap → Remove, with a confirm dialog (`DELETE`).
- **AI generate sheet** — replaces the v0 "coming soon" snackbar with a
  real dietary-preferences sheet (dietary preference, avoid ingredients,
  calorie target prefilled from profile, meals/day) → `POST /meal-plans/generate`.
  Premium-gated upstream.
- Write actions are gated to weeks the user can view (free = current week);
  the read paths, week navigator, and grocery list are unchanged.

### Tests
- +9 host tests: repository request-contract (POST/PATCH/DELETE payload
  keys + paths, mocktail) and the add sheet (validation + typed create
  call). 484 → 493 passing.

### Notes
- Recipe browser intentionally deferred — it only adds value once the
  prod `recipes` table is confirmed populated (seeded in migration 013,
  but prod state unverified). Custom entry covers the core need.

## [1.2.1+18] - 2026-05-24 - Revert debug exception leak (launch blocker)

### Security
- `backend/main.py` unhandled-exception handler no longer returns the
  `_debug_exc` field (exception class + truncated message) in 500
  response bodies. It was added intentionally for live-prod QA without
  Render dashboard access; exposing exception class names is a soft
  information-disclosure issue (can leak schema/internal names) and had
  to come out before store submission. Full trace is still logged
  server-side. Backend suite: 139 passed / 8 skipped.

## [1.2.0+17] - 2026-05-24 - Local coach mood bubbles + i18n activation

### Features
- **Mood-bubble layer** (`lib/features/coach/mood/`) — a local,
  zero-OpenAI persona layer on top of the daily Coach insight. Fires an
  instant, on-device bubble at real user moments:
  - **Meal save** — situation derived from today's post-save totals:
    first meal / under target / on track / over target.
  - **Water-low** — nudge after a water add if still behind target past
    14:00.
  - **Streak milestone** — celebrates 3/7/14/21/30/50/100/365-day
    streaks, de-duped per value via `MoodSeenStore` so it fires once.
  - 4 personas (gentle / funny / direct / calm) × 6 situations = 24
    copy lines, localized in all 7 shipped locales. Over-target copy
    follows the wellness boundary (no shame, no deficit drama, no
    compensation framing).
- **Coach persona picker** in Settings (`coachToneQuestion` + the
  long-dormant `personaGentle/Funny/Direct/Calm` strings, finally wired).
  Local-only (SharedPreferences); never round-trips to the backend.

### Infrastructure
- **Activated app-wide localization.** `MaterialApp` now wires
  `localizationsDelegates` + `supportedLocales` + a `locale` driven by
  `globalLanguageNotifier`, and `main()` calls `preloadLanguage()`. The
  690 existing `.arb` keys and the in-app language switcher were built but
  never connected to the runtime — they are now live. (Screens still
  using hardcoded English strings are unaffected until individually
  migrated.)

### Tests
- +24 host tests: situation detection (meal/water/streak), copy-bank
  resolution across locales, persona persistence. 460 → 484 passing.

## [1.1.1+16] - 2026-05-24 - Session handoff doc refresh

### Docs
- `docs/SESSION_HANDOFF.md` rewritten as of 2026-05-24 ~13:30 TRT:
  enumerate every fix this session shipped (schema drifts, signup
  bypass, auth popUntil, water freeze, RC iOS guards, profile edit,
  Coach pipeline cron + FCM, dashboard kcal parse), Render env state
  after Firebase setup, full live-endpoint smoke log, and a 7-item
  next-session priority list. Mood-bubble flagged as #1 (Ali asked
  twice). Debug exc revert flagged as launch-blocker #2.
- Memory: `project_coach_pipeline_live.md` snapshot — what's wired,
  what env is set on Render, and the iOS-sim APNS gap so next session
  doesn't think push is broken.

No code changes.

## [1.1.0+15] - 2026-05-24 - Coach pipeline: cron + push (A→B→C)

### Backend
- **A.** APScheduler wired in `main.py` lifespan. Daily at 02:00 UTC
  it calls `cron.daily_insights_job.run_for_all_users()` which generates
  a fresh Coach insight for every active user. Default ON; turn off with
  `APP_ENABLE_INTERNAL_CRON=false` if you switch to Option B (Render
  Cron Service — see `docs/ops/cron.md`).
- **B.** `docs/ops/cron.md` — Render Cron Service setup, smoke-test
  command, env list, cost-guard math, and Phase-C wiring notes.
- **C.** `services/fcm_service.py` — FCM v1 push helper. Gated on
  `FIREBASE_PROJECT_ID` + `FIREBASE_SERVICE_ACCOUNT_JSON_B64`; no-ops
  silently when env missing. Prunes UNREGISTERED / INVALID_ARGUMENT
  tokens lazily. Daily-insights job calls `send_to_user` with
  `data={"route": "/coach", "kind": "daily_insight"}` so the tap
  payload can deep-link.
- `POST /me/device-tokens` and `DELETE /me/device-tokens/{token}` —
  Flutter calls these on sign-in / sign-out / `onTokenRefresh`. Dedup
  is server-side: an existing token row is deleted before re-insert so
  a token migrating users (rare but real) doesn't double-fire.
- `google-auth==2.34.0` added to requirements (only required when FCM
  env is present at runtime; httpx was already pinned).

### Flutter
- `core/notifications/fcm_token_register.dart` — minimal glue that
  requests permission (iOS), fetches token, POSTs to backend, and
  subscribes to `onTokenRefresh`. Cancels on sign-out and DELETEs the
  token so the backend stops addressing the device.
- `main.dart` `_wireAuthRevenueCatSync` now also fires FCM register /
  unregister inside a separate try block — RC failure (dev build w/o
  RC_APPLE_KEY) doesn't skip push registration.

### What's still needed (one-time, Ali's hands)
- Firebase Console → Project Settings → Service accounts →
  Generate private key → base64 → set
  `FIREBASE_PROJECT_ID` + `FIREBASE_SERVICE_ACCOUNT_JSON_B64` on the
  Render backend service. Cron + Flutter side are both ready and idle
  until those env vars land.

## [1.0.4+14] - 2026-05-23 - Profile edit + water-test rewrite

### Features
- **Profile edit screen** — settings gear in `ProfileHeader` now opens
  `ProfileEditScreen` instead of debug-printing. Form covers name, sex,
  date of birth, height, weight, activity level, dietary preference;
  ships only changed fields to `PATCH /me` then invalidates
  profileProvider so the goals screen re-fetches.

### Tests
- Rewrote `water_quick_card_test.dart` to match the new chip-only
  picker (the "Custom (ml)" TextField was removed in 1.0.3 for the
  iOS freeze fix; the tests were still poking at it). 4 obsolete
  tests → 4 new tests covering the widened preset set + 1000 ml
  chip dispatch. 458 → 460 passing.

## [1.0.3+13] - 2026-05-23 - Sprint A live-device QA pass

### Features
- F1 AI Meal Scan UI (#124) — camera/gallery, preview/retake, rotating
  progress text, editable result with per-food + scale slider, premium
  gate (5/day free) routes to paywall.
- F2 AI Coach insight surface (#128) — 6th bottom-nav tab. Nutrition
  score arc, today's coaching paragraph, tip list with all 8 backend
  `TipIcon` glyphs, one-tap `recommended_action` apply.
- F4 Meal Planner v0 (#129) — read-only weekly view, day cards, grocery
  bottom sheet, premium paywall for past/future weeks. Manual add and
  AI generate land in v0.1.

### Bug fixes (live-device QA found)
- **Signup SMTP bypass** — Supabase's default mailer rate-limits at
  ~2/hr; users got stuck on "verify your email" with no mail ever
  arriving. New `POST /auth/signup` mints users with
  `email_confirm=True` via the service-role admin API; Flutter calls
  it then `signInWithPassword`. Revert path documented in the router.
- **iOS RC native fatal** — `Purchases.*` calls on an unconfigured SDK
  raised a Swift `fatalError` (SIGTRAP) that no Dart try/catch could
  recover. Every `RevenueCatService` method now guards on
  `_initialized` and returns falsy when the SDK was skipped.
- **Auth screens didn't pop** — `signUpWithEmail` / `signInWithEmail`
  / Apple / Google now `popUntil(isFirst)` so AuthGate becomes
  visible with the new session.
- **Habits schema drift adapter** — prod table uses `title`,
  `display_order`, `schedule_type`, `days_of_week TEXT[]`, plus a
  NOT NULL `habit_type` (default `check`). Router translates between
  the public API contract and the actual columns on every path; enum
  values outside Literal normalize to safe defaults.
- **Coach `daily_recap` NOT NULL** — `ai_insights` row insert was
  500ing because the prompt didn't yet produce a recap field. We
  dump the full payload under a `summary` key as a placeholder.
- **Meals `notes` column drift** — prod table has no `notes`; POST
  body now strips that field plus other nulls.
- **Weight goals `status` enum** — `cancelled` violated the prod
  check constraint; the deactivate-old-goal path now writes
  `abandoned`.
- **Dashboard TodaySummary `consumed_*` parse** — backend ships
  `consumed_calories` / `daily_calorie_target` / `meal_count_today`;
  Flutter model was reading the older `calories_consumed` etc keys
  and seeing 0. Both spellings now accepted.
- **Water portion-picker freeze** — focusing the "Custom (ml)"
  TextField inside the bottom sheet triggered an infinite-width
  BoxConstraints cascade that killed the simulator. TextField
  removed; preset list widened to 11 options (100…1000 ml).
- **insights_generation_service habits select** — was reading
  `habits.name`; switched to `id` only (we don't need title at the
  insight-aggregate level).

### Tooling
- `backend/scripts/confirm_user_email.py` — flip
  `email_confirmed_at` for any account via service-role admin API.
- `backend/scripts/seed_reviewer_account.py` — bug fix
  (`init_supabase()` returns None → use `get_supabase()`).
- `backend/main.py` exception handler temporarily leaks
  `_debug_exc` (class + truncated message) in 500 responses so we
  can diagnose prod issues without Render dashboard access. **Must
  revert before App Store / Play Store submit** (tracked as
  Task #43).

### Tests
- 410 → 461+ host tests (+51): scan models, scan-count gate, coach
  insight JSON, tip-icon mapping for all 8 backend values,
  regen-gate transitions, planner JSON, gate transitions.

## [0.9.0+1] - 2026-05-04 - Pre-launch hazirligi

### Tasarim
- Ocean palette uygulandi (web sitesi ile uyumlu)
- Dark tema mukemmellestirildi
- Coach card mor gradient ocean aqua degistirildi
- Bu Hafta grafigi pixel overflow duzeltildi

### Altyapi
- Supabase Auth tam entegrasyonu
- Backend API (Render) baglantisi kuruldu
- 41 route GoRouter ile yapilandirildi
- Compile-time env yonetimi

### Yapi
- iOS app icon guncellendi (15 boyut)
- Android adaptive icon eklendi
- Build hatalari cozuldu (209 to 0)
- shared_preferences eklendi

### Web (nuveli.com.tr)
- A+ skoru elde edildi (95/100)
- 5 yasal sayfa redesign
- FAQPage + WebSite + Organization schema
- iOS PWA tam destegi

## Versiyonlama Kurali

MAJOR.MINOR.PATCH+BUILD

- Bug fix: 0.9.0 to 0.9.1
- Yeni ozellik: 0.9.0 to 0.10.0
- Major redesign: 1.x.x to 2.0.0
- Her build: +1 to +2 to +3

## Yol Haritasi

- 0.9.x - Pre-launch, TestFlight beta
- 1.0.0 - App Store launch
- 1.x.x - Post-launch updates
