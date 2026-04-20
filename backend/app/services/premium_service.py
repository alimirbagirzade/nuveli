"""Premium Service — tier, feature matrix, trial claim."""
from datetime import datetime, timedelta, timezone
from ..core.config import settings
from ..core.logging import get_logger
from ..db.client import get_supabase

logger = get_logger(__name__)


FEATURE_MATRIX = {
    "free": {
        "meal_analyses_per_day": settings.free_meal_analyses_per_day,
        "coach_messages_per_day": settings.free_coach_messages_per_day,
        "voice_reply": False,
        "weekly_summary": False,
        "monthly_insight": False,
        "progress_charts": "basic",
    },
    "trial": {
        "meal_analyses_per_day": 9999,
        "coach_messages_per_day": 9999,
        "voice_reply": True,
        "weekly_summary": True,
        "monthly_insight": False,
        "progress_charts": "full",
    },
    "premium": {
        "meal_analyses_per_day": 9999,
        "coach_messages_per_day": 9999,
        "voice_reply": True,
        "weekly_summary": True,
        "monthly_insight": True,
        "progress_charts": "full",
    },
}


class PremiumService:

    def __init__(self):
        self.db = get_supabase()

    async def get_status(self, user_id: str) -> dict:
        result = self.db.table("premium_status_cache")\
            .select("*").eq("user_id", user_id).execute()
        if not result.data:
            # default free
            default = {"user_id": user_id, "tier": "free"}
            self.db.table("premium_status_cache").upsert(default).execute()
            return default

        status = result.data[0]

        # Trial bitmişse düşür
        if status["tier"] == "trial" and status.get("trial_ends_at"):
            end = datetime.fromisoformat(status["trial_ends_at"].replace("Z", "+00:00"))
            if end < datetime.now(timezone.utc):
                self.db.table("premium_status_cache")\
                    .update({"tier": "free", "trial_ends_at": None})\
                    .eq("user_id", user_id).execute()
                status["tier"] = "free"

        return status

    async def get_features(self, user_id: str) -> dict:
        status = await self.get_status(user_id)
        tier = status.get("tier", "free")
        return {"tier": tier, "features": FEATURE_MATRIX.get(tier, FEATURE_MATRIX["free"])}

    async def claim_trial(self, user_id: str) -> dict:
        current = await self.get_status(user_id)
        if current["tier"] != "free":
            return {"claimed": False, "reason": "already_upgraded"}

        end = datetime.now(timezone.utc) + timedelta(days=7)
        self.db.table("premium_status_cache").upsert({
            "user_id": user_id,
            "tier": "trial",
            "trial_ends_at": end.isoformat(),
        }, on_conflict="user_id").execute()
        logger.info("trial_claimed", user_id=user_id)
        return {"claimed": True, "trial_ends_at": end.isoformat()}

    async def update_from_webhook(self, user_id: str, tier: str, ends_at: str | None, rc_customer_id: str | None) -> None:
        """RevenueCat webhook'undan gelen premium durumunu günceller."""
        self.db.table("premium_status_cache").upsert({
            "user_id": user_id,
            "tier": tier,
            "subscription_ends_at": ends_at,
            "rc_customer_id": rc_customer_id,
        }, on_conflict="user_id").execute()
