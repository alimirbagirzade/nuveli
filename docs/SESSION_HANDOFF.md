# Nuveli — Session Handoff (last updated 2026-05-27, ~00:30 TRT)

> Continuity doc between Claude Code sessions. New chat:
> `Read docs/SESSION_HANDOFF.md and continue from "Now / next".`

---

## Where we are — v1.8.0+34, main, in Play **closed/internal testing**

Android-first. **iOS paused** (Apple enrollment deferred; code kept aligned).
App is in Play testing with real testers; first AAB (versionCode 28) uploaded
and installed. Monetization (RevenueCat + Play Billing) is **configured and a
real test purchase succeeded**. Backend is on Render (free tier) + Supabase +
OpenAI; **UptimeRobot pings `/health` every 5 min** so the dyno no longer
cold-starts.

### This session (2026-05-27) — 3 PRs merged (#152–154) + AAB built
Repo cleanup + launch-prep docs. **No app code, no version bump** (still v1.8.0+34).

**#152 — Repo cleanup:** gitignore `app/CLAUDE.md` (ruflo config); sync
`app/ios/Podfile.lock` (flutter_secure_storage + share_plus pods, iOS aligned);
add `logo/Nuveli logo with water flourish.png`. Working tree now clean (all
other tooling junk already gitignored).

**#153 — Health Connect disclosure + TR privacy policy:**
- `docs/ops/play-data-safety.md`: new **Health Connect (Android)** section —
  the *separate* Play "Health apps declaration" obligation (read-only
  Exercise/Active-calories/Steps, opt-in, display-only, deleted with account);
  Health & fitness data-type row split to disclose imported workouts.
- `docs/legal/privacy-policy.md` (EN): new §3a Health Connect.
- `docs/legal/privacy-policy.tr.md` (**NEW**): full TR translation + KVKK-6698
  legal-verify TODO. Data types verified against `health_service.dart`.

**#154 — Play Store listing copy + guide + icon:**
- `docs/ops/play-store-listing.md`: ready-to-paste TR+EN copy (name/short/full
  within 30/80/4000), step-by-step Play Console guide (release-blockers 🔒),
  content-rating answers, screenshot shot-list (5 flows).
- `logo/store-icon-512.png` (**NEW**): 512² app icon. Feature graphic
  `logo/1024 x 500.png` already 1024×500.

**AAB built (not yet uploaded):** `app/build/app/outputs/bundle/release/app-release.aab`
(70 MB, **versionCode 34**, release-signed, prod env, minSdk 26). Pre-flight
clean: release guards gated, signing + `.env.production` present, gradle uses
`flutter.versionCode`. **Ali still needs to upload it to the test track.**

### Earlier session (2026-05-26) — 2 PRs merged (#149–150)
Built the **exercise / activity** feature end-to-end. Versions 1.6.9+32 → **1.8.0+34**.

**#149 — Exercise logging (v1.7.0+33), device-verified end-to-end on the sim:**
- `/exercise` backend (logs CRUD + today/weekly summaries) + migration **020
  `exercise_logs`** (owner RLS, applied to prod). 14 activity types.
- **Display-only MET calories** — `kcal = MET × weight_kg × hours` (weight from
  `user_profiles.weight_kg`), shown as a neutral "≈N kcal" badge. **NEVER added
  to the calorie budget** (wellness boundary; Ali first said no-calories, then
  reversed to display-only-via-MET — see [[project_exercise_feature]]).
- App: dashboard quick-card, scrollable log sheet, today list (swipe-delete),
  weekly bar chart. 7 locales. Verified: save → DB → badge → weekly card; daily
  budget unchanged.
- Bundled fixes: meal-planner/paywall English leftovers localized (7 locales);
  grocery error stops leaking raw backend text; `ApiEndpoints.baseUrl` now
  honours the `API_BASE_URL` dart-define (was hard-coded to prod).

**#150 — Phone health-data import (v1.8.0+34), Android-first:**
- `POST /exercise/import` (batch upsert deduped by `(user_id, external_id)`) +
  migration **021** (`source` / `external_id` / `device_calories` + dedupe
  index, applied to prod). `est_calories` prefers device calories, falls back to
  MET. Still display-only.
- App: `health: ^13.3.1`; Settings **opt-in toggle** (default off) + manual sync;
  Health Connect (Android) read of last 14 days → import; source glyph on
  imported rows. iOS HealthKit code-aligned but **entitlement NOT added** (paused).
- Native: `minSdk 26`, `MainActivity → FlutterFragmentActivity`, Health Connect
  perms/queries/rationale. **Android APK debug build passes.**
- ⚠️ **Live health-read is UNVERIFIED** — Health Connect can't be tested on the
  iOS sim / Android emulator; needs a real Android device.

Backend (198→216 tests green), `flutter analyze` clean, independent review on
every diff: no issues. Both deploy to Render on merge.

### This session (2026-05-25) — 8 PRs merged (#140–147)
Device-QA + two rounds of real-tester feedback. Versions 1.6.0+23 → **1.6.9+32**.

**Backend — LIVE on Render now (no app update needed):**
- Weight-goal **save fix** (the partial unique index is on `is_active`, code
  only flipped `status`) — verified by a tester.
