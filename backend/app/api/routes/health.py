from fastapi import APIRouter
from ...core.config import settings

router = APIRouter()


@router.get("/health", tags=["system"])
async def health_check():
    """Sistem sağlık kontrolü. Auth gerektirmez."""
    return {
        "status": "ok",
        "version": settings.app_version,
        "env": settings.app_env,
    }
