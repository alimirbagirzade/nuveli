"""
Manual Exercise Logging endpoints (V1.1).

WELLNESS BOUNDARY (hard rule): exercise is a POSITIVE HABIT log only. This
router exposes a MET-based estimated calories-burned ONLY as a DISPLAY value
for the UI (an info badge). That figure is NEVER added to/subtracted from the
user's calorie target/budget — no endpoint here mutates any calorie goal, and
there is no burn/compensate/"you earned calories / eat more" semantics.
See docs/protocols/safety-wellness-boundary.md.
"""
from datetime import date, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, Query, status

from core.auth import get_current_user
from core.supabase_client import get_supabase
from core.exceptions import NotFound, ValidationError
from core.logging import get_logger
from models.exercise import (
    ExerciseLogCreate,
    ExerciseLogResponse,
    ExerciseTodaySummary,
    ExerciseDayTotal,
    ExerciseWeeklyResponse,
)
from services.exercise_calories import estimate_calories

logger = get_logger(__name__)
router = APIRouter()


def _get_user_weight_kg(supabase, user_id: str) -> Optional[float]:
    """
    Resolve the user's current weight in kg for the DISPLAY-ONLY calorie badge.

    Primary source: user_profiles.weight_kg (the live profile column — both
    onboarding and weight-logging write it; see routers/profiles.py & weight.py).
    Fallback: the most recent weight_logs.weight_kg by logged_at.

    Returns None when no weight is available — callers must then surface
    est_calories as None rather than guessing a default weight. Best-effort:
    any read error degrades to None so the activity log still serves.
    """
    try:
        prof = (
            supabase.table("user_profiles")
            .select("weight_kg")
            .eq("user_id", user_id)
            .limit(1)
            .execute()
        )
        if prof.data:
            w = prof.data[0].get("weight_kg")
            if w is not None:
                try:
                    wf = float(w)
                    if wf > 0:
                        return wf
                except (TypeError, ValueError):
                    pass
    except Exception as e:
        logger.warning(f"exercise weight lookup (profile) failed for {user_id}: {e}")

    try:
        wl = (
            supabase.table("weight_logs")
            .select("weight_kg, logged_at")
            .eq("user_id", user_id)
            .order("logged_at", desc=True)
            .limit(1)
            .execute()
        )
        if wl.data:
            w = wl.data[0].get("weight_kg")
            if w is not None:
                try:
                    wf = float(w)
                    if wf > 0:
                        return wf
                except (TypeError, ValueError):
                    pass
    except Exception as e:
        logger.warning(f"exercise weight lookup (weight_logs) failed for {user_id}: {e}")

    return None


# --- Logs ---

@router.post("/logs", response_model=ExerciseLogResponse, status_code=status.HTTP_201_CREATED)
async def create_exercise_log(
    log: ExerciseLogCreate,
    user_id: str = Depends(get_current_user),
):
    """
    Create an exercise log. We own exercise_logs (migration 020) so there's
    no schema drift to dodge — every column is sent straight through.

    local_day is set explicitly (today) so the row lands in the right
    calendar bucket regardless of DB DEFAULT, mirroring water/weight.
    activity_type is already normalized to the allowed set by the model.
    """
    supabase = get_supabase()
    payload = log.model_dump(mode="json")
    payload["user_id"] = user_id
    payload["local_day"] = date.today().isoformat()
    res = supabase.table("exercise_logs").insert(payload).execute()
    if not res.data:
        raise ValidationError("Failed to log exercise")

    row = res.data[0]
    # DISPLAY-ONLY estimate echoed on the created log. est_calories is None when
    # weight is unknown. It is NOT stored (no column) and never touches a budget.
    weight_kg = _get_user_weight_kg(supabase, user_id)
    row["est_calories"] = estimate_calories(
        activity_type=row.get("activity_type"),
        duration_min=row.get("duration_min"),
        intensity=row.get("intensity"),
        weight_kg=weight_kg,
    )
    return row


@router.get("/logs", response_model=list[ExerciseLogResponse])
async def list_exercise_logs(
    user_id: str = Depends(get_current_user),
    date_filter: Optional[date] = Query(None, alias="date"),
    limit: int = Query(50, ge=1, le=200),
):
    """List logs for a single local-day (default today), newest first.

    Each row gets a DISPLAY-ONLY est_calories (None if weight unknown). Weight
    is fetched ONCE per request, not per row.
    """
    supabase = get_supabase()
    target_date = date_filter or date.today()
    res = (
        supabase.table("exercise_logs")
        .select("*")
        .eq("user_id", user_id)
        .eq("local_day", target_date.isoformat())
        .order("logged_at", desc=True)
        .limit(limit)
        .execute()
    )
    rows = res.data or []
    weight_kg = _get_user_weight_kg(supabase, user_id)
    for r in rows:
        r["est_calories"] = estimate_calories(
            activity_type=r.get("activity_type"),
            duration_min=r.get("duration_min"),
            intensity=r.get("intensity"),
            weight_kg=weight_kg,
        )
    return rows


