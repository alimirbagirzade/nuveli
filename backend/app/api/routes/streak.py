"""GET /streak — kullanıcı streak ve gamification verilerini döner."""

from fastapi import APIRouter, Depends

from ...core.dependencies import get_current_user
from ...schemas.common import ApiResponse
from ...services.streak_service import StreakService

router = APIRouter()


@router.get("/streak")
async def get_streak(user_id: str = Depends(get_current_user)):
    """
    Kullanıcının streak ve milestone verilerini döner.

    Response:
        current_streak (int): Şu an aktif olan streak
        longest_streak (int): Tüm zamanların en uzun streak'i
        last_active_day (str|null): Son öğün eklenen gün (ISO date)
        today_logged (bool): Bugün öğün eklendi mi
        at_risk (bool): Akşam oldu, bugün kayıt yok → streak risk altında
        milestone (str|null): Özel rakama ulaşıldıysa (örn "7", "30")
    """
    svc = StreakService()
    data = await svc.compute_streak(user_id)
    return ApiResponse.ok(data)
