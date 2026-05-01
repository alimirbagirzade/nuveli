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
            "ai_insight": self._weekly_ai_insight(days, days_logged, total_cal),
            "premium_only_insight": True,
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
            "ai_insight": self._monthly_ai_insight(days, insights),
            "premium_only_insight": True,
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

    def _weekly_ai_insight(self, days: list, days_logged: int, total_cal: int) -> str | None:
        """Premium-only zenginlestirilmis haftalik yorum. Sprint 3'te LLM ile."""
        if not days or days_logged == 0:
            return None
        if days_logged < 3:
            return (
                f"Bu hafta {days_logged} gun kaydin var. Hala basliyoruz; "
                "her kayit ozel bir adim. Yeni haftaya bir foto cekerek baslayalim."
            )
        if days_logged >= 6:
            return (
                f"{days_logged} gun ust uste kayit — guzel bir suekme. "
                "Kalori ortalaman istikrarli; gelecek hafta ozellikle hafta sonuna dikkat."
            )
        return (
            f"{days_logged} gun kayit, dengeli bir tempo. "
            "Hafta arasinda devamliligin guclu, hafta sonu icin kucuk bir hatirlatma kuralim."
        )

    def _monthly_ai_insight(self, days: list, insights: list) -> str | None:
        """Premium-only aylik orutu yorumu. Sprint 3'te LLM ile."""
        logged_days = [d for d in days if d.get("meal_count", 0) > 0]
        if not logged_days:
            return None
        if len(logged_days) < 7:
            return (
                "Henuz 30 gunlu bir orutu cikarmak icin yeterli veri yok. "
                "Birkac hafta daha kaydedince burada daha derin yorum gorursun."
            )
        # Hafta ici vs hafta sonu farki
        weekday_cals = []
        weekend_cals = []
        for d in logged_days:
            try:
                from datetime import date as _date
                y, m, dd = d["local_day"].split("-")
                wd = _date(int(y), int(m), int(dd)).weekday()  # 0=Mon..6=Sun
                if wd >= 5:
                    weekend_cals.append(d["total_calories"])
                else:
                    weekday_cals.append(d["total_calories"])
            except Exception:
                continue
        if weekday_cals and weekend_cals:
            avg_wd = sum(weekday_cals) / len(weekday_cals)
            avg_we = sum(weekend_cals) / len(weekend_cals)
            diff = avg_we - avg_wd
            if abs(diff) > 200:
                direction = "yuksek" if diff > 0 else "dusuk"
                return (
                    f"Hafta sonlarin hafta icine gore ortalama {abs(int(diff))} kcal "
                    f"daha {direction}. Onemli olan farkina varmak; yargi yok."
                )
        return (
            f"{len(logged_days)} gun kaydin var — sabit bir tempo. "
            "Sonraki ay icin hedef: ufak ama duzenli adimlar."
        )
