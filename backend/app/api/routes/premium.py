"""
backend/app/api/routes/premium.py

Premium routes — RevenueCat sync, webhook, status, features, usage.
PRD §7.2 Premium backend logic.
"""

from __future__ import annotations
from typing import Optional
import logging

from fastapi import APIRouter, Depends, Header, HTTPException, Request
from pydantic import BaseModel, Field

from app.core.dependencies import get_current_user_id, get_premium_service
from app.services.premium_service import PremiumService, PremiumSyncPayload

logger = logging.getLogger(__name__)
router = APIRouter()


# ═══════════════════════════════════════════════════════════════
# Request / Response models
# ═══════════════════════════════════════════════════════════════

class PremiumSyncRequest(BaseModel):
    rc_customer_id: str
    active_entitlement_ids: list[str] = []
    active_product_id: Optional[str] = None
    expiration_date: Optional[str] = None
    period_type: Optional[str] = None


class PremiumStatusResponse(BaseModel):
    status: str  # 'free' | 'trial' | 'premium' | 'expired'
    is_premium: bool
    trial_ends_at: Optional[str] = None
    current_period_end: Optional[str] = None
    active_product_id: Optional[str] = None


class FeaturesResponse(BaseModel):
    status: str
    features: dict


class Day2GiftStatus(BaseModel):
    eligible: bool


class UsageTodayResponse(BaseModel):
    date: str
    status: str
    usage: dict


# ═══════════════════════════════════════════════════════════════
# Endpoints
# ═══════════════════════════════════════════════════════════════

@router.get("/status", response_model=PremiumStatusResponse)
async def premium_status(
    user_id: str = Depends(get_current_user_id),
    svc: PremiumService = Depends(get_premium_service),
):
    return PremiumStatusResponse(**await svc.get_status(user_id))


@router.get("/features", response_model=FeaturesResponse)
async def premium_features(
    user_id: str = Depends(get_current_user_id),
    svc: PremiumService = Depends(get_premium_service),
):
    return FeaturesResponse(**await svc.get_features(user_id))


@router.post("/sync")
async def premium_sync(
    body: PremiumSyncRequest,
    user_id: str = Depends(get_current_user_id),
    svc: PremiumService = Depends(get_premium_service),
):
    payload = PremiumSyncPayload.from_dict(body.dict())
    result = await svc.sync_from_client(user_id, payload)
    return {"ok": True, **result}


@router.post("/webhook")
async def premium_webhook(
    request: Request,
    svc: PremiumService = Depends(get_premium_service),
    authorization: Optional[str] = Header(None),
):
    """
    RevenueCat webhook endpoint.

    RevenueCat dashboard'da konfigure et:
    - URL: https://nuveli-api.onrender.com/premium/webhook
    - Authorization header: Bearer <REVENUECAT_WEBHOOK_SECRET>

    NOT: RevenueCat HMAC signature kullanmaz, sadece Bearer header.
    Authorization header'ı env'deki REVENUECAT_WEBHOOK_SECRET ile karşılaştırılır.
    """
    raw_body = await request.body()
    expected = f"Bearer {svc.webhook_secret}" if svc.webhook_secret else ""

    if svc.webhook_secret and authorization != expected:
        logger.warning("Webhook auth mismatch")
        raise HTTPException(status_code=401, detail="invalid_signature")

    try:
        event = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="invalid_json")

    result = await svc.handle_webhook(event)
    return result


@router.get("/day2-gift-status", response_model=Day2GiftStatus)
async def day2_gift_status(
    user_id: str = Depends(get_current_user_id),
    svc: PremiumService = Depends(get_premium_service),
):
    eligible = await svc.is_day2_gift_eligible(user_id)
    if eligible:
        # Status sorgulanması = modal gösterildi → mark
        await svc.mark_day2_gift_offered(user_id)
    return Day2GiftStatus(eligible=eligible)


class Day2ClaimRequest(BaseModel):
    product_id: str


@router.post("/day2-gift-claim")
async def day2_gift_claim(
    body: Day2ClaimRequest,
    user_id: str = Depends(get_current_user_id),
    svc: PremiumService = Depends(get_premium_service),
):
    await svc.mark_day2_gift_claimed(user_id)
    return {"ok": True}


# ═══════════════════════════════════════════════════════════════
# /usage/today — buradan değil ama isimsel olarak premium ile ilişkili
# Mevcut kodda /usage/today nerede ise oraya taşı, ya da burada bırak
# ═══════════════════════════════════════════════════════════════

@router.get("/usage/today", response_model=UsageTodayResponse)
async def usage_today(
    user_id: str = Depends(get_current_user_id),
    svc: PremiumService = Depends(get_premium_service),
):
    return UsageTodayResponse(**await svc.get_usage_today(user_id))
