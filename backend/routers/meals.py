"""
Meal endpoints: AI scan, CRUD, today summary.
"""
from datetime import date, datetime
from typing import Optional
from fastapi import APIRouter, Depends, Query, Request, status

from core.auth import get_current_user
from core.rate_limit import limiter
from core.supabase_client import get_supabase
from core.exceptions import NotFound, ValidationError
from core.logging import get_logger
from models.meal import (
    MealCreate, MealUpdate, MealResponse,
    MealScanRequest, MealScanResponse, TodaySummary,
)
from services.openai_vision_service import analyze_meal_image

logger = get_logger(__name__)
router = APIRouter()


@router.post("/scan", response_model=MealScanResponse, summary="AI Vision meal analysis")
@limiter.limit("10/minute")
async def scan_meal(
    request: Request,
    body: MealScanRequest,
    user_id: str = Depends(get_current_user),
):
    """
    Analyze a meal photo with GPT-4o Vision.
    Returns detected foods + nutritional estimate. Does NOT auto-save —
    frontend confirms with the user and calls POST /meals separately.

    Rate limit: 10/minute per user. Free-tier daily quota is enforced
    elsewhere; this cap is defense-in-depth against burst abuse.
    """
    logger.info(f"User {user_id} scanning meal (hint={body.meal_type_hint})")
    return await analyze_meal_image(body.image_base64, body.meal_type_hint)


@router.post("", response_model=MealResponse, status_code=status.HTTP_201_CREATED,
             summary="Create meal log")
