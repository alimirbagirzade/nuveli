# Google Play — Data Safety form answers (Nuveli)

> Transcribe these into Play Console → App content → **Data safety**. Derived
> from the actual data flows in the codebase (2026-05-26). Re-verify if the
> data handling changes.
>
> ⚠️ **As of v1.8.0+34 the app also READS phone health data via Health Connect**
> (Android, opt-in). This adds a **separate** Play Console obligation beyond the
> Data safety form — see the **Health Connect (Android)** section below.

## Global answers
- **Does your app collect or share any of the required user data types?** → **Yes**
- **Is all data encrypted in transit?** → **Yes** (all API/Supabase/OpenAI calls are HTTPS/TLS).
- **Do you provide a way for users to request that their data be deleted?** →
  **Yes** (in-app: Settings → Delete account, which removes the profile and all
  logs; plus support@nuveli.com.tr). Provide the deletion URL/instructions.

## Data types — collected / shared / purpose

| Data type | Collected | Shared* | Purpose | Optional? |
|-----------|-----------|---------|---------|-----------|
| **Name** | Yes | No | App functionality (greeting, profile) | Required |
| **Email address** | Yes | No | Account management / auth | Required |
| **Health & fitness** (weight, meals, calories, macros, water, goals, habits, **+ exercise/workouts**) | Yes | No | App functionality (core tracking + AI coaching; exercise logging is display-only) | Required for the feature |
| **Health & fitness — imported from Health Connect** (workout sessions: type, duration, active energy) | Yes | No | App functionality (optional import of phone workouts into the activity log; display-only, never affects the calorie budget) | **Optional** (opt-in toggle, default off) |
| **Photos** (meal photos) | Yes | **Yes → OpenAI** (processed for food analysis; **not stored** by Nuveli) | App functionality (AI meal analysis) | Optional (user can use manual entry) |
| **App interactions / other actions** | Yes | No | Analytics (Firebase Analytics) | — |
| **Crash logs** | Yes | No | Crash diagnostics (Firebase Crashlytics) | — |
| **Diagnostics / performance** | Yes | No | Analytics / app performance | — |
| **Device or other IDs** (FCM token, Advertising ID) | Yes | No | Push notifications + Analytics | — |
| **Purchase history** | Yes | No** | Subscription management (RevenueCat + Google Play Billing) | — |

\* "Shared" = transferred to a third party that is not a service provider acting on Nuveli's behalf. Google's definition treats *processors* (Supabase, Firebase, RevenueCat) as service providers, NOT "sharing". OpenAI receives the **meal photo** to perform analysis — disclose it (some reviewers expect the photo transfer noted); it is processed, not sold, and not stored long-term by Nuveli.
\** Google handles the payment; Nuveli never sees card/financial-instrument data.

## Health Connect (Android) — separate Play obligation

The app **reads** workout data from Health Connect when the user opts in
(Settings → "Connect phone health data", default **off**). This triggers a
**separate Play Console flow** beyond the Data safety form:

- **Permissions declared** (read-only, v1.8.1+35 — trimmed to actual usage):
  `READ_EXERCISE` (WORKOUT) and `READ_ACTIVE_CALORIES_BURNED` (the per-session
  active-energy figure carried on a workout). WORKOUT is the only type queried
  (last 14 days). `READ_STEPS` / `ACTIVITY_RECOGNITION` were **removed** —
  steps were never read or shown, and an unused health permission gets the
  Health-apps declaration rejected.
- **Play Console → App content → "Health apps declaration"**: declare each
  Health Connect permission, the data-access purpose, and that access is
  **read-only**, **opt-in**, and used solely to display imported workouts in
  the activity log. Google requires a short justification per permission and
  may ask for an in-app demo video showing the consent + usage flow.
- **Health Connect data-handling rules** (Google enforces these):
  - Used only for the user-facing exercise/activity feature; **not** sold,
    **not** shared, **not** used for ads.
  - Imported workouts are stored per-user (deduped by record UUID) and are
    deleted with the account (Settings → Delete account).
  - Calories from imported workouts are **display-only** and never added to
    the daily calorie budget (wellness boundary).
- **Privacy policy** must explicitly describe Health Connect access — see the
  Health Connect subsection in `docs/legal/privacy-policy.md`. Google rejects
  Health Connect apps whose policy doesn't name the data accessed.
- **iOS / Apple Health**: code is aligned (`apple_health` source) but the
  HealthKit entitlement is **NOT** added — iOS launch is paused. No App Store
  health declaration needed until enrollment resumes.

## Notes / decisions
- **Meal photos are NOT stored** server-side: the image is sent to `/meals/scan`
  → OpenAI Vision → only the parsed result (food names, calories, macros) is
  saved. No Supabase storage upload, no `image_url` on scanned meals.
- **Advertising ID**: collected via Firebase Analytics. Declared in the
  Advertising ID declaration as **Analytics** purpose (no ads in the app).
- **Health data**: Play has no dedicated "health" sensitive class for general
  wellness apps, but weight/meals fall under "Health & fitness". Nuveli is a
  **wellness** app (not medical) — keep store copy consistent (no medical
  claims, per docs/protocols/safety-wellness-boundary.md).
- This app is **Android-only for launch** (iOS paused). Same answers apply when
  iOS resumes.

## Privacy policy
- ✅ **HOSTED** (GitHub Pages, `gh-pages` branch):
  - EN: https://alimirbagirzade.github.io/nuveli/privacy.html
  - TR: https://alimirbagirzade.github.io/nuveli/gizlilik.html
- Enter the EN URL in Play Console → App content → Privacy policy. Source text:
  `docs/legal/privacy-policy.md` (EN) + `docs/legal/privacy-policy.tr.md` (TR);
  the served HTML lives on the `gh-pages` branch — keep it in sync on changes.
