"""
Decision Engine
Kullanıcı bağlamına göre koçun hangi modda yanıt vereceğine karar verir.
Bu karar, prompt_engine'e geçer — oradan AI çağrısı yapılır.
"""
from datetime import date, timedelta
from ..core.logging import get_logger
from ..db.client import get_supabase
from .safety_service import RiskLevel

logger = get_logger(__name__)


class CoachDecision:
    """Koç yanıt kararı. prompt_engine bunu kullanır."""

    def __init__(
        self,
        use_ai: bool,
        fixed_message: str | None = None,
        tone: str = "neutral",
        persona: str = "supportive",
        risk_level: str = RiskLevel.NORMAL,
        context: dict | None = None,
    ):
        self.use_ai = use_ai
        self.fixed_message = fixed_message
        self.tone = tone
        self.persona = persona
        self.risk_level = risk_level
        self.context = context or {}


class DecisionEngine:

    def __init__(self):
        self.db = get_supabase()

    async def decide(
        self,
        user_id: str,
        user_message: str,
        risk_level: str,
        fixed_safety_message: str | None,
    ) -> CoachDecision:
        """
        Koç yanıtı için karar verir.
        Sırayla: safety > persona > tone > context.
        """
        # 1. Crisis — AI bloke, sabit metin döner
        if fixed_safety_message and risk_level == RiskLevel.CRISIS:
            return CoachDecision(
                use_ai=False,
                fixed_message=fixed_safety_message,
                risk_level=risk_level,
            )

        # 2. Distress / low_intake — sabit nüdge, AI yanıt üretmez
        if fixed_safety_message:
            return CoachDecision(
                use_ai=False,
                fixed_message=fixed_safety_message,
                risk_level=risk_level,
            )

        # 3. Persona yükle
        persona = await self._get_persona(user_id)

        # 4. Context oluştur (son öğünler, check-in, vb.)
        context = await self._build_context(user_id)

        # 5. Ton seçimi — son check-in'e göre
        tone = self._select_tone(context)

        return CoachDecision(
            use_ai=True,
            tone=tone,
            persona=persona,
            risk_level=risk_level,
            context=context,
        )

    async def _get_persona(self, user_id: str) -> str:
        res = self.db.table("coach_preferences")\
            .select("coach_persona").eq("user_id", user_id).execute()
        if res.data:
            return res.data[0].get("coach_persona") or "supportive"
        return "supportive"

    async def _build_context(self, user_id: str) -> dict:
        today = str(date.today())
        yesterday = str(date.today() - timedelta(days=1))

        # Son 7 gün kayıt sayısı
        meals_7d = self.db.table("meal_logs")\
            .select("id", count="exact")\
            .eq("user_id", user_id)\
            .gte("local_day", str(date.today() - timedelta(days=7)))\
            .execute()

        # Son check-in
        checkin = self.db.table("daily_checkins")\
            .select("mood, local_day")\
            .eq("user_id", user_id)\
            .order("local_day", desc=True)\
            .limit(1)\
            .execute()

        # Bugün öğün var mı
        today_meals = self.db.table("meal_logs")\
            .select("id", count="exact")\
            .eq("user_id", user_id)\
            .eq("local_day", today)\
            .execute()

        return {
            "meals_last_7_days": meals_7d.count or 0,
            "last_mood": checkin.data[0]["mood"] if checkin.data else None,
            "last_checkin_day": checkin.data[0]["local_day"] if checkin.data else None,
            "meals_today": today_meals.count or 0,
            "is_empty_day": (today_meals.count or 0) == 0,
        }

    def _select_tone(self, context: dict) -> str:
        """Son check-in ve bağlama göre ton seç."""
        mood = context.get("last_mood")
        if mood in ("bad", "rough"):
            return "gentle"
        if mood in ("great", "good"):
            return "celebrate"
        if context.get("is_empty_day"):
            return "invite"
        return "neutral"