async def create_meal(
    meal: MealCreate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()

    # 1. Insert meal row
    meal_payload = meal.model_dump(exclude={"foods"}, mode="json")
    meal_payload["user_id"] = user_id
    res = supabase.table("meals").insert(meal_payload).execute()
    if not res.data:
        raise ValidationError("Failed to create meal")
    meal_id = res.data[0]["id"]

    # 2. Insert foods
    if meal.foods:
        foods_payload = [
            {**f.model_dump(mode="json"), "meal_id": meal_id} for f in meal.foods
        ]
        supabase.table("meal_foods").insert(foods_payload).execute()
        # Trigger recomputes total_calories etc.

    # 3. Re-fetch with foods relationship
    final = (
        supabase.table("meals")
        .select("*, meal_foods(*)")
        .eq("id", meal_id)
        .single()
        .execute()
    )
    return final.data


@router.get("", response_model=list[MealResponse], summary="List meals")
async def list_meals(
    user_id: str = Depends(get_current_user),
    date_filter: Optional[date] = Query(None, alias="date"),
    meal_type: Optional[str] = None,
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
):
    supabase = get_supabase()
    query = (
        supabase.table("meals")
        .select("*, meal_foods(*)")
        .eq("user_id", user_id)
        .order("consumed_at", desc=True)
        .range(offset, offset + limit - 1)
    )
    if date_filter:
        query = (
            query.gte("consumed_at", f"{date_filter}T00:00:00")
            .lt("consumed_at", f"{date_filter}T23:59:59")
        )
    if meal_type:
        query = query.eq("meal_type", meal_type)

    res = query.execute()
    return res.data or []


@router.get("/today/summary", response_model=TodaySummary, summary="Today's summary")
async def todays_summary(user_id: str = Depends(get_current_user)):
    """
    Aggregate today's calories + macros + water for the dashboard ring.
    Uses dashboard_today view (Chat 13) when available; fallback to manual queries.
    """
    supabase = get_supabase()

    # Try view first
    try:
        view = (
            supabase.table("dashboard_today")
            .select("*")
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if view.data:
            d = view.data
            target = d.get("daily_calorie_target", 2000)
            consumed = d.get("consumed_calories", 0)
            return TodaySummary(
                consumed_calories=consumed,
                consumed_protein_g=d.get("consumed_protein_g", 0),
                consumed_carbs_g=d.get("consumed_carbs_g", 0),
                consumed_fat_g=d.get("consumed_fat_g", 0),
                daily_calorie_target=target,
                daily_protein_target_g=d.get("protein_target_g", 0),
                daily_carbs_target_g=d.get("carbs_target_g", 0),
                daily_fat_target_g=d.get("fat_target_g", 0),
                consumed_water_ml=d.get("consumed_water_ml", 0),
                daily_water_target_ml=d.get("daily_water_target_ml", 2500),
                meal_count_today=d.get("meal_count_today", 0),
                remaining_calories=max(0, target - consumed),
                percent_complete=round(min(100, consumed / target * 100), 1) if target else 0,
            )
    except Exception as e:
        logger.debug(f"dashboard_today view unavailable: {e}")

    # Fallback when the dashboard_today view path errored (caught above)
    # or returned no row. Smoke test (Chat 25) caught two ways this path
    # used to 500 on real prod traffic:
    #   - user_profiles asked for protein/carbs/fat_target_g — columns
    #     never existed in the schema (profiles.py strips them before
    #     upsert with the same note)
    #   - water_logs asked for `logged_at` — prod schema appears to be
    #     out of sync with migration 004 ("column water_logs.logged_at
    #     does not exist", postgrest 42703)
    #
    # Fix shape: each sub-query is now wrapped in its own try/except so
    # one bad column doesn't take down the entire dashboard. Default
    # values render a sane "no data yet" state instead of "Sunucu hatası".
    # Macros derive from daily_calorie_target via the 25/45/30 split
    # documented in routers/profiles.py — no separate columns needed.
    today = date.today()

    meals: list[dict[str, Any]] = []
    try:
        meals_res = (
            supabase.table("meals")
            .select("total_calories, total_protein_g, total_carbs_g, total_fat_g")
            .eq("user_id", user_id)
            .gte("consumed_at", f"{today}T00:00:00")
            .lt("consumed_at", f"{today}T23:59:59")
            .execute()
        )
        meals = meals_res.data or []
    except Exception as e:
        logger.warning(f"today_summary meals query failed for {user_id}: {e}")

    water_ml_today = 0
    try:
        water_res = (
            supabase.table("water_logs")
            .select("amount_ml")
            .eq("user_id", user_id)
            .gte("logged_at", f"{today}T00:00:00")
            .lt("logged_at", f"{today}T23:59:59")
            .execute()
        )
        water_ml_today = sum(w.get("amount_ml", 0) for w in (water_res.data or []))
    except Exception as e:
        logger.warning(f"today_summary water_logs query failed for {user_id}: {e}")

    p: dict[str, Any] = {}
    try:
        prof_res = (
            supabase.table("user_profiles")
            .select("daily_calorie_target, daily_water_target_ml")
            .eq("user_id", user_id)
            .maybe_single()
            .execute()
        )
        p = prof_res.data or {}
    except Exception as e:
        logger.warning(f"today_summary user_profiles query failed for {user_id}: {e}")

    consumed = sum(m.get("total_calories", 0) for m in meals)
    target_kcal = p.get("daily_calorie_target") or 2000

    # Macro split mirrors _compute_targets in routers/profiles.py
    # (25% protein, 45% carbs, 30% fat). Keep in sync if that split ever
    # changes — there's no single config constant for it yet.
    protein_target_g = round((target_kcal * 0.25) / 4)
    carbs_target_g = round((target_kcal * 0.45) / 4)
    fat_target_g = round((target_kcal * 0.30) / 9)

    return TodaySummary(
        consumed_calories=consumed,
        consumed_protein_g=sum(m.get("total_protein_g", 0) for m in meals),
        consumed_carbs_g=sum(m.get("total_carbs_g", 0) for m in meals),
        consumed_fat_g=sum(m.get("total_fat_g", 0) for m in meals),
        daily_calorie_target=target_kcal,
        daily_protein_target_g=protein_target_g,
        daily_carbs_target_g=carbs_target_g,
        daily_fat_target_g=fat_target_g,
        consumed_water_ml=water_ml_today,
        daily_water_target_ml=p.get("daily_water_target_ml") or 2500,
        meal_count_today=len(meals),
        remaining_calories=max(0, target_kcal - consumed),
        percent_complete=round(min(100, consumed / target_kcal * 100), 1) if target_kcal else 0,
    )


@router.get("/{meal_id}", response_model=MealResponse, summary="Get one meal")
async def get_meal(
    meal_id: str,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    res = (
        supabase.table("meals")
        .select("*, meal_foods(*)")
        .eq("id", meal_id)
        .eq("user_id", user_id)
        .maybe_single()
        .execute()
    )
    if not res.data:
        raise NotFound("Meal")
    return res.data


@router.patch("/{meal_id}", response_model=MealResponse, summary="Update meal")
async def update_meal(
    meal_id: str,
    update: MealUpdate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = update.model_dump(exclude_unset=True, mode="json")
    if not payload:
        raise ValidationError("Empty update")

    res = (
        supabase.table("meals")
        .update(payload)
        .eq("id", meal_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Meal")

    # Re-fetch with foods
    final = (
        supabase.table("meals")
        .select("*, meal_foods(*)")
        .eq("id", meal_id)
        .single()
        .execute()
    )
    return final.data


@router.delete("/{meal_id}", status_code=status.HTTP_204_NO_CONTENT,
               summary="Delete meal")
async def delete_meal(
    meal_id: str,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    res = (
        supabase.table("meals")
        .delete()
        .eq("id", meal_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Meal")
