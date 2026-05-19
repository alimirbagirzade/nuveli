"""
Weight tracking Pydantic models.
"""
from pydantic import BaseModel, Field
from datetime import datetime, date
from typing import Optional, Literal
from uuid import UUID


WeightGoalDirection = Literal["lose", "maintain", "gain"]
GoalStatus = Literal["active", "achieved", "paused", "cancelled"]


class WeightLogCreate(BaseModel):
    weight_kg: float = Field(..., ge=20, le=400)
    logged_at: datetime = Field(default_factory=datetime.utcnow)
    note: Optional[str] = None


class WeightLogResponse(BaseModel):
    id: UUID
    user_id: UUID
    weight_kg: float
    logged_at: datetime
    note: Optional[str] = None
    created_at: datetime


class WeightTrendPoint(BaseModel):
    date: date
    weight_kg: float
    moving_avg_kg: Optional[float] = None


class WeightTrendResponse(BaseModel):
    points: list[WeightTrendPoint]
    period_days: int
    start_weight: Optional[float] = None
    current_weight: Optional[float] = None
    delta_kg: Optional[float] = None


class WeightGoalCreate(BaseModel):
    target_kg: float = Field(..., ge=20, le=400)
    target_date: Optional[date] = None
    direction: WeightGoalDirection
    starting_weight_kg: Optional[float] = None


class WeightGoalUpdate(BaseModel):
    target_kg: Optional[float] = None
    target_date: Optional[date] = None
    status: Optional[GoalStatus] = None


class WeightGoalResponse(BaseModel):
    id: UUID
    user_id: UUID
    target_kg: float
    target_date: Optional[date] = None
    direction: WeightGoalDirection
    starting_weight_kg: Optional[float] = None
    status: GoalStatus = "active"
    created_at: datetime
    # Derived
    progress_percent: Optional[float] = None
    weekly_change_kg: Optional[float] = None
