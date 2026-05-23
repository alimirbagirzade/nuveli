"""
AI Coach: daily insight generation via GPT-4o.
Aggregates user's 7-day data, prompts GPT-4o, persists to ai_insights table.
"""
import json
from datetime import date, timedelta
from typing import Any
from openai import AsyncOpenAI, APIError, APITimeoutError

from config import get_settings
from core.exceptions import ExternalServiceError, ValidationError
from core.supabase_client import get_supabase
from core.logging import get_logger
from prompts.coach_prompts import build_coach_insight_messages
from services.nutrition_score_service import compute_nutrition_score

logger = get_logger(__name__)


def _get_client() -> AsyncOpenAI:
    settings = get_settings()
    return AsyncOpenAI(
        api_key=settings.openai_api_key,
        timeout=settings.openai_timeout_seconds,
        max_retries=settings.openai_max_retries,
    )


async def gather_user_7day_data(user_id: str) -> dict[str, Any]:
    """
    Aggregate user's 7-day data for the AI prompt.
    Uses Chat 13's user_7day_summary view if available, falls back to manual queries.
    """
    supabase = get_supabase()
    end_date = date.today()
    start_date = end_date - timedelta(days=7)

    # Try the view first
    try:
        view = (
            supabase.table("user_7day_summary")
            .select("*")
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if view.data:
            return view.data
    except Exception as e:
        logger.debug(f"user_7day_summary view unavailable, falling back: {e}")

    # Manual aggregation fallback
    meals_res = (
        supabase.table("meals")
        .select("total_calories, total_protein_g, total_carbs_g, total_fat_g, consumed_at")
        .eq("user_id", user_id)
        .gte("consumed_at", start_date.isoformat())
        .execute()
    )
    water_res = (
        supabase.table("water_logs")
        .select("amount_ml, logged_at")
        .eq("user_id", user_id)
        .gte("logged_at", start_date.isoformat())
        .execute()
    )
    habits_res = (
        # `name` column doesn't exist in prod (it's `title`); we only
        # use `len(habits)` here so just select id and avoid the join.
        supabase.table("habits")
        .select("id")
        .eq("user_id", user_id)
        .eq("is_active", True)
        .execute()
    )
    completions_res = (
        supabase.table("habit_completions")
        .select("habit_id, completed_at")
        .eq("user_id", user_id)
        .gte("completed_at", start_date.isoformat())
        .execute()
    )
    weight_res = (
        supabase.table("weight_logs")
        .select("weight_kg, logged_at")
        .eq("user_id", user_id)
        .gte("logged_at", start_date.isoformat())
        .order("logged_at")
        .execute()
    )
    profile_res = (
        supabase.table("user_profiles")
        .select("daily_calorie_target, protein_target_g, carbs_target_g, fat_target_g, daily_water_target_ml")
        .eq("user_id", user_id)
        .single()
        .execute()
    )

    meals = meals_res.data or []
    water = water_res.data or []
    habits = habits_res.data or []
    completions = completions_res.data or []
    weights = weight_res.data or []
    profile = profile_res.data or {}

    total_calories = sum(m.get("total_calories", 0) for m in meals)
    total_protein = sum(m.get("total_protein_g", 0) for m in meals)
    total_carbs = sum(m.get("total_carbs_g", 0) for m in meals)
    total_fat = sum(m.get("total_fat_g", 0) for m in meals)
    total_water = sum(w.get("amount_ml", 0) for w in water)

    days = 7
    return {
        "period_days": days,
        "meals_logged": len(meals),
        "avg_daily_calories": round(total_calories / days, 1),
        "avg_daily_protein_g": round(total_protein / days, 1),
        "avg_daily_carbs_g": round(total_carbs / days, 1),
        "avg_daily_fat_g": round(total_fat / days, 1),
        "target_calories": profile.get("daily_calorie_target", 2000),
        "target_protein_g": profile.get("protein_target_g"),
        "target_carbs_g": profile.get("carbs_target_g"),
        "target_fat_g": profile.get("fat_target_g"),
        "avg_daily_water_ml": round(total_water / days),
        "target_water_ml": profile.get("daily_water_target_ml", 2500),
        "habits_count": len(habits),
        "habits_completions": len(completions),
        "habit_completion_rate": (
            round(len(completions) / (len(habits) * days), 2) if habits else 0
        ),
        "weight_logs": [
            {"date": w["logged_at"], "kg": w["weight_kg"]} for w in weights
        ],
    }


def _strip_json(text: str) -> str:
    s = text.strip()
    if s.startswith("```"):
        lines = s.splitlines()
        if lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].startswith("```"):
            lines = lines[:-1]
        return "\n".join(lines).strip()
    return s