- **AI food-name localization** on scan (foods/insight in the user's language) —
  verified via prod API.
- **Balanced-nutrition coaching** — coach insight flags a consistent macro skew
  and suggests concrete whole foods (veg/fruit/lean protein). Non-clinical.
- **Recipe browser + shopping list fix** — prod `recipes.calories` vs model
  `calories_per_serving` drift (+ grocery non-dict ingredient guard).

**App — waiting for the next AAB (build in ~2-3 days, after more feedback):**
- 🔴 **Auth launch-crash** (`LateInitializationError _authService`) — `late final`
  services moved to lazy field initializers.
- Dashboard greeting uses the profile name (not the email local-part "cfatihonal").
- Coach hides regenerate in the empty state.
- Profile overflow, coach empty-state, paywall/scan/dashboard/manual-add i18n.
- **Onboarding safe-pace guard** (step 4: target date + gentle too-fast warning;
  `core/utils/weight_pace.dart`).
- Brand: smiling water-drop mark + "Nuveli" wordmark.
- "7–8 saat uy" → "uyu" typo.

### Tester bug ledger — 15 reported, 14 fixed
All fixed except cold-start, which is now mitigated by UptimeRobot (#15).

### Features
- Done: editable meal-name, brand mark/wordmark, balanced-nutrition coaching,
  onboarding safe-pace guard.
- **Exercise logging (manual)** → ✅ SHIPPED (#149, v1.7.0+33), device-verified.
  Display-only MET calories; never affects budget.
- **Wearable / smartwatch sync** → ✅ SHIPPED Android-first (#150, v1.8.0+34) via
  Health Connect import. iOS HealthKit gated until enrollment. **Live read still
  needs real-Android verification.**
- **Prescriptive meal/diet plan** → never (clinical diet plan = boundary).
- `POST /recipes` is still schema-mismatched (DB `calories` + NOT NULL
  `meal_types`) — testers only browse; fix when recipe creation is needed.

---

## Now / next

**The AAB (vCode 34) is built and waiting.** The critical path is now: upload →
install → device-verify Health Connect → screenshots → host policies → fill Play
Console → submit. Steps 1–2 unblock everything else.

1. **Upload the AAB** — `app/build/app/outputs/bundle/release/app-release.aab`
   (vCode 34, already built this session) → Play Console → test track → release
   to testers (mostly Ali). Then update the device to vCode 34.
2. **Verify Health Connect import on a real Android device** (the one untested
   path — blocked until vCode 34 is installed; the live tester still has +28
   which predates the feature): Settings → "Connect phone health data" toggle →
   grant the Health Connect read permission → manual sync → confirm imported
   workouts appear with the source glyph + device-calorie badge. iOS sim/Android
   emulator can't do this. Claude can confirm the import from the backend log.
3. **Capture 5 phone screenshots** for the store listing (shot-list in
   `docs/ops/play-store-listing.md §0`): dashboard, meal-scan result, coach
   insight, exercise weekly chart, progress/weight.
4. **Production-launch P0** (Play Console + legal — mostly Ali; copy/docs DONE):
   - **Host the privacy policy** — `docs/legal/privacy-policy.md` (EN) +
     `docs/legal/privacy-policy.tr.md` (TR) at public URLs (e.g. `/privacy` +
     `/gizlilik`); enter in Play Console.
   - **Data Safety form** — paste from `docs/ops/play-data-safety.md`.
   - **Health apps declaration** 🔒 — Health Connect read perms (NEW this
     feature; Google rejects without it). Section in play-data-safety.md.
   - **Store listing** — copy + assets ready in `docs/ops/play-store-listing.md`
     (icon `logo/store-icon-512.png`, feature graphic `logo/1024 x 500.png`).
   - **Content rating** — IARC questionnaire (expected answers in the doc §6).
5. Keep the tester-feedback loop: report → diagnose → fix → merge → backend
   deploys (live) / app fixes accumulate for the AAB.

## Architecture / standing notes
- **Coach** = insight-only (no chat/audio). Cron 02:00 UTC + on-demand.
- **Schema drift is endemic** — verify prod columns (`information_schema`) before
  trusting repo migrations. Bugs this session: weight_goals (`is_active` vs
  `status`), recipes (`calories` vs `calories_per_serving`).
- **i18n two tracks:** UI strings → `.arb` (template `app_tr.arb`; run
  `flutter gen-l10n` **from the `app/` dir** or the generated file won't update);
  AI output → backend prompt + `_get_user_language`.
- **Conventions:** squash-merge `… (#NN)`; version bump + CHANGELOG every fix;
  no `Co-Authored-By`; use cavecrew-reviewer on each diff.

## Memory
| Memory | Note |
|---|---|
| `user_ali.md` | Solo dev, Android-first, iOS paused |
| `project_feature_queue.md` | Exercise=V1.1, wearable=V2, diet-plan=never; balanced-nutrition + pace SHIPPED |
| `project_schema_drift_endemic.md` | always verify prod cols |
| `feedback_verify_on_device.md` | test-green ≠ done |
| `feedback_brand_art_use_real_asset.md` | glossy logos → real PNG, not vector |

---

**Prepared:** 2026-05-25 (after tester rounds 1–2, all code bugs cleared,
launch-prep docs drafted).
**Next update:** after the next AAB ships or production launch prep advances.
