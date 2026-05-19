"""
Healthy habits Pydantic models.
"""
from pydantic import BaseModel, Field
from datetime import datetime, date
from typing import Optional, Literal
from uuid import UUID


HabitTargetType = Literal["boolean", "count", "duration_min", "amount_ml"]
HabitSchedule = Literal["daily", "weekdays", "custom"]


class HabitCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    icon: Optional[str] = Field("✨", description="Emoji or icon name")
    target_type: HabitTargetType = "boolean"
    target_value: Optional[float] = None
    schedule: HabitSchedule = "daily"
    custom_days: Optional[list[int]] = Field(
        None, description="0=Mon, 6=Sun if schedule=custom"
    )
    reminder_time: Optional[str] = Field(None, description="HH:MM")
    sort_order: int = 0


class HabitUpdate(BaseModel):
    name: Optional[str] = None
    icon: Optional[str] = None
    target_type: Optional[HabitTargetType] = None
    target_value: Optional[float] = None
    schedule: Optional[HabitSchedule] = None
    custom_days: Optional[list[int]] = None
    reminder_time: Optional[str] = None
    is_active: Optional[bool] = None
    sort_order: Optional[int] = None


class HabitResponse(BaseModel):
    id: UUID
    user_id: UUID
    name: str
    icon: Optional[str] = None
    target_type: HabitTargetType
    target_value: Optional[float] = None
    schedule: HabitSchedule
    custom_days: Optional[list[int]] = None
    reminder_time: Optional[str] = None
    is_active: bool = True
    sort_order: int = 0
    created_at: datetime
    # Derived fields:
    completed_today: bool = False
    current_streak: int = 0


class HabitCompletionResponse(BaseModel):
    id: UUID
    habit_id: UUID
    user_id: UUID
    completed_at: datetime
    value: Optional[float] = None


class HabitDayConsistency(BaseModel):
    day: date
    completed_count: int
    total_count: int
    percent: float


class WeeklyConsistencyResponse(BaseModel):
    days: list[HabitDayConsistency]
    week_avg_percent: float


class HabitStreakResponse(BaseModel):
    current_streak: int
    longest_streak: int
    last_completed_date: Optional[date] = None
    days_with_full_completion: int  # in last 30 days
