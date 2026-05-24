"""
Achievement Checker Cron Job
=============================

Walks every active user and unlocks any achievements whose targets have
been crossed. Designed to run a few times per day (e.g. every 6 hours)
as a safety net — most achievements should unlock in real time via the
POST /achievements/check endpoint after relevant user actions.

Run manually:
    python -m cron.achievement_checker_job
"""
import asyncio
from datetime import datetime

import sentry_sdk

from core.logging import setup_logging, get_logger
from core.supabase_client import init_supabase, get_supabase
from services.achievement_service import check_and_unlock

logger = get_logger(__name__)


async def run_for_all_users() -> dict:
    """Run achievement checks for every user profile."""
    supabase = get_supabase()
    profiles_res = (
        supabase.table("user_profiles")
        .select("user_id")
        .execute()
    )
    profiles = profiles_res.data or []

    logger.info(f"Achievement checker starting for {len(profiles)} profiles")

    total_unlocked = 0
    failures = 0

    for profile in profiles:
        user_id = profile.get("user_id")
        if not user_id:
            continue
        try:
            unlocked = await check_and_unlock(user_id)
            if unlocked:
                total_unlocked += len(unlocked)
                logger.info(f"User {user_id}: {len(unlocked)} achievements unlocked")
        except Exception as e:
            failures += 1
            logger.error(f"Achievement check failed for {user_id}: {e}")
            sentry_sdk.capture_exception(e)

    summary = {
        "total_profiles": len(profiles),
        "total_unlocked": total_unlocked,
        "failures": failures,
        "completed_at": datetime.utcnow().isoformat(),
    }
    logger.info(f"Achievement checker complete: {summary}")
    return summary


async def main():
    setup_logging()
    init_supabase()
    summary = await run_for_all_users()
    print(summary)


if __name__ == "__main__":
    asyncio.run(main())
