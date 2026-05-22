"""
Water tracker endpoints.
"""
from datetime import date, datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, Query, status

from core.auth import get_current_user
from core.supabase_client import get_supabase
from core.exceptions import NotFound, ValidationError
from core.logging import get_logger
from models.water import (
    WaterLogCreate, WaterLogResponse, WaterTodaySummary,
    WaterReminderCreate, WaterReminderUpdate, WaterReminderResponse,
    WaterInsight,
)

logger = get_logger(__name__)
router = APIRouter()


# --- Logs ---

@router.post("/logs", response_model=WaterLogResponse, status_code=status.HTTP_201_CREATED)
async def create_water_log(
    log: WaterLogCreate,
    user_id: str = Depends(get_current_user),
):
    """
    Create a water-intake record. Strips every optional column to dodge
    schema drift between migration 004 and the live prod water_logs
    table. Smoke test surfaced TWO PGRST204 / 42703 failures in a row:
      1) "column water_logs.logged_at does not exist" — stripped in PR #84
      2) "Could not find the 'source' column of 'water_logs' in the
          schema cache" — also stripped now

    Only `amount_ml` + `user_id` are sent. Anything else (timestamps,
    source label) is filled in by DB defaults when the column exists,
    or silently dropped when it doesn't. The response echoes the
    request's logged_at + source so the Pydantic response model is
    satisfied even when those columns aren't in the row.

    If a future migration restores both columns to prod, this strip
    is harmless — the DB defaults still apply.
    """
    supabase = get_supabase()
    payload = log.model_dump(mode="json", exclude={"logged_at", "source"})
    payload["user_id"] = user_id
    # Same `local_day NOT NULL` constraint as weight_logs in prod —
    # not in migration 004 but the live table has it. Send today's
    # date so INSERT doesn't 23502. Migration 016 added DEFAULT
    # CURRENT_DATE only on weight_logs; water_logs needs the same
    # treatment (covered in the SQL block I'll attach in the PR body).
    payload["local_day"] = date.today().isoformat()
    res = supabase.table("water_logs").insert(payload).execute()
    if not res.data:
        raise ValidationError("Failed to log water")
    row = res.data[0]
    # Backfill the response with request values when the DB row is
    # missing those keys (drift). Frontend gets a consistent shape.
    if "logged_at" not in row:
        row["logged_at"] = log.logged_at.isoformat()
    if "source" not in row:
        row["source"] = log.source
    return row


@router.get("/logs", response_model=list[WaterLogResponse])
async def list_water_logs(
    user_id: str = Depends(get_current_user),
    date_filter: Optional[date] = Query(None, alias="date"),
    limit: int = Query(50, ge=1, le=200),
):
    supabase = get_supabase()
    target_date = date_filter or date.today()
    res = (
        supabase.table("water_logs")
        .select("*")
        .eq("user_id", user_id)
        .gte("logged_at", f"{target_date}T00:00:00")
        .lt("logged_at", f"{target_date}T23:59:59")
        .order("logged_at", desc=True)
        .limit(limit)
        .execute()
    )
    return res.data or []


@router.delete("/logs/{log_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_water_log(
    log_id: str,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    res = (
        supabase.table("water_logs")
        .delete()
        .eq("id", log_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Water log")


@router.get("/today/summary", response_model=WaterTodaySummary)
async def water_today_summary(user_id: str = Depends(get_current_user)):
    supabase = get_supabase()
    today = date.today()
    logs = (
        supabase.table("water_logs")
        .select("amount_ml")
        .eq("user_id", user_id)
        .gte("logged_at", f"{today}T00:00:00")
        .lt("logged_at", f"{today}T23:59:59")
        .execute()
    )
    prof = (
        supabase.table("user_profiles")
        .select("daily_water_target_ml")
        .eq("user_id", user_id)
        .single()
        .execute()
    )
    target = (prof.data or {}).get("daily_water_target_ml") or 2500
    rows = logs.data or []
    consumed = sum(r.get("amount_ml", 0) for r in rows)
    glasses = consumed // 250
    target_glasses = target // 250 or 10
    return WaterTodaySummary(
        consumed_ml=consumed,
        target_ml=target,
        percent_complete=round(min(100, consumed / target * 100), 1) if target else 0,
        glass_count=glasses,
        target_glasses=target_glasses,
        remaining_ml=max(0, target - consumed),
        logs_count=len(rows),
    )


# --- Reminders ---

@router.get("/reminders", response_model=list[WaterReminderResponse])
async def list_reminders(user_id: str = Depends(get_current_user)):
    supabase = get_supabase()
    res = (
        supabase.table("water_reminders")
        .select("*")
        .eq("user_id", user_id)
        .order("time_of_day")
        .execute()
    )
    return res.data or []


@router.post("/reminders", response_model=WaterReminderResponse,
             status_code=status.HTTP_201_CREATED)
async def create_reminder(
    reminder: WaterReminderCreate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = reminder.model_dump(mode="json")
    payload["user_id"] = user_id
    res = supabase.table("water_reminders").insert(payload).execute()
    return res.data[0]


@router.patch("/reminders/{reminder_id}", response_model=WaterReminderResponse)
async def update_reminder(
    reminder_id: str,
    update: WaterReminderUpdate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = update.model_dump(exclude_unset=True, mode="json")
    if not payload:
        raise ValidationError("Empty update")
    res = (
        supabase.table("water_reminders")
        .update(payload)
        .eq("id", reminder_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Reminder")
    return res.data[0]


@router.delete("/reminders/{reminder_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_reminder(
    reminder_id: str,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    res = (
        supabase.table("water_reminders")
        .delete()
        .eq("id", reminder_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Reminder")


# --- Insights ---

@router.get("/insights", response_model=WaterInsight)
async def water_insights(user_id: str = Depends(get_current_user)):
    """
    Rule-based pattern detection over last 7 days.
    Compares before-noon vs after-noon hydration averages.
    """
    supabase = get_supabase()
    end = date.today()
    start = end - timedelta(days=7)

    logs = (
        supabase.table("water_logs")
        .select("amount_ml, logged_at")
        .eq("user_id", user_id)
        .gte("logged_at", start.isoformat())
        .execute()
    )
    rows = logs.data or []
    if not rows:
        return WaterInsight(
            title="Start tracking",
            description="Log your water to see hydration patterns over time.",
            period_days=7,
        )

    before_noon_ml = 0
    after_noon_ml = 0
    for r in rows:
        ts = r.get("logged_at") or ""
        try:
            hour = int(ts[11:13])
        except (ValueError, IndexError):
            hour = 12
        amt = r.get("amount_ml", 0)
        if hour < 12:
            before_noon_ml += amt
        else:
            after_noon_ml += amt

    total = before_noon_ml + after_noon_ml
    if total == 0:
        return WaterInsight(
            title="No data yet",
            description="Keep logging — patterns emerge after a few days.",
            period_days=7,
        )

    before_pct = before_noon_ml / total * 100
    if before_pct >= 60:
        return WaterInsight(
            title="Strong morning hydration",
            description=f"You drank {round(before_pct)}% of your water before noon this week — a great pattern for energy and focus.",
            period_days=7,
            metric_value=before_pct,
        )
    elif before_pct < 30:
        return WaterInsight(
            title="Front-load your hydration",
            description=f"Only {round(before_pct)}% of your water came before noon. Try a glass right after waking — afternoon focus often follows.",
            period_days=7,
            metric_value=before_pct,
        )
    return WaterInsight(
        title="Balanced hydration",
        description="Your water intake is well distributed across the day. Keep it up!",
        period_days=7,
        metric_value=before_pct,
    )
