"""
Achievements router.
List user achievements and check for newly unlocked ones.
"""
from fastapi import APIRouter, Depends, HTTPException, status

from core.auth import get_current_user
from core.logging import get_logger
from models.achievement import AchievementResponse, AchievementCheckResponse
from services.achievement_service import list_user_achievements, check_and_unlock

logger = get_logger(__name__)
router = APIRouter()


@router.get("", response_model=list[AchievementResponse])
async def get_achievements(user: dict = Depends(get_current_user)):
    """
    List all achievements with unlock status for the current user.
    Returns both locked and unlocked achievements with progress info.
    """
    user_id = user["sub"]
    try:
        rows = await list_user_achievements(user_id)
        return [AchievementResponse(**row) for row in rows]
    except Exception as e:
        logger.error(f"Failed to list achievements for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to load achievements",
        )


@router.post("/check", response_model=AchievementCheckResponse)
async def check_achievements(user: dict = Depends(get_current_user)):
    """
    Check for newly unlocked achievements based on current user progress.
    Persists newly unlocked rows to user_achievements table.
    Returns list of newly unlocked achievements (empty if none).
    """
    user_id = user["sub"]
    try:
        newly_unlocked = await check_and_unlock(user_id)
        all_achievements = await list_user_achievements(user_id)
        total_unlocked = sum(1 for a in all_achievements if a.get("unlocked"))
        total_available = len(all_achievements)
        return AchievementCheckResponse(
            newly_unlocked=[AchievementResponse(**row) for row in newly_unlocked],
            total_unlocked=total_unlocked,
            total_available=total_available,
        )
    except Exception as e:
        logger.error(f"Achievement check failed for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to check achievements",
        )