@router.delete("/logs/{log_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_exercise_log(
    log_id: str,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    res = (
        supabase.table("exercise_logs")
        .delete()
        .eq("id", log_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Exercise log")


@router.get("/today/summary", response_model=ExerciseTodaySummary)
async def exercise_today_summary(user_id: str = Depends(get_current_user)):
    """
    Today's activity rollup: total minutes, session count, distinct activity
    types, and an `active` flag (sessions > 0), plus a DISPLAY-ONLY
    total_calories (sum of per-session MET estimates). total_calories is None
    only when the user's weight is unknown; it never affects a calorie budget.
    """
    supabase = get_supabase()
    today = date.today()
    res = (
        supabase.table("exercise_logs")
        .select("activity_type, duration_min, intensity")
        .eq("user_id", user_id)
        .eq("local_day", today.isoformat())
        .execute()
    )
    rows = res.data or []
    total_minutes = sum(r.get("duration_min", 0) or 0 for r in rows)
    # Distinct activity types, stable order (first-seen) for a tidy chip row.
    seen: list[str] = []
    for r in rows:
        at = r.get("activity_type")
        if at and at not in seen:
            seen.append(at)

    # DISPLAY-ONLY calorie total. Weight fetched once. None when weight unknown.
    weight_kg = _get_user_weight_kg(supabase, user_id)
    total_calories: Optional[int] = None
    if weight_kg is not None:
        total_calories = sum(
            estimate_calories(
                activity_type=r.get("activity_type"),
                duration_min=r.get("duration_min"),
                intensity=r.get("intensity"),
                weight_kg=weight_kg,
            ) or 0
            for r in rows
        )

    return ExerciseTodaySummary(
        total_minutes=total_minutes,
        sessions_count=len(rows),
        active=len(rows) > 0,
        activity_types=seen,
        total_calories=total_calories,
    )


@router.get("/weekly", response_model=ExerciseWeeklyResponse,
            summary="Last 7 local-days of exercise totals")
async def exercise_weekly(user_id: str = Depends(get_current_user)):
    """
    Per-day activity totals for the last 7 calendar days (inclusive of
    today). Always returns exactly 7 buckets — missing days come back as
    total_minutes=0 so the Dashboard strip stays a clean 7-bar week.

    Each day and the week carry a DISPLAY-ONLY total_calories (MET estimate
    sum), None when the user's weight is unknown. These figures never affect a
    calorie budget/target.
    """
    supabase = get_supabase()
    end = date.today()
    start = end - timedelta(days=6)

    res = (
        supabase.table("exercise_logs")
        .select("duration_min, local_day, activity_type, intensity")
        .eq("user_id", user_id)
        .gte("local_day", start.isoformat())
        .lte("local_day", end.isoformat())
        .execute()
    )

    # Weight fetched once for the whole week. None → all calorie totals None.
    weight_kg = _get_user_weight_kg(supabase, user_id)
    has_weight = weight_kg is not None

    minutes_by_day: dict[date, int] = {}
    sessions_by_day: dict[date, int] = {}
    calories_by_day: dict[date, int] = {}
    for row in res.data or []:
        d_str = (row.get("local_day") or "")[:10]
        try:
            d = date.fromisoformat(d_str)
        except ValueError:
            continue
        minutes_by_day[d] = minutes_by_day.get(d, 0) + (row.get("duration_min") or 0)
        sessions_by_day[d] = sessions_by_day.get(d, 0) + 1
        if has_weight:
            calories_by_day[d] = calories_by_day.get(d, 0) + (
                estimate_calories(
                    activity_type=row.get("activity_type"),
                    duration_min=row.get("duration_min"),
                    intensity=row.get("intensity"),
                    weight_kg=weight_kg,
                ) or 0
            )

    days: list[ExerciseDayTotal] = []
    for i in range(7):
        d = start + timedelta(days=i)
        days.append(
            ExerciseDayTotal(
                day=d,
                total_minutes=minutes_by_day.get(d, 0),
                sessions_count=sessions_by_day.get(d, 0),
                total_calories=calories_by_day.get(d, 0) if has_weight else None,
            )
        )

    week_total_minutes = sum(day.total_minutes for day in days)
    active_days = sum(1 for day in days if day.sessions_count > 0)
    week_total_calories = (
        sum(calories_by_day.get(start + timedelta(days=i), 0) for i in range(7))
        if has_weight
        else None
    )

    return ExerciseWeeklyResponse(
        days=days,
        week_total_minutes=week_total_minutes,
        active_days=active_days,
        week_total_calories=week_total_calories,
    )
