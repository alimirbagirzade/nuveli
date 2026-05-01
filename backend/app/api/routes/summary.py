from fastapi import APIRouter, Depends
from ...core.dependencies import get_current_user
from ...services.summary_service import SummaryService
from ...schemas.common import ApiResponse

router = APIRouter()


@router.get("/weekly/current")
async def weekly_summary(user_id: str = Depends(get_current_user)):
    svc = SummaryService()
    data = await svc.weekly_current(user_id)
    return ApiResponse.ok(data)


@router.get("/monthly/current")
async def monthly_summary(user_id: str = Depends(get_current_user)):
    svc = SummaryService()
    data = await svc.monthly_current(user_id)
    return ApiResponse.ok(data)
