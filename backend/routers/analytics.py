"""
Analytics endpoints: dashboard, weekly bars, weight trend, macro breakdown.
"""
from datetime import date, datetime, timedelta
from fastapi import APIRouter, Depends, Query

from core.auth import get_current_user
from core.supabase_client import get_supabase
from core.logging import get_logger
from models.achievement import (
    DashboardResponse, WeeklyAnalyticsResponse, WeeklyCalorieDay,
    MacroPercentages, MacroBreakdownResponse,
)
from models.weight import WeightTrendResponse, WeightTrendPoint
from services.streak_service import compute_user_streak

logger = get_logger(__name__)
router = APIRouter()


def _parse_period_days(period: str) -> int:
    p = period.lower().strip()
    if p.endswith("w"):
        return int(p[:-1]) * 7
    if p.endswith("m"):
        return int(p[:-1]) * 30
    if p.endswith("y"):
        return int(p[:-1]) * 365
    if p.endswith("d"):
        return int(p[:-1])
    return 56


@router.get("/dashboard", response_model=DashboardResponse, summary="Dashboard payload")
async def dashboard(user_id: str = Depends(get_current_user)):
    """
    Single-call dashboard payload: today summary + streak + score + recent meals.
    Designed to minimize round-trips on app open.
    """
    supabase = get_supabase()
    today = date.today()

    # Today summary (re-use logic from meals router for consistency)
    from routers.meals import todays_summary
    today_data = await todays_summary(user_id)

    # Streak
    streak = await compute_user_streak(user_id)

    # Cached nutrition score
    insight = (
        supabase.table("ai_insights")
        .select("payload")
        .eq("user_id", user_id)
        .eq("insight_date", today.isoformat())
        .maybe_single()
        .execute()
    )
    score = None
    if insight.data and (insight.data.get("payload") or {}).get("nutrition_score") is not None:
        score = insight.data["payload"]["nutrition_score"]

    # Recent meals (last 5)
    recent_meals = (
        supabase.table("meals")
        .select("id, meal_type, name, total_calories, consumed_at, image_url")
        .eq("user_id", user_id)
        .order("consumed_at", desc=True)
        .limit(5)
        .execute()
    )

    return DashboardResponse(
        today_summary=today_data.model_dump(mode="json"),
        streak_days=streak,
        nutrition_score=score,
        recent_meals=recent_meals.data or [],
        water_consumed_ml=today_data.consumed_water_ml,
        water_target_ml=today_data.daily_water_target_ml,
    )


@router.get("/weekly", response_model=WeeklyAnalyticsResponse, summary="Weekly calorie bars")
async def weekly_analytics(user_id: str = Depends(get_current_user)):
    """Last 7 days: daily calorie bars + avg macros."""
    supabase = get_supabase()
    end = date.today()
    start = end - timedelta(days=6)

    meals = (
        supabase.table("meals")
        .select("total_calories, total_protein_g, total_carbs_g, total_fat_g, consumed_at")
        .eq("user_id", user_id)
        .gte("consumed_at", start.isoformat())
        .execute()
    )
    rows = meals.data or []

    prof = (
        supabase.table("user_profiles")
        .select("daily_calorie_target")
        .eq("user_id", user_id)
        .maybe_single()
        .execute()
    )
    target = (prof.data or {}).get("daily_calorie_target") or 2000

    # Bucket by day
    by_day: dict[date, list] = {}
    for m in rows:
        try:
            d = date.fromisoformat((m.get("consumed_at") or "")[:10])
            by_day.setdefault(d, []).append(m)
        except ValueError:
            continue

    days: list[WeeklyCalorieDay] = []
    days_within = 0
    for i in range(7):
        d = start + timedelta(days=i)
        day_meals = by_day.get(d, [])
        cal = sum(m.get("total_calories", 0) for m in day_meals)
        pct = cal / target * 100 if target else 0
        if 0.85 <= pct / 100 <= 1.10:
            days_within += 1
        days.append(WeeklyCalorieDay(
            day=d,
            calories=cal,
            target=target,
            percent=round(pct, 1),
        ))

    # Macro averages
    total_p = sum(m.get("total_protein_g", 0) for m in rows)
    total_c = sum(m.get("total_carbs_g", 0) for m in rows)
    total_f = sum(m.get("total_fat_g", 0) for m in rows)
    p_kcal = total_p * 4
    c_kcal = total_c * 4
    f_kcal = total_f * 9
    macro_total = p_kcal + c_kcal + f_kcal or 1

    avg_macros = MacroPercentages(
        protein_percent=round(p_kcal / macro_total * 100, 1),
        carbs_percent=round(c_kcal / macro_total * 100, 1),
        fat_percent=round(f_kcal / macro_total * 100, 1),
    )
    avg_daily = sum(d.calories for d in days) / 7 if days else 0

    return WeeklyAnalyticsResponse(
        days=days,
        avg_daily_calories=round(avg_daily, 1),
        avg_macro_breakdown=avg_macros,
        days_within_target=days_within,
    )


