"""
backend/app/api/routes/notifications.py

Notification routes — token register, prefs.
PRD §13.

NOT: Mevcut notifications.py'i bu dosya REPLACE eder. Eğer mevcut dosyada
ek endpoint'ler varsa, onları buraya kopyalayıp birleştirin (integration guide).
"""

from __future__ import annotations
from typing import Optional
import logging

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.core.dependencies import get_current_user_id, get_supabase_client
from app.services.push_service import PushService

logger = logging.getLogger(__name__)
router = APIRouter()


def get_push_service(db=Depends(get_supabase_client)) -> PushService:
    """DI factory. Settings'ten Firebase SA JSON oku."""
    import os
    sa_json = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON", "")
    return PushService(db, firebase_service_account_json=sa_json)


# ═══════════════════════════════════════════════════════════════
# Token register / unregister
# ═══════════════════════════════════════════════════════════════

class TokenRegisterRequest(BaseModel):
    fcm_token: str = Field(..., min_length=10)
    platform: str  # 'ios' | 'android'
    device_id: Optional[str] = None
    device_model: Optional[str] = None
    app_version: Optional[str] = None
    os_version: Optional[str] = None


@router.post("/token")
async def register_token(
    body: TokenRegisterRequest,
    user_id: str = Depends(get_current_user_id),
    push: PushService = Depends(get_push_service),
):
    if body.platform not in ("ios", "android"):
        raise HTTPException(400, "platform must be 'ios' or 'android'")
    return await push.register_token(
        user_id=user_id,
        fcm_token=body.fcm_token,
        platform=body.platform,
        device_info={
            "device_id": body.device_id,
            "device_model": body.device_model,
            "app_version": body.app_version,
            "os_version": body.os_version,
        },
    )


class TokenUnregisterRequest(BaseModel):
    fcm_token: str


@router.delete("/token")
async def unregister_token(
    body: TokenUnregisterRequest,
    user_id: str = Depends(get_current_user_id),
    push: PushService = Depends(get_push_service),
):
    return await push.unregister_token(user_id, body.fcm_token)


# ═══════════════════════════════════════════════════════════════
# Preferences
# ═══════════════════════════════════════════════════════════════

class NotificationPrefsResponse(BaseModel):
    meal_reminders: bool
    water_reminders: bool
    weekly_summary: bool
    celebrations: bool
    coach_messages: bool
    empty_day_nudge: bool
    quiet_hours_start: str
    quiet_hours_end: str
    intensity: str
    timezone: str


class NotificationPrefsUpdateRequest(BaseModel):
    meal_reminders: Optional[bool] = None
    water_reminders: Optional[bool] = None
    weekly_summary: Optional[bool] = None
    celebrations: Optional[bool] = None
    coach_messages: Optional[bool] = None
    empty_day_nudge: Optional[bool] = None
    quiet_hours_start: Optional[str] = None
    quiet_hours_end: Optional[str] = None
    intensity: Optional[str] = None
    timezone: Optional[str] = None


@router.get("/preferences")
async def get_preferences(
    user_id: str = Depends(get_current_user_id),
    db=Depends(get_supabase_client),
):
    try:
        res = (
            db.table("notification_preferences")
            .select("*")
            .eq("user_id", user_id)
            .maybe_single()
            .execute()
        )
        if res.data:
            return res.data

        # Default oluştur
        defaults = {
            "user_id": user_id,
            "meal_reminders": True,
            "water_reminders": True,
            "weekly_summary": True,
            "celebrations": True,
            "coach_messages": True,
            "empty_day_nudge": True,
            "quiet_hours_start": "22:30:00",
            "quiet_hours_end": "08:00:00",
            "intensity": "light",
            "timezone": "Europe/Istanbul",
        }
        db.table("notification_preferences").upsert(
            defaults, on_conflict="user_id"
        ).execute()
        return defaults
    except Exception as e:
        logger.error("Prefs fetch failed: %s", e)
        raise HTTPException(500, "preferences_fetch_failed")


@router.patch("/preferences")
async def update_preferences(
    body: NotificationPrefsUpdateRequest,
    user_id: str = Depends(get_current_user_id),
    db=Depends(get_supabase_client),
):
    updates = {k: v for k, v in body.dict().items() if v is not None}
    if not updates:
        return {"ok": True, "no_changes": True}

    try:
        # upsert (kullanıcının prefs satırı yoksa default'larla yarat)
        existing = (
            db.table("notification_preferences")
            .select("user_id")
            .eq("user_id", user_id)
            .maybe_single()
            .execute()
        )
        if not existing.data:
            base = {
                "user_id": user_id,
                "meal_reminders": True,
                "water_reminders": True,
                "weekly_summary": True,
                "celebrations": True,
                "coach_messages": True,
                "empty_day_nudge": True,
                "quiet_hours_start": "22:30:00",
                "quiet_hours_end": "08:00:00",
                "intensity": "light",
                "timezone": "Europe/Istanbul",
            }
            base.update(updates)
            db.table("notification_preferences").upsert(
                base, on_conflict="user_id"
            ).execute()
        else:
            db.table("notification_preferences").update(updates).eq(
                "user_id", user_id
            ).execute()
        return {"ok": True, "updated": updates}
    except Exception as e:
        logger.error("Prefs update failed: %s", e)
        raise HTTPException(500, "preferences_update_failed")
