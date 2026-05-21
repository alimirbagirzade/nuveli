"""
Meal planner & recipe endpoints.
"""
import json
from datetime import date, datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, Query, Request, status

from core.auth import get_current_user
from core.rate_limit import limiter
from core.supabase_client import get_supabase
from core.exceptions import NotFound, ValidationError, ExternalServiceError
from core.logging import get_logger
from config import get_settings
from models.meal_plan import (
    MealPlanCreate, MealPlanUpdate, MealPlanResponse, WeeklyPlanResponse,
    DailyPlanTotal, GrocerySummaryResponse, GroceryItem,
    RecipeCreate, RecipeResponse,
    GeneratePlanRequest, GeneratePlanResponse,
)
from prompts.coach_prompts import build_meal_plan_messages

logger = get_logger(__name__)
router = APIRouter()


# --- Meal Plans ---

@router.get("/meal-plans", response_model=WeeklyPlanResponse)
async def list_meal_plans(
    user_id: str = Depends(get_current_user),
    week_start: Optional[date] = Query(None, description="Start of week (Monday)"),
    plan_date: Optional[date] = Query(None, alias="date"),
):
    """Get plans for a week or a single day."""
    supabase = get_supabase()

    if plan_date:
        ws = plan_date
        we = plan_date
    else:
        today = date.today()
        ws = week_start or (today - timedelta(days=today.weekday()))
        we = ws + timedelta(days=6)

    res = (
        supabase.table("meal_plans")
        .select("*, recipe:recipes(*)")
        .eq("user_id", user_id)
        .gte("plan_date", ws.isoformat())
        .lte("plan_date", we.isoformat())
        .order("plan_date")
        .order("meal_type")
        .execute()
    )
    plans = res.data or []

    # Build daily totals
    by_day: dict[date, list] = {}
    for p in plans:
        d = date.fromisoformat(p["plan_date"]) if isinstance(p["plan_date"], str) else p["plan_date"]
        by_day.setdefault(d, []).append(p)

    days = []
    for i in range((we - ws).days + 1):
        d = ws + timedelta(days=i)
        day_plans = by_day.get(d, [])
        days.append(DailyPlanTotal(
            plan_date=d,
            total_calories=sum(p.get("total_calories", 0) for p in day_plans),
            total_protein_g=sum(p.get("total_protein_g", 0) for p in day_plans),
            total_carbs_g=sum(p.get("total_carbs_g", 0) for p in day_plans),
            total_fat_g=sum(p.get("total_fat_g", 0) for p in day_plans),
            meal_count=len(day_plans),
        ))

    return WeeklyPlanResponse(
        week_start=ws,
        week_end=we,
        days=days,
        total_calories=sum(d.total_calories for d in days),
        plans=plans,
    )


@router.post("/meal-plans", response_model=MealPlanResponse,
             status_code=status.HTTP_201_CREATED)
