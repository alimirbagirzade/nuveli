from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional, List
from ...core.dependencies import get_current_user
from ...services.profile_service import ProfileService
from ...schemas.common import ApiResponse

router = APIRouter()


class OnboardingRequest(BaseModel):
    display_name: Optional[str] = None
    birth_year: int
    gender: str
    height_cm: float
    weight_kg: float
    goal: str
    activity_level: str
    special_conditions: List[str] = []


class CoachPrefRequest(BaseModel):
    coach_persona: str


class UpdateProfileRequest(BaseModel):
    """Partial profile update — only fields user can edit themselves.
    All fields optional so client can patch one at a time (e.g. avatar only).
    """
    display_name: Optional[str] = None
    avatar_style: Optional[str] = None
    avatar_seed: Optional[str] = None


class NotifPrefRequest(BaseModel):
    meal_reminders: bool = True
    coach_nudges: bool = True
    weekly_summary: bool = True
    quiet_start: str = "22:00"
    quiet_end: str = "08:00"


@router.post("/onboarding")
async def save_onboarding(
    body: OnboardingRequest,
    user_id: str = Depends(get_current_user),
):
    svc = ProfileService()
    data = await svc.save_onboarding(user_id, body.model_dump())
    return ApiResponse.ok(data)


@router.post("/coach-preferences")
async def save_coach_preferences(
    body: CoachPrefRequest,
    user_id: str = Depends(get_current_user),
):
    svc = ProfileService()
    data = await svc.save_coach_preferences(user_id, body.coach_persona)
    return ApiResponse.ok(data)


@router.post("/notification-preferences")
async def save_notification_preferences(
    body: NotifPrefRequest,
    user_id: str = Depends(get_current_user),
):
    svc = ProfileService()
    data = await svc.save_notification_preferences(user_id, body.model_dump())
    return ApiResponse.ok(data)


@router.post("/complete-onboarding")
async def complete_onboarding(user_id: str = Depends(get_current_user)):
    svc = ProfileService()
    await svc.complete_onboarding(user_id)
    return ApiResponse.ok({"completed": True})


@router.get("")
async def get_profile(user_id: str = Depends(get_current_user)):
    svc = ProfileService()
    profile = await svc.get_profile(user_id)
    if not profile:
        from fastapi import HTTPException
        raise HTTPException(404, detail={"code": "NOT_FOUND", "message": "Profil bulunamadı."})
    return ApiResponse.ok(profile)


@router.patch("")
async def update_profile(
    body: UpdateProfileRequest,
    user_id: str = Depends(get_current_user),
):
    """Partial update of user-editable profile fields.

    Accepts any combination of: display_name, avatar_style, avatar_seed.
    Validates avatar_style against known DiceBear styles. Empty/null
    fields in the request are skipped — only provided fields are updated.
    """
    svc = ProfileService()
    payload = {k: v for k, v in body.model_dump().items() if v is not None}
    if not payload:
        from fastapi import HTTPException
        raise HTTPException(400, detail={"code": "EMPTY_UPDATE", "message": "En az bir alan girin."})

    # Guard against bad avatar_style values that would violate the DB check constraint
    if "avatar_style" in payload:
        allowed = {"lorelei", "peep", "bottts", "adventurer", "fun-emoji"}
        if payload["avatar_style"] not in allowed:
            from fastapi import HTTPException
            raise HTTPException(400, detail={"code": "BAD_AVATAR_STYLE", "message": "Geçersiz avatar stili."})

    profile = await svc.update_profile(user_id, payload)
    return ApiResponse.ok(profile)


@router.get("/notification-preferences")
async def get_notification_preferences(user_id: str = Depends(get_current_user)):
    """Kullanıcının bildirim tercihlerini döner. Yoksa default."""
    svc = ProfileService()
    prefs = await svc.get_notification_preferences(user_id)
    return ApiResponse.ok(prefs)


@router.delete("")
async def delete_account(user_id: str = Depends(get_current_user)):
    """
    Kullanıcı hesabını ve tüm verileri kalıcı olarak siler.
    GDPR/KVKK right-to-be-forgotten.
    """
    svc = ProfileService()
    await svc.delete_account(user_id)
    return ApiResponse.ok({"deleted": True})
