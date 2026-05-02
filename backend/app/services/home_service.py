"""Home Service — composite home payload."""
from datetime import date
from ..core.config import settings
from ..core.logging import get_logger
from ..db.client import get_supabase
from .streak_service import StreakService

logger = get_logger(__name__)


class HomeService:

    def __init__(self):
        self.db = get_supabase()
        self.streak_service = StreakService()

    async def get_home_payload(self, user_id: str) -> dict:
        today = str(date.today())

        # Profile + premium
        profile = self.db.table("profiles").select("*").eq("id", user_id).single().execute()
        premium = self.db.table("premium_status_cache").select("*").eq("user_id", user_id).execute()
        usage = self.db.table("usage_counters_daily")\
            .select("*").eq("user_id", user_id).eq("local_day", today).execute()

        # Summary
        summary = await self._get_or_build_summary(user_id, today)

        # Streak (gamification)
        try:
            streak_data = await self.streak_service.compute_streak(user_id)
        except Exception as e:
            logger.warning("streak_compute_failed", error=str(e))
            streak_data = {
                "current_streak": 0,
                "longest_streak": 0,
                "today_logged": False,
                "at_risk": False,
                "milestone": None,
            }

        profile_data = profile.data or {}
        premium_data = premium.data[0] if premium.data else {"status": "free"}
        # Row-based: each feature is a separate row. Aggregate into dict.
        usage_data = {"meal_analyses": 0, "coach_messages": 0}
        for row in (usage.data or []):
            feature = row.get("feature")
            count = row.get("count", 0)
            if feature in ("meal_analyses", "meal_photo_analysis"):
                usage_data["meal_analyses"] = count
            elif feature in ("coach_messages", "coach_text_response", "coach_voice_response"):
                usage_data["coach_messages"] = count

        tier = premium_data.get("status", premium_data.get("tier", "free"))
        meal_limit = 9999 if tier in ("trial", "premium") else settings.free_meal_analyses_per_day
        coach_limit = 9999 if tier in ("trial", "premium") else settings.free_coach_messages_per_day

        return {
            "greeting": self._greeting(profile_data.get("display_name")),
            "daily_summary": {
                "calories": summary.get("total_calories", 0),
                "target": profile_data.get("daily_calorie_target", 2000),
                "protein_g": summary.get("total_protein_g", 0),
                "carb_g": summary.get("total_carb_g", 0),
                "fat_g": summary.get("total_fat_g", 0),
                "water_ml": summary.get("water_ml", 0),
                "meal_count": summary.get("meal_count", 0),
            },
            "quick_actions": {
                "can_add_meal": usage_data["meal_analyses"] < meal_limit,
                "meal_analyses_used": usage_data["meal_analyses"],
                "meal_analyses_limit": meal_limit,
            },
            "coach_card": {
                "visible": True,
                "message_preview": self._coach_preview(summary),
            },
            "craving_prompt": {
                "visible": summary.get("meal_count", 0) == 0 and self._is_afternoon(),
            },
            "premium_preview": {
                "tier": tier,
                "trial_ends_at": premium_data.get("trial_ends_at"),
            },
            "streak": {
                "current": streak_data.get("current_streak", 0),
                "longest": streak_data.get("longest_streak", 0),
                "today_logged": streak_data.get("today_logged", False),
                "at_risk": streak_data.get("at_risk", False),
                "milestone": streak_data.get("milestone"),
            },
        }

    async def _get_or_build_summary(self, user_id: str, local_day: str) -> dict:
        cached = self.db.table("daily_summaries")\
            .select("*").eq("user_id", user_id).eq("local_day", local_day).execute()
        if cached.data:
            return cached.data[0]

        meals = self.db.table("meal_logs")\
            .select("calories,protein_g,carb_g,fat_g")\
            .eq("user_id", user_id).eq("local_day", local_day).execute()
        water = self.db.table("water_logs")\
            .select("amount_ml").eq("user_id", user_id).eq("local_day", local_day).execute()
        weight = self.db.table("weight_logs")\
            .select("weight_kg").eq("user_id", user_id).eq("local_day", local_day).execute()

        summary = {
            "user_id": user_id,
            "local_day": local_day,
            "total_calories": sum((m["calories"] or 0) for m in (meals.data or [])),
            "total_protein_g": sum((m["protein_g"] or 0) for m in (meals.data or [])),
            "total_carb_g": sum((m["carb_g"] or 0) for m in (meals.data or [])),
            "total_fat_g": sum((m["fat_g"] or 0) for m in (meals.data or [])),
            "water_ml": sum((w["amount_ml"] or 0) for w in (water.data or [])),
            "weight_kg": weight.data[0]["weight_kg"] if weight.data else None,
            "meal_count": len(meals.data or []),
        }

        # UPSERT: zaten varsa güncelle (yeni yemek eklendiyse total değişir)
        self.db.table("daily_summaries").upsert(summary, on_conflict="user_id,local_day").execute()
        return summary

    def _greeting(self, name: str | None) -> str:
        import datetime
        hour = datetime.datetime.now().hour
        greet = "Günaydın" if hour < 11 else "Tünaydın" if hour < 17 else "İyi akşamlar"
        return f"{greet}{', ' + name if name else ''}!"

    def _coach_preview(self, summary: dict) -> str:
        if summary.get("meal_count", 0) == 0:
            return "Bugün nasıl hissediyorsun? Seni dinlerim."
        return "Bugün de yanındayım. Bir şey konuşmak ister misin?"

    def _is_afternoon(self) -> bool:
        import datetime
        return 14 <= datetime.datetime.now().hour < 19
