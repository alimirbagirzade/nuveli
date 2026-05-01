"""
Profile Service
Onboarding, profil okuma/yazma ve bootstrap işlemleri.
"""
from datetime import date

from ..core.logging import get_logger
from ..db.client import get_supabase

logger = get_logger(__name__)


class ProfileService:

    def __init__(self):
        self.db = get_supabase()

    async def save_onboarding(self, user_id: str, data: dict) -> dict:
        """Onboarding profil verisini kaydeder. Mifflin-St Jeor ile kalori hedefi hesaplar."""
        calorie_target = self._calculate_calorie_target(data)

        payload = {
            "id": user_id,
            "display_name": data.get("display_name"),
            "birth_year": data.get("birth_year"),
            "gender": data.get("gender"),
            "height_cm": data.get("height_cm"),
            "weight_kg": data.get("weight_kg"),
            "goal": data.get("goal"),
            "activity_level": data.get("activity_level"),
            "daily_calorie_target": calorie_target,
            "special_conditions": data.get("special_conditions", []),
        }

        result = self.db.table("profiles").upsert(payload).execute()
        logger.info("onboarding_saved", user_id=user_id)
        return result.data[0] if result.data else {}

    async def save_coach_preferences(self, user_id: str, persona: str) -> dict:
        payload = {"user_id": user_id, "coach_persona": persona}
        result = self.db.table("coach_preferences").upsert(payload).execute()
        return result.data[0] if result.data else {}

    async def save_notification_preferences(self, user_id: str, prefs: dict) -> dict:
        payload = {"user_id": user_id, **prefs}
        result = self.db.table("notification_preferences").upsert(payload).execute()
        return result.data[0] if result.data else {}

    async def get_notification_preferences(self, user_id: str) -> dict:
        """Kullanıcının bildirim tercihlerini çek. Yoksa default döner."""
        result = self.db.table("notification_preferences") \
            .select("*").eq("user_id", user_id).execute()
        if result.data:
            return result.data[0]
        # Default: tüm bildirimler açık, sessiz saatler 22-08
        return {
            "meal_reminders": True,
            "coach_nudges": True,
            "weekly_summary": True,
            "quiet_start": "22:00",
            "quiet_end": "08:00",
        }

    async def delete_account(self, user_id: str) -> None:
        """
        Kullanıcının tüm verilerini siler (GDPR/KVKK compliance).

        Siler: meals, meal_analyses, coach_threads, notification_prefs,
        coach_prefs, premium_status_cache, profile, auth user.

        NOT: Bu işlem geri alınamaz ve async transaction değil — her tablo için
        ayrı DELETE çalışır. Gerçek production'da event-driven + retry gerekir.
        """
        logger.info("delete_account_started", user_id=user_id)

        # Sıra önemli: FK constraint'ler için önce child tablolar
        tables_to_clean = [
            "meals",
            "meal_analyses",
            "coach_threads",
            "coach_preferences",
            "notification_preferences",
            "premium_status_cache",
            "safety_incidents",  # Varsa
        ]

        for table in tables_to_clean:
            try:
                self.db.table(table).delete().eq("user_id", user_id).execute()
            except Exception as e:
                # Tablo yoksa veya başka bir hata — devam et, tam silmek kritik
                logger.warning("delete_table_failed", table=table, error=str(e))

        # Profile tablosunda user_id değil id kolonu var
        try:
            self.db.table("profiles").delete().eq("id", user_id).execute()
        except Exception as e:
            logger.warning("delete_profile_failed", error=str(e))

        # Auth user'ı sil (Supabase admin API)
        try:
            self.db.auth.admin.delete_user(user_id)
        except Exception as e:
            logger.error("delete_auth_user_failed", user_id=user_id, error=str(e))
            raise

        logger.info("delete_account_completed", user_id=user_id)

    async def complete_onboarding(self, user_id: str) -> None:
        self.db.table("profiles").update({"onboarding_completed": True}).eq("id", user_id).execute()
        # Premium cache başlat
        self.db.table("premium_status_cache").upsert({
            "user_id": user_id,
            "tier": "free",
        }).execute()
        logger.info("onboarding_completed", user_id=user_id)

    async def get_profile(self, user_id: str) -> dict | None:
        result = self.db.table("profiles").select("*").eq("id", user_id).single().execute()
        return result.data

    async def get_bootstrap(self, user_id: str) -> dict:
        """Uygulama açılışında tüm state'i tek seferde döndürür."""
        profile = await self.get_profile(user_id)

        coach_prefs = self.db.table("coach_preferences").select("*").eq("user_id", user_id).execute()
        premium = self.db.table("premium_status_cache").select("*").eq("user_id", user_id).execute()

        return {
            "profile": profile,
            "coach_preferences": coach_prefs.data[0] if coach_prefs.data else None,
            "premium_status": premium.data[0] if premium.data else {"tier": "free"},
            "onboarding_completed": profile.get("onboarding_completed", False) if profile else False,
        }

    def _calculate_calorie_target(self, data: dict) -> int:
        """
        Mifflin-St Jeor formülü ile günlük kalori hedefi hesaplar.
        Minimum: 1200 kcal (kadın), 1500 kcal (erkek).
        """
        gender = data.get("gender", "other")
        weight = data.get("weight_kg", 70)
        height = data.get("height_cm", 170)
        birth_year = data.get("birth_year", 1990)
        age = date.today().year - birth_year
        goal = data.get("goal", "maintain")
        activity = data.get("activity_level", "light")

        # BMR
        if gender == "male":
            bmr = 10 * weight + 6.25 * height - 5 * age + 5
        else:
            bmr = 10 * weight + 6.25 * height - 5 * age - 161

        # TDEE
        activity_factors = {
            "sedentary": 1.2,
            "light": 1.375,
            "moderate": 1.55,
            "active": 1.725,
        }
        tdee = bmr * activity_factors.get(activity, 1.375)

        # Hedef ayarı
        if goal == "lose":
            target = tdee - 500
        elif goal == "gain":
            target = tdee + 300
        else:
            target = tdee

        # Minimum güvenli limit
        minimum = 1500 if gender == "male" else 1200
        return max(int(target), minimum)
