"""
Weight tracking endpoints.
"""
from datetime import date, datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, Query, status

from core.auth import get_current_user
from core.supabase_client import get_supabase
from core.exceptions import NotFound, ValidationError
from core.logging import get_logger
from models.weight import (
    WeightLogCreate, WeightLogResponse,
    WeightGoalCreate, WeightGoalUpdate, WeightGoalResponse,
)

logger = get_logger(__name__)
router = APIRouter()


def _parse_period(period: str) -> int:
    """Parse '8w', '3m', '1y' → days."""
    period = period.lower().strip()
    if period.endswith("w"):
        return int(period[:-1]) * 7
    if period.endswith("m"):
        return int(period[:-1]) * 30
    if period.endswith("y"):
        return int(period[:-1]) * 365
    if period.endswith("d"):
        return int(period[:-1])
    return 56  # default 8 weeks


# --- Logs ---

@router.post("/logs", response_model=WeightLogResponse, status_code=status.HTTP_201_CREATED)
async def create_weight_log(
    log: WeightLogCreate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = log.model_dump(mode="json")
    payload["user_id"] = user_id
    res = supabase.table("weight_logs").insert(payload).execute()
    if not res.data:
        raise ValidationError("Failed to log weight")

    # Also update profile.weight_kg with latest
    supabase.table("user_profiles").update(
        {"weight_kg": log.weight_kg, "updated_at": datetime.utcnow().isoformat()}
    ).eq("user_id", user_id).execute()

    return res.data[0]


@router.get("/logs", response_model=list[WeightLogResponse])
async def list_weight_logs(
    user_id: str = Depends(get_current_user),
    period: str = Query("8w", description="Time window: 7d, 4w, 8w, 3m, 1y"),
    limit: int = Query(200, ge=1, le=500),
):
    supabase = get_supabase()
    days = _parse_period(period)
    start = (date.today() - timedelta(days=days)).isoformat()
    res = (
        supabase.table("weight_logs")
        .select("*")
        .eq("user_id", user_id)
        .gte("logged_at", start)
        .order("logged_at")
        .limit(limit)
        .execute()
    )
    return res.data or []


@router.delete("/logs/{log_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_weight_log(
    log_id: str,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    res = (
        supabase.table("weight_logs")
        .delete()
        .eq("id", log_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Weight log")


# --- Goals ---

@router.get("/goal", response_model=Optional[WeightGoalResponse])
async def get_active_goal(user_id: str = Depends(get_current_user)):
    supabase = get_supabase()
    res = (
        supabase.table("weight_goals")
        .select("*")
        .eq("user_id", user_id)
        .eq("status", "active")
        .order("created_at", desc=True)
        .limit(1)
        .execute()
    )
    if not res.data:
        return None
    goal = res.data[0]

    # Compute progress
    current_w = (
        supabase.table("weight_logs")
        .select("weight_kg, logged_at")
        .eq("user_id", user_id)
        .order("logged_at", desc=True)
        .limit(1)
        .execute()
    )
    if current_w.data and goal.get("starting_weight_kg"):
        current = current_w.data[0]["weight_kg"]
        start = goal["starting_weight_kg"]
        target = goal["target_kg"]
        if abs(target - start) > 0.01:
            progress = (start - current) / (start - target) * 100
            goal["progress_percent"] = round(max(0, min(100, progress)), 1)

    return goal


@router.post("/goal", response_model=WeightGoalResponse, status_code=status.HTTP_201_CREATED)
async def create_goal(
    goal: WeightGoalCreate,
    user_id: str = Depends(get_current_user),
):
    """Create new goal. Marks any previous active goal as 'cancelled'."""
    supabase = get_supabase()

    # Deactivate existing active goals
    supabase.table("weight_goals")\
        .update({"status": "cancelled"})\
        .eq("user_id", user_id)\
        .eq("status", "active")\
        .execute()

    payload = goal.model_dump(mode="json")
    payload["user_id"] = user_id
    payload["status"] = "active"

    # Auto-fill starting_weight if missing
    if not payload.get("starting_weight_kg"):
        latest = (
            supabase.table("weight_logs")
            .select("weight_kg")
            .eq("user_id", user_id)
            .order("logged_at", desc=True)
            .limit(1)
            .execute()
        )
        if latest.data:
            payload["starting_weight_kg"] = latest.data[0]["weight_kg"]

    res = supabase.table("weight_goals").insert(payload).execute()
    return res.data[0]


@router.patch("/goal", response_model=WeightGoalResponse)
async def update_goal(
    update: WeightGoalUpdate,
    user_id: str = Depends(get_current_user),
):
    """Update the currently active goal."""
    supabase = get_supabase()
    payload = update.model_dump(exclude_unset=True, mode="json")
    if not payload:
        raise ValidationError("Empty update")

    active = (
        supabase.table("weight_goals")
        .select("id")
        .eq("user_id", user_id)
        .eq("status", "active")
        .limit(1)
        .execute()
    )
    if not active.data:
        raise NotFound("Active goal")

    res = (
        supabase.table("weight_goals")
        .update(payload)
        .eq("id", active.data[0]["id"])
        .eq("user_id", user_id)
        .execute()
    )
    return res.data[0]
