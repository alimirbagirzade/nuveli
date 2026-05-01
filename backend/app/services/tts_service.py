"""
TTS Service
Kısa koç yanıtları için OpenAI TTS.
Max 2 cümle — uzunsa kesilir.
"""
import re
from openai import OpenAI

from ..core.config import settings
from ..core.logging import get_logger

logger = get_logger(__name__)


class TTSService:

    def __init__(self):
        self.openai = OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None

    async def synthesize_short(self, text: str, voice: str = "nova") -> bytes | None:
        """
        Kısa TTS üretir (max 2 cümle, 200 karakter).
        Ses bytes döner; Supabase Storage'a yüklenmesi arayanın sorumluluğu.
        Hata durumunda None döner — koç metin yine de iletilir.
        """
        if not self.openai:
            logger.info("tts_skipped_no_key")
            return None

        short = self._trim(text)

        try:
            resp = self.openai.audio.speech.create(
                model="tts-1",
                voice=voice,
                input=short,
                response_format="mp3",
            )
            return resp.content
        except Exception as e:
            logger.warning("tts_failed", error=str(e))
            return None

    def _trim(self, text: str) -> str:
        sentences = re.split(r"(?<=[.!?])\s+", text.strip())
        short = " ".join(sentences[:2])
        return short[:200]

    async def upload_to_storage(self, user_id: str, audio_bytes: bytes, message_id: str) -> str | None:
        """
        TTS ses dosyasını Supabase Storage'a yükler ve public URL döndürür.
        Bucket: 'coach-audio' (Supabase panelinden önceden oluşturulmalı).
        """
        from ..db.client import get_supabase
        db = get_supabase()
        try:
            path = f"{user_id}/{message_id}.mp3"
            db.storage.from_("coach-audio").upload(
                path, audio_bytes,
                file_options={"content-type": "audio/mpeg", "upsert": "true"},
            )
            return db.storage.from_("coach-audio").get_public_url(path)
        except Exception as e:
            logger.warning("tts_upload_failed", error=str(e))
            return None