@router.get("/weight-trend", response_model=WeightTrendResponse)
async def weight_trend(
    user_id: str = Depends(get_current_user),
    period: str = Query("8w"),
):
    """Weight log points + 7-day moving average."""
    supabase = get_supabase()
    days = _parse_period_days(period)
    start = (date.today() - timedelta(days=days)).isoformat()

    res = (
        supabase.table("weight_logs")
        .select("weight_kg, logged_at")
        .eq("user_id", user_id)
        .gte("logged_at", start)
        .order("logged_at")
        .execute()
    )
    rows = res.data or []

    # Daily samples (collapse multi-logs to last per day)
    daily: dict[date, float] = {}
    for r in rows:
        try:
            d = date.fromisoformat((r.get("logged_at") or "")[:10])
            daily[d] = r["weight_kg"]
        except ValueError:
            continue

    sorted_days = sorted(daily.keys())
    points = []
    window: list[float] = []
    for d in sorted_days:
        w = daily[d]
        window.append(w)
        if len(window) > 7:
            window.pop(0)
        avg = sum(window) / len(window)
        points.append(WeightTrendPoint(
            date=d,
            weight_kg=w,
            moving_avg_kg=round(avg, 2),
        ))

    start_w = points[0].weight_kg if points else None
    current_w = points[-1].weight_kg if points else None
    delta = round(current_w - start_w, 2) if (start_w and current_w) else None

    return WeightTrendResponse(
        points=points,
        period_days=days,
        start_weight=start_w,
        current_weight=current_w,
        delta_kg=delta,
    )


@router.get("/macro-breakdown", response_model=MacroBreakdownResponse)
async def macro_breakdown(
    user_id: str = Depends(get_current_user),
    period: str = Query("7d"),
):
    """Daily macro percentages over a window. Used in Analytics donut + history."""
    supabase = get_supabase()
    days = _parse_period_days(period)
    start = date.today() - timedelta(days=days - 1)

    res = (
        supabase.table("meals")
        .select("total_protein_g, total_carbs_g, total_fat_g, consumed_at")
        .eq("user_id", user_id)
        .gte("consumed_at", start.isoformat())
        .execute()
    )
    rows = res.data or []

    by_day: dict[date, dict] = {}
    for m in rows:
        try:
            d = date.fromisoformat((m.get("consumed_at") or "")[:10])
        except ValueError:
            continue
        acc = by_day.setdefault(d, {"p": 0.0, "c": 0.0, "f": 0.0})
        acc["p"] += m.get("total_protein_g", 0) or 0
        acc["c"] += m.get("total_carbs_g", 0) or 0
        acc["f"] += m.get("total_fat_g", 0) or 0

    daily_breakdown = []
    sum_p_pct = sum_c_pct = sum_f_pct = 0.0
    counted = 0
    for d, v in sorted(by_day.items()):
        p_kcal = v["p"] * 4
        c_kcal = v["c"] * 4
        f_kcal = v["f"] * 9
        tot = p_kcal + c_kcal + f_kcal
        if tot <= 0:
            continue
        pp = round(p_kcal / tot * 100, 1)
        cp = round(c_kcal / tot * 100, 1)
        fp = round(f_kcal / tot * 100, 1)
        daily_breakdown.append({
            "date": d.isoformat(),
            "protein_percent": pp,
            "carbs_percent": cp,
            "fat_percent": fp,
        })
        sum_p_pct += pp
        sum_c_pct += cp
        sum_f_pct += fp
        counted += 1

    if counted == 0:
        avg = MacroPercentages(protein_percent=0, carbs_percent=0, fat_percent=0)
    else:
        avg = MacroPercentages(
            protein_percent=round(sum_p_pct / counted, 1),
            carbs_percent=round(sum_c_pct / counted, 1),
            fat_percent=round(sum_f_pct / counted, 1),
        )

    return MacroBreakdownResponse(
        period_days=days,
        average=avg,
        daily=daily_breakdown,
    )
