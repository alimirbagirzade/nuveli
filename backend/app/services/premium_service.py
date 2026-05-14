"""
backend/app/services/premium_service.py

Premium Service — RevenueCat webhook + sync handler.
PRD §7.2 Premium backend logic, §9.6 source of truth RevenueCat'tir.

Endpoints (routes/premium.py'da expose):
- POST /premium/sync — App'ten gelen client-side sync
- POST /premium/webhook — RevenueCat → backend webhook
- GET /premium/status — premium_status_cache'ten okur
- GET /premium/features — feature matrix
- GET /premium/day2-gift-status — Day 2 hediye trial uygun mu?
- POST /premium/day2-gift-claim — kullanıcı hediyeyi aldı, mark
- GET /usage/today — bugünkü kullanım
"""

from __future__ import annotations
from dataclasses import dataclass
from datetime import datetime, timezone, timedelta
from typing import Optional
import hashlib
import hmac
import logging

from supabase import Client as SupabaseClient

from ..core.config import settings

logger = logging.getLogger(__name__)


# Feature matrix (PRD §4.3) — frontend bunu /premium/features endpoint'inden çeker
FEATURE_MATRIX = {
    "free": {
        "meal_photo_analysis_per_day": 1,
        "coach_text_per_day": 3,
        "coach_voice_per_day": 1,
        "weekly_summary": "mini",
        "monthly_insights": "basic",
        "personas": "limited",
        "early_crisis_warning": False,
        "csv_export": False,
    },
    "trial": {
        "meal_photo_analysis_per_day": 15,
        "coach_text_per_day": 40,
        "coach_voice_per_day": 15,
        "weekly_summary": "full",
        "monthly_insights": "advanced",
        "personas": "full",
        "early_crisis_warning": True,
        "csv_export": True,
    },
    "premium": {
        "meal_photo_analysis_per_day": 10,
        "coach_text_per_day": 30,
        "coach_voice_per_day": 10,
        "weekly_summary": "full",
        "monthly_insights": "advanced",
        "personas": "full",
        "early_crisis_warning": True,
        "csv_export": True,
    },
    "expired": {
        # Expired = free + premium preview kartları gösterilir (PRD §6.4)
        "meal_photo_analysis_per_day": 1,
        "coach_text_per_day": 3,
        "coach_voice_per_day": 1,
        "weekly_summary": "mini",
        "monthly_insights": "basic",
        "personas": "limited",
        "early_crisis_warning": False,
        "csv_export": False,
        "show_preview_cards": True,
    },
}


@dataclass
class PremiumSyncPayload:
    rc_customer_id: str
    active_entitlement_ids: list[str]
    active_product_id: Optional[str]
    expiration_date: Optional[str]      # ISO string
    period_type: Optional[str]          # 'normal' | 'trial' | 'intro'

    @classmethod
    def from_dict(cls, d: dict) -> "PremiumSyncPayload":
        return cls(
            rc_customer_id=d.get("rc_customer_id", ""),
            active_entitlement_ids=d.get("active_entitlement_ids", []),
            active_product_id=d.get("active_product_id"),
            expiration_date=d.get("expiration_date"),
            period_type=d.get("period_type"),
        )

    def to_status(self) -> str:
        if not self.active_entitlement_ids:
            return "free"
        if self.period_type == "trial":
            return "trial"
        return "premium"


