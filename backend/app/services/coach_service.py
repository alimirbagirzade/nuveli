"""
backend/app/services/coach_service.py

Coach Service — AI Boru Hattı Orkestrası.
PRD §7.2: Decision → Prompt → Model → Safety → (TTS) → Response.

Bu servis NE iş yapmaz:
- AI logic doğrudan yazmaz (prompt_engine yapar)
- Karar vermez (decision_engine verir)
- Filtreleme yapmaz (safety_service yapar)
- Fallback üretmez (fallback_copy_service çağırır)

Sadece zinciri orkestre eder ve usage counter'ı artırır.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
import logging
import asyncio

from openai import AsyncOpenAI
from openai import OpenAIError, APITimeoutError, RateLimitError

from app.services.decision_engine import (
    DecisionEngine,
    Decision,
    Surface,
    SafetyMode,
    PremiumState,
)
from app.services.prompt_engine import PromptEngine
from app.services.safety_service import SafetyService, BlockReason
from app.services.fallback_copy_service import FallbackCopyService
from app.services.tts_service import TTSService

logger = logging.getLogger(__name__)


# Feature key mapping (decision_engine.FEATURE_LIMITS ile uyumlu)
FEATURE_KEYS = {
    Surface.CHAT_RESPONSE: "coach_text_response",
    Surface.HOME_CARD: "coach_text_response",
    Surface.MEAL_REACTION: "coach_text_response",
    Surface.WEEKLY_SUMMARY: None,  # weekly summary limit'siz (job tarafı)
    Surface.EMPTY_DAY: None,
    Surface.RECOVERY_DAY: None,
    Surface.CELEBRATION: None,
}


@dataclass
class CoachResponse:
    text: str
    mode: str                    # 'normal' | 'sensitive' | 'high_risk'
    persona: str
    surface: str
    is_fallback: bool = False
    fallback_reason: Optional[str] = None
    voice_url: Optional[str] = None     # TTS varsa
    show_resources: bool = False        # high_risk için pro destek linki
    show_premium_upsell: bool = False
    show_day2_gift: bool = False
    usage_remaining: Optional[int] = None  # Bu surface için kalan
    error_code: Optional[str] = None    # 'limit_reached' | 'service_unavailable' | None
    metadata: dict = field(default_factory=dict)


class CoachService:
    def __init__(
        self,
        decision_engine: DecisionEngine,
        prompt_engine: PromptEngine,
        safety_service: SafetyService,
        fallback_copy_service: FallbackCopyService,
        openai_client: AsyncOpenAI,
        tts_service: Optional[TTSService] = None,
    ):
        self.decision_engine = decision_engine
        self.prompt_engine = prompt_engine
        self.safety_service = safety_service
        self.fallback_copy_service = fallback_copy_service
        self.openai_client = openai_client
        self.tts_service = tts_service

    async def respond(
        self,
        user_id: str,
        surface: Surface,
        user_message: Optional[str] = None,
        meal_context: Optional[dict] = None,
        weekly_data: Optional[dict] = None,
        request_voice: bool = False,
    ) -> CoachResponse:
        """
        Ana entry point. Tüm AI cevap akışı buradan geçer.
        """
        # ────────────────────────────────────────────
        # 1. DECISION
        # ────────────────────────────────────────────
        feature_key = FEATURE_KEYS.get(surface)
        decision = await self.decision_engine.resolve(
            user_id=user_id,
            surface=surface,
            feature_key=feature_key,
        )
        logger.info("Coach.respond: %s", decision)

        # ────────────────────────────────────────────
        # 2. USAGE GATE
        # ────────────────────────────────────────────
        if not decision.usage_ok:
            return self._limit_reached_response(decision)

        # ────────────────────────────────────────────
        # 3. PROMPT
        # ────────────────────────────────────────────
        try:
            prompt_output = self.prompt_engine.build(
                decision=decision,
                user_message=user_message,
                meal_context=meal_context,
                weekly_data=weekly_data,
            )
        except Exception as e:
            logger.exception("PromptEngine failed: %s", e)
            return self._fallback_response(
                decision, reason="prompt_engine_error"
            )

        # ────────────────────────────────────────────
        # 4. MODEL
        # ────────────────────────────────────────────
        try:
            ai_text = await self._call_openai(
                messages=prompt_output.messages,
                model=prompt_output.model_recommendation,
                mode=decision.safety_mode,
            )
        except (APITimeoutError, RateLimitError) as e:
            logger.warning("OpenAI rate/timeout: %s", e)
            return self._fallback_response(decision, reason="openai_unavailable")
        except OpenAIError as e:
            logger.error("OpenAI error: %s", e)
            return self._fallback_response(decision, reason="openai_error")
        except Exception as e:
            logger.exception("Unexpected OpenAI error: %s", e)
            return self._fallback_response(decision, reason="unexpected_error")

        if not ai_text or not ai_text.strip():
            return self._fallback_response(decision, reason="empty_response")

        # ────────────────────────────────────────────
        # 5. SAFETY FILTER
        # ────────────────────────────────────────────
        safety_result = self.safety_service.filter(
            text=ai_text,
            mode=decision.safety_mode,
            locale=decision.locale,
        )
        if not safety_result.passed:
            logger.warning(
                "Safety blocked AI response: reason=%s patterns=%s",
                safety_result.block_reason.value if safety_result.block_reason else None,
                safety_result.triggered_patterns,
            )
            return self._fallback_response(
                decision,
                reason=f"safety_block:{safety_result.block_reason.value if safety_result.block_reason else 'unknown'}",
            )

        # ────────────────────────────────────────────
        # 6. TTS (opsiyonel)
        # ────────────────────────────────────────────
        voice_url = None
        if request_voice and self.tts_service and decision.safety_mode != SafetyMode.HIGH_RISK:
            # TTS için ayrı feature limit kontrolü
            voice_decision = await self.decision_engine.resolve(
                user_id=user_id,
                surface=surface,
                feature_key="coach_voice_response",
            )
            if voice_decision.usage_ok:
                try:
                    voice_url = await self.tts_service.synthesize(
                        text=safety_result.filtered_text,
                        user_id=user_id,
                        locale=decision.locale,
                    )
                    await self.decision_engine.increment_usage(
                        user_id, "coach_voice_response"
                    )
                except Exception as e:
                    logger.warning("TTS failed (non-fatal): %s", e)

        # ────────────────────────────────────────────
        # 7. USAGE INCREMENT
        # ────────────────────────────────────────────
        if feature_key:
            await self.decision_engine.increment_usage(user_id, feature_key)

        # ────────────────────────────────────────────
        # 8. RESPONSE
        # ────────────────────────────────────────────
        usage_remaining = None
        if feature_key:
            usage_remaining = max(
                0, decision.usage_limit_today - (decision.usage_count_today + 1)
            )

        return CoachResponse(
            text=safety_result.filtered_text,
            mode=decision.safety_mode.value,
            persona=decision.persona.value,
            surface=surface.value,
            is_fallback=False,
            voice_url=voice_url,
            show_resources=self.safety_service.should_show_resources(
                decision.safety_mode, user_message
            ),
            show_premium_upsell=decision.show_premium_upsell,
            show_day2_gift=decision.show_day2_gift,
            usage_remaining=usage_remaining,
            metadata={
                "model_used": prompt_output.model_recommendation,
                "estimated_tokens": prompt_output.estimated_tokens,
            },
        )

    # ───────────────────────────────────────────────────
    # Internal: OpenAI call
    # ───────────────────────────────────────────────────

    async def _call_openai(
        self,
        messages: list[dict],
        model: str,
        mode: SafetyMode,
    ) -> str:
        """
        OpenAI çağrısı. Mode'a göre temperature ayarlar.
        Timeout: high_risk'te daha uzun verilir (yanıt önemli).
        """
        temperature = {
            SafetyMode.NORMAL: 0.7,
            SafetyMode.SENSITIVE: 0.5,
            SafetyMode.HIGH_RISK: 0.3,
        }.get(mode, 0.7)

        timeout = 30.0 if mode == SafetyMode.HIGH_RISK else 15.0

        completion = await asyncio.wait_for(
            self.openai_client.chat.completions.create(
                model=model,
                messages=messages,
                temperature=temperature,
                max_tokens=300,  # Cevaplar kısa olmalı (PRD §11)
            ),
            timeout=timeout,
        )

        return (completion.choices[0].message.content or "").strip()

    # ───────────────────────────────────────────────────
    # Response helpers
    # ───────────────────────────────────────────────────

    def _limit_reached_response(self, decision: Decision) -> CoachResponse:
        """Kullanım limiti dolmuş — PRD §10.2."""
        if decision.locale == "en":
            text = (
                "You've used today's coach replies. Tomorrow they reset, "
                "or premium gives you more depth."
                if decision.premium_state == PremiumState.FREE
                else "You've reached today's limit. Tomorrow we continue."
            )
        else:
            text = (
                "Bugünkü koç haklarını kullandın. Yarın yeniden açılıyor, "
                "ya da premium daha derin bir deneyim sunuyor."
                if decision.premium_state == PremiumState.FREE
                else "Bugünkü limiti tamamladın. Yarın yine konuşuruz."
            )

        return CoachResponse(
            text=text,
            mode=decision.safety_mode.value,
            persona=decision.persona.value,
            surface=decision.surface.value,
            is_fallback=False,
            error_code="limit_reached",
            show_premium_upsell=decision.show_premium_upsell,
            usage_remaining=0,
        )

    def _fallback_response(
        self,
        decision: Decision,
        reason: str,
    ) -> CoachResponse:
        """AI/safety başarısız — fallback metin."""
        text = self.fallback_copy_service.get(
            persona=decision.persona,
            surface=decision.surface,
            locale=decision.locale,
            safety_mode=decision.safety_mode,
        )
        # Fallback'te usage SAYAÇLAMAYIZ (kullanıcı hak yanmasın — PRD §10.1)
        return CoachResponse(
            text=text,
            mode=decision.safety_mode.value,
            persona=decision.persona.value,
            surface=decision.surface.value,
            is_fallback=True,
            fallback_reason=reason,
            show_resources=self.safety_service.should_show_resources(
                decision.safety_mode
            ),
            metadata={"fallback_reason": reason},
        )
