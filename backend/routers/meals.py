"""
Meal endpoints: AI scan, CRUD, today summary.
"""
from datetime import date, datetime
from typing import Optional
from fastapi import APIRouter, Depends, Query, status

from core.auth import get_current_user
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
async def scan_meal(
    request: MealScanRequest,
    user_id: str = Depends(get_current_user),
):
    """
    Analyze a meal photo with GPT-4o Vision.
    Returns detected foods + nutritional estimate. Does NOT auto-save —
    frontend confirms with the user and calls POST /meals separately.
    """
    logger.info(f"User {user_id} scanning meal (hint={request.meal_type_hint})")
    return await analyze_meal_image(request.image_base64, request.meal_type_hint)


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

    # Fallback
    today = date.today()
    meals_res = (
        supabase.table("meals")
        .select("total_calories, total_protein_g, total_carbs_g, total_fat_g")
        .eq("user_id", user_id)
        .gte("consumed_at", f"{today}T00:00:00")
        .lt("consumed_at", f"{today}T23:59:59")
        .execute()
    )
    meals = meals_res.data or []
    water_res = (
        supabase.table("water_logs")
        .select("amount_ml")
        .eq("user_id", user_id)
        .gte("logged_at", f"{today}T00:00:00")
        .lt("logged_at", f"{today}T23:59:59")
        .execute()
    )
    prof = (
        supabase.table("user_profiles")
        .select("daily_calorie_target, protein_target_g, carbs_target_g, fat_target_g, daily_water_target_ml")
        .eq("user_id", user_id)
        .single()
        .execute()
    )
    p = prof.data or {}

    consumed = sum(m.get("total_calories", 0) for m in meals)
    target = p.get("daily_calorie_target") or 2000
    return TodaySummary(
        consumed_calories=consumed,
        consumed_protein_g=sum(m.get("total_protein_g", 0) for m in meals),
        consumed_carbs_g=sum(m.get("total_carbs_g", 0) for m in meals),
        consumed_fat_g=sum(m.get("total_fat_g", 0) for m in meals),
        daily_calorie_target=target,
        daily_protein_target_g=p.get("protein_target_g") or 0,
        daily_carbs_target_g=p.get("carbs_target_g") or 0,
        daily_fat_target_g=p.get("fat_target_g") or 0,
        consumed_water_ml=sum(w.get("amount_ml", 0) for w in (water_res.data or [])),
        daily_water_target_ml=p.get("daily_water_target_ml") or 2500,
        meal_count_today=len(meals),
        remaining_calories=max(0, target - consumed),
        percent_complete=round(min(100, consumed / target * 100), 1) if target else 0,
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
