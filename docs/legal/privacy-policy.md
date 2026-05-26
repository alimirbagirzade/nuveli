# Nuveli — Privacy Policy

_Last updated: 2026-05-26_

Nuveli ("Nuveli", "we", "us") is an AI calorie & wellness coaching app. This
policy explains what we collect, why, who we share it with, and your choices.
Questions: **support@nuveli.com.tr**.

> Nuveli is a **wellness** app. It does not provide medical diagnosis,
> treatment, or clinical dietary plans.

## 1. Information we collect

**You provide:**
- **Account:** name and email address (used to create and secure your account).
- **Profile & goals:** age range, sex, height, weight, activity level, dietary
  preference, weight goal and target date, preferred language.
- **Health & fitness logs:** meals and their calories/macros, water intake,
  weight entries, habits, check-ins, and exercise/activity entries.
- **Meal photos (optional):** if you use AI Meal Scan, the photo is sent for
  analysis (see §3). You can instead enter meals manually.
- **Phone health data via Health Connect (Android, optional):** if you turn on
  "Connect phone health data" in Settings (off by default), Nuveli reads your
  recent **workout sessions** from Health Connect — the activity type, start
  time, duration, and the session's active energy (calories) — to import them
  into your in-app activity log. Access is **read-only**; we never write to
  Health Connect. You can turn it off at any time. See §3a.

**Collected automatically:**
- **Device & usage:** app interactions, diagnostics and performance data,
  crash reports, a push-notification token, and an advertising identifier
  (used for analytics only — Nuveli shows no ads).
- **Purchases:** subscription status and purchase history (payment is handled
  by Google Play; we never receive your card details).

## 2. How we use your information

- Provide the core features: calorie/macro tracking, AI coaching insights,
  meal analysis, progress and reminders.
- Calculate your daily targets from your profile and goal.
- Send notifications you've enabled.
- Manage subscriptions and entitlements.
- Diagnose crashes and improve performance and reliability.

## 3. Third parties / service providers

We use the following processors. They handle data on our behalf and are not
permitted to use it for their own purposes:

- **Supabase** — authentication and database (stores your account, profile and
  logs).
- **OpenAI** — when you scan a meal, the **photo and the analysis request are
  sent to OpenAI** to estimate foods, calories and macros. The photo is used
  for that analysis and is **not stored by Nuveli**; only the parsed result is
  saved to your account.
- **Google Firebase** — analytics, crash reporting (Crashlytics) and push
  notifications (FCM).
- **RevenueCat & Google Play Billing** — subscription management and payments.

We do **not** sell your personal data.

## 3a. Health Connect (Android)

When you opt in, Nuveli uses **Android Health Connect** to read your workout
data. We request read-only access to: **Exercise/Workouts** and **Active
calories burned** — and nothing else.

- The data is used **only** to show your imported workouts inside Nuveli's
  activity log. Calories shown for an activity are **display-only** and are
  **never** added to or subtracted from your daily calorie budget.
- We do **not** sell or share Health Connect data, and we do **not** use it for
  advertising.
- Imported workouts are stored in your account (deduplicated per record) and are
  deleted when you delete your account (§5).
- Nuveli never **writes** data back to Health Connect.
- You control this entirely: it is off by default, and you can revoke access in
  Settings or in the Health Connect app at any time.

## 4. Data retention

We keep your account data while your account is active. Meal photos are not
retained after analysis. When you delete your account, your profile and all
associated logs are removed.

## 5. Your rights & choices

- **Access / update:** edit your profile and logs in the app.
- **Delete:** Settings → Delete account permanently removes your profile and all
  logs. You may also email **support@nuveli.com.tr** to request deletion.
- **Notifications:** manage in Settings (and your device settings).

## 6. Security

All data is transmitted over encrypted connections (HTTPS/TLS). We restrict
access to stored data to what is needed to operate the service.

## 7. Children

Nuveli is not intended for children. The app includes an age gate at sign-up
and is meant for adults managing their own wellness.

## 8. International transfers

Your data may be processed on servers operated by our providers (e.g. in the
EU/US). We rely on those providers' safeguards for such transfers.

## 9. Changes

We may update this policy; material changes will be reflected by the "Last
updated" date above.

## 10. Contact

**support@nuveli.com.tr**

---

> **TODO before production launch:**
> 1. ✅ **HOSTED via GitHub Pages** (gh-pages branch, source `/tmp` HTML mirror):
>    - EN: https://alimirbagirzade.github.io/nuveli/privacy.html
>    - TR: https://alimirbagirzade.github.io/nuveli/gizlilik.html
>    - Landing: https://alimirbagirzade.github.io/nuveli/
>    Enter the EN URL in Play Console (App content → Privacy policy). If a
>    custom domain (nuveli.com.tr) is set up later, move the pages there and
>    update the Console URL. **HTML lives only on the `gh-pages` branch** — when
>    this markdown changes, re-sync the HTML on that branch.
> 2. ✅ Turkish translation — `privacy-policy.tr.md`, hosted as `gizlilik.html`.
>    Keep markdown + HTML (both EN/TR) in sync on every change.
> 3. Verify the company/contact details and **KVKK** (Law 6698) specifics in the
>    TR version: data-controller identity, legal basis, VERBİS registration if
>    applicable, and Art. 11 data-subject rights.
> 4. **Health Connect:** complete Play Console → App content → **Health apps
>    declaration** (read-only Exercise + Active-calories, opt-in,
>    display-only) — see `docs/ops/play-data-safety.md`.
