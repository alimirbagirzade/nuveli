"""
Healthy habits endpoints.
"""
from datetime import date, datetime, timedelta
from fastapi import APIRouter, Depends, status

from core.auth import get_current_user
from core.supabase_client import get_supabase
from core.exceptions import NotFound, ValidationError
from core.logging import get_logger
from models.habit import (
    HabitCreate, HabitUpdate, HabitResponse,
    HabitCompletionResponse, WeeklyConsistencyResponse,
    HabitDayConsistency, HabitStreakResponse,
)
from services.streak_service import compute_habit_streak

logger = get_logger(__name__)
router = APIRouter()


# --- Schema drift adapter ---
#
# Prod `habits` table actually uses these column names (verified 2026-05-23
# via service-role probes):
#   title              (our Pydantic field is `name`)
#   display_order      (our field is `sort_order`)
#   schedule_type      (our field is `schedule`)
#   days_of_week TEXT[] {mon,tue,wed,thu,fri,sat,sun}  (we use int[] custom_days)
#   habit_type         (NOT NULL, default 'check' — not on our model)
#   target_type, target_value, icon, is_active, created_at
#
# Backend (this file) and `models/habit.py` were written against an older
# repo migration that used different names. Migration would be the right
# fix, but doing it without diffing every prod row carries data-loss risk.
# Instead we adapt at the router boundary so the API contract stays
# stable while the DB stays untouched.

_DOW_NAMES = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]


def _row_to_api(row: dict) -> dict:
    """Translate one prod `habits` row into the HabitResponse shape."""
    days_raw = row.get("days_of_week") or []
    if isinstance(days_raw, list):
        custom_days = [
            _DOW_NAMES.index(d.lower())
            for d in days_raw
            if isinstance(d, str) and d.lower() in _DOW_NAMES
        ]
    else:
        custom_days = None
    return {
        "id": row.get("id"),
        "user_id": row.get("user_id"),
        "name": row.get("title", ""),
        "icon": row.get("icon"),
        "target_type": row.get("target_type", "boolean"),
        "target_value": row.get("target_value"),
        "schedule": row.get("schedule_type", "daily"),
        "custom_days": custom_days or None,
        "reminder_time": None,  # prod has no reminder column yet
        "is_active": row.get("is_active", True),
        "sort_order": row.get("display_order", 0),
        "created_at": row.get("created_at"),
    }


def _api_to_row(payload: dict) -> dict:
    """Translate inbound HabitCreate/HabitUpdate payload to prod columns."""
    out: dict = {}
    if "name" in payload:
        out["title"] = payload["name"]
    if "icon" in payload:
        out["icon"] = payload["icon"]
    if "target_type" in payload:
        out["target_type"] = payload["target_type"]
    if "target_value" in payload:
        out["target_value"] = payload["target_value"]
    if "schedule" in payload:
        out["schedule_type"] = payload["schedule"]
    if "custom_days" in payload and payload["custom_days"] is not None:
        out["days_of_week"] = [
            _DOW_NAMES[i] for i in payload["custom_days"] if 0 <= i < 7
        ]
    if "sort_order" in payload:
        out["display_order"] = payload["sort_order"]
    if "is_active" in payload:
        out["is_active"] = payload["is_active"]
    # `habit_type` is NOT NULL with default 'check' in prod; only set on
    # create. Update paths don't include it (the row already has a value).
    return out


@router.get("", response_model=list[HabitResponse])
async def list_habits(user_id: str = Depends(get_current_user)):
    """List active habits with completed_today + current_streak derived fields."""
    supabase = get_supabase()
    res = (
        supabase.table("habits")
        .select("*")
        .eq("user_id", user_id)
        .eq("is_active", True)
        .order("display_order")
        .execute()
    )
    rows = res.data or []

    today = date.today()
    completions_today = (
        supabase.table("habit_completions")
        .select("habit_id")
        .eq("user_id", user_id)
        .gte("completed_at", f"{today}T00:00:00")
        .lt("completed_at", f"{today}T23:59:59")
        .execute()
    )
    done_today = {c["habit_id"] for c in (completions_today.data or [])}

    habits = []
    for row in rows:
        h = _row_to_api(row)
        h["completed_today"] = h["id"] in done_today
        h["current_streak"] = 0  # cheap default; full streak via /habits/streak
        habits.append(h)
    return habits


