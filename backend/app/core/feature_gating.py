"""
backend/app/core/feature_gating.py

Feature Gating — endpoint dekoratörleri ve dependency'ler.
PRD §4.3 Feature gating, §6 Premium psikolojisi.

Kullanım:
    @router.post("/meals/analyze")
    async def analyze_meal(
        body: ...,
        user_id: str = Depends(get_current_user_id),
        _gate = Depends(require_feature("meal_photo_analysis")),
    ):
        ...

Eğer limit aşıldıysa HTTP 402 (Payment Required) atılır:
{
  "error_code": "limit_reached",
  "feature": "meal_photo_analysis",
  "used_today": 1,
  "limit_today": 1,
  "premium_status": "free",
  "message": "Bugün için fotoğraf analizi hakkın doldu. Yarın yenileniyor."
}
"""

from __future__ import annotations
from typing import Callable, Optional
import logging

from fastapi import Depends, HTTPException, Request, status
from fastapi.responses import JSONResponse

from app.core.dependencies import get_current_user_id, get_premium_service
from app.services.premium_service import PremiumService, FEATURE_MATRIX

logger = logging.getLogger(__name__)


# Feature key → feature_matrix limit_key mapping
LIMIT_KEY_MAP = {
    "meal_photo_analysis": "meal_photo_analysis_per_day",
    "coach_text_response": "coach_text_per_day",
    "coach_voice_response": "coach_voice_per_day",
}


class LimitReachedException(HTTPException):
    """402 Payment Required."""

    def __init__(self, feature: str, used: int, limit: int, status_str: str):
        message = (
            f"Bugün için {feature} hakkın doldu. Yarın yenileniyor."
            if status_str == "free"
            else f"Bugünkü limiti tamamladın ({used}/{limit}). Yarın devam ederiz."
        )
        super().__init__(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail={
                "error_code": "limit_reached",
                "feature": feature,
                "used_today": used,
                "limit_today": limit,
                "premium_status": status_str,
                "message": message,
            },
        )


def require_feature(feature_key: str) -> Callable:
    """
    Endpoint decorator factory. Limit aşılmışsa 402 atar.
    Atmıyorsa istek devam eder; başarılı dönerse SAYACINI ARTIRMAK
    endpoint'in sorumluluğundadır (genellikle service içinde).

    Bu fonksiyon DI sırasında çağrılır → endpoint başına bir kez resolve.
    """

    async def dependency(
        user_id: str = Depends(get_current_user_id),
        premium: PremiumService = Depends(get_premium_service),
    ):
        usage_today = await premium.get_usage_today(user_id)
        feature_data = usage_today["usage"].get(feature_key)
        if not feature_data:
            # Bilinmeyen feature → geçişe izin ver, log warning
            logger.warning("Unknown feature key in gate: %s", feature_key)
            return {"feature": feature_key, "passed": True}

        used = feature_data["used"]
        limit = feature_data["limit"]

        if used >= limit:
            raise LimitReachedException(
                feature=feature_key,
                used=used,
                limit=limit,
                status_str=usage_today["status"],
            )

        return {
            "feature": feature_key,
            "passed": True,
            "used": used,
            "limit": limit,
            "remaining": limit - used,
        }

    return dependency


# ═══════════════════════════════════════════════════════════════
# Usage helper — endpoint başarılı dönmesinden sonra çağır
# ═══════════════════════════════════════════════════════════════

async def increment_feature_usage(
    user_id: str,
    feature_key: str,
    db,
) -> None:
    """
    Endpoint başarılı tamamlandığında çağrılır.
    Atomic upsert (RPC yoksa fallback).
    """
    from datetime import date
    today = date.today().isoformat()

    try:
        db.rpc(
            "increment_usage_counter",
            {
                "p_user_id": user_id,
                "p_date": today,
                "p_feature": feature_key,
            },
        ).execute()
    except Exception as e:
        logger.info(
            "increment_usage_counter RPC unavailable, using fallback: %s", e
        )
        try:
            existing = (
                db.table("usage_counters_daily")
                .select("id, count")
                .eq("user_id", user_id)
                .eq("usage_date", today)
                .eq("feature", feature_key)
                .maybe_single()
                .execute()
            )
            if existing.data:
                db.table("usage_counters_daily").update(
                    {"count": existing.data["count"] + 1}
                ).eq("id", existing.data["id"]).execute()
            else:
                db.table("usage_counters_daily").insert(
                    {
                        "user_id": user_id,
                        "usage_date": today,
                        "feature": feature_key,
                        "count": 1,
                    }
                ).execute()
        except Exception as e2:
            logger.error("Usage increment fallback failed: %s", e2)
