"""
Achievement unlock detection.
Achievements are defined as code constants below;
user_achievements table tracks unlock state.
"""
from datetime import datetime, date, timedelta
from typing import Any

from core.supabase_client import get_supabase
from core.logging import get_logger

logger = get_logger(__name__)


# Achievement registry — synced with user_achievements seed data.
ACHIEVEMENTS: list[dict[str, Any]] = [
    {"code": "first_meal", "title": "First Bite", "description": "Log your first meal", "icon": "🥗", "category": "milestone", "target_value": 1},
    {"code": "10_meals", "title": "Getting Started", "description": "Log 10 meals", "icon": "🍽️", "category": "milestone", "target_value": 10},
    {"code": "100_meals", "title": "Centurion", "description": "Log 100 meals", "icon": "💯", "category": "milestone", "target_value": 100},
    {"code": "streak_3", "title": "Three in a Row", "description": "3-day logging streak", "icon": "🔥", "category": "streak", "target_value": 3},
    {"code": "streak_7", "title": "One Week Strong", "description": "7-day logging streak", "icon": "🔥", "category": "streak", "target_value": 7},
    {"code": "streak_30", "title": "Month of Consistency", "description": "30-day streak", "icon": "🏆", "category": "streak", "target_value": 30},
    {"code": "water_2_5L", "title": "Hydration Hero", "description": "Hit 2.5L water in a day", "icon": "💧", "category": "water", "target_value": 2500},
    {"code": "water_7_day_target", "title": "Hydration Week", "description": "Meet water target 7 days in a row", "icon": "🌊", "category": "water", "target_value": 7},
    {"code": "protein_target_day", "title": "Protein Power", "description": "Hit protein target in a day", "icon": "💪", "category": "macro", "target_value": 1},
    {"code": "scan_first", "title": "AI Eye", "description": "First AI scan", "icon": "📸", "category": "scan", "target_value": 1},
    {"code": "scan_10", "title": "Scan Pro", "description": "10 AI scans", "icon": "🔍", "category": "scan", "target_value": 10},
    {"code": "habits_all_day", "title": "Perfect Day", "description": "Complete all habits in one day", "icon": "✅", "category": "habits", "target_value": 1},
    {"code": "weight_logged_7d", "title": "Weight Watcher", "description": "Log weight 7 days in a row", "icon": "⚖️", "category": "weight", "target_value": 7},
]


def _registry_by_code() -> dict[str, dict]:
    return {a["code"]: a for a in ACHIEVEMENTS}


