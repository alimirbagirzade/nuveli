from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
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
    # Sprint 2.1: yeni alanlar
    food_relationship: Optional[Dict[str, Any]] = None
    allergies: List[str] = []
    dietary_preference: str = "none"


class CoachPrefRequest(BaseModel):
    coach_persona: str


class UpdateProfileRequest(BaseModel):
    """Partial profile update — only fields user can edit themselves.
    All fields optional so client can patch one at a time (e.g. avatar only).
    """
    display_name: Optional[str] = None
    avatar_style: Optional[str] = None
    avatar_seed: Optional[str] = None
    avatar_photo_url: Optional[str] = None

    # Personal info
    birth_year: Optional[int] = None
    gender: Optional[str] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None

    # Goals
    goal: Optional[str] = None
    activity_level: Optional[str] = None
    daily_calorie_target: Optional[int] = None
    avatar_photo_url: Optional[str] = None  # Pass empty string to clear

    # Personal info — editable from the new "Kişisel Bilgiler" screen
    birth_year: Optional[int] = None
    gender: Optional[str] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    activity_level: Optional[str] = None
    goal: Optional[str] = None

    # Goals — editable from the new "Hedefler" screen
    daily_calorie_target: Optional[int] = None
    target_protein_g: Optional[int] = None
    target_carb_g: Optional[int] = None
    target_fat_g: Optional[int] = None


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

    Accepts any combination of: display_name, avatar_style, avatar_seed,
    avatar_photo_url, birth_year, gender, height_cm, weight_kg,
    activity_level, goal, daily_calorie_target, target_protein_g,
    target_carb_g, target_fat_g.
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
        allowed = {"lorelei", "peep", "bottts", "adventurer", "fun-emoji", "custom"}
        if payload["avatar_style"] not in allowed:
            from fastapi import HTTPException
            raise HTTPException(400, detail={"code": "BAD_AVATAR_STYLE", "message": "Geçersiz avatar stili."})

    # Empty string for photo_url means "clear it", so allow it through
    # but treat None as "don't touch the column" (already filtered above).
    if payload.get("avatar_photo_url") == "":
        payload["avatar_photo_url"] = None

    profile = await svc.update_profile(user_id, payload)
    return ApiResponse.ok(profile)


class AvatarUploadRequest(BaseModel):
    """Base64-encoded image upload for the user's avatar.

    Client sends the image as base64 (already resized client-side to
    keep payload small — see meal_image_capture). We push it to Supabase
    Storage and return the public URL, which the client then PATCHes
    into avatar_photo_url.
    """
    image_b64: str
    content_type: str = "image/jpeg"


@router.post("/avatar")
async def upload_avatar(
    body: AvatarUploadRequest,
    user_id: str = Depends(get_current_user),
):
    """Upload a user-supplied photo as their avatar.

    Stores the file in Supabase Storage under avatars/{user_id}.jpg
    (overwriting any previous one) and updates profiles.avatar_photo_url
    to the public URL. Returns the new URL so the client can refresh.
    """
    import base64
    import time
    from fastapi import HTTPException

    svc = ProfileService()
    try:
        image_bytes = base64.b64decode(body.image_b64)
    except Exception:
        raise HTTPException(400, detail={"code": "BAD_IMAGE", "message": "Geçersiz fotoğraf."})

    # Sanity check — avatars shouldn't be huge. Client should resize first.
    if len(image_bytes) > 5 * 1024 * 1024:
        raise HTTPException(400, detail={"code": "IMAGE_TOO_LARGE", "message": "Fotoğraf çok büyük."})

    # Cache-busting suffix so the public URL changes on every upload —
    # otherwise iOS/CDN serves the old image even after replace.
    suffix = int(time.time())
    storage_path = f"{user_id}/{suffix}.jpg"
    public_url = await svc.upload_avatar_photo(user_id, storage_path, image_bytes, body.content_type)
    return ApiResponse.ok({"url": public_url})


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
