"""
Daily Insights Cron Job
========================

Generates an AI coach insight for every active user.
Designed to run nightly around 02:00 UTC.

Run manually:
    python -m cron.daily_insights_job

Run with APScheduler (in-process):
    Imported and scheduled from main.py if APP_ENABLE_INTERNAL_CRON=true.

Render.com cron job:
    Create a Cron Service with command: python -m cron.daily_insights_job
"""
import asyncio
from datetime import date, datetime

import sentry_sdk

from core.logging import setup_logging, get_logger
from core.supabase_client import init_supabase, get_supabase
from services.fcm_service import send_to_user
from services.insights_generation_service import generate_daily_insight

logger = get_logger(__name__)


async def run_for_all_users(target_date: date | None = None) -> dict:
    """
    Generate insights for every active user.
    Returns summary dict with success / failure counts.
    """
    if target_date is None:
        target_date = date.today()

    supabase = get_supabase()
    # Active users = anyone who has logged something in the last 14 days.
    # Use the user_profiles table as authoritative; filter by last_active_at if available.
    profiles_res = (
        supabase.table("user_profiles")
        .select("user_id, last_active_at, is_premium, language")
        .execute()
    )
    profiles = profiles_res.data or []

    logger.info(f"Daily insights job starting for {len(profiles)} profiles, target_date={target_date}")

    success = 0
    failures = 0
    skipped = 0

    for profile in profiles:
        user_id = profile.get("user_id")
        if not user_id:
            skipped += 1
            continue
        try:
            await generate_daily_insight(user_id, target_date=target_date)
            success += 1
            # Best-effort push — send_to_user no-ops if FCM env is
            # missing, so this is safe to call unconditionally.
            try:
                await send_to_user(
                    user_id,
                    title="Your daily insight is ready 🌱",
                    body="Tap to see today's tips from your AI coach.",
                    data={"route": "/coach", "kind": "daily_insight"},
                )
            except Exception as push_err:
                # Never let a push failure mask an otherwise-successful
                # insight — the user can still open the app and read it.
                logger.warning(f"FCM push failed for {user_id}: {push_err}")
        except Exception as e:
            failures += 1
            logger.error(f"Insight generation failed for {user_id}: {e}")
            sentry_sdk.capture_exception(e)

    summary = {
        "target_date": target_date.isoformat(),
        "total_profiles": len(profiles),
        "success": success,
        "failures": failures,
        "skipped": skipped,
        "completed_at": datetime.utcnow().isoformat(),
    }
    logger.info(f"Daily insights job complete: {summary}")
    return summary


async def main():
    setup_logging()
    init_supabase()
    summary = await run_for_all_users()
    print(summary)


if __name__ == "__main__":
    asyncio.run(main())
