"""
Seed an App Store / Play Store reviewer account.

What it creates
---------------
* A Supabase Auth user `reviewer@nuveli.app` / `ReviewPass2026!`
  (email + password configurable via env / flags)
* `user_profiles` row with `is_premium=true` and `premium_expires_at` set
  60 days in the future so the reviewer never hits the paywall mid-flow
* Seven days of believable demo data:
    - ~21 meals (3/day across 7 days)
    - water logs (5/day)
    - weight logs (1/day, gentle downward trend)
    - 4 custom habits with completions on most days

Idempotency
-----------
The script looks up the auth user by email and reuses it if present, so
re-running won't create duplicate accounts. Per-table demo data is
cleared (only for THIS user) before re-seeding so the reviewer always
sees a clean 7-day window. RLS is bypassed because we use the
service-role client.

Safety
------
* Refuses to run when `APP_ENV=production` UNLESS `--allow-production`
  is passed — this matches Ali's typical "dev fixture" usage pattern
  where running against prod is a deliberate, eyes-open submission step.
* Prints final credentials so you can copy/paste them into App Store
  Connect → App Review Information.

Usage
-----
    cd backend
    source venv/bin/activate
    python scripts/seed_reviewer_account.py
    # or against prod (final submission step):
    python scripts/seed_reviewer_account.py --allow-production
"""
from __future__ import annotations

import argparse
import os
import random
import sys
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from typing import Any

# Make `backend/` importable when invoked as `python scripts/...`
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from config import get_settings  # noqa: E402
from core.supabase_client import init_supabase  # noqa: E402

DEFAULT_EMAIL = "reviewer@nuveli.app"
DEFAULT_PASSWORD = "ReviewPass2026!"

# Demo meals, sized to land near the reviewer's 2000 kcal/day target.
DEMO_MEALS_PER_DAY = [
    # (meal_type, name, kcal, p_g, c_g, f_g)
    ("breakfast", "Yulaf ezmesi + muz + ceviz", 380, 12.0, 60.0, 11.0),
    ("lunch", "Izgara tavuk salatası", 540, 42.0, 30.0, 22.0),
    ("dinner", "Mercimek çorbası + tam tahıllı ekmek", 460, 18.0, 70.0, 8.0),
]

DEMO_HABITS = [
    # (name, target_type, days_of_week)
    ("Sabah 10 dk meditasyon", "duration", ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]),
    ("Günde 8.000 adım", "count", ["mon", "tue", "wed", "thu", "fri"]),
    ("Şekerli içecek yok", "check", ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]),
    ("Erken yat (23:00)", "check", ["mon", "tue", "wed", "thu", "fri", "sun"]),
]


