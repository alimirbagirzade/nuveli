"""
backend/app/services/decision_engine.py

Decision Engine — AI çağrısından önce her şeyi çözer.
PRD §7.2 Ortak AI boru hattı, §11 AI Protokolleri.

Sorumluluğu:
1. Kullanıcının safety_mode'unu belirle (normal / sensitive / high_risk)
2. Persona seç (kullanıcı tercihi + safety mode override)
3. Premium state'i çöz (free / trial / premium)
4. Usage limit kontrolü (PRD §4.3 feature gating)
5. Surface'ı belirle (home_card, chat_response, weekly_summary, ...)

Bu engine HİÇBİR AI çağrısı yapmaz. Sadece kararları döner.
Prompt Engine ve Coach Service bu kararları kullanır.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta
from enum import Enum
from typing import Optional
import logging

from supabase import Client as SupabaseClient

logger = logging.getLogger(__name__)


# ═══════════════════════════════════════════════════════════════
# Tipler
# ═══════════════════════════════════════════════════════════════

class SafetyMode(str, Enum):
    NORMAL = "normal"
    SENSITIVE = "sensitive"
    HIGH_RISK = "high_risk"


class PremiumState(str, Enum):
    FREE = "free"
    TRIAL = "trial"
    PREMIUM = "premium"
    EXPIRED = "expired"


class CoachPersona(str, Enum):
    GENTLE = "gentle"      # nazik
    FUNNY = "funny"        # komik
    DIRECT = "direct"      # direkt
    CALM = "calm"          # sakin


class Surface(str, Enum):
    HOME_CARD = "home_card"
    CHAT_RESPONSE = "chat_response"
    MEAL_REACTION = "meal_reaction"
    WEEKLY_SUMMARY = "weekly_summary"
    EMPTY_DAY = "empty_day"
    RECOVERY_DAY = "recovery_day"
    CELEBRATION = "celebration"


# Feature limits (PRD §4.3)
FEATURE_LIMITS = {
    PremiumState.FREE: {
        "meal_photo_analysis": 1,
        "coach_text_response": 3,
        "coach_voice_response": 1,
    },
    PremiumState.TRIAL: {
        # Trial: tam deneyim ama arka planda adil kullanım koruması
        "meal_photo_analysis": 15,
        "coach_text_response": 40,
        "coach_voice_response": 15,
    },
    PremiumState.PREMIUM: {
        "meal_photo_analysis": 10,
        "coach_text_response": 30,
        "coach_voice_response": 10,
    },
    PremiumState.EXPIRED: {
        # Expired premium = free limitleri (PRD §6.4)
        "meal_photo_analysis": 1,
        "coach_text_response": 3,
        "coach_voice_response": 1,
    },
}


@dataclass
class Decision:
    """AI çağrısı öncesi resolve edilmiş tüm kararlar."""

    user_id: str
    surface: Surface

    safety_mode: SafetyMode
    safety_reason: Optional[str]  # mode neden seçildi (audit için)

    persona: CoachPersona
    locale: str  # 'tr' | 'en'

    premium_state: PremiumState
    is_in_trial_window: bool  # Day 0-6 trial?

    # Usage gate
    usage_ok: bool
    usage_feature: Optional[str]
    usage_count_today: int
    usage_limit_today: int

    # Premium upsell gösterilmeli mi?
    # PRD §6.4: yüksek risk veya hassas mod aninda upsell GÖSTERİLMEZ
    show_premium_upsell: bool

    # Day 2 trial gift gösterilmeli mi?
    show_day2_gift: bool

    # Kontekst (prompt engine'e geçer)
    user_context: dict = field(default_factory=dict)

    def __str__(self) -> str:
        return (
            f"Decision(user={self.user_id[:8]}, surface={self.surface.value}, "
            f"mode={self.safety_mode.value}, persona={self.persona.value}, "
            f"premium={self.premium_state.value}, usage_ok={self.usage_ok})"
        )


# ═══════════════════════════════════════════════════════════════
# Engine
# ═══════════════════════════════════════════════════════════════

class DecisionEngine:
    def __init__(self, db: SupabaseClient):
        self.db = db

    async def resolve(
        self,
        user_id: str,
        surface: Surface,
        feature_key: Optional[str] = None,
    ) -> Decision:
        """
        Kullanıcı için bir AI çağrısı kararını çözer.

        Args:
            user_id: Auth user UUID
            surface: Hangi yüzeyden çağrı geliyor
            feature_key: Hangi feature için limit kontrolü yapılacak.
                         None ise usage_ok=True döner (limit kontrolü atla).
        """
        # 1. Profil + tercihler
        profile = self._fetch_profile(user_id)
        coach_prefs = self._fetch_coach_prefs(user_id)
        safety_flags = self._fetch_safety_flags(user_id)

        # 2. Safety mode
        safety_mode, safety_reason = self._compute_safety_mode(
            profile, safety_flags
        )

        # 3. Persona (safety mode override eder)
        persona = self._resolve_persona(coach_prefs, safety_mode)

        # 4. Premium state
        premium_state, in_trial_window = self._fetch_premium_state(user_id)

        # 5. Usage check
        usage_ok = True
        usage_count = 0
        usage_limit = 0
        if feature_key:
            usage_count, usage_limit = self._check_usage(
                user_id, feature_key, premium_state
            )
            usage_ok = usage_count < usage_limit

        # 6. Premium upsell mantığı (PRD §6.4)
        show_upsell = self._should_show_upsell(
            safety_mode, premium_state, surface
        )

        # 7. Day 2 trial gift (PRD §6.4)
        show_day2 = self._should_show_day2_gift(
            user_id, profile, premium_state
        )

        # 8. User context (prompt engine'e geçer)
        ctx = self._build_user_context(profile, coach_prefs, safety_flags)

        return Decision(
            user_id=user_id,
            surface=surface,
            safety_mode=safety_mode,
            safety_reason=safety_reason,
            persona=persona,
            locale=profile.get("locale", "tr") if profile else "tr",
            premium_state=premium_state,
            is_in_trial_window=in_trial_window,
            usage_ok=usage_ok,
            usage_feature=feature_key,
            usage_count_today=usage_count,
            usage_limit_today=usage_limit,
            show_premium_upsell=show_upsell,
            show_day2_gift=show_day2,
            user_context=ctx,
        )

    # ───────────────────────────────────────────────────
    # Safety mode
    # ───────────────────────────────────────────────────

    def _compute_safety_mode(
        self,
        profile: Optional[dict],
        flags: Optional[dict],
    ) -> tuple[SafetyMode, Optional[str]]:
        """
        PRD §11.1, §16.3
        Karar sırası:
        1. flags.current_mode varsa kullan
        2. Profil hassas (hamilelik / kronik / yeme bozukluğu) → sensitive
        3. Hedef agresif mi? → sensitive
        4. Default → normal
        """
        if flags and flags.get("current_mode"):
            mode = flags["current_mode"]
            return SafetyMode(mode), flags.get("mode_reason")

        if flags:
            if flags.get("has_eating_disorder_history"):
                return SafetyMode.HIGH_RISK, "eating_disorder_history"
            if flags.get("has_pregnancy") or flags.get("has_chronic_condition"):
                return SafetyMode.SENSITIVE, "special_health_situation"

        if profile:
            target_kg_per_week = profile.get("target_weight_loss_per_week_kg")
            if target_kg_per_week and target_kg_per_week > 1.0:
                # PRD §11.3: Agresif hedefleri onaylama
                return SafetyMode.SENSITIVE, "aggressive_target"

            calorie_target = profile.get("daily_calorie_target")
            if calorie_target and calorie_target < 1200:
                return SafetyMode.HIGH_RISK, "very_low_calorie_target"

        return SafetyMode.NORMAL, None

    def _resolve_persona(
        self,
        coach_prefs: Optional[dict],
        safety_mode: SafetyMode,
    ) -> CoachPersona:
        """
        Yüksek risk modda persona override:
        - high_risk: her zaman 'calm' (PRD §11.1)
        - sensitive: 'funny' personayı 'gentle'a çevir
        - normal: kullanıcı tercihi
        """
        user_choice = CoachPersona(
            (coach_prefs or {}).get("persona", "gentle")
        )

        if safety_mode == SafetyMode.HIGH_RISK:
            return CoachPersona.CALM
        if safety_mode == SafetyMode.SENSITIVE and user_choice == CoachPersona.FUNNY:
            return CoachPersona.GENTLE

        return user_choice

    # ───────────────────────────────────────────────────
    # Premium
    # ───────────────────────────────────────────────────

    def _fetch_premium_state(
        self, user_id: str
    ) -> tuple[PremiumState, bool]:
        """premium_status_cache'ten okur."""
        try:
            res = (
                self.db.table("premium_status_cache")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            if not res.data:
                return PremiumState.FREE, False

            status = PremiumState(res.data["status"])
            in_trial = False
            trial_end = res.data.get("trial_ends_at")
            if status == PremiumState.TRIAL and trial_end:
                in_trial = datetime.fromisoformat(
                    trial_end.replace("Z", "+00:00")
                ) > datetime.now().astimezone()
            return status, in_trial
        except Exception as e:
            logger.warning("premium_status_cache fetch failed: %s", e)
            return PremiumState.FREE, False

    def _check_usage(
        self,
        user_id: str,
        feature_key: str,
        premium_state: PremiumState,
    ) -> tuple[int, int]:
        """
        Bugünkü kullanım sayısını ve limiti döner.
        PRD §9.6: timezone'a göre sıfırlanır → kullanıcı timezone'unu profile'dan al
        Şimdilik UTC date kullanıyoruz; Sprint 2'de timezone-aware'a çevrilecek.
        """
        limit = FEATURE_LIMITS.get(premium_state, {}).get(feature_key, 0)
        if limit == 0:
            return 0, 0

        today = date.today().isoformat()
        try:
            res = (
                self.db.table("usage_counters_daily")
                .select("count")
                .eq("user_id", user_id)
                .eq("usage_date", today)
                .eq("feature", feature_key)
                .maybe_single()
                .execute()
            )
            count = (res.data or {}).get("count", 0)
            return count, limit
        except Exception as e:
            logger.warning("usage counter fetch failed: %s", e)
            # Fail-safe: hatada kullanıcıyı bloklama
            return 0, limit

    def _should_show_upsell(
        self,
        safety_mode: SafetyMode,
        premium_state: PremiumState,
        surface: Surface,
    ) -> bool:
        """PRD §6.4, §10.1: high_risk veya sensitive'da upsell yok."""
        if safety_mode in (SafetyMode.HIGH_RISK, SafetyMode.SENSITIVE):
            return False
        if premium_state in (PremiumState.TRIAL, PremiumState.PREMIUM):
            return False
        # Recovery day'de upsell yok (PRD §5.4: retention duvarı, premium duvarı değil)
        if surface == Surface.RECOVERY_DAY:
            return False
        return True

    def _should_show_day2_gift(
        self,
        user_id: str,
        profile: Optional[dict],
        premium_state: PremiumState,
    ) -> bool:
        """
        PRD §6.4: Day 2 hediye trial.
        Koşullar:
        - Kullanıcı henüz trial başlatmamış
        - Hesap 1-3 günlük arası
        - Day2 gift daha önce sunulmamış
        """
        if premium_state != PremiumState.FREE:
            return False
        if not profile:
            return False
        created_at = profile.get("created_at")
        if not created_at:
            return False

        try:
            created = datetime.fromisoformat(
                created_at.replace("Z", "+00:00")
            )
            days_since = (datetime.now().astimezone() - created).days
            if days_since < 1 or days_since > 3:
                return False

            # premium_status_cache'te day2_gift_offered_at kontrolü
            res = (
                self.db.table("premium_status_cache")
                .select("day2_gift_offered_at")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            if res.data and res.data.get("day2_gift_offered_at"):
                return False
            return True
        except Exception as e:
            logger.warning("day2 gift check failed: %s", e)
            return False

    # ───────────────────────────────────────────────────
    # Data fetch helpers
    # ───────────────────────────────────────────────────

    def _fetch_profile(self, user_id: str) -> Optional[dict]:
        try:
            res = (
                self.db.table("profiles")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            return res.data
        except Exception as e:
            logger.warning("profile fetch failed: %s", e)
            return None

    def _fetch_coach_prefs(self, user_id: str) -> Optional[dict]:
        try:
            res = (
                self.db.table("coach_preferences")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            return res.data
        except Exception as e:
            logger.warning("coach_preferences fetch failed: %s", e)
            return None

    def _fetch_safety_flags(self, user_id: str) -> Optional[dict]:
        try:
            res = (
                self.db.table("safety_flags")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            return res.data
        except Exception as e:
            logger.warning("safety_flags fetch failed: %s", e)
            return None

    def _build_user_context(
        self,
        profile: Optional[dict],
        coach_prefs: Optional[dict],
        flags: Optional[dict],
    ) -> dict:
        """Prompt engine'e geçecek özet bağlam (PII minimize)."""
        if not profile:
            return {}
        return {
            "first_name": profile.get("first_name"),
            "goal_type": profile.get("goal_type"),  # 'lose' | 'maintain' | 'gain'
            "daily_calorie_target": profile.get("daily_calorie_target"),
            "humor_level": (coach_prefs or {}).get("humor_level", "medium"),
            "voice_tone": (coach_prefs or {}).get("voice_tone", "warm"),
            "has_special_situation": bool(
                (flags or {}).get("has_pregnancy")
                or (flags or {}).get("has_chronic_condition")
            ),
        }

    # ───────────────────────────────────────────────────
    # Public helpers (route'lar bunları doğrudan çağırabilir)
    # ───────────────────────────────────────────────────

    async def increment_usage(
        self, user_id: str, feature_key: str
    ) -> None:
        """
        Başarılı bir AI çağrısından sonra sayacı artır.
        Atomic upsert.
        """
        today = date.today().isoformat()
        try:
            # Postgres ON CONFLICT ile upsert + increment
            self.db.rpc(
                "increment_usage_counter",
                {
                    "p_user_id": user_id,
                    "p_date": today,
                    "p_feature": feature_key,
                },
            ).execute()
        except Exception as e:
            # RPC yoksa fallback: SELECT + UPDATE/INSERT
            logger.info(
                "increment_usage_counter RPC unavailable, using fallback: %s", e
            )
            self._increment_usage_fallback(user_id, feature_key, today)

    def _increment_usage_fallback(
        self, user_id: str, feature_key: str, usage_date: str
    ) -> None:
        try:
            existing = (
                self.db.table("usage_counters_daily")
                .select("id, count")
                .eq("user_id", user_id)
                .eq("usage_date", usage_date)
                .eq("feature", feature_key)
                .maybe_single()
                .execute()
            )
            if existing.data:
                self.db.table("usage_counters_daily").update(
                    {"count": existing.data["count"] + 1}
                ).eq("id", existing.data["id"]).execute()
            else:
                self.db.table("usage_counters_daily").insert(
                    {
                        "user_id": user_id,
                        "usage_date": usage_date,
                        "feature": feature_key,
                        "count": 1,
                    }
                ).execute()
        except Exception as e:
            logger.error("usage counter increment failed: %s", e)
