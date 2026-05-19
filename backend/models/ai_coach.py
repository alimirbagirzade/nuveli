"""
AI Coach Pydantic models.
"""
from pydantic import BaseModel, Field
from datetime import datetime, date
from typing import Optional, Literal, Any
from uuid import UUID


TipIcon = Literal["muscle", "leaf", "water", "fire", "moon", "walk", "scale", "sun"]


class CoachTip(BaseModel):
    icon: TipIcon = "leaf"
    title: str
    description: str
    category: Optional[str] = None  # "protein", "hydration", "sleep", ...


class RecommendedAction(BaseModel):
    text: str
    action_type: Optional[Literal[
        "add_meal", "adjust_reminder", "add_habit", "log_water", "increase_target"
    ]] = None
    payload: Optional[dict[str, Any]] = None  # data needed to apply the tip


class AIInsightResponse(BaseModel):
    model_config = {"protected_namespaces": ()}
    id: Optional[UUID] = None
    user_id: UUID
    insight_date: date
    nutrition_score: int = Field(..., ge=0, le=100)
    today_insight: str
    tips: list[CoachTip]
    recommended_action: Optional[RecommendedAction] = None
    generated_at: datetime
    model_used: Optional[str] = None


class GenerateInsightRequest(BaseModel):
    """Manual trigger (admin/test). Optional override for testing."""
    force: bool = False  # bypass daily cache
    target_date: Optional[date] = None


class ApplyTipRequest(BaseModel):
    insight_id: UUID
    action_payload: Optional[dict[str, Any]] = None  # override server payload if needed


class ApplyTipResponse(BaseModel):
    success: bool
    action_taken: str
    details: Optional[dict[str, Any]] = None


class NutritionScoreBreakdown(BaseModel):
    total: int
    calorie_score: int  # /40
    macro_score: int  # /30
    water_score: int  # /15
    habits_score: int  # /15
    components: dict[str, float] = Field(default_factory=dict)
