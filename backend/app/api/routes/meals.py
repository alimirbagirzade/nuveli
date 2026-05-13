from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional
from ...core.dependencies import get_current_user
from ...services.meal_service import MealService
from ...schemas.common import ApiResponse

router = APIRouter()


class AnalyzeRequest(BaseModel):
    image_b64: Optional[str] = None
    description: Optional[str] = None


class ConfirmRequest(BaseModel):
    local_day: str
    meal_type: str = "snack"


class EditRequest(BaseModel):
    name: str
    calories: int
    protein_g: Optional[float] = None
    carb_g: Optional[float] = None
    fat_g: Optional[float] = None
    local_day: str
    meal_type: str = "snack"


class ManualRequest(BaseModel):
    name: str
    calories: int
    protein_g: Optional[float] = None
    carb_g: Optional[float] = None
    fat_g: Optional[float] = None
    local_day: str
    meal_type: str = "snack"


@router.post("/analyze")
async def analyze_meal(body: AnalyzeRequest, user_id: str = Depends(get_current_user)):
    if not body.image_b64 and not body.description:
        raise HTTPException(400, detail={
            "code": "VALIDATION_ERROR",
            "message": "Fotoğraf veya açıklama gerekli."
        })
    svc = MealService()
    result = await svc.analyze(user_id, body.image_b64, body.description)
    return ApiResponse.ok(result)


@router.post("/{analysis_id}/confirm")
async def confirm_meal(analysis_id: str, body: ConfirmRequest, user_id: str = Depends(get_current_user)):
    svc = MealService()
    try:
        result = await svc.confirm(user_id, analysis_id, body.local_day, body.meal_type)
        return ApiResponse.ok(result)
    except ValueError as e:
        raise HTTPException(404, detail={"code": "NOT_FOUND", "message": str(e)})


@router.post("/{analysis_id}/edit")
async def edit_meal(analysis_id: str, body: EditRequest, user_id: str = Depends(get_current_user)):
    svc = MealService()
    result = await svc.edit_and_save(user_id, analysis_id, body.model_dump())
    return ApiResponse.ok(result)


@router.post("/manual")
async def manual_meal(body: ManualRequest, user_id: str = Depends(get_current_user)):
    svc = MealService()
    result = await svc.manual_entry(user_id, body.model_dump())
    return ApiResponse.ok(result)


@router.get("")
async def list_meals(local_day: str, user_id: str = Depends(get_current_user)):
    svc = MealService()
    result = await svc.list_meals(user_id, local_day)
    return ApiResponse.ok(result)


@router.delete("/{meal_id}")
async def delete_meal(meal_id: str, user_id: str = Depends(get_current_user)):
    svc = MealService()
    await svc.delete_meal(user_id, meal_id)
    return ApiResponse.ok({"deleted": True})
