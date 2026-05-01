from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from ...core.dependencies import get_current_user
from ...db.client import get_supabase
from ...schemas.common import ApiResponse

router = APIRouter()


class PushTokenRequest(BaseModel):
    token: str
    platform: str  # ios | android


class NotifPrefPatch(BaseModel):
    meal_reminders: Optional[bool] = None
    coach_nudges: Optional[bool] = None
    weekly_summary: Optional[bool] = None
    quiet_start: Optional[str] = None
    quiet_end: Optional[str] = None


@router.post("/devices/push-token")
async def register_push_token(body: PushTokenRequest, user_id: str = Depends(get_current_user)):
    db = get_supabase()
    # Upsert by token unique
    db.table("device_tokens").upsert({
        "user_id": user_id,
        "token": body.token,
        "platform": body.platform,
    }, on_conflict="token").execute()
    return ApiResponse.ok({"registered": True})


@router.get("/notifications/preferences")
async def get_notification_preferences(user_id: str = Depends(get_current_user)):
    db = get_supabase()
    result = db.table("notification_preferences")\
        .select("*").eq("user_id", user_id).execute()
    if result.data:
        return ApiResponse.ok(result.data[0])
    return ApiResponse.ok({
        "user_id": user_id,
        "meal_reminders": True,
        "coach_nudges": True,
        "weekly_summary": True,
        "quiet_start": "22:00",
        "quiet_end": "08:00",
    })


@router.patch("/notifications/preferences")
async def patch_notification_preferences(body: NotifPrefPatch, user_id: str = Depends(get_current_user)):
    db = get_supabase()
    updates = {k: v for k, v in body.model_dump().items() if v is not None}
    updates["user_id"] = user_id
    result = db.table("notification_preferences").upsert(updates, on_conflict="user_id").execute()
    return ApiResponse.ok(result.data[0] if result.data else {})
