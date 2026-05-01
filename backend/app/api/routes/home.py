from fastapi import APIRouter, Depends
from datetime import date
from ...core.dependencies import get_current_user
from ...services.home_service import HomeService
from ...db.client import get_supabase
from ...schemas.common import ApiResponse

router = APIRouter()


@router.get("/home")
async def get_home(user_id: str = Depends(get_current_user)):
    svc = HomeService()
    data = await svc.get_home_payload(user_id)
    return ApiResponse.ok(data)


@router.get("/summary/daily")
async def get_daily_summary(local_day: str | None = None, user_id: str = Depends(get_current_user)):
    day = local_day or str(date.today())
    svc = HomeService()
    summary = await svc._get_or_build_summary(user_id, day)
    return ApiResponse.ok(summary)


@router.get("/usage/today")
async def get_usage_today(user_id: str = Depends(get_current_user)):
    db = get_supabase()
    today = str(date.today())
    result = db.table("usage_counters_daily")\
        .select("*").eq("user_id", user_id).eq("local_day", today).execute()
    data = result.data[0] if result.data else {
        "user_id": user_id, "local_day": today, "meal_analyses": 0, "coach_messages": 0
    }
    return ApiResponse.ok(data)
