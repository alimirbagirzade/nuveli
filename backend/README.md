# Nuveli Backend API

FastAPI backend for the Nuveli AI Calorie Coach app.
Stack: **Python 3.11 + FastAPI + Supabase + OpenAI GPT-4o**.

Production URL: `https://nuveli-api.onrender.com`
Interactive docs: `https://nuveli-api.onrender.com/docs`

---

## Quick Start

```bash
# 1. Clone & enter
cd backend

# 2. Create virtualenv
python3.11 -m venv venv
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure env
cp .env.example .env
# Edit .env with your Supabase + OpenAI credentials

# 5. Run
uvicorn main:app --reload --port 8000
```

Visit http://localhost:8000/docs for Swagger UI.

---

## Project Structure

```
backend/
├── main.py                    # FastAPI app entry + router mounting
├── config.py                  # Pydantic settings (env vars)
├── dependencies.py            # Re-exports for routers
├── core/
│   ├── auth.py                # JWT verification, get_current_user
│   ├── supabase_client.py     # Cached Supabase service-role client
│   ├── exceptions.py          # Custom domain exceptions
│   └── logging.py             # Structured logging setup
├── models/                    # Pydantic request/response schemas
│   ├── profile.py
│   ├── meal.py
│   ├── water.py
│   ├── habit.py
│   ├── weight.py
│   ├── meal_plan.py
│   ├── ai_coach.py
│   ├── achievement.py
│   └── common.py
├── routers/                   # 10 route modules → 40+ endpoints
│   ├── profiles.py
│   ├── meals.py
│   ├── water.py
│   ├── habits.py
│   ├── weight.py
│   ├── meal_planner.py
│   ├── ai_coach.py
│   ├── analytics.py
│   ├── achievements.py
│   └── premium.py
├── services/                  # Business logic / external APIs
│   ├── openai_vision_service.py
│   ├── insights_generation_service.py
│   ├── nutrition_score_service.py
│   ├── streak_service.py
│   └── achievement_service.py
├── prompts/                   # GPT-4o system prompts
│   ├── meal_scan_prompt.py
│   └── coach_prompts.py
├── cron/                      # Scheduled jobs (run via Render Cron)
│   ├── daily_insights_job.py
│   ├── achievement_checker_job.py
│   └── streak_resetter_job.py
├── tests/                     # Pytest smoke tests
├── requirements.txt
├── render.yaml                # Render.com Blueprint
├── .env.example
├── .gitignore
└── README.md
```

---

## Endpoint Map

All endpoints (except `/health`, `/`, `/docs`, `/premium/webhook`) require
a Supabase JWT in the `Authorization: Bearer <token>` header.

### `/me` — Profile
| Method | Path                | Description                               |
|--------|---------------------|-------------------------------------------|
| GET    | `/me`               | Get my profile (auto-creates stub)        |
| PATCH  | `/me`               | Update profile fields                     |
| POST   | `/me/onboarding`    | Complete onboarding (computes BMR/TDEE)   |
| DELETE | `/me`               | GDPR cascade delete                       |

### `/meals` — Meals
| Method | Path                     | Description                          |
|--------|--------------------------|--------------------------------------|
| POST   | `/meals/scan`            | AI scan image → detected foods       |
| POST   | `/meals`                 | Log a meal (with foods)              |
| GET    | `/meals`                 | List meals (date/type filter)        |
| GET    | `/meals/today/summary`   | Today's totals vs targets            |
| GET    | `/meals/{id}`            | Single meal detail                   |
| PATCH  | `/meals/{id}`            | Update meal                          |
| DELETE | `/meals/{id}`            | Delete meal                          |

### `/water` — Water
| Method | Path                    | Description                         |
|--------|-------------------------|-------------------------------------|
| POST   | `/water/logs`           | Log water intake                    |
| GET    | `/water/logs`           | List water logs                     |
| DELETE | `/water/logs/{id}`      | Delete log                          |
| GET    | `/water/today/summary`  | Today consumed / target / glasses   |
| GET    | `/water/reminders`      | List reminders                      |
| POST   | `/water/reminders`      | Create reminder                     |
| PATCH  | `/water/reminders/{id}` | Update reminder                     |
| DELETE | `/water/reminders/{id}` | Delete reminder                     |
| GET    | `/water/insights`       | Hydration pattern insight           |

### `/habits` — Habits
| Method | Path                       | Description                       |
|--------|----------------------------|-----------------------------------|
| GET    | `/habits`                  | List active habits                |
| POST   | `/habits`                  | Create habit                      |
| PATCH  | `/habits/{id}`             | Update habit                      |
| DELETE | `/habits/{id}`             | Soft delete                       |
| POST   | `/habits/{id}/complete`    | Mark complete today (idempotent)  |
| DELETE | `/habits/{id}/complete`    | Undo today's completion           |
| GET    | `/habits/weekly`           | 7-day consistency view            |
| GET    | `/habits/streak`           | Current / longest habit streak    |

