"""
Exercise log Pydantic models (Manual Exercise Logging — V1.1).

WELLNESS BOUNDARY: exercise is a positive-habit log only. The `est_calories`
field (and the per-day/week calorie totals) are **DISPLAY-ONLY** — computed via
a MET formula purely so the UI can show an informational badge. They are NEVER
added to/subtracted from the user's calorie target/budget, and nothing here
mutates a calorie goal. See docs/protocols/safety-wellness-boundary.md.
"""
from pydantic import BaseModel, Field, field_validator
from datetime import datetime, date
from typing import Optional, Literal
from uuid import UUID


# Allowed activity types. Anything outside this set normalizes to 'other'.
# Kept in sync with services.exercise_calories.BASE_MET (same 14 keys).
ACTIVITY_TYPES = frozenset(
    {
        "walking", "running", "cycling", "hiking", "swimming", "gym", "yoga",
        "pilates", "dancing", "hiit", "jump_rope", "rowing", "sports", "other",
    }
)


class ExerciseLogCreate(BaseModel):
    activity_type: str = Field(
        ...,
        description=(
            "walking|running|cycling|hiking|swimming|gym|yoga|pilates|"
            "dancing|hiit|jump_rope|rowing|sports|other"
        ),
    )
    duration_min: int = Field(..., ge=1, le=1440, description="Duration in minutes (1–1440)")
    intensity: Optional[Literal["light", "moderate", "vigorous"]] = None
    note: Optional[str] = None
    logged_at: datetime = Field(default_factory=datetime.utcnow)

    @field_validator("activity_type", mode="before")
    @classmethod
    def normalize_activity_type(cls, v: object) -> str:
        """Lowercase + trim; map any unknown value to 'other' so the DB never
        sees an out-of-vocabulary type. We deliberately accept-and-normalize
        rather than reject — the UI offers a fixed picker, but a stale client
        or 'custom' entry should still log cleanly."""
        if not isinstance(v, str):
            return "other"
        cleaned = v.strip().lower()
        return cleaned if cleaned in ACTIVITY_TYPES else "other"


class ExerciseLogResponse(BaseModel):
    id: UUID
    user_id: UUID
    activity_type: str
    duration_min: int
    intensity: Optional[str] = None
    note: Optional[str] = None
    logged_at: datetime
    created_at: datetime
    # DISPLAY-ONLY MET estimate for a UI badge. None when weight is unknown.
    # NEVER affects the user's calorie target/budget.
    est_calories: Optional[int] = None


class ExerciseTodaySummary(BaseModel):
    total_minutes: int = 0
    sessions_count: int = 0
    active: bool = False  # sessions_count > 0
    activity_types: list[str] = Field(default_factory=list)  # distinct types logged today
    # DISPLAY-ONLY sum of today's est_calories. None when weight is unknown.
    total_calories: Optional[int] = None


class ExerciseDayTotal(BaseModel):
    day: date  # local calendar day
    total_minutes: int
    sessions_count: int
    # DISPLAY-ONLY sum of est_calories for this day. None when weight unknown.
    total_calories: Optional[int] = None


class ExerciseWeeklyResponse(BaseModel):
    days: list[ExerciseDayTotal]  # always 7 entries, oldest → today
    week_total_minutes: int
    active_days: int
    # DISPLAY-ONLY sum of est_calories across the week. None when weight unknown.
    week_total_calories: Optional[int] = None
