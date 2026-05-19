"""
User profile Pydantic models.
"""
from pydantic import BaseModel, Field, EmailStr
from datetime import datetime, date
from typing import Optional, Literal
from uuid import UUID


Sex = Literal["male", "female", "other"]
ActivityLevel = Literal["sedentary", "light", "moderate", "active", "very_active"]
DietaryPreference = Literal[
    "none", "vegetarian", "vegan", "pescatarian", "keto", "paleo", "halal", "kosher"
]
WeightGoalDirection = Literal["lose", "maintain", "gain"]


class ProfileBase(BaseModel):
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    sex: Optional[Sex] = None
    date_of_birth: Optional[date] = None
    height_cm: Optional[float] = Field(None, ge=50, le=260)
    weight_kg: Optional[float] = Field(None, ge=20, le=400)
    activity_level: Optional[ActivityLevel] = None
    dietary_preference: Optional[DietaryPreference] = None
    timezone: Optional[str] = "UTC"
    locale: Optional[str] = "en"


class ProfileUpdate(ProfileBase):
    """All fields optional for PATCH."""
    pass


class OnboardingRequest(BaseModel):
    """Initial onboarding payload — collected after signup."""
    full_name: str
    sex: Sex
    date_of_birth: date
    height_cm: float = Field(..., ge=50, le=260)
    weight_kg: float = Field(..., ge=20, le=400)
    activity_level: ActivityLevel
    dietary_preference: DietaryPreference = "none"
    weight_goal_direction: WeightGoalDirection
    target_weight_kg: Optional[float] = Field(None, ge=20, le=400)
    target_date: Optional[date] = None
    timezone: str = "UTC"
    locale: str = "en"


class ProfileResponse(ProfileBase):
    id: UUID
    user_id: UUID
    email: Optional[EmailStr] = None
    daily_calorie_target: Optional[int] = None
    daily_water_target_ml: Optional[int] = None
    protein_target_g: Optional[float] = None
    carbs_target_g: Optional[float] = None
    fat_target_g: Optional[float] = None
    bmr: Optional[float] = None
    tdee: Optional[float] = None
    is_premium: bool = False
    premium_expires_at: Optional[datetime] = None
    onboarding_completed: bool = False
    created_at: datetime
    updated_at: Optional[datetime] = None
