"""
Meal & food Pydantic models.
"""
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, Literal
from uuid import UUID


MealType = Literal["breakfast", "lunch", "dinner", "snack"]
ScanSource = Literal["ai_scan", "manual", "barcode", "recipe"]


class MealFoodCreate(BaseModel):
    name: str
    portion: Optional[str] = None
    grams: Optional[float] = Field(None, ge=0)
    calories: int = Field(..., ge=0)
    protein_g: float = Field(0, ge=0)
    carbs_g: float = Field(0, ge=0)
    fat_g: float = Field(0, ge=0)
    position: int = 0


class MealFoodResponse(MealFoodCreate):
    id: UUID
    meal_id: UUID


class MealCreate(BaseModel):
    meal_type: MealType
    name: Optional[str] = None
    consumed_at: datetime = Field(default_factory=datetime.utcnow)
    image_url: Optional[str] = None
    scan_source: ScanSource = "manual"
    notes: Optional[str] = None
    foods: list[MealFoodCreate] = Field(default_factory=list)


class MealUpdate(BaseModel):
    name: Optional[str] = None
    meal_type: Optional[MealType] = None
    consumed_at: Optional[datetime] = None
    notes: Optional[str] = None


class MealResponse(BaseModel):
    id: UUID
    user_id: UUID
    meal_type: MealType
    name: Optional[str] = None
    total_calories: int = 0
    total_protein_g: float = 0
    total_carbs_g: float = 0
    total_fat_g: float = 0
    image_url: Optional[str] = None
    scan_source: Optional[str] = None
    notes: Optional[str] = None
    consumed_at: datetime
    created_at: datetime
    meal_foods: list[MealFoodResponse] = Field(default_factory=list)


# --- AI Vision Scan ---

class MealScanRequest(BaseModel):
    image_base64: str = Field(..., max_length=10_000_000, description="Base64-encoded JPEG/PNG (~7MB max)")
    meal_type_hint: Optional[MealType] = None


class DetectedFoodResponse(BaseModel):
    name: str
    portion: str
    grams: Optional[float] = None
    calories: int
    protein_g: float
    carbs_g: float
    fat_g: float


class PortionInsightResponse(BaseModel):
    score: int = Field(..., ge=0, le=100)
    main_text: str
    highlights: list[str] = Field(default_factory=list)


class MealScanResponse(BaseModel):
    foods: list[DetectedFoodResponse]
    total_calories: int
    total_protein_g: float = 0
    total_carbs_g: float = 0
    total_fat_g: float = 0
    portion_insight: PortionInsightResponse
    suggested_meal_type: Optional[MealType] = None


# --- Summary / Dashboard ---

class TodaySummary(BaseModel):
    consumed_calories: int = 0
    consumed_protein_g: float = 0
    consumed_carbs_g: float = 0
    consumed_fat_g: float = 0
    daily_calorie_target: int = 2000
    daily_protein_target_g: float = 0
    daily_carbs_target_g: float = 0
    daily_fat_target_g: float = 0
    consumed_water_ml: int = 0
    daily_water_target_ml: int = 2500
    meal_count_today: int = 0
    remaining_calories: int = 0
    percent_complete: float = 0.0
