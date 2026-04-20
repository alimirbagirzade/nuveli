"""
Coach Service
DecisionEngine + PromptEngine + Safety + Fallback + TTS orkestrasyon.

Akış:
  1. Safety scan (risk level)
  2. Decision engine (use_ai? tone? persona? context?)
  3. Crisis/distress → sabit metin, AI yok
  4. Normal → prompt_engine → OpenAI
  5. Başarısız → fallback copy
  6. Opsiyonel: TTS üret, storage'a yükle
  7. Thread'e kaydet
"""
from datetime import date
from openai import OpenAI

from ..core.config import settings
from ..core.exceptions import LimitExceededError
from ..core.logging import get_logger
from ..db.client import get_supabase
from .decision_engine import DecisionEngine
from .fallback_copy_service import get_fallback
from .prompt_engine import PromptEngine
from .safety_service import SafetyService
from .tts_service import TTSService

logger = get_logger(__name__)


class CoachService:

    def __init__(self):
        self.db = get_supabase()
        self.openai = OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None
        self.safety = SafetyService()
        self.decision = DecisionEngine()
        self.prompt = PromptEngine()
        self.tts = TTSService()

    async def respond(self, user_id: str, user_message: str, want_audio: bool = False) -> dict:
        """Kullanıcı mesajına koç yanıtı üretir."""
        # 1. Limit kontrolü
        from .premium_service import PremiumService
        status = await PremiumService().get_status(user_id)
        if status["tier"] == "free":
            used = await self._get_coach_usage_today(user_id)
            if used >= settings.free_coach_messages_per_day:
                raise LimitExceededError("coach_messages", settings.free_coach_messages_per_day)

        # 2. Risk tarama
        risk_level = self.safety.scan(user_message)
        fixed_message = self.safety.get_fixed_message(risk_level)

        # 3. Decision
        decision = await self.decision.decide(
            user_id=user_id,
            user_message=user_message,
            risk_level=risk_level,
            fixed_safety_message=fixed_message,
        )

        # 4. Kullanıcı mesajını kaydet
        await self.save_message(user_id, "user", user_message)

        # 5. Yanıt üret
        if not decision.use_ai:
            message_text = decision.fixed_message
            is_fallback = True
            audio_url = None
        else:
            message_text, is_fallback = await self._generate_ai_reply(user_id, user_message, decision)
            audio_url = None
            if want_audio and status["tier"] in ("trial", "premium") and not is_fallback:
                audio_url = await self._try_tts(user_id, message_text)

        # 6. Usage ++
        await self._increment_coach_usage(user_id)

        # 7. Risk mode güncelle
        if risk_level != "normal":
            self.db.table("coach_preferences").upsert({
                "user_id": user_id,
                "risk_mode": risk_level,
            }, on_conflict="user_id").execute()

        # 8. Koç yanıtını kaydet
        saved = await self.save_message(
            user_id, "coach", message_text,
            is_fallback=is_fallback, audio_url=audio_url,
        )

        return {
            "message": message_text,
            "is_fallback": is_fallback,
            "risk_level": risk_level,
            "audio_url": audio_url,
            "message_id": saved["id"],
        }

    async def save_message(
        self, user_id: str, role: str, content: str,
        is_fallback: bool = False, audio_url: str | None = None,
    ) -> dict:
        thread = self.db.table("coach_threads").select("id").eq("user_id", user_id).execute()
        if not thread.data:
            t = self.db.table("coach_threads").insert({"user_id": user_id}).execute()
            thread_id = t.data[0]["id"]
        else:
            thread_id = thread.data[0]["id"]

        row = self.db.table("coach_messages").insert({
            "thread_id": thread_id,
            "user_id": user_id,
            "role": role,
            "content": content,
            "is_fallback": is_fallback,
            "audio_url": audio_url,
        }).execute()
        return row.data[0]

    async def get_thread(self, user_id: str, limit: int = 50) -> list:
        thread = self.db.table("coach_threads").select("id").eq("user_id", user_id).execute()
        if not thread.data:
            return []
        thread_id = thread.data[0]["id"]
        result = self.db.table("coach_messages")\
            .select("*").eq("thread_id", thread_id)\
            .order("created_at", desc=False).limit(limit).execute()
        return result.data or []

    # ─── İçeriden ────

    async def _generate_ai_reply(self, user_id: str, user_message: str, decision) -> tuple[str, bool]:
        if not self.openai:
            return get_fallback("neutral"), True

        history = await self.get_thread(user_id, limit=6)
        messages = self.prompt.build_messages(decision, user_message, history)

        try:
            resp = self.openai.chat.completions.create(
                model="gpt-4o-mini",
                messages=messages,
                max_tokens=150,
                temperature=0.7,
            )
            text = resp.choices[0].message.content.strip()
            return text, False
        except Exception as e:
            logger.warning("coach_ai_failed", user_id=user_id, error=str(e))
            kind = {"gentle": "tough", "celebrate": "encourage",
                    "invite": "greeting"}.get(decision.tone, "neutral")
            return get_fallback(kind), True

    async def _try_tts(self, user_id: str, text: str) -> str | None:
        audio_bytes = await self.tts.synthesize_short(text)
        if not audio_bytes:
            return None
        from uuid import uuid4
        return await self.tts.upload_to_storage(user_id, audio_bytes, str(uuid4()))

    async def _get_coach_usage_today(self, user_id: str) -> int:
        today = str(date.today())
        res = self.db.table("usage_counters_daily")\
            .select("coach_messages")\
            .eq("user_id", user_id).eq("local_day", today).execute()
        if res.data:
            return res.data[0].get("coach_messages") or 0
        return 0

    async def _increment_coach_usage(self, user_id: str) -> None:
        today = str(date.today())
        current = await self._get_coach_usage_today(user_id)
        self.db.table("usage_counters_daily").upsert({
            "user_id": user_id,
            "local_day": today,
            "coach_messages": current + 1,
        }, on_conflict="user_id,local_day").execute()