async def generate_daily_insight(user_id: str, target_date: date | None = None) -> dict:
    """
    Generate one AI insight for a user. Persists to ai_insights table.
    Returns the payload dict.
    """
    target_date = target_date or date.today()
    settings = get_settings()

    # 1. Aggregate user data
    user_data = await gather_user_7day_data(user_id)

    # 2. Compute deterministic nutrition score (don't trust LLM with the math)
    score_breakdown = compute_nutrition_score(user_data)

    # 3. Call GPT-4o
    client = _get_client()
    messages = build_coach_insight_messages(user_data)

    logger.info(f"Generating AI insight for user {user_id} on {target_date}")

    try:
        resp = await client.chat.completions.create(
            model=settings.openai_model_chat,
            messages=messages,
            max_tokens=900,
            temperature=0.7,
            response_format={"type": "json_object"},
        )
    except APITimeoutError:
        raise ExternalServiceError("OpenAI Coach", "Timed out")
    except APIError as e:
        raise ExternalServiceError("OpenAI Coach", str(e))

    raw = resp.choices[0].message.content or ""
    raw = _strip_json(raw)

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        logger.error(f"Coach JSON parse failed: {e}\nRaw: {raw[:500]}")
        raise ValidationError("AI returned invalid JSON")

    # 4. Override LLM's nutrition_score with our deterministic version
    payload["nutrition_score"] = score_breakdown["total"]
    payload["score_breakdown"] = score_breakdown

    # 5. Persist — map LLM JSON keys → live DB structured columns.
    #
    # ai_insights schema (per information_schema):
    #   nutrition_score, score_label, score_breakdown (jsonb),
    #   main_insight (jsonb), small_insights (jsonb), recommendation (jsonb),
    #   daily_recap (jsonb), ai_model, tokens_used, generated_at
    #
    # LLM payload (per prompts/coach_prompts.py COACH_INSIGHT_SYSTEM_PROMPT):
    #   nutrition_score, today_insight, tips (list), recommended_action
    #
    # The names don't match — earlier code wrote a single "payload"
    # column that doesn't exist, so the upsert silently failed and no
    # insight was ever persisted. Now we map explicitly. score_label and
    # daily_recap stay NULL until the prompt/contract is extended to
    # produce them.
    supabase = get_supabase()
    today_insight = payload.get("today_insight")
    record = {
        "user_id": user_id,
        "insight_date": target_date.isoformat(),
        "nutrition_score": payload["nutrition_score"],
        "score_breakdown": payload.get("score_breakdown"),
        # main_insight is jsonb on DB so we wrap the string under a known key
        "main_insight": {"text": today_insight} if today_insight else None,
        "small_insights": payload.get("tips"),
        "recommendation": payload.get("recommended_action"),
        # daily_recap is NOT NULL in prod. We don't have a separate
        # recap field in the LLM payload yet, so dump the whole payload
        # under a `summary` key — gives future migrations / debugging
        # something to read while satisfying the constraint.
        "daily_recap": {"summary": today_insight or "", "raw": payload},
        "ai_model": settings.openai_model_chat,
        "tokens_used": getattr(resp.usage, "total_tokens", None) if hasattr(resp, "usage") else None,
    }
    # Upsert: one insight per user per day
    supabase.table("ai_insights").upsert(
        record, on_conflict="user_id,insight_date"
    ).execute()

    logger.info(f"✅ Insight generated for {user_id} (score={payload['nutrition_score']})")
    return payload


async def get_cached_insight(user_id: str, target_date: date | None = None) -> dict | None:
    """Get today's insight from cache (no regeneration)."""
    target_date = target_date or date.today()
    supabase = get_supabase()
    res = (
        supabase.table("ai_insights")
        .select("*")
        .eq("user_id", user_id)
        .eq("insight_date", target_date.isoformat())
        .order("generated_at", desc=True)
        .limit(1)
        .execute()
    )
    if res.data:
        return res.data[0]
    return None