@router.post("", response_model=HabitResponse, status_code=status.HTTP_201_CREATED)
async def create_habit(
    habit: HabitCreate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = _api_to_row(habit.model_dump(mode="json"))
    payload["user_id"] = user_id
    payload["is_active"] = True
    payload.setdefault("habit_type", "check")  # NOT NULL in prod
    res = supabase.table("habits").insert(payload).execute()
    if not res.data:
        raise ValidationError("Failed to create habit")
    h = _row_to_api(res.data[0])
    h["completed_today"] = False
    h["current_streak"] = 0
    return h


@router.patch("/{habit_id}", response_model=HabitResponse)
async def update_habit(
    habit_id: str,
    update: HabitUpdate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = _api_to_row(update.model_dump(exclude_unset=True, mode="json"))
    if not payload:
        raise ValidationError("Empty update")
    res = (
        supabase.table("habits")
        .update(payload)
        .eq("id", habit_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Habit")
    h = _row_to_api(res.data[0])
    h["completed_today"] = False
    h["current_streak"] = 0
    return h


@router.delete("/{habit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_habit(
    habit_id: str,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    # Soft delete: set is_active=false to preserve completion history
    res = (
        supabase.table("habits")
        .update({"is_active": False})
        .eq("id", habit_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Habit")


@router.post("/{habit_id}/complete", response_model=HabitCompletionResponse,
             status_code=status.HTTP_201_CREATED)
async def complete_habit(
    habit_id: str,
    user_id: str = Depends(get_current_user),
):
    """Mark habit done for today. Idempotent — re-completing returns existing record."""
    supabase = get_supabase()

    # Verify ownership
    h = (
        supabase.table("habits")
        .select("id")
        .eq("id", habit_id)
        .eq("user_id", user_id)
        .maybe_single()
        .execute()
    )
    if not h.data:
        raise NotFound("Habit")

    today = date.today()
    existing = (
        supabase.table("habit_completions")
        .select("*")
        .eq("habit_id", habit_id)
        .eq("user_id", user_id)
        .gte("completed_at", f"{today}T00:00:00")
        .lt("completed_at", f"{today}T23:59:59")
        .execute()
    )
    if existing.data:
        return existing.data[0]

    res = supabase.table("habit_completions").insert({
        "habit_id": habit_id,
        "user_id": user_id,
        "completed_at": datetime.utcnow().isoformat(),
    }).execute()
    return res.data[0]


@router.delete("/{habit_id}/complete", status_code=status.HTTP_204_NO_CONTENT)
async def uncomplete_habit(
    habit_id: str,
    user_id: str = Depends(get_current_user),
):
    """Undo today's completion."""
    supabase = get_supabase()
    today = date.today()
    supabase.table("habit_completions")\
        .delete()\
        .eq("habit_id", habit_id)\
        .eq("user_id", user_id)\
        .gte("completed_at", f"{today}T00:00:00")\
        .lt("completed_at", f"{today}T23:59:59")\
        .execute()


@router.get("/weekly", response_model=WeeklyConsistencyResponse)
async def weekly_consistency(user_id: str = Depends(get_current_user)):
    """Last-7-days consistency: completed_count / total_active habits per day."""
    supabase = get_supabase()
    end = date.today()
    start = end - timedelta(days=6)

    habits = (
        supabase.table("habits")
        .select("id")
        .eq("user_id", user_id)
        .eq("is_active", True)
        .execute()
    )
    total = len(habits.data or []) or 1

    completions = (
        supabase.table("habit_completions")
        .select("habit_id, completed_at")
        .eq("user_id", user_id)
        .gte("completed_at", start.isoformat())
        .execute()
    )
    per_day: dict[date, set] = {}
    for c in completions.data or []:
        try:
            d = date.fromisoformat((c.get("completed_at") or "")[:10])
            per_day.setdefault(d, set()).add(c["habit_id"])
        except ValueError:
            continue

    days = []
    for i in range(7):
        d = start + timedelta(days=i)
        done = len(per_day.get(d, set()))
        days.append(HabitDayConsistency(
            day=d,
            completed_count=done,
            total_count=total,
            percent=round(min(100, done / total * 100), 1) if total else 0,
        ))

    avg = sum(d.percent for d in days) / 7 if days else 0
    return WeeklyConsistencyResponse(days=days, week_avg_percent=round(avg, 1))


@router.get("/streak", response_model=HabitStreakResponse)
async def habit_streak(user_id: str = Depends(get_current_user)):
    streak = await compute_habit_streak(user_id)
    return HabitStreakResponse(**streak)
