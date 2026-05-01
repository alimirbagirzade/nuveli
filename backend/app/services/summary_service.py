"""Summary Service — haftalık ve aylık ilerleme."""
from datetime import date, timedelta
from ..db.client import get_supabase


class SummaryService:

    def __init__(self):
        self.db = get_supabase()

    async def weekly_current(self, user_id: str) -> dict:
        today = date.today()
        start = today - timedelta(days=6)

        summaries = self.db.table("daily_summaries")\
            .select("*").eq("user_id", user_id)\
            .gte("local_day", str(start)).lte("local_day", str(today))\
            .order("local_day").execute()

        days = summaries.data or []
        total_cal = sum(d["total_calories"] for d in days)
        total_meals = sum(d["meal_count"] for d in days)
        days_logged = len([d for d in days if d["meal_count"] > 0])

        return {
            "start_date": str(start),
            "end_date": str(today),
            "total_calories": total_cal,
            "avg_calories": int(total_cal / max(days_logged, 1)),
            "total_meals": total_meals,
            "days_logged": days_logged,
            "daily_breakdown": days,
            "headline": self._weekly_headline(days_logged, total_meals),
        }

    async def monthly_current(self, user_id: str) -> dict:
        today = date.today()
        start = today - timedelta(days=29)

        summaries = self.db.table("daily_summaries")\
            .select("*").eq("user_id", user_id)\
            .gte("local_day", str(start)).lte("local_day", str(today))\
            .order("local_day").execute()

        days = summaries.data or []
        insights = self._generate_insights(days)

        return {
            "start_date": str(start),
            "end_date": str(today),
            "days_logged": len([d for d in days if d["meal_count"] > 0]),
            "total_days": 30,
            "insights": insights,
        }

    def _weekly_headline(self, days_logged: int, total_meals: int) -> str:
        if days_logged == 0:
            return "Bu hafta kayıt yok. Yeni bir hafta her zaman mümkün."
        if days_logged >= 5:
            return f"Güzel bir hafta! {days_logged} gün kayıt yaptın."
        return f"{days_logged} gün kayıt yaptın. İyi bir ilerleme."

    def _generate_insights(self, days: list) -> list[dict]:
        """Temel 3 içgörü kuralı."""
        insights = []

        if not days:
            return [{"title": "Henüz veri yok", "body": "Birkaç gün kayıt yaptıktan sonra içgörüler burada belirecek."}]

        logged_days = [d for d in days if d["meal_count"] > 0]
        if logged_days:
            avg_cal = sum(d["total_calories"] for d in logged_days) / len(logged_days)
            insights.append({
                "title": "Günlük ortalama",
                "body": f"Son 30 günde ortalama {int(avg_cal)} kcal tükettin.",
            })

            total_water = sum(d.get("water_ml", 0) for d in logged_days)
            if total_water > 0:
                avg_water = total_water / len(logged_days)
                insights.append({
                    "title": "Su tüketimi",
                    "body": f"Günlük ortalama {int(avg_water)} ml su içtin.",
                })

            consistency = len(logged_days) / len(days) * 100
            insights.append({
                "title": "Tutarlılık",
                "body": f"%{int(consistency)} tutarlılık. Küçük adımlar büyük farklar yaratır.",
            })

        return insights[:3]
