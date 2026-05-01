"""
Summary Generation Jobs
`daily_summaries` tablosunu yeniden hesaplar.

Çağrı yerleri:
- Meal eklenince / silinince / düzenlenince → ilgili günü yeniden hesapla
- Cron/scheduled job → geceyarısı önceki günü kesinleştir
- API endpoint → kullanıcı manual refresh isterse

Mantık:
Bu iş ağır bir computation değil — SQL aggregations. Ama ReadTime'de
her home çağrısında hesaplamak yerine cache'liyoruz, çünkü home
ekranı sık açılıyor ve bu trip down database yorar.
"""
from datetime import date
from ..core.logging import get_logger
from ..db.client import get_supabase

logger = get_logger(__name__)


class SummaryGenerator:

    def __init__(self):
        self.db = get_supabase()

    async def regenerate_day(self, user_id: str, local_day: str) -> dict:
        """
        Belirli bir gün için daily_summaries satırını yeniden hesaplar.
        Var olanı günceller; yoksa oluşturur.
        """
        # Meal toplamları
        meals = self.db.table("meal_logs")\
            .select("calories, protein_g, carb_g, fat_g")\
            .eq("user_id", user_id)\
            .eq("local_day", local_day)\
            .execute()

        meal_list = meals.data or []
        total_cal = sum(m.get("calories") or 0 for m in meal_list)
        total_pro = sum(m.get("protein_g") or 0 for m in meal_list)
        total_carb = sum(m.get("carb_g") or 0 for m in meal_list)
        total_fat = sum(m.get("fat_g") or 0 for m in meal_list)

        # Su toplamı
        waters = self.db.table("water_logs")\
            .select("amount_ml")\
            .eq("user_id", user_id).eq("local_day", local_day)\
            .execute()
        total_water = sum(w.get("amount_ml") or 0 for w in (waters.data or []))

        # O gün kilosu (varsa)
        weights = self.db.table("weight_logs")\
            .select("weight_kg")\
            .eq("user_id", user_id).eq("local_day", local_day)\
            .execute()
        weight = weights.data[0]["weight_kg"] if weights.data else None

        payload = {
            "user_id": user_id,
            "local_day": local_day,
            "total_calories": total_cal,
            "total_protein_g": total_pro,
            "total_carb_g": total_carb,
            "total_fat_g": total_fat,
            "water_ml": total_water,
            "weight_kg": weight,
            "meal_count": len(meal_list),
        }

        # Upsert
        self.db.table("daily_summaries").upsert(
            payload, on_conflict="user_id,local_day"
        ).execute()

        logger.info("daily_summary_regenerated", user_id=user_id, day=local_day)
        return payload

    async def regenerate_today(self, user_id: str) -> dict:
        return await self.regenerate_day(user_id, str(date.today()))
