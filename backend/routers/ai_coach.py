"""
AI Coach endpoints: today's insight, manual generate, apply-tip.
"""
from datetime import date, datetime
from fastapi import APIRouter, Depends, status

from core.auth import get_current_user
from core.supabase_client import get_supabase
from core.exceptions import NotFound, ValidationError
from core.logging import get_logger
from models.ai_coach import (
    AIInsightResponse, GenerateInsightRequest,
    ApplyTipRequest, ApplyTipResponse,
)
from services.insights_generation_service import (
    generate_daily_insight, get_cached_insight,
)

logger = get_logger(__name__)
router = APIRouter()


def _row_to_response(row: dict) -> AIInsightResponse:
    """Map ai_insights row → response model."""
    payload = row.get("payload") or {}
    return AIInsightResponse(
        id=row.get("id"),
        user_id=row["user_id"],
        insight_date=date.fromisoformat(row["insight_date"]) if isinstance(row["insight_date"], str) else row["insight_date"],
        nutrition_score=payload.get("nutrition_score", 0),
        today_insight=payload.get("today_insight", ""),
        tips=payload.get("tips", []),
        recommended_action=payload.get("recommended_action"),
        generated_at=row.get("generated_at") or row.get("created_at") or datetime.utcnow(),
        model_used=row.get("model_used"),
    )


@router.get("/today", response_model=AIInsightResponse, summary="Today's AI insight")
async def coach_today(user_id: str = Depends(get_current_user)):
    """
    Return today's cached insight. If none exists yet, generate on-demand.
    Note: in production the daily cron pre-generates these — this fallback
    handles new users and missed runs.
    """
    cached = await get_cached_insight(user_id)
    if cached:
        return _row_to_response(cached)

    logger.info(f"No cached insight for {user_id}; generating on-demand")
    payload = await generate_daily_insight(user_id)

    # Re-fetch the newly inserted row
    cached = await get_cached_insight(user_id)
    if not cached:
        raise NotFound("Insight (generation succeeded but fetch failed)")
    return _row_to_response(cached)


@router.post("/generate", response_model=AIInsightResponse, summary="Force regenerate insight")
async def coach_generate(
    req: GenerateInsightRequest = GenerateInsightRequest(),
    user_id: str = Depends(get_current_user),
):
    """Manually trigger insight generation. Useful for testing & forced refresh."""
    target_date = req.target_date or date.today()

    if not req.force:
        cached = await get_cached_insight(user_id, target_date)
        if cached:
            return _row_to_response(cached)

    await generate_daily_insight(user_id, target_date)
    cached = await get_cached_insight(user_id, target_date)
    if not cached:
        raise NotFound("Insight")
    return _row_to_response(cached)


@router.post("/apply-tip", response_model=ApplyTipResponse, summary="Apply recommended action")
async def apply_tip(
    req: ApplyTipRequest,
    user_id: str = Depends(get_current_user),
):
    """
    Execute the recommended_action from an insight.
    Supports: adjust_reminder, add_habit, log_water, add_meal, increase_target.
    """
    supabase = get_supabase()

    # Fetch the insight to validate ownership
    insight = (
        supabase.table("ai_insights")
        .select("*")
        .eq("id", str(req.insight_id))
        .eq("user_id", user_id)
        .maybe_single()
        .execute()
    )
    if not insight.data:
        raise NotFound("Insight")

    payload = insight.data.get("payload") or {}
    action = payload.get("recommended_action") or {}
    action_payload = req.action_payload or action.get("payload") or {}
    action_type = action.get("action_type")

    if not action_type:
        raise ValidationError("Insight has no actionable recommendation")

    details: dict = {}

    if action_type == "adjust_reminder":
        # Update or create a water reminder
        reminder_type = action_payload.get("reminder_type", "water")
        time_str = action_payload.get("time", "13:00")
        if reminder_type == "water":
            supabase.table("water_reminders").insert({
                "user_id": user_id,
                "time_of_day": time_str,
                "label": "AI suggested",
                "enabled": True,
            }).execute()
            details = {"reminder_type": "water", "time": time_str}

    elif action_type == "add_habit":
        name = action_payload.get("name", "New habit")
        icon = action_payload.get("icon", "✨")
        supabase.table("habits").insert({
            "user_id": user_id,
            "name": name,
            "icon": icon,
            "target_type": "boolean",
            "schedule": "daily",
            "is_active": True,
        }).execute()
        details = {"habit_name": name}

    elif action_type == "log_water":
        amount = int(action_payload.get("amount_ml", 250))
        supabase.table("water_logs").insert({
            "user_id": user_id,
            "amount_ml": amount,
            "logged_at": datetime.utcnow().isoformat(),
            "source": "ai_apply_tip",
        }).execute()
        details = {"amount_ml": amount}

    elif action_type == "increase_target":
        field = action_payload.get("field", "protein_target_g")
        delta = action_payload.get("delta", 10)
        prof = (
            supabase.table("user_profiles")
            .select(field)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if prof.data:
            current = prof.data.get(field) or 0
            new_val = current + delta
            supabase.table("user_profiles").update(
                {field: new_val, "updated_at": datetime.utcnow().isoformat()}
            ).eq("user_id", user_id).execute()
            details = {"field": field, "old": current, "new": new_val}

    else:
        raise ValidationError(f"Unsupported action_type: {action_type}")

    logger.info(f"User {user_id} applied tip: {action_type}")
    return ApplyTipResponse(
        success=True,
        action_taken=action_type,
        details=details,
    )
