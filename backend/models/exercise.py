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
    # Provenance: 'manual' (logged in-app) | 'health_connect' | 'apple_health'.
    source: str = "manual"
    # Health-platform record id (dedupe key); None for manual logs.
    external_id: Optional[str] = None
    # DISPLAY-ONLY calorie estimate for a UI badge. Prefers the health
    # platform's own figure (device_calories) when the row carries one, else the
    # MET estimate. None when neither is available. NEVER affects the user's
    # calorie target/budget.
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


# =============================================================================
# Health-data IMPORT (Apple Health / Google Health Connect → exercise_logs)
# =============================================================================
# Workouts read from the phone's health platform flow in here. Each item carries
# the platform's own record id (external_id) so re-imports dedupe, and may carry
# the platform's own calorie figure (device_calories).
#
# WELLNESS BOUNDARY (unchanged): device_calories is DISPLAY-ONLY. It surfaces in
# est_calories exactly like the MET estimate — never added to/subtracted from a
# calorie budget/target, and import mutates no calorie goal.

# Health-platform source vocabulary. Anything else normalizes to the default.
IMPORT_SOURCES = frozenset({"health_connect", "apple_health"})


class ExerciseImportItem(BaseModel):
    activity_type: str = Field(
        ...,
        description=(
            "walking|running|cycling|hiking|swimming|gym|yoga|pilates|"
            "dancing|hiit|jump_rope|rowing|sports|other"
        ),
    )
    duration_min: int = Field(..., ge=1, le=1440, description="Duration in minutes (1–1440)")
    intensity: Optional[Literal["light", "moderate", "vigorous"]] = None
    # The activity's start time on the device, used to bucket it into a local_day.
    logged_at: datetime
    # Health-platform record id — required; the per-user dedupe key on re-import.
    external_id: str = Field(..., min_length=1, max_length=255)
    # Calories the health platform itself reported (DISPLAY-ONLY). None → fall
    # back to the MET estimate for the badge. Never touches a calorie budget.
    device_calories: Optional[int] = Field(default=None, ge=0)
    source: str = Field(default="health_connect")

    @field_validator("activity_type", mode="before")
    @classmethod
    def normalize_activity_type(cls, v: object) -> str:
        """Same accept-and-normalize rule as ExerciseLogCreate: lowercase +
        trim, map anything out-of-vocabulary to 'other' so the DB never sees an
        unknown type — health platforms emit arbitrary workout labels."""
        if not isinstance(v, str):
            return "other"
        cleaned = v.strip().lower()
        return cleaned if cleaned in ACTIVITY_TYPES else "other"

    @field_validator("source", mode="before")
    @classmethod
    def normalize_source(cls, v: object) -> str:
        """Constrain source to the known health platforms; anything unexpected
        (including non-strings) falls back to 'health_connect' so the column
        stays a clean enum-like value."""
        if not isinstance(v, str):
            return "health_connect"
        cleaned = v.strip().lower()
        return cleaned if cleaned in IMPORT_SOURCES else "health_connect"


class ExerciseImportRequest(BaseModel):
    # Cap the batch so a runaway sync can't post an unbounded payload.
    items: list[ExerciseImportItem] = Field(..., min_length=1, max_length=200)


class ExerciseImportResult(BaseModel):
    imported: int = 0  # newly inserted rows
    skipped: int = 0   # items whose external_id was already present (dedupe)