def _utc_iso(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _find_or_create_auth_user(supabase, email: str, password: str) -> str:
    """Return the user_id; create the account if it doesn't already exist."""
    listing = supabase.auth.admin.list_users()
    # supabase-py returns either a list of User or an object with .users
    users = getattr(listing, "users", listing) or []
    for u in users:
        if (getattr(u, "email", None) or "").lower() == email.lower():
            print(f"  ✔ Auth user already exists: {u.id}")
            return u.id

    created = supabase.auth.admin.create_user(
        {
            "email": email,
            "password": password,
            "email_confirm": True,
            "user_metadata": {"is_reviewer": True},
        }
    )
    user_id = (
        getattr(created.user, "id", None)
        if hasattr(created, "user")
        else getattr(created, "id", None)
    )
    if not user_id:
        raise RuntimeError(f"create_user returned an unexpected shape: {created!r}")
    print(f"  ✔ Created auth user: {user_id}")
    return user_id


def _clear_user_data(supabase, user_id: str) -> None:
    """Wipe the user's domain rows so re-seeding gives a clean 7-day window."""
    for table in (
        "meal_foods",  # cascaded but be explicit
        "meals",
        "water_logs",
        "weight_logs",
        "habit_completions",
        "habits",
        "ai_insights",
    ):
        try:
            supabase.table(table).delete().eq("user_id", user_id).execute()
        except Exception as exc:  # noqa: BLE001
            # meal_foods FKs to meals — cascading delete handles it. Skip noisily.
            print(f"  · skip cleanup on {table}: {exc}")


def _seed_profile(supabase, user_id: str) -> None:
    profile = {
        "user_id": user_id,
        "display_name": "App Review",
        "date_of_birth": "1990-06-15",
        "sex": "female",
        "height_cm": 168.0,
        "current_weight_kg": 64.5,
        "activity_level": "moderate",
        "goal_type": "lose_weight",
        "dietary_preference": "balanced",
        "daily_calorie_target": 1900,
        "daily_water_target_ml": 2400,
        "timezone": "Europe/Istanbul",
        "locale": "tr",
        "onboarding_completed": True,
        "onboarding_completed_at": _utc_iso(datetime.utcnow() - timedelta(days=14)),
        "is_premium": True,
        "premium_expires_at": _utc_iso(datetime.utcnow() + timedelta(days=60)),
    }
    supabase.table("user_profiles").upsert(profile, on_conflict="user_id").execute()
    print(f"  ✔ Upserted profile (premium until {profile['premium_expires_at']})")


def _seed_meals_and_water(supabase, user_id: str) -> None:
    today = date.today()
    meal_rows: list[dict[str, Any]] = []
    water_rows: list[dict[str, Any]] = []

    for offset in range(7):
        day = today - timedelta(days=offset)
        for hour, (mtype, name, kcal, p, c, f) in zip([8, 13, 19], DEMO_MEALS_PER_DAY):
            consumed = datetime.combine(day, datetime.min.time()).replace(
                hour=hour, minute=random.randint(0, 30)
            )
            meal_rows.append(
                {
                    "user_id": user_id,
                    "meal_type": mtype,
                    "name": name,
                    "total_calories": kcal,
                    "total_protein_g": p,
                    "total_carbs_g": c,
                    "total_fat_g": f,
                    "scan_source": "manual",
                    "consumed_at": _utc_iso(consumed),
                }
            )
        for cup in range(5):
            water_rows.append(
                {
                    "user_id": user_id,
                    "amount_ml": 250,
                    "logged_at": _utc_iso(
                        datetime.combine(day, datetime.min.time()).replace(
                            hour=9 + 2 * cup
                        )
                    ),
                }
            )

    supabase.table("meals").insert(meal_rows).execute()
    supabase.table("water_logs").insert(water_rows).execute()
    print(f"  ✔ Seeded {len(meal_rows)} meals + {len(water_rows)} water logs")


def _seed_weights(supabase, user_id: str) -> None:
    today = date.today()
    rows = []
    for offset in range(7):
        rows.append(
            {
                "user_id": user_id,
                "weight_kg": round(64.5 + offset * 0.15, 1),  # gentle 7-day downtrend
                "logged_at": (today - timedelta(days=offset)).isoformat(),
            }
        )
    supabase.table("weight_logs").insert(rows).execute()
    print(f"  ✔ Seeded {len(rows)} weight logs")


def _seed_habits(supabase, user_id: str) -> None:
    today = date.today()
    habit_payload = [
        {
            "user_id": user_id,
            "name": name,
            "target_type": ttype,
            "target_value": 10 if ttype == "duration" else (8000 if ttype == "count" else None),
            "target_unit": "min" if ttype == "duration" else ("steps" if ttype == "count" else None),
            "days_of_week": days,
        }
        for name, ttype, days in DEMO_HABITS
    ]
    inserted = supabase.table("habits").insert(habit_payload).execute()
    habit_rows = inserted.data or []
    if not habit_rows:
        print("  · habits insert returned no rows; skipping completions")
        return

    completions = []
    for h in habit_rows:
        for offset in range(7):
            day = today - timedelta(days=offset)
            # Skip ~20% of days so the streak isn't a perfect 7-of-7 for every habit.
            if random.random() < 0.2:
                continue
            completions.append(
                {
                    "habit_id": h["id"],
                    "user_id": user_id,
                    "completed_at": _utc_iso(
                        datetime.combine(day, datetime.min.time()).replace(hour=21)
                    ),
                }
            )
    if completions:
        supabase.table("habit_completions").insert(completions).execute()
    print(f"  ✔ Seeded {len(habit_rows)} habits + {len(completions)} completions")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--email", default=os.getenv("REVIEWER_EMAIL", DEFAULT_EMAIL))
    parser.add_argument(
        "--password", default=os.getenv("REVIEWER_PASSWORD", DEFAULT_PASSWORD)
    )
    parser.add_argument(
        "--allow-production",
        action="store_true",
        help="Permit running when APP_ENV=production",
    )
    args = parser.parse_args()

    settings = get_settings()
    if settings.is_production and not args.allow_production:
        print(
            "Refusing to run against production. Re-run with --allow-production "
            "if you are deliberately seeding prod for App Review.",
            file=sys.stderr,
        )
        return 2

    supabase = init_supabase()
    print(
        f"Seeding reviewer account ({args.email}) into "
        f"{settings.app_env} ({settings.supabase_url})"
    )

    user_id = _find_or_create_auth_user(supabase, args.email, args.password)
    _clear_user_data(supabase, user_id)
    _seed_profile(supabase, user_id)
    _seed_meals_and_water(supabase, user_id)
    _seed_weights(supabase, user_id)
    _seed_habits(supabase, user_id)

    print()
    print("─" * 60)
    print("App Store / Play Store Reviewer credentials")
    print("─" * 60)
    print(f"Email:    {args.email}")
    print(f"Password: {args.password}")
    print(f"User ID:  {user_id}")
    print(f"Premium:  active until +60 days")
    print(f"Locale:   tr-TR / Europe/Istanbul")
    print()
    print("Paste the email + password into App Store Connect →")
    print("  App Review Information → Sign-In Required → Username/Password.")
    print("─" * 60)

    return 0


if __name__ == "__main__":
    sys.exit(main())
