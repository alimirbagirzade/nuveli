# backend/routers/_premium_gating_examples.py
#
# Bu dosya REFERANS amaçlıdır — kendisi import edilmez.
# Aşağıdaki snippet'leri ilgili router dosyalarına ekle.
#
# Chat 19 hazırlık dosyasındaki kurallara göre üç endpoint'te
# premium gating yapılması gerekiyor:
#   - POST /meal-plans/generate    → premium-only (hard gate)
#   - GET  /analytics/weight-trend → free=8w, premium=full (soft gate)
#   - POST /coach/generate         → free=1/day, premium=unlimited (soft gate)

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query

# from ..core.auth import (
#     get_current_user,
#     require_premium,
#     get_premium_status,
#     PremiumStatus,
# )


# ============================================================
# 1) HARD GATE — Premium-only endpoint
# ============================================================
# Sadece premium user'lar çağırabilir. Free user 402 alır.
#
# Dosya: backend/routers/meal_planner.py

meal_planner_router = APIRouter(prefix="/meal-plans", tags=["meal-planner"])


@meal_planner_router.post(
    "/generate",
    dependencies=[Depends("require_premium")],  # PLACEHOLDER
    summary="Generate AI weekly meal plan (Premium only)",
)
async def generate_ai_plan(
    # user: User = Depends(get_current_user),
):
    """
    AI-generated weekly meal plan using GPT-4o.
    Premium-only — costs ~$0.02 per generation, free tier abuse riski yok.
    """
    # ... GPT-4o call → 7 günlük plan üret
    return {"plan_id": "...", "days": []}


# ============================================================
# 2) SOFT GATE — Free tier limitli (analytics: 8 hafta max)
# ============================================================
# Free user kabaca 8 hafta görür. >8 hafta için 402.
#
# Dosya: backend/routers/analytics.py

analytics_router = APIRouter(prefix="/analytics", tags=["analytics"])

FREE_TIER_MAX_WEEKS = 8


@analytics_router.get("/weight-trend")
async def get_weight_trend(
    weeks: int = Query(default=4, ge=1, le=520),
    # premium: PremiumStatus = Depends(get_premium_status),
    # user: User = Depends(get_current_user),
    premium=Depends("get_premium_status"),  # PLACEHOLDER
):
    """
    Weight trend data.
    Free tier: max 8 hafta. Premium: tüm tarih.
    """
    if not premium.is_active and weeks > FREE_TIER_MAX_WEEKS:
        raise HTTPException(
            status_code=402,
            detail={
                "error": "premium_required",
                "message": f"Free tier limited to {FREE_TIER_MAX_WEEKS} weeks. Upgrade for full history.",
                "free_tier_max": FREE_TIER_MAX_WEEKS,
                "requested": weeks,
            },
        )

    # ... actual query
    return {"data_points": [], "weeks": weeks}


# ============================================================
# 3) DAILY LIMIT — Coach insight free=1/day
# ============================================================
# Free user günde 1 insight üretebilir; ikinciye 402.
# Premium unlimited.
#
# Dosya: backend/routers/coach.py

coach_router = APIRouter(prefix="/coach", tags=["coach"])

FREE_TIER_DAILY_INSIGHTS = 1


@coach_router.post("/generate")
async def generate_insight(
    # premium: PremiumStatus = Depends(get_premium_status),
    # user: User = Depends(get_current_user),
    premium=Depends("get_premium_status"),  # PLACEHOLDER
):
    """
    AI Coach insight üret (GPT-4o).
    Free tier: günde 1. Premium: unlimited.
    """
    # if not premium.is_active:
    #     today_count = await _count_today_insights(user.id)
    #     if today_count >= FREE_TIER_DAILY_INSIGHTS:
    #         raise HTTPException(
    #             status_code=402,
    #             detail={
    #                 "error": "daily_limit_reached",
    #                 "message": "You've used your daily insight. Upgrade for unlimited.",
    #                 "limit": FREE_TIER_DAILY_INSIGHTS,
    #                 "used": today_count,
    #             },
    #         )

    # ... GPT-4o call → insight üret, ai_insights tablosuna kaydet
    return {"insight_id": "...", "text": "..."}


# ============================================================
# 4) DAILY LIMIT — Meal scan free=5/day
# ============================================================
# Dosya: backend/routers/meals.py içine ekle

meals_router = APIRouter(prefix="/meals", tags=["meals"])

FREE_TIER_DAILY_SCANS = 5


@meals_router.post("/scan")
async def scan_meal(
    # image_data: bytes = ...,
    # premium: PremiumStatus = Depends(get_premium_status),
    # user: User = Depends(get_current_user),
    premium=Depends("get_premium_status"),  # PLACEHOLDER
):
    """
    AI meal scan with GPT-4o Vision.
    Free tier: 5/day. Premium: unlimited.
    """
    # if not premium.is_active:
    #     today_count = await _count_today_scans(user.id)
    #     if today_count >= FREE_TIER_DAILY_SCANS:
    #         raise HTTPException(
    #             status_code=402,
    #             detail={
    #                 "error": "daily_limit_reached",
    #                 "message": "You've used all 5 daily scans. Upgrade for unlimited.",
    #                 "limit": FREE_TIER_DAILY_SCANS,
    #                 "used": today_count,
    #             },
    #         )

    # ... Vision call → meals tablosuna kaydet
    return {"meal_id": "...", "foods": []}


@meals_router.get("/scan-count-today")
async def get_scan_count_today(
    # user: User = Depends(get_current_user),
):
    """
    Frontend banner için: bugün kaç scan kullanıldı?
    """
    # today_count = await _count_today_scans(user.id)
    today_count = 0  # placeholder
    return {"count": today_count, "limit": FREE_TIER_DAILY_SCANS}


# ============================================================
# HELPER SQL — _count_today_insights / _count_today_scans
# ============================================================
#
# async def _count_today_insights(user_id: str) -> int:
#     sb = get_supabase_admin()
#     today = datetime.now(timezone.utc).date()
#     res = (
#         sb.table("ai_insights")
#         .select("id", count="exact")
#         .eq("user_id", user_id)
#         .gte("created_at", today.isoformat())
#         .execute()
#     )
#     return res.count or 0
#
# async def _count_today_scans(user_id: str) -> int:
#     sb = get_supabase_admin()
#     today = datetime.now(timezone.utc).date()
#     res = (
#         sb.table("meals")
#         .select("id", count="exact")
#         .eq("user_id", user_id)
#         .eq("source", "ai_scan")
#         .gte("created_at", today.isoformat())
#         .execute()
#     )
#     return res.count or 0
