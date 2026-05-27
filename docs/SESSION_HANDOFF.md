# Nuveli — Session Handoff (last updated 2026-05-27, ~00:30 TRT)

> Continuity doc between Claude Code sessions. New chat:
> `Read docs/SESSION_HANDOFF.md and continue from "Now / next".`

---

## Where we are — v1.8.1+35, main, in Play **closed testing**

Android-first. **iOS paused** (Apple enrollment deferred; code kept aligned).
**vCode 35 AAB uploaded** to the closed-testing track. Monetization (RevenueCat
+ Play Billing) is **configured and a real test purchase succeeded**. Backend is
on Render (free tier) + Supabase + OpenAI; **UptimeRobot pings `/health` every 5
min** so the dyno no longer cold-starts.

🔴 **#1 LAUNCH GATE — 12 testers / 14 days.** This is a personal (post-Nov-2023)
Play account, so production access requires **12 testers opted-in to closed
testing for 14 continuous days**. Currently **only 2** joined. The others failed
because they used the **public** store URL (`/store/apps/details?id=…` → "item
not found" — the app isn't public yet) instead of the **closed-testing opt-in
link**, and/or weren't on the tester list. **Sideloaded APKs do NOT count.** Next
real-world task: build a tester list (Google Group is easiest) → share the
opt-in link → get 12 real Gmail accounts to join via Play → wait 14 days.

### This session (2026-05-27, later) — PRs #155–160, vCode 35, privacy LIVE
- **#157 — Health Connect perm trim (v1.8.1+35):** dropped unused `STEPS` +
  `ACTIVITY_RECOGNITION` (only WORKOUT + active-calories are read). Verified via
  aapt2. Rebuilt **AAB + APK at vCode 35**; Ali uploaded the AAB.
- **Privacy policy is LIVE & Play-ready:** the real site **nuveli.com.tr/privacy**
  already had a 7-lang KVKK+GDPR policy but predated Health Connect. Injected a
  Health Connect section into all 7 live pages (TR `gizlilik.html` +
  `privacy/{en,de,fr,es,ru,it}.html`) via a cPanel zip; **verified live** (HC
  section + date 27 May + on-brand CSS on all 7). A short-lived GitHub Pages
  mirror was torn down. **Play privacy URL = https://nuveli.com.tr/privacy.**
- **#159** repointed docs to the canonical site + added
  `docs/legal/health-connect-privacy-insert.md` (7-lang HC text).
- **#160 + `docs/brand/`** captured the site's **design system**
  (`nuveli-web.css` verbatim + `website-design-system.md`): teal/navy palette,
  Inter + Plus Jakarta Sans. Lesson: site inlines CSS per page (no shared
  stylesheet) → new pages drift off-brand unless they reuse it.
- **Site link audit:** all 14 pages 200, no broken links, no orphans (mesh nav).
- **#155** handoff refresh, **#156** removed stale chat15/16/17 dev artifacts.
- **APK for sideload:** `~/Downloads/Nuveli-v1.8.1-build35.apk` (vCode 35) — lets
  friends try it, but does NOT count toward the 12-tester gate.
- **App content (Play Console) — Ali still to finish:** Health-apps declaration
  (2 boxes: READ_EXERCISE + READ_ACTIVE_CALORIES_BURNED; text in chat/docs),
  Data Safety, content rating, privacy URL. Device: Health Connect verify + 5
  screenshots (after vCode 35 installs).

### This session (2026-05-27, earlier) — 3 PRs merged (#152–154) + AAB built
Repo cleanup + launch-prep docs.

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

**Build + privacy are DONE. The gate is now people + Play Console clicks, not code.**

1. 🔴 **GET 12 TESTERS (14 continuous days)** — the real production gate (see
   "Where we are"). Build a tester list (Google Group easiest) → Play Console →
   Closed testing → Testers → add emails / group → **Copy opt-in link** → each
   tester opens it ON their phone with a listed Gmail → "Become a tester" →
   installs via Play → stays 14 days. **APK sideload does NOT count.** Only 2/12
   so far. (Consider Open testing to drop the per-email allowlist, or
   tester-exchange communities to find 12.)
2. **Finish App content (Play Console — Ali clicks; values ready):**
   - **Privacy policy URL:** `https://nuveli.com.tr/privacy` ✅ live & HC-disclosed.
   - **Health-apps declaration** 🔒 — now **2 boxes** (vCode 35): READ_EXERCISE +
     READ_ACTIVE_CALORIES_BURNED. Justification text in chat / `play-data-safety.md`.
   - **Data Safety** — `docs/ops/play-data-safety.md`.
   - **Content rating** — IARC (`docs/ops/play-store-listing.md §6`).
3. **Device (after vCode 35 installs):** Health Connect verify (toggle on → grant
   → sync → workouts show with source glyph + calorie badge; Claude confirms via
   backend log) + **5 store screenshots** (`play-store-listing.md §0`).
4. **Store listing** — copy + assets ready (`play-store-listing.md`; icon
   `logo/store-icon-512.png`, feature graphic `logo/1024 x 500.png`).
5. **Device-compat warning** when publishing vCode 35: "Continue anyway" — only
   ~1.7% of devices (Android <8.0) are excluded; minSdk 26 is required by Health
   Connect and is the correct trade (see the deep-dive earlier this session).
6. Keep the tester-feedback loop: report → diagnose → fix → merge → backend
   deploys live / app fixes accumulate for the next AAB.

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
