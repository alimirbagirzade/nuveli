# On-device QA plan (real Android, USB)

App id: `com.nuveli.app` · Backend: live on Render · Approach: USB sideload +
structured bug log + fix loop.

## 0. Build + install over USB

```bash
cd app
flutter devices                      # confirm the phone shows up
# Release APK (signed; RC keys baked in from .env.production):
flutter build apk --release --dart-define-from-file=.env.production
flutter install --release            # installs to the connected device
# …or directly:  adb install -r build/app/outputs/flutter-apk/app-release.apk
```

> `adb` lives in `~/Library/Android/sdk/platform-tools/` (not on PATH). Either
> add it, or use `flutter install` / `flutter run --release -d <id>`.

**Live logs while testing** (second terminal, keep open):
```bash
adb logcat --pid=$(adb shell pidof -s com.nuveli.app)        # app-only
# or capture to a file per session:
adb logcat -v time | tee docs/qa/logs/session-$(date +%Y%m%d-%H%M).log
```
Flutter `debugPrint`/errors surface under tag `flutter`.

## 1. Test matrix (walk every tab)

| # | Flow | Check |
|---|------|-------|
| A | Cold start → AuthGate | Splash → login or dashboard, no crash |
| B | Signup / login | Email signup (admin auto-confirm), login, logout |
| C | Dashboard | Calorie ring, macros, water card (+ presets), today meals, habits |
| D | Add Food (manual) | Sheet → save → dashboard updates |
| E | **Scan** | Camera permission, capture, AI analysis, edit foods, save → mood bubble |
| F | Meal history ("See all") | Grouped by day, swipe-to-delete + confirm |
| G | **Coach** | Daily insight loads, nutrition score, tips; mood bubble after meal save |
| H | Coach "Upgrade to regenerate" | Paywall — **expected empty until RC/Play config** (see ops doc) |
| I | **Meal Planner** | Week view, per-day "+" add, edit/delete, AI generate (premium-gated) |
| J | Analytics | Weekly calorie chart, weight trend, macro breakdown |
| K | Profile | Weight goal, edit profile (PATCH /me) |
| L | Settings | Coach persona picker, language switch (now live), export, delete account |
| M | Language switch | Change language → mood-bubble + meal-history localize; rest stays EN (known) |
| N | Push (FCM) | Real device only — daily insight push (needs 02:00 UTC cron or manual trigger) |

## 2. Bug capture — what to send me per bug

1. **Screenshot** (or screen recording for flows).
2. **Repro steps** — numbered, from a known state ("from Dashboard, tap …").
3. **`adb logcat` slice** around the moment (stack trace if it crashed).
4. **Expected vs actual** in one line.

## 3. Severity rubric

| Sev | Meaning | Action |
|-----|---------|--------|
| **P0** | Crash, data loss, can't get past a screen, security | Fix immediately → rebuild → reverify before continuing |
| **P1** | Core flow broken (save fails, wrong totals, auth) | Fix this session |
| **P2** | Works but wrong/ugly (layout, copy, minor UX) | Queue, batch-fix |
| **P3** | Cosmetic/nice-to-have | Backlog |

> Config-blocked items (paywall packages until RC/Play set up) are **not bugs** —
> log as "blocked: config" so we don't chase them.

## 4. Fix loop

```
find bug → log it (table below) → triage Pn
  P0/P1 → I diagnose from logcat+repro → fix → flutter install --release → you reverify
  P2/P3 → stays in the table → batched into one PR at the end
```
Each fix follows the project rules: version bump + CHANGELOG + cavecrew-reviewer,
then branch + PR + rebase-merge (same flow as this session).

## 5. Bug log (fill during the session)

| ID | Tab/Flow | Sev | Symptom | Repro | logcat? | Status |
|----|----------|-----|---------|-------|---------|--------|
| _e.g._ 1 | Scan | P1 | save 500s | capture→edit→Save | yes | open |
|  |  |  |  |  |  |  |
