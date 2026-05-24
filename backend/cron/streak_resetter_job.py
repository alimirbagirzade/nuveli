"""
Streak Resetter Cron Job
=========================

Detects users whose logging streak has been broken (no meal logged for
yesterday) and resets their `current_streak` field on user_profiles to 0.
The longest_streak is preserved.

Designed to run once daily, around 01:00 UTC (before daily insights job).

Run manually:
    python -m cron.streak_resetter_job
"""
import asyncio
from datetime import date, datetime, timedelta

import sentry_sdk

from core.logging import setup_logging, get_logger
from core.supabase_client import init_supabase, get_supabase
from services.streak_service import compute_user_streak

logger = get_logger(__name__)


async def run() -> dict:
    """Sync current_streak for all users."""
    supabase = get_supabase()
    profiles_res = (
        supabase.table("user_profiles")
        .select("user_id, current_streak, longest_streak")
        .execute()
    )
    profiles = profiles_res.data or []

    logger.info(f"Streak resetter starting for {len(profiles)} profiles")

    today = date.today()
    reset_count = 0
    updated_count = 0
    failures = 0

    for profile in profiles:
        user_id = profile.get("user_id")
        if not user_id:
            continue

        old_streak = profile.get("current_streak") or 0
        old_longest = profile.get("longest_streak") or 0

        try:
            new_streak = await compute_user_streak(user_id)
        except Exception as e:
            failures += 1
            logger.error(f"Streak compute failed for {user_id}: {e}")
            sentry_sdk.capture_exception(e)
            continue

        # Only write if changed.
        if new_streak == old_streak and new_streak <= old_longest:
            continue

        new_longest = max(old_longest, new_streak)
        update_fields = {
            "current_streak": new_streak,
            "longest_streak": new_longest,
            "streak_last_synced_at": datetime.utcnow().isoformat(),
        }
        try:
            supabase.table("user_profiles").update(update_fields).eq("user_id", user_id).execute()
            updated_count += 1
            if new_streak == 0 and old_streak > 0:
                reset_count += 1
                logger.info(f"User {user_id} streak reset: {old_streak} -> 0")
        except Exception as e:
            failures += 1
            logger.error(f"Profile update failed for {user_id}: {e}")
            sentry_sdk.capture_exception(e)

    summary = {
        "date": today.isoformat(),
        "total_profiles": len(profiles),
        "updated": updated_count,
        "reset_to_zero": reset_count,
        "failures": failures,
        "completed_at": datetime.utcnow().isoformat(),
    }
    logger.info(f"Streak resetter complete: {summary}")
    return summary


async def main():
    setup_logging()
    init_supabase()
    summary = await run()
    print(summary)


if __name__ == "__main__":
    asyncio.run(main())