async def create_meal_plan(
    plan: MealPlanCreate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = plan.model_dump(mode="json")
    payload["user_id"] = user_id

    # Compute totals if recipe is linked
    if plan.recipe_id:
        recipe = (
            supabase.table("recipes")
            .select("calories_per_serving, protein_g, carbs_g, fat_g")
            .eq("id", str(plan.recipe_id))
            .maybe_single()
            .execute()
        )
        if recipe.data:
            r = recipe.data
            payload["total_calories"] = int((r.get("calories_per_serving", 0)) * plan.servings)
            payload["total_protein_g"] = (r.get("protein_g", 0)) * plan.servings
            payload["total_carbs_g"] = (r.get("carbs_g", 0)) * plan.servings
            payload["total_fat_g"] = (r.get("fat_g", 0)) * plan.servings
    elif plan.custom_calories:
        payload["total_calories"] = plan.custom_calories
        payload["total_protein_g"] = plan.custom_protein_g or 0
        payload["total_carbs_g"] = plan.custom_carbs_g or 0
        payload["total_fat_g"] = plan.custom_fat_g or 0

    res = supabase.table("meal_plans").insert(payload).execute()
    if not res.data:
        raise ValidationError("Failed to create plan")

    # Re-fetch with recipe
    final = (
        supabase.table("meal_plans")
        .select("*, recipe:recipes(*)")
        .eq("id", res.data[0]["id"])
        .single()
        .execute()
    )
    return final.data


@router.patch("/meal-plans/{plan_id}", response_model=MealPlanResponse)
async def update_meal_plan(
    plan_id: str,
    update: MealPlanUpdate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = update.model_dump(exclude_unset=True, mode="json")
    if not payload:
        raise ValidationError("Empty update")

    res = (
        supabase.table("meal_plans")
        .update(payload)
        .eq("id", plan_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Meal plan")

    final = (
        supabase.table("meal_plans")
        .select("*, recipe:recipes(*)")
        .eq("id", plan_id)
        .single()
        .execute()
    )
    return final.data


@router.delete("/meal-plans/{plan_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_meal_plan(
    plan_id: str,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    res = (
        supabase.table("meal_plans")
        .delete()
        .eq("id", plan_id)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Meal plan")


# --- Grocery summary ---

@router.get("/meal-plans/grocery", response_model=GrocerySummaryResponse)
async def grocery_summary(
    user_id: str = Depends(get_current_user),
    week_start: Optional[date] = Query(None),
):
    """Aggregate all ingredients from recipes used in the week's meal plans."""
    supabase = get_supabase()
    today = date.today()
    ws = week_start or (today - timedelta(days=today.weekday()))
    we = ws + timedelta(days=6)

    plans = (
        supabase.table("meal_plans")
        .select("servings, recipe:recipes(name, ingredients)")
        .eq("user_id", user_id)
        .gte("plan_date", ws.isoformat())
        .lte("plan_date", we.isoformat())
        .execute()
    )

    # Aggregate {(name, unit): total}
    agg: dict[tuple, dict] = {}
    recipe_count = 0
    for p in plans.data or []:
        recipe = p.get("recipe") or {}
        if not recipe:
            continue
        recipe_count += 1
        ingredients = recipe.get("ingredients") or []
        if isinstance(ingredients, str):
            try:
                ingredients = json.loads(ingredients)
            except (ValueError, TypeError):
                ingredients = []
        servings = p.get("servings", 1) or 1
        for ing in ingredients:
            name = ing.get("name", "").lower().strip()
            unit = ing.get("unit", "")
            amount = (ing.get("amount", 0) or 0) * servings
            key = (name, unit)
            if key in agg:
                agg[key]["total_amount"] += amount
                agg[key]["used_in_recipes"] += 1
            else:
                agg[key] = {
                    "name": ing.get("name", ""),
                    "unit": unit,
                    "total_amount": amount,
                    "used_in_recipes": 1,
                }

    items = [GroceryItem(**v) for v in agg.values()]
    items.sort(key=lambda i: i.name.lower())

    return GrocerySummaryResponse(
        week_start=ws,
        week_end=we,
        items=items,
        recipe_count=recipe_count,
    )


# --- AI plan generation ---

@router.post("/meal-plans/generate", response_model=GeneratePlanResponse)
@limiter.limit("3/minute")
async def generate_meal_plan(
    request: Request,
    req: GeneratePlanRequest,
    user_id: str = Depends(get_current_user),
):
    """
    Generate an AI meal plan with GPT-4o.
    Inserts plans into meal_plans table (without recipe_id; custom_* fields).

    Rate limit: 3/minute per user — generates a full week of meals per call,
    so even a small abuse burst is expensive.
    """
    from openai import AsyncOpenAI, APIError, APITimeoutError

    settings = get_settings()
    supabase = get_supabase()

    # Fetch profile for target_calories if not provided
    if not req.target_calories:
        prof = (
            supabase.table("user_profiles")
            .select("daily_calorie_target, dietary_preference")
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if prof.data:
            req.target_calories = prof.data.get("daily_calorie_target") or 2000
            if not req.dietary_preference:
                req.dietary_preference = prof.data.get("dietary_preference") or "none"

    client = AsyncOpenAI(
        api_key=settings.openai_api_key,
        timeout=settings.openai_timeout_seconds,
        max_retries=settings.openai_max_retries,
    )
    messages = build_meal_plan_messages(req.model_dump(mode="json"))

    logger.info(f"Generating AI meal plan for user {user_id}, days={req.days}")
    try:
        resp = await client.chat.completions.create(
            model=settings.openai_model_chat,
            messages=messages,
            max_tokens=3000,
            temperature=0.7,
            response_format={"type": "json_object"},
        )
    except APITimeoutError:
        raise ExternalServiceError("OpenAI Plan", "Timed out")
    except APIError as e:
        raise ExternalServiceError("OpenAI Plan", str(e))

    raw = resp.choices[0].message.content or "{}"
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        raise ValidationError("AI returned invalid plan JSON")

    plan_rows = []
    for day_idx, day_obj in enumerate(data.get("plan", [])):
        plan_date = req.week_start + timedelta(days=day_idx)
        for meal in day_obj.get("meals", []):
            plan_rows.append({
                "user_id": user_id,
                "plan_date": plan_date.isoformat(),
                "meal_type": meal.get("meal_type", "lunch"),
                "custom_name": meal.get("name"),
                "custom_calories": meal.get("calories"),
                "custom_protein_g": meal.get("protein_g", 0),
                "custom_carbs_g": meal.get("carbs_g", 0),
                "custom_fat_g": meal.get("fat_g", 0),
                "total_calories": meal.get("calories", 0),
                "total_protein_g": meal.get("protein_g", 0),
                "total_carbs_g": meal.get("carbs_g", 0),
                "total_fat_g": meal.get("fat_g", 0),
                "servings": 1.0,
                "ai_generated_payload": meal,  # store full JSON for later recipe creation
            })

    if plan_rows:
        supabase.table("meal_plans").insert(plan_rows).execute()

    return GeneratePlanResponse(
        plans_created=len(plan_rows),
        week_start=req.week_start,
        week_end=req.week_start + timedelta(days=req.days - 1),
    )


# --- Recipes ---

@router.get("/recipes", response_model=list[RecipeResponse])
async def list_recipes(
    user_id: str = Depends(get_current_user),
    search: Optional[str] = Query(None),
    only_mine: bool = False,
    limit: int = Query(50, ge=1, le=200),
):
    supabase = get_supabase()
    query = supabase.table("recipes").select("*").limit(limit)
    if only_mine:
        query = query.eq("user_id", user_id)
    else:
        # User's own + public
        query = query.or_(f"user_id.eq.{user_id},is_public.eq.true")
    if search:
        query = query.ilike("name", f"%{search}%")
    res = query.execute()
    return res.data or []


@router.get("/recipes/{recipe_id}", response_model=RecipeResponse)
async def get_recipe(
    recipe_id: str,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    res = (
        supabase.table("recipes")
        .select("*")
        .eq("id", recipe_id)
        .maybe_single()
        .execute()
    )
    if not res.data:
        raise NotFound("Recipe")
    # User can see their own + public
    if res.data.get("user_id") and res.data["user_id"] != user_id and not res.data.get("is_public"):
        raise NotFound("Recipe")
    return res.data


@router.post("/recipes", response_model=RecipeResponse, status_code=status.HTTP_201_CREATED)
async def create_recipe(
    recipe: RecipeCreate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = recipe.model_dump(mode="json")
    payload["user_id"] = user_id
    res = supabase.table("recipes").insert(payload).execute()
    return res.data[0]
