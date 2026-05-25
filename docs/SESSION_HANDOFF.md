# Nuveli — Session Handoff (last updated 2026-05-25, ~22:40 TRT)

> Continuity doc between Claude Code sessions. New chat:
> `Read docs/SESSION_HANDOFF.md and continue from "Now / next".`

---

## Where we are — v1.6.9+32, main, in Play **closed/internal testing**

Android-first. **iOS paused** (Apple enrollment deferred; code kept aligned).
App is in Play testing with real testers; first AAB (versionCode 28) uploaded
and installed. Monetization (RevenueCat + Play Billing) is **configured and a
real test purchase succeeded**. Backend is on Render (free tier) + Supabase +
OpenAI; **UptimeRobot pings `/health` every 5 min** so the dyno no longer
cold-starts.

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
- **Exercise logging (manual)** → V1.1 (post-launch). Strong tester demand; build
  carefully — NO "burn it off"/compensation framing (wellness boundary).
- **Wearable / smartwatch sync** → V2 (in `mvp-scope.md` MVP-dışı).
- **Prescriptive meal/diet plan** → never (clinical diet plan = boundary).
- `POST /recipes` is still schema-mismatched (DB `calories` + NOT NULL
  `meal_types`) — testers only browse; fix when recipe creation is needed.

---

## Now / next

1. **Build the next AAB** (~2-3 days, once feedback settles): `cd app && flutter
   build appbundle --release --dart-define-from-file=.env.production` → upload to
   the testing track (versionCode 33). Carries all the app fixes above.
2. **Production-launch P0** (Play Console + legal — mostly Ali):
   - **Data Safety form** — answers mapped in `docs/ops/play-data-safety.md`.
   - **Privacy policy** — draft in `docs/legal/privacy-policy.md`; must be HOSTED
     at a public URL + a Turkish translation for the TR market.
   - Store listing (title/desc/screenshots/feature graphic), content rating.
3. Keep the tester-feedback loop: report → diagnose → fix → merge → backend
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
