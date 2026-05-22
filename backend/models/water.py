"""
Water tracker Pydantic models.
"""
from pydantic import BaseModel, Field
from datetime import datetime, time, date
from typing import Optional
from uuid import UUID


class WaterLogCreate(BaseModel):
    amount_ml: int = Field(..., ge=1, le=5000, description="Amount in milliliters")
    logged_at: datetime = Field(default_factory=datetime.utcnow)
    source: Optional[str] = Field(None, description="manual / quick_add_250 / quick_add_500")


class WaterLogResponse(BaseModel):
    id: UUID
    user_id: UUID
    amount_ml: int
    logged_at: datetime
    source: Optional[str] = None
    created_at: datetime


class WaterTodaySummary(BaseModel):
    consumed_ml: int = 0
    target_ml: int = 2500
    percent_complete: float = 0.0
    glass_count: int = 0  # 250ml per glass
    target_glasses: int = 10
    remaining_ml: int = 0
    logs_count: int = 0


class WaterDayTotal(BaseModel):
    day: date  # local calendar day
    total_ml: int
    target_ml: int


class WaterWeeklyResponse(BaseModel):
    days: list[WaterDayTotal]  # always 7 entries, oldest → today
    target_ml: int


class WaterReminderCreate(BaseModel):
    time_of_day: time = Field(..., description="HH:MM")
    label: Optional[str] = None
    enabled: bool = True


class WaterReminderUpdate(BaseModel):
    time_of_day: Optional[time] = None
    label: Optional[str] = None
    enabled: Optional[bool] = None


class WaterReminderResponse(BaseModel):
    id: UUID
    user_id: UUID
    time_of_day: time
    label: Optional[str] = None
    enabled: bool = True
    created_at: datetime


class WaterInsight(BaseModel):
    title: str
    description: str
    period_days: int = 7
    metric_value: Optional[float] = None
