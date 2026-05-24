# Coach Daily Insights — cron / scheduler

The Coach pipeline (`POST /coach/today` cached daily insight) needs a
nightly job that calls `cron.daily_insights_job.run_for_all_users()`.
We support two ways to drive it. Pick one — don't run both, or the same
user will get the insight generated twice and you'll burn OpenAI tokens.

## Option A — in-process APScheduler (default)

Set up in `backend/main.py` lifespan. Runs daily at **02:00 UTC**.

**Enabled by default in production**. Disable only if you switch to
Option B or if you scale to multiple Render web instances (because each
instance would fire the job once → N× insights per user per day).

```bash
# Render → backend service → Environment
APP_ENABLE_INTERNAL_CRON=true   # default; omit if you like
```

**Limits:**

- Render Free Web Service tier sleeps after ~15 minutes of inactivity.
  If the instance is asleep at 02:00 UTC the cron silently misses the
  day. `misfire_grace_time=3600` lets us catch up if the wake happens
  within an hour, but past that the day is lost.
- If you start using multiple instances, switch to Option B
  immediately.

## Option B — Render Cron Service (recommended for paid tier)

A dedicated Render Cron Service is the standard "boring" trigger.
Reliable, observable, doesn't depend on the web service being awake.

### Setup (one-time, Render dashboard)

1. **New** → **Cron Job**
2. Name: `nuveli-daily-insights`
3. Region: same as your web service
4. Branch: `main`
5. Build command: `pip install -r requirements.txt`
6. Schedule: `0 2 * * *`  (02:00 UTC every day)
7. Command: `python -m cron.daily_insights_job`
8. Env vars — copy from the web service:
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `SUPABASE_JWT_SECRET`
   - `OPENAI_API_KEY`
   - `OPENAI_MODEL_CHAT`
   - `APP_ENV=production`
9. **Save → Run job manually** once to smoke-test.

### After Option B is wired

Set on the **web service** so the in-process scheduler doesn't also
fire:

```bash
APP_ENABLE_INTERNAL_CRON=false
```

## Smoke-test manually

Run on your laptop with prod creds (or via Render shell):

```bash
cd backend
source .venv311/bin/activate
python -m cron.daily_insights_job
```

Should print a summary dict:

```json
{
  "target_date": "2026-05-24",
  "total_profiles": 6,
  "success": 6,
  "failures": 0,
  "skipped": 0,
  "completed_at": "..."
}
```

Then `GET /coach/today` for any active user returns the freshly
generated row instead of triggering on-demand generation.

## What happens when the job fires

For every row in `user_profiles`:

1. Pull last 7 days of meals, water, weight, habits, profile target.
2. Build a prompt (`prompts/coach_prompts.py` `COACH_INSIGHT_SYSTEM_PROMPT`).
3. Call GPT-4o, parse JSON: `nutrition_score`, `today_insight`,
   `tips[]`, `recommended_action`.
4. Upsert into `ai_insights` keyed by `(user_id, insight_date)`.
5. **If FCM is configured** (see below): send a push to every
   registered device for that user — "Your daily insight is ready 🌱".
   Tap payload is `{route: "/coach", kind: "daily_insight"}`.

## FCM push setup (Phase C)

The insight job tries to push "Your insight is ready" to every
registered device. Send is **gated**: if `FIREBASE_PROJECT_ID` and
`FIREBASE_SERVICE_ACCOUNT_JSON_B64` are both set the push fires,
otherwise the job silently skips push and just persists the insight.

### One-time setup

1. **Firebase Console** → Project Settings → Service accounts →
   **Generate new private key**. You get `nuveli-prod-*.json`.
2. Base64-encode it:
   ```bash
   base64 -i nuveli-prod-*.json | pbcopy
   ```
3. On Render → backend service → Environment, add:
   - `FIREBASE_PROJECT_ID` = your Firebase project id (e.g.
     `nuveli-prod`)
   - `FIREBASE_SERVICE_ACCOUNT_JSON_B64` = paste the base64 blob
4. Redeploy the web service. (And the cron service if you're using
   Option B — it needs the same env.)

### Flutter side

`POST /me/device-tokens` (body `{token, platform}`) is wired and
ready. The Flutter side should call it on first launch after
`FirebaseMessaging.instance.getToken()` resolves, and again on
`onTokenRefresh`. On sign-out, call `DELETE /me/device-tokens/{token}`
to stop sending.

If you want to skip all FCM work entirely (e.g. v0 launch without
push), leave the env vars unset — the cron job will only persist
insights and the Coach tab will surface them when the user opens the
app. Users just don't get nudged.

## Cost guard

Each insight generation is one GPT-4o call, currently ~1000 tokens
(~$0.005 at 2026 pricing). 1000 active users × 1 insight/day ≈ $5/day.
Watch `ai_insights.tokens_used` to monitor.

If costs balloon, the cheapest fix is moving the cron from "every day"
to "every weekday" or "only when user has logged ≥1 meal that week"
(filter `profiles` in `run_for_all_users`).
