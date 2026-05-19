"""
Achievement & analytics Pydantic models.
"""
from pydantic import BaseModel, Field
from datetime import datetime, date
from typing import Optional, Literal
from uuid import UUID


AchievementCategory = Literal[
    "streak", "milestone", "macro", "water", "habits", "weight", "scan"
]


class AchievementResponse(BaseModel):
    id: Optional[UUID] = None  # DB row id when unlocked; None for registry-only entries
    code: str  # "first_meal", "7_day_streak", "100_meals_logged"
    title: str
    description: str
    icon: Optional[str] = None
    category: AchievementCategory
    target_value: float
    current_progress: float = 0
    percent_complete: float = 0
    unlocked: bool = False
    unlocked_at: Optional[datetime] = None


class AchievementCheckResponse(BaseModel):
    newly_unlocked: list[AchievementResponse]
    total_unlocked: int
    total_available: int


# --- Analytics ---

class MacroPercentages(BaseModel):
    protein_percent: float
    carbs_percent: float
    fat_percent: float


class WeeklyCalorieDay(BaseModel):
    day: date
    calories: int
    target: int
    percent: float


class WeeklyAnalyticsResponse(BaseModel):
    days: list[WeeklyCalorieDay]
    avg_daily_calories: float
    avg_macro_breakdown: MacroPercentages
    days_within_target: int


class DashboardResponse(BaseModel):
    """Full dashboard payload — used by GET /analytics/dashboard."""
    today_summary: dict  # TodaySummary serialized
    streak_days: int = 0
    nutrition_score: Optional[int] = None
    recent_meals: list[dict] = Field(default_factory=list)
    water_consumed_ml: int = 0
    water_target_ml: int = 2500


class MacroBreakdownResponse(BaseModel):
    period_days: int
    average: MacroPercentages
    daily: list[dict]  # [{date, protein_percent, carbs_percent, fat_percent}]


# --- Premium ---

class PremiumStatusResponse(BaseModel):
    is_premium: bool
    expires_at: Optional[datetime] = None
    product_id: Optional[str] = None
    will_renew: bool = False
    source: Optional[str] = None  # "revenuecat", "manual"
