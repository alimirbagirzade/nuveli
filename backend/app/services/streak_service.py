"""
Streak Service — kullanıcı engagement gamification mantığı.

"Streak" tanımı: kullanıcının arka arkaya öğün eklediği gün sayısı.
Öğün eklemek en güçlü engagement sinyali olduğu için bunu kullanıyoruz
(su kayıtları opsiyonel, mood check-in seyrek, kilo girişi haftalık).

Hesaplama mantığı:
1. Kullanıcının meals tablosundaki tüm DISTINCT local_day'leri al
2. Bugünden geriye doğru saymaya başla
3. Bugün kayıt yoksa ama dün varsa: streak hâlâ aktif (akşama kadar
   grace period — saat 23:59'a kadar)
4. Hem dün hem bugün yoksa: streak break

En uzun streak = tüm tarihlerin sıralı dizisinde en uzun ardışık seri.
"""

from datetime import date, timedelta, datetime
from typing import Set

from ..core.logging import get_logger
from ..db.client import get_supabase

logger = get_logger(__name__)


class StreakService:
    """Streak hesaplaması — read-only, kullanıcı verilerinden türetilir."""

    def __init__(self):
        self.db = get_supabase()

    async def compute_streak(self, user_id: str) -> dict:
        """
        Kullanıcının streak durumunu hesapla.

        Returns:
        {
            "current_streak": int,
            "longest_streak": int,
            "last_active_day": str | None,
            "today_logged": bool,
            "at_risk": bool,
            "milestone": str | None  // "3", "7", "14", "30", "60", "100"
        }
        """
        # Kullanıcının öğün eklediği tüm günleri çek (DISTINCT)
        meals_result = (
            self.db.table("meal_logs")
            .select("local_day")
            .eq("user_id", user_id)
            .order("local_day", desc=True)
            .execute()
        )

        # Tarihleri set'e dönüştür (DISTINCT)
        meal_days: Set[date] = set()
        for row in (meals_result.data or []):
            day_str = row.get("local_day")
            if day_str:
                try:
                    meal_days.add(date.fromisoformat(day_str))
                except (ValueError, TypeError):
                    pass

        if not meal_days:
            # Hiç öğün eklenmemiş
            return {
                "current_streak": 0,
                "longest_streak": 0,
                "last_active_day": None,
                "today_logged": False,
                "at_risk": False,
                "milestone": None,
            }

        today = date.today()
        yesterday = today - timedelta(days=1)
        today_logged = today in meal_days

        # Current streak — bugünden veya dünden başlayarak geriye say
        current_streak = self._compute_current_streak(meal_days, today, today_logged)

        # Longest streak — tüm tarihlerde en uzun ardışık dizi
        longest_streak = self._compute_longest_streak(meal_days)

        # En son aktif gün
        last_active = max(meal_days)

        # At risk: bugün kayıt yok ve şu an akşam (saat 18+)
        # → kullanıcı bugün eklemezse yarın streak break olur
        now_hour = datetime.now().hour
        at_risk = (
            current_streak > 0
            and not today_logged
            and now_hour >= 18
        )

        # Milestone — özel rakamlara ulaştı mı?
        milestone = self._milestone(current_streak)

        return {
            "current_streak": current_streak,
            "longest_streak": longest_streak,
            "last_active_day": last_active.isoformat(),
            "today_logged": today_logged,
            "at_risk": at_risk,
            "milestone": milestone,
        }

    @staticmethod
    def _compute_current_streak(
        meal_days: Set[date],
        today: date,
        today_logged: bool,
    ) -> int:
        """
        Bugünden veya dünden başlayarak geriye doğru ardışık günleri say.

        Kural: bugün kayıt yoksa ama dün varsa streak hâlâ aktif (grace
        period — kullanıcı bugün hâlâ ekleyebilir). Hem dün hem bugün
        yoksa streak 0.
        """
        # Sayma başlangıcı: bugün kayıtlıysa bugün, değilse dün
        cursor = today if today_logged else (today - timedelta(days=1))

        if cursor not in meal_days:
            # Ne bugün ne dün → break
            return 0

        streak = 0
        while cursor in meal_days:
            streak += 1
            cursor -= timedelta(days=1)

        return streak

    @staticmethod
    def _compute_longest_streak(meal_days: Set[date]) -> int:
        """Tüm tarihlerde en uzun ardışık dizi uzunluğu."""
        if not meal_days:
            return 0

        sorted_days = sorted(meal_days)
        longest = 1
        current = 1

        for i in range(1, len(sorted_days)):
            if sorted_days[i] - sorted_days[i - 1] == timedelta(days=1):
                current += 1
                if current > longest:
                    longest = current
            else:
                current = 1

        return longest

    @staticmethod
    def _milestone(streak: int) -> str | None:
        """Önemli mesafeler için milestone döndür."""
        milestones = {3, 7, 14, 21, 30, 60, 90, 100, 180, 365}
        return str(streak) if streak in milestones else None