class PremiumService:
    def __init__(self, db: SupabaseClient, webhook_secret: str = ""):
        self.db = db
        self.webhook_secret = webhook_secret

    # ───────────────────────────────────────────────────
    # Client sync (app → backend)
    # ───────────────────────────────────────────────────

    async def sync_from_client(
        self, user_id: str, payload: PremiumSyncPayload
    ) -> dict:
        """App, satın alma sonrası bunu çağırır."""
        status = payload.to_status()
        expires_at = self._parse_iso(payload.expiration_date)

        record = {
            "user_id": user_id,
            "status": status,
            "rc_customer_id": payload.rc_customer_id,
            "entitlement_id": (
                payload.active_entitlement_ids[0]
                if payload.active_entitlement_ids
                else None
            ),
            "product_id": payload.active_product_id,
            "current_period_end": expires_at.isoformat() if expires_at else None,
            "trial_ends_at": (
                expires_at.isoformat()
                if expires_at and status == "trial"
                else None
            ),
            "trial_started_at": (
                datetime.now(timezone.utc).isoformat()
                if status == "trial"
                else None
            ),
            "last_synced_at": datetime.now(timezone.utc).isoformat(),
            "raw_payload": {
                "active_entitlement_ids": payload.active_entitlement_ids,
                "period_type": payload.period_type,
            },
        }

        try:
            self.db.table("premium_status_cache").upsert(
                record, on_conflict="user_id"
            ).execute()
        except Exception as e:
            logger.error("Premium sync upsert failed: %s", e)
            raise

        return {
            "status": status,
            "expires_at": expires_at.isoformat() if expires_at else None,
            "synced_at": record["last_synced_at"],
        }

    # ───────────────────────────────────────────────────
    # Status read
    # ───────────────────────────────────────────────────

    async def get_status(self, user_id: str) -> dict:
        # Lifetime premium allowlist check (env var: LIFETIME_PREMIUM_EMAILS)
        # Bu listedeki email'ler ödeme yapmadan premium gibi davranır.
        if settings.lifetime_premium_emails:
            try:
                user_resp = self.db.auth.admin.get_user_by_id(user_id)
                user_email = (user_resp.user.email or "").lower() if user_resp and user_resp.user else None
                if user_email and user_email in settings.lifetime_premium_emails:
                    logger.info("Lifetime premium grant: %s", user_email)
                    return {
                        "status": "premium",
                        "is_premium": True,
                        "trial_ends_at": None,
                        "current_period_end": None,
                        "active_product_id": None,
                        "source": "lifetime_grant",
                    }
            except Exception as e:
                logger.warning("Lifetime premium check failed (falling through): %s", e)

        try:
            res = (
                self.db.table("premium_status_cache")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            if not res.data:
                return {
                    "status": "free",
                    "is_premium": False,
                    "trial_ends_at": None,
                    "current_period_end": None,
                }

            data = res.data
            status = data.get("status", "free")

            # Expired kontrolü
            current_end = self._parse_iso(data.get("current_period_end"))
            if (
                status in ("trial", "premium")
                and current_end
                and current_end < datetime.now(timezone.utc)
            ):
                status = "expired"
                # Cache'i güncelle (background'da)
                try:
                    self.db.table("premium_status_cache").update(
                        {"status": "expired"}
                    ).eq("user_id", user_id).execute()
                except Exception:
                    pass

            return {
                "status": status,
                "is_premium": status in ("trial", "premium"),
                "trial_ends_at": data.get("trial_ends_at"),
                "current_period_end": data.get("current_period_end"),
                "active_product_id": data.get("product_id"),
            }
        except Exception as e:
            logger.error("Premium status fetch failed: %s", e)
            # Fail-open: hatada free dön
            return {"status": "free", "is_premium": False}

    async def get_features(self, user_id: str) -> dict:
        status = (await self.get_status(user_id))["status"]
        return {
            "status": status,
            "features": FEATURE_MATRIX.get(status, FEATURE_MATRIX["free"]),
        }

    # ───────────────────────────────────────────────────
    # Webhook (RevenueCat → backend)
    # ───────────────────────────────────────────────────

    def verify_webhook_signature(
        self, raw_body: bytes, header_signature: str
    ) -> bool:
        """RevenueCat webhook signature doğrulaması."""
        if not self.webhook_secret:
            logger.warning("Webhook secret not configured, skipping verification")
            return True  # Dev mode

        expected = hmac.new(
            self.webhook_secret.encode("utf-8"),
            raw_body,
            hashlib.sha256,
        ).hexdigest()
        return hmac.compare_digest(expected, header_signature or "")

    async def handle_webhook(self, event: dict) -> dict:
        """RevenueCat webhook event handler.

        Event types:
        - INITIAL_PURCHASE
        - RENEWAL
        - CANCELLATION
        - EXPIRATION
        - BILLING_ISSUE
        - PRODUCT_CHANGE
        - SUBSCRIBER_ALIAS
        """
        event_type = event.get("event", {}).get("type")
        app_user_id = event.get("event", {}).get("app_user_id")

        if not app_user_id:
            logger.warning("Webhook event missing app_user_id: %s", event_type)
            return {"handled": False, "reason": "missing_user_id"}

        logger.info("RC webhook: %s for user=%s", event_type, app_user_id[:8])

        if event_type in (
            "INITIAL_PURCHASE",
            "RENEWAL",
            "PRODUCT_CHANGE",
            "UNCANCELLATION",
        ):
            await self._mark_active(event, app_user_id)
        elif event_type == "CANCELLATION":
            # Kullanıcı iptal etti AMA dönem sonuna kadar premium kalabilir
            await self._mark_cancelled(event, app_user_id)
        elif event_type == "EXPIRATION":
            await self._mark_expired(app_user_id)
        elif event_type == "BILLING_ISSUE":
            await self._mark_billing_issue(app_user_id)

        return {"handled": True, "event_type": event_type}

    async def _mark_active(self, event: dict, user_id: str):
        ev = event.get("event", {})
        period_type = ev.get("period_type", "NORMAL").lower()
        status = "trial" if period_type == "trial" else "premium"
        expires_ms = ev.get("expiration_at_ms")
        expires_at = (
            datetime.fromtimestamp(expires_ms / 1000, tz=timezone.utc)
            if expires_ms
            else None
        )

        self.db.table("premium_status_cache").upsert(
            {
                "user_id": user_id,
                "status": status,
                "rc_customer_id": user_id,
                "entitlement_id": ev.get("entitlement_id"),
                "product_id": ev.get("product_id"),
                "current_period_end": expires_at.isoformat() if expires_at else None,
                "trial_ends_at": expires_at.isoformat()
                if expires_at and status == "trial"
                else None,
                "last_synced_at": datetime.now(timezone.utc).isoformat(),
                "raw_payload": event,
            },
            on_conflict="user_id",
        ).execute()

    async def _mark_cancelled(self, event: dict, user_id: str):
        # Cancellation = auto-renew off, ama dönem sonuna kadar geçerli
        # Status'u şimdilik korur, EXPIRATION geldiğinde expired'a düşer
        logger.info("Cancellation noted for user=%s, awaiting expiration", user_id[:8])

    async def _mark_expired(self, user_id: str):
        self.db.table("premium_status_cache").update(
            {
                "status": "expired",
                "last_synced_at": datetime.now(timezone.utc).isoformat(),
            }
        ).eq("user_id", user_id).execute()

    async def _mark_billing_issue(self, user_id: str):
        # Premium hak yanmaz — grace period
        logger.warning("Billing issue for user=%s", user_id[:8])

    # ───────────────────────────────────────────────────
    # Day 2 trial gift
    # ───────────────────────────────────────────────────

    async def is_day2_gift_eligible(self, user_id: str) -> bool:
        """PRD §6.4: Day 2 hediye trial koşulları."""
        try:
            # Profile created_at
            profile_res = (
                self.db.table("profiles")
                .select("created_at")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            if not profile_res.data:
                return False
            created_at = self._parse_iso(profile_res.data.get("created_at"))
            if not created_at:
                return False

            days_since = (datetime.now(timezone.utc) - created_at).days
            if days_since < 1 or days_since > 3:
                return False

            # Daha önce sunulmuş mu? + premium değilse
            premium_res = (
                self.db.table("premium_status_cache")
                .select("status, day2_gift_offered_at")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            if premium_res.data:
                if premium_res.data.get("status") in ("trial", "premium"):
                    return False
                if premium_res.data.get("day2_gift_offered_at"):
                    return False

            return True
        except Exception as e:
            logger.warning("Day2 gift eligibility check failed: %s", e)
            return False

    async def mark_day2_gift_offered(self, user_id: str):
        """Modal gösterildiğinde çağır."""
        try:
            self.db.table("premium_status_cache").upsert(
                {
                    "user_id": user_id,
                    "status": "free",
                    "day2_gift_offered_at": datetime.now(timezone.utc).isoformat(),
                    "last_synced_at": datetime.now(timezone.utc).isoformat(),
                },
                on_conflict="user_id",
            ).execute()
        except Exception as e:
            logger.error("Day2 gift mark failed: %s", e)

    async def mark_day2_gift_claimed(self, user_id: str):
        try:
            self.db.table("premium_status_cache").update(
                {
                    "day2_gift_claimed_at": datetime.now(timezone.utc).isoformat(),
                    "last_synced_at": datetime.now(timezone.utc).isoformat(),
                }
            ).eq("user_id", user_id).execute()
        except Exception as e:
            logger.error("Day2 gift claim mark failed: %s", e)

    # ───────────────────────────────────────────────────
    # Usage today
    # ───────────────────────────────────────────────────

    async def get_usage_today(self, user_id: str) -> dict:
        """Bugünkü kullanım + limitler. PRD §4.3 + §9.6."""
        from datetime import date as _date
        today = _date.today().isoformat()

        status_data = await self.get_status(user_id)
        status = status_data["status"]
        limits = FEATURE_MATRIX.get(status, FEATURE_MATRIX["free"])

        try:
            res = (
                self.db.table("usage_counters_daily")
                .select("feature, count")
                .eq("user_id", user_id)
                .eq("usage_date", today)
                .execute()
            )
            counts = {row["feature"]: row["count"] for row in (res.data or [])}
        except Exception as e:
            logger.warning("Usage fetch failed: %s", e)
            counts = {}

        return {
            "date": today,
            "status": status,
            "usage": {
                "meal_photo_analysis": {
                    "used": counts.get("meal_photo_analysis", 0),
                    "limit": limits.get("meal_photo_analysis_per_day", 0),
                },
                "coach_text_response": {
                    "used": counts.get("coach_text_response", 0),
                    "limit": limits.get("coach_text_per_day", 0),
                },
                "coach_voice_response": {
                    "used": counts.get("coach_voice_response", 0),
                    "limit": limits.get("coach_voice_per_day", 0),
                },
            },
        }

    # ───────────────────────────────────────────────────
    # Helpers
    # ───────────────────────────────────────────────────

    def _parse_iso(self, s: Optional[str]) -> Optional[datetime]:
        if not s:
            return None
        try:
            return datetime.fromisoformat(s.replace("Z", "+00:00"))
        except Exception:
            return None
