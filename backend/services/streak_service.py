"""
Streak calculations: ardışık gün sayısı (consecutive days).
Used for habits screen + dashboard streak card.
"""
from datetime import date, timedelta
from core.supabase_client import get_supabase
from core.logging import get_logger

logger = get_logger(__name__)


def _date_set_from_timestamps(rows: list[dict], field: str) -> set[date]:
    """Convert a list of rows into a set of unique date()s from a timestamp field."""
    out = set()
    for r in rows:
        ts = r.get(field)
        if not ts:
            continue
        if isinstance(ts, str):
            # supabase returns ISO strings; take YYYY-MM-DD prefix
            try:
                out.add(date.fromisoformat(ts[:10]))
            except ValueError:
                continue
        elif hasattr(ts, "date"):
            out.add(ts.date())
    return out


def _count_consecutive(days_set: set[date], starting_from: date | None = None) -> int:
    """Count consecutive days backwards from starting_from (default today)."""
    starting_from = starting_from or date.today()
    streak = 0
    d = starting_from
    # If today is missing, allow yesterday as the start (grace for in-progress day)
    if d not in days_set:
        d = d - timedelta(days=1)
    while d in days_set:
        streak += 1
        d = d - timedelta(days=1)
    return streak


async def compute_meal_streak(user_id: str) -> int:
    """Consecutive days (ending today/yesterday) where at least 1 meal was logged."""
    supabase = get_supabase()
    end = date.today()
    start = end - timedelta(days=60)  # look back 60 days max
    res = (
        supabase.table("meals")
        .select("consumed_at")
        .eq("user_id", user_id)
        .gte("consumed_at", start.isoformat())
        .execute()
    )
    days = _date_set_from_timestamps(res.data or [], "consumed_at")
    return _count_consecutive(days)


async def compute_habit_streak(user_id: str, threshold: float = 0.8) -> dict:
    """
    Consecutive days where >= threshold of active habits were completed.
    Returns dict with current_streak, longest_streak, last_completed_date.
    """
    supabase = get_supabase()
    end = date.today()
    start = end - timedelta(days=90)

    habits = (
        supabase.table("habits")
        .select("id")
        .eq("user_id", user_id)
        .eq("is_active", True)
        .execute()
    )
    total_habits = len(habits.data or [])
    if total_habits == 0:
        return {"current_streak": 0, "longest_streak": 0, "last_completed_date": None,
                "days_with_full_completion": 0}

    completions = (
        supabase.table("habit_completions")
        .select("habit_id, completed_at")
        .eq("user_id", user_id)
        .gte("completed_at", start.isoformat())
        .execute()
    )

    # Group completions by date
    per_day: dict[date, set] = {}
    for c in completions.data or []:
        ts = c.get("completed_at")
        if not ts:
            continue
        try:
            d = date.fromisoformat(ts[:10])
        except ValueError:
            continue
        per_day.setdefault(d, set()).add(c["habit_id"])

    # "Qualifying" days = days where >=threshold of habits completed
    qualifying_days = {
        d for d, habit_ids in per_day.items()
        if len(habit_ids) >= total_habits * threshold
    }

    current_streak = _count_consecutive(qualifying_days)

    # Longest streak in the 90-day window
    longest = 0
    if qualifying_days:
        sorted_days = sorted(qualifying_days)
        run = 1
        for i in range(1, len(sorted_days)):
            if (sorted_days[i] - sorted_days[i - 1]).days == 1:
                run += 1
                longest = max(longest, run)
            else:
                run = 1
        longest = max(longest, run)

    last_completed = max(per_day.keys()) if per_day else None

    return {
        "current_streak": current_streak,
        "longest_streak": longest,
        "last_completed_date": last_completed,
        "days_with_full_completion": len(qualifying_days),
    }


async def compute_user_streak(user_id: str) -> int:
    """Composite streak: at least 1 meal AND any habit completion that day."""
    meal_streak = await compute_meal_streak(user_id)
    habit = await compute_habit_streak(user_id)
    return min(meal_streak, habit["current_streak"]) if habit["current_streak"] else meal_streak
