"""
backend/app/api/routes/checkins.py

Daily check-in endpoints.
"""

from __future__ import annotations
from typing import Optional
import logging

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from app.core.dependencies import get_current_user_id, get_supabase_client
from app.services.checkin_service import CheckinService, CheckinInput

logger = logging.getLogger(__name__)
router = APIRouter()


def get_checkin_service(db=Depends(get_supabase_client)) -> CheckinService:
    return CheckinService(db)


class CheckinCreateRequest(BaseModel):
    type: str
    value: str
    payload: Optional[dict] = None
    checkin_date: Optional[str] = None


@router.post("")
async def create_checkin(
    body: CheckinCreateRequest,
    user_id: str = Depends(get_current_user_id),
    svc: CheckinService = Depends(get_checkin_service),
):
    return await svc.create(user_id, CheckinInput(**body.dict()))


@router.get("/today")
async def get_today_checkins(
    user_id: str = Depends(get_current_user_id),
    svc: CheckinService = Depends(get_checkin_service),
):
    return await svc.get_today(user_id)


@router.get("/recent")
async def get_recent_checkins(
    days: int = 7,
    user_id: str = Depends(get_current_user_id),
    svc: CheckinService = Depends(get_checkin_service),
):
    return await svc.get_recent(user_id, days=days)


@router.get("/empty-day-status")
async def empty_day_status(
    user_id: str = Depends(get_current_user_id),
    svc: CheckinService = Depends(get_checkin_service),
):
    """Frontend home init'inde empty_day_screen tetiklenip tetiklenmeyeceğini sorar."""
    is_empty = await svc.is_empty_day(user_id)
    today = await svc.get_today(user_id)
    already_acknowledged = any(
        c["type"] == "empty_day" for c in today["checkins"]
    )
    return {
        "is_empty_day": is_empty,
        "already_acknowledged": already_acknowledged,
        "should_show_screen": is_empty and not already_acknowledged,
    }
