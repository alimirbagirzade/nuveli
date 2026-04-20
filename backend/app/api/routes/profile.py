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
