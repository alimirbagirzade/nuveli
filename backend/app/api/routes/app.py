from fastapi import APIRouter, Depends
from ...core.dependencies import get_current_user
from ...services.profile_service import ProfileService
from ...schemas.common import ApiResponse

router = APIRouter()


@router.get("/bootstrap")
async def app_bootstrap(user_id: str = Depends(get_current_user)):
    """Uygulama açılışında tek çağrı ile tüm state'i döndürür."""
    svc = ProfileService()
    data = await svc.get_bootstrap(user_id)
    return ApiResponse.ok(data)
