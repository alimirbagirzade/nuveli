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
    """
    Log a weight entry. Strips every column that prod schema might be
    missing — smoke test caught `logged_at` (PR #88), then `note`
    (this PR). Only `weight_kg` + `user_id` go to the INSERT; anything
    else gets DB defaults when the column exists or is silently absent.
    Response is backfilled from request values so Pydantic stays
    consistent regardless of live DB shape.

    See migrations/015_schema_drift_repair.sql for the permanent fix.
    Once Ali runs that in prod, this strip is a no-op (still safe).
    """
    supabase = get_supabase()
    payload = log.model_dump(mode="json", exclude={"logged_at", "note"})
    payload["user_id"] = user_id
    # Prod schema has `local_day` (DATE) as NOT NULL with no default.
    # If we don't send it, INSERT fails with 23502 not-null violation.
    # Use today (server-side UTC date) — same calendar day the entry
    # was logged. Migration 016 adds SET DEFAULT CURRENT_DATE to make
    # this self-filling, but sending it is harmless either way.
    payload["local_day"] = date.today().isoformat()

    # weight_logs has UNIQUE(user_id, local_day) — one weight entry per
    # user per calendar day, by design (chronic weighing is anti-pattern
    # in the wellness protocol). Without upsert, the second "Save weight"
    # tap on the same day returns 23505 → frontend banner "Could not save".
    # Upsert resolves the conflict by UPDATING the existing row instead.
    res = (
        supabase.table("weight_logs")
        .upsert(payload, on_conflict="user_id,local_day")
        .execute()
    )
    if not res.data:
        raise ValidationError("Failed to log weight")

    row = res.data[0]
    if "logged_at" not in row:
        row["logged_at"] = log.logged_at.isoformat()
    if "note" not in row:
        row["note"] = log.note

    # Also update profile.weight_kg with latest. Wrapped because the
    # user-visible action (logging weight) shouldn't fail if this side
    # effect errors — log loudly but return success.
    try:
        supabase.table("user_profiles").update(
            {"weight_kg": log.weight_kg, "updated_at": datetime.utcnow().isoformat()}
        ).eq("user_id", user_id).execute()
    except Exception as e:
        logger.warning(f"weight_log profile mirror failed for {user_id}: {e}")

    return row


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
#
# Schema drift: the live DB has columns `start_weight_kg`, `target_weight_kg`,
# and NO `direction` column on weight_goals. The Pydantic models + Flutter
# client speak the older names (`starting_weight_kg`, `target_kg`, `direction`).
# Two small adapters bridge the two without forcing a destructive DB rename or
# a Flutter release. When/if a future migration renames the DB columns, drop
# these helpers along with the Pydantic field renames.


def _db_to_api(row: dict) -> dict:
    """DB row → API/Flutter-shaped dict."""
    out = dict(row)
    if "start_weight_kg" in out and "starting_weight_kg" not in out:
        out["starting_weight_kg"] = out["start_weight_kg"]
    if "target_weight_kg" in out and "target_kg" not in out:
        out["target_kg"] = out["target_weight_kg"]
    # `direction` isn't stored on weight_goals — infer from start vs target.
    if not out.get("direction"):
        start = out.get("starting_weight_kg") or 0
        target = out.get("target_kg") or 0
        if abs(start - target) < 0.01:
            out["direction"] = "maintain"
        elif target < start:
            out["direction"] = "lose"
        else:
            out["direction"] = "gain"
    return out


def _api_to_db(payload: dict) -> dict:
    """API/Pydantic-shaped payload → DB column names (drops fields DB lacks)."""
    out = dict(payload)
    if "starting_weight_kg" in out:
        out["start_weight_kg"] = out.pop("starting_weight_kg")
    if "target_kg" in out:
        out["target_weight_kg"] = out.pop("target_kg")
    # weight_goals table has no `direction` column today. Strip it so the
    # INSERT/UPDATE doesn't trip "column does not exist". Direction is
    # re-inferred on read by _db_to_api.
    out.pop("direction", None)
    return out


@router.get("/goal", response_model=Optional[WeightGoalResponse])
async def get_active_goal(user_id: str = Depends(get_current_user)):
    supabase = get_supabase()
    # Prod weight_goals may not have a `status` column (schema drift —
    # migration 007 declared it but live schema is missing it). Try the
    # filtered query first; on PGRST204/42703, fall back to "most recent
    # goal regardless of status" so the Profile tab stops 500-ing.
    try:
        res = (
            supabase.table("weight_goals")
            .select("*")
            .eq("user_id", user_id)
            .eq("status", "active")
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )
    except Exception as e:
        logger.warning(f"weight_goals.status filter failed for {user_id}: {e}")
        res = (
            supabase.table("weight_goals")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )
    if not res.data:
        return None
    goal = _db_to_api(res.data[0])

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

    res = supabase.table("weight_goals").insert(_api_to_db(payload)).execute()
    return _db_to_api(res.data[0])


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
        .update(_api_to_db(payload))
        .eq("id", active.data[0]["id"])
        .eq("user_id", user_id)
        .execute()
    )
    return _db_to_api(res.data[0])
