# Google Play — Data Safety form answers (Nuveli)

> Transcribe these into Play Console → App content → **Data safety**. Derived
> from the actual data flows in the codebase (2026-05-25). Re-verify if the
> data handling changes.

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
| **Health & fitness** (weight, meals, calories, macros, water, goals, habits) | Yes | No | App functionality (the core tracking + AI coaching) | Required for the feature |
| **Photos** (meal photos) | Yes | **Yes → OpenAI** (processed for food analysis; **not stored** by Nuveli) | App functionality (AI meal analysis) | Optional (user can use manual entry) |
| **App interactions / other actions** | Yes | No | Analytics (Firebase Analytics) | — |
| **Crash logs** | Yes | No | Crash diagnostics (Firebase Crashlytics) | — |
| **Diagnostics / performance** | Yes | No | Analytics / app performance | — |
| **Device or other IDs** (FCM token, Advertising ID) | Yes | No | Push notifications + Analytics | — |
| **Purchase history** | Yes | No** | Subscription management (RevenueCat + Google Play Billing) | — |

\* "Shared" = transferred to a third party that is not a service provider acting on Nuveli's behalf. Google's definition treats *processors* (Supabase, Firebase, RevenueCat) as service providers, NOT "sharing". OpenAI receives the **meal photo** to perform analysis — disclose it (some reviewers expect the photo transfer noted); it is processed, not sold, and not stored long-term by Nuveli.
\** Google handles the payment; Nuveli never sees card/financial-instrument data.

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
- A public **privacy policy URL** is required. Draft text: `docs/legal/privacy-policy.md`.
  It must be HOSTED at a stable URL (e.g. nuveli.com.tr/privacy or GitHub Pages)
  and entered in Play Console → Store listing + App content.
