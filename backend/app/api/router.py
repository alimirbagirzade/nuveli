from fastapi import APIRouter
from .routes import (
    health, profile, app as app_route, meals, home, tracking,
    coach, premium, summary, notifications, safety, streak, checkins,
)

api_router = APIRouter()

# System
api_router.include_router(health.router, tags=["system"])

# App bootstrap
api_router.include_router(app_route.router, prefix="/app", tags=["app"])

# Profile & onboarding
api_router.include_router(profile.router, prefix="/profile", tags=["profile"])

# Meals
api_router.include_router(meals.router, prefix="/meals", tags=["meals"])

# Home & summary & usage
api_router.include_router(home.router, tags=["home"])

# Tracking (water, weight, checkin)
api_router.include_router(tracking.router, tags=["tracking"])

# Streak (gamification)
api_router.include_router(streak.router, tags=["streak"])

# Coach
api_router.include_router(coach.router, prefix="/coach", tags=["coach"])

# Premium
api_router.include_router(premium.router, prefix="/premium", tags=["premium"])

# Summary (weekly + monthly)
api_router.include_router(summary.router, prefix="/summary", tags=["summary"])

# Notifications
api_router.include_router(notifications.router, tags=["notifications"])

# Daily check-ins (empty_day, mood, craving)
api_router.include_router(checkins.router, prefix="/checkins", tags=["checkins"])

# Safety + delete
api_router.include_router(safety.router, tags=["safety"])
