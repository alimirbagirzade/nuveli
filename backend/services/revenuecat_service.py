# backend/services/revenuecat_service.py
#
# RevenueCat REST API client.
# Webhook handler bu service'i kullanarak event'in gerçekliğini doğrular
# ve subscriber bilgilerini RC'den taze çekebilir.
#
# Dokümantasyon: https://www.revenuecat.com/docs/api-v1

from __future__ import annotations

import logging
import os
from datetime import datetime, timezone
from typing import Any

import httpx
from pydantic import BaseModel

logger = logging.getLogger(__name__)


class SubscriberSnapshot(BaseModel):
    """RC subscriber endpoint'inden gelen veriyi normalize ettiğimiz model."""

    app_user_id: str
    is_premium: bool
    expires_at: datetime | None
    product_id: str | None
    platform: str | None  # app_store / play_store / stripe
    is_in_trial: bool = False
    will_renew: bool = True
    original_app_user_id: str | None = None


class RevenueCatService:
    """
    Subset of the RC REST API we actually need.

    Auth: secret API key (NOT the public mobile keys).
    Bu key RevenueCat dashboard → Project Settings → API Keys → "Secret API Key"
    altından alınır. Backend'de RC_SECRET_API_KEY olarak saklanır.
    """

    BASE_URL = "https://api.revenuecat.com/v1"
    ENTITLEMENT_ID = "premium"

    def __init__(
        self,
        secret_api_key: str | None = None,
        timeout: float = 10.0,
    ) -> None:
        self.secret_api_key = secret_api_key or os.environ.get(
            "RC_SECRET_API_KEY"
        )
        if not self.secret_api_key:
            raise RuntimeError(
                "RC_SECRET_API_KEY not set. "
                "Get it from RevenueCat dashboard → API Keys → Secret."
            )
        self.timeout = timeout

    @property
    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self.secret_api_key}",
            "Content-Type": "application/json",
            "X-Platform": "server",
        }

    # ────────────────────────────────────────────────────────
    # Subscriber lookup
    # ────────────────────────────────────────────────────────

    async def get_subscriber(self, app_user_id: str) -> SubscriberSnapshot | None:
        """
        RC'den subscriber'ın güncel durumunu çek.

        Webhook gecikmesinden şüphelenildiğinde veya manuel sync gerektiğinde
        kullanılır. Webhook'un kendisinde GENELDE kullanmayız (event payload
        zaten yeterli bilgiyi içerir).
        """
        url = f"{self.BASE_URL}/subscribers/{app_user_id}"
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            try:
                res = await client.get(url, headers=self._headers)
            except httpx.HTTPError as e:
                logger.error("RC API call failed: %s", e)
                return None

        if res.status_code == 404:
            logger.info("RC subscriber not found: %s", app_user_id)
            return None
        if res.status_code != 200:
            logger.error(
                "RC API returned %s: %s", res.status_code, res.text[:200]
            )
            return None

        return self._parse_subscriber(res.json(), app_user_id)

    def _parse_subscriber(
        self, payload: dict[str, Any], app_user_id: str
    ) -> SubscriberSnapshot:
        sub = payload.get("subscriber", {})
        entitlements = sub.get("entitlements", {}) or {}
        premium_ent = entitlements.get(self.ENTITLEMENT_ID)

        if not premium_ent:
            return SubscriberSnapshot(
                app_user_id=app_user_id,
                is_premium=False,
                expires_at=None,
                product_id=None,
                platform=None,
                original_app_user_id=sub.get("original_app_user_id"),
            )

        expires_at = self._parse_ts(premium_ent.get("expires_date"))
        is_premium = expires_at is None or expires_at > datetime.now(timezone.utc)
        product_id = premium_ent.get("product_identifier")
        platform = self._detect_platform(sub, product_id)

        # Subscription detayı (will_renew, trial info)
        subs = sub.get("subscriptions", {}) or {}
        sub_detail = subs.get(product_id, {}) if product_id else {}
        will_renew = not sub_detail.get("unsubscribe_detected_at")
        is_in_trial = sub_detail.get("period_type") == "trial"

        return SubscriberSnapshot(
            app_user_id=app_user_id,
            is_premium=is_premium,
            expires_at=expires_at,
            product_id=product_id,
            platform=platform,
            is_in_trial=is_in_trial,
            will_renew=will_renew,
            original_app_user_id=sub.get("original_app_user_id"),
        )

    @staticmethod
    def _parse_ts(s: str | None) -> datetime | None:
        if not s:
            return None
        try:
            return datetime.fromisoformat(s.replace("Z", "+00:00"))
        except (ValueError, AttributeError):
            return None

    @staticmethod
    def _detect_platform(sub: dict, product_id: str | None) -> str | None:
        """Subscriber payload'undan platform ipucu çıkar."""
        if not product_id:
            return None
        non_subs = sub.get("non_subscriptions", {}).get(product_id, [])
        subs = sub.get("subscriptions", {}).get(product_id, {})
        store = (
            (non_subs[0].get("store") if non_subs else None)
            or subs.get("store")
        )
        return {
            "app_store": "app_store",
            "play_store": "play_store",
            "stripe": "stripe",
        }.get(store)


# ────────────────────────────────────────────────────────────
# Dependency injection helper (FastAPI)
# ────────────────────────────────────────────────────────────

_service: RevenueCatService | None = None


def get_revenuecat_service() -> RevenueCatService:
    """FastAPI dependency. Lazy init singleton."""
    global _service
    if _service is None:
        _service = RevenueCatService()
    return _service