async def _user_progress(user_id: str) -> dict[str, float]:
    """Compute current progress for each achievement code."""
    supabase = get_supabase()
    progress: dict[str, float] = {}

    # Meal counts
    meals = (
        supabase.table("meals")
        .select("id, consumed_at, scan_source")
        .eq("user_id", user_id)
        .execute()
    )
    meal_rows = meals.data or []
    progress["first_meal"] = float(min(len(meal_rows), 1))
    progress["10_meals"] = float(len(meal_rows))
    progress["100_meals"] = float(len(meal_rows))

    scans = [m for m in meal_rows if m.get("scan_source") == "ai_scan"]
    progress["scan_first"] = float(min(len(scans), 1))
    progress["scan_10"] = float(len(scans))

    # Meal streak
    from services.streak_service import compute_meal_streak
    meal_streak = await compute_meal_streak(user_id)
    progress["streak_3"] = float(meal_streak)
    progress["streak_7"] = float(meal_streak)
    progress["streak_30"] = float(meal_streak)

    # Water — best single day
    water = (
        supabase.table("water_logs")
        .select("amount_ml, logged_at")
        .eq("user_id", user_id)
        .execute()
    )
    by_day: dict[str, int] = {}
    for w in water.data or []:
        d = (w.get("logged_at") or "")[:10]
        if d:
            by_day[d] = by_day.get(d, 0) + (w.get("amount_ml") or 0)
    best_day = max(by_day.values()) if by_day else 0
    progress["water_2_5L"] = float(best_day)

    # Water 7-day target — consecutive days meeting daily_water_target_ml
    prof = (
        supabase.table("user_profiles")
        .select("daily_water_target_ml")
        .eq("user_id", user_id)
        .single()
        .execute()
    )
    target = (prof.data or {}).get("daily_water_target_ml") or 2500
    qualifying = {d for d, total in by_day.items() if total >= target}
    sorted_q = sorted(qualifying)
    run = 0
    best_run = 0
    prev: date | None = None
    for ds in sorted_q:
        d = date.fromisoformat(ds)
        if prev and (d - prev).days == 1:
            run += 1
        else:
            run = 1
        best_run = max(best_run, run)
        prev = d
    progress["water_7_day_target"] = float(best_run)

    # Weight logs — consecutive days
    weights = (
        supabase.table("weight_logs")
        .select("logged_at")
        .eq("user_id", user_id)
        .execute()
    )
    weight_days = sorted({(w.get("logged_at") or "")[:10] for w in (weights.data or []) if w.get("logged_at")})
    run = 0
    best_w = 0
    prev = None
    for ds in weight_days:
        if not ds:
            continue
        d = date.fromisoformat(ds)
        if prev and (d - prev).days == 1:
            run += 1
        else:
            run = 1
        best_w = max(best_w, run)
        prev = d
    progress["weight_logged_7d"] = float(best_w)

    # Habit perfect day — at least one day with all habits done
    habits = (
        supabase.table("habits")
        .select("id")
        .eq("user_id", user_id)
        .eq("is_active", True)
        .execute()
    )
    total_h = len(habits.data or [])
    if total_h > 0:
        completions = (
            supabase.table("habit_completions")
            .select("habit_id, completed_at")
            .eq("user_id", user_id)
            .execute()
        )
        per_day: dict[str, set] = {}
        for c in completions.data or []:
            d = (c.get("completed_at") or "")[:10]
            if d:
                per_day.setdefault(d, set()).add(c["habit_id"])
        perfect_days = sum(1 for hs in per_day.values() if len(hs) >= total_h)
        progress["habits_all_day"] = float(min(perfect_days, 1))

    # Protein target day — at least one day hitting protein target
    progress.setdefault("protein_target_day", 0)
    # (left as a future computation; trigger could populate via daily_summaries view)

    return progress


async def list_user_achievements(user_id: str) -> list[dict]:
    """Return all achievements with current progress and unlock state."""
    supabase = get_supabase()
    progress = await _user_progress(user_id)

    unlocked_res = (
        supabase.table("user_achievements")
        .select("code, unlocked_at")
        .eq("user_id", user_id)
        .execute()
    )
    unlocked_map = {r["code"]: r.get("unlocked_at") for r in (unlocked_res.data or [])}

    result = []
    for a in ACHIEVEMENTS:
        code = a["code"]
        current = progress.get(code, 0)
        target = a["target_value"]
        percent = min(100, (current / target) * 100) if target else 0
        result.append({
            "code": code,
            "title": a["title"],
            "description": a["description"],
            "icon": a["icon"],
            "category": a["category"],
            "target_value": target,
            "current_progress": current,
            "percent_complete": round(percent, 1),
            "unlocked": code in unlocked_map,
            "unlocked_at": unlocked_map.get(code),
        })
    return result


async def check_and_unlock(user_id: str) -> list[dict]:
    """Check all achievements; insert any newly unlocked into user_achievements."""
    supabase = get_supabase()
    progress = await _user_progress(user_id)

    existing = (
        supabase.table("user_achievements")
        .select("code")
        .eq("user_id", user_id)
        .execute()
    )
    already = {r["code"] for r in (existing.data or [])}

    newly_unlocked = []
    for a in ACHIEVEMENTS:
        code = a["code"]
        if code in already:
            continue
        if progress.get(code, 0) >= a["target_value"]:
            newly_unlocked.append({
                "user_id": user_id,
                "code": code,
                "unlocked_at": datetime.utcnow().isoformat(),
            })

    if newly_unlocked:
        supabase.table("user_achievements").insert(newly_unlocked).execute()
        logger.info(f"User {user_id} unlocked {len(newly_unlocked)} achievements")

    # Hydrate the response with title/description from registry
    by_code = _registry_by_code()
    return [
        {
            **by_code[u["code"]],
            "unlocked_at": u["unlocked_at"],
            "unlocked": True,
            "current_progress": progress.get(u["code"], 0),
            "percent_complete": 100,
        }
        for u in newly_unlocked
    ]