### `/weight` — Weight
| Method | Path                | Description                                |
|--------|---------------------|--------------------------------------------|
| POST   | `/weight/logs`      | Log weight (updates profile)               |
| GET    | `/weight/logs`      | List logs (period filter 7d/4w/8w/3m/1y)   |
| DELETE | `/weight/logs/{id}` | Delete log                                 |
| GET    | `/weight/goal`      | Active goal with progress %                |
| POST   | `/weight/goal`      | Create new goal (cancels previous)         |
| PATCH  | `/weight/goal`      | Update active goal                         |

### `/meal-plans` & `/recipes` — Meal Planner
| Method | Path                          | Description                       |
|--------|-------------------------------|-----------------------------------|
| GET    | `/meal-plans`                 | Week or day plans                 |
| POST   | `/meal-plans`                 | Add plan entry                    |
| PATCH  | `/meal-plans/{id}`            | Update plan entry                 |
| DELETE | `/meal-plans/{id}`            | Delete plan entry                 |
| GET    | `/meal-plans/grocery`         | Aggregated shopping list          |
| POST   | `/meal-plans/generate`        | AI-generate weekly plan           |
| GET    | `/recipes`                    | Search recipes                    |
| GET    | `/recipes/{id}`               | Recipe detail                     |
| POST   | `/recipes`                    | Create recipe                     |

### `/coach` — AI Coach
| Method | Path                | Description                              |
|--------|---------------------|------------------------------------------|
| GET    | `/coach/today`      | Today's cached insight (generates if not)|
| POST   | `/coach/generate`   | Force-regenerate insight                 |
| POST   | `/coach/apply-tip`  | Apply a tip's recommended action         |

### `/analytics` — Analytics
| Method | Path                          | Description                  |
|--------|-------------------------------|------------------------------|
| GET    | `/analytics/dashboard`        | Today + streak + score combo |
| GET    | `/analytics/weekly`           | 7-day chart + averages       |
| GET    | `/analytics/weight-trend`     | Weight trend with MA         |
| GET    | `/analytics/macro-breakdown`  | Daily macro percentages      |

### `/achievements` — Achievements
| Method | Path                   | Description                       |
|--------|------------------------|-----------------------------------|
| GET    | `/achievements`        | List all with progress / unlock   |
| POST   | `/achievements/check`  | Check & unlock new achievements   |

### `/premium` — Premium / RevenueCat
| Method | Path                | Description                                |
|--------|---------------------|--------------------------------------------|
| POST   | `/premium/webhook`  | RevenueCat events (Bearer-authed, public)  |
| GET    | `/premium/status`   | Current user's subscription state          |

### Meta
| Method | Path       | Description           |
|--------|------------|-----------------------|
| GET    | `/`        | Root (info)           |
| GET    | `/health`  | Liveness probe        |
| GET    | `/docs`    | Swagger UI            |
| GET    | `/redoc`   | ReDoc                 |

---

## Authentication

The backend trusts Supabase-issued JWTs. The Flutter app obtains a token
via `supabase.auth.signIn(...)` and sends it as:

```
Authorization: Bearer <supabase_access_token>
```

The backend uses the **service-role key** to bypass RLS, and every router
manually filters by `user_id = jwt.sub` for defense-in-depth.

---

## Running Tests

```bash
pip install -r requirements.txt
pytest tests/ -v
```

Tests use a mocked Supabase client (no live DB needed). See `tests/conftest.py`.

---

## Deploy to Render.com

### Option A — Blueprint (recommended)
1. Push to GitHub.
2. Go to https://dashboard.render.com → New + → Blueprint.
3. Point to the repo; Render reads `backend/render.yaml`.
4. Fill in the secret env vars in the dashboard.

### Option B — Manual
1. Create a Web Service.
2. Root Directory: `backend`
3. Build: `pip install -r requirements.txt`
4. Start: `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Health Check Path: `/health`
6. Add env vars from `.env.example` (with real values).

### Post-deploy verification
```bash
# 1. Health
curl https://nuveli-api.onrender.com/health
# → {"status":"ok","version":"1.0.0","env":"production"}

# 2. Docs
open https://nuveli-api.onrender.com/docs

# 3. Auth-guarded endpoint with a real JWT
curl -H "Authorization: Bearer <token>" https://nuveli-api.onrender.com/me
```

---

## Cron Jobs

Three jobs ship with the backend. On Render's free plan, cron services
aren't included — run them manually or move to a paid tier.

| Job                          | Schedule       | Purpose                              |
|------------------------------|----------------|--------------------------------------|
| `daily_insights_job`         | 02:00 UTC      | Generate AI insights for all users   |
| `streak_resetter_job`        | 01:00 UTC      | Recompute / reset streaks            |
| `achievement_checker_job`    | every 6 h      | Safety net for achievement unlocks   |

Manual run:
```bash
python -m cron.daily_insights_job
python -m cron.streak_resetter_job
python -m cron.achievement_checker_job
```

---

## Environment Variables

See `.env.example` for the full list. Required in production:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_JWT_SECRET`
- `OPENAI_API_KEY`
- `REVENUECAT_WEBHOOK_SECRET` (when RevenueCat is wired up)
- `APP_ENV=production`

Optional:
- `SENTRY_DSN`
- `CORS_ORIGINS` (default `*`)

---

## License

Proprietary — © 2026 Nuveli. All rights reserved.
