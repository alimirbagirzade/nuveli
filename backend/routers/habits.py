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


@router.get("", response_model=list[HabitResponse])
async def list_habits(user_id: str = Depends(get_current_user)):
    """List active habits with completed_today + current_streak derived fields."""
    supabase = get_supabase()
    res = (
        supabase.table("habits")
        .select("*")
        .eq("user_id", user_id)
        .eq("is_active", True)
        .order("sort_order")
        .execute()
    )
    habits = res.data or []

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

    # Add derived fields
    for h in habits:
        h["completed_today"] = h["id"] in done_today
        h["current_streak"] = 0  # cheap default; full streak via /habits/streak
    return habits


@router.post("", response_model=HabitResponse, status_code=status.HTTP_201_CREATED)
async def create_habit(
    habit: HabitCreate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = habit.model_dump(mode="json")
    payload["user_id"] = user_id
    payload["is_active"] = True
    res = supabase.table("habits").insert(payload).execute()
    if not res.data:
        raise ValidationError("Failed to create habit")
    h = res.data[0]
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
    payload = update.model_dump(exclude_unset=True, mode="json")
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
    h = res.data[0]
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
