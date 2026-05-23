# Nuveli Changelog

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
