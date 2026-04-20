from fastapi import APIRouter, Depends, Header, Request, HTTPException
from pydantic import BaseModel
from typing import Optional
from ...core.config import settings
from ...core.dependencies import get_current_user
from ...core.logging import get_logger
from ...services.premium_service import PremiumService
from ...schemas.common import ApiResponse

logger = get_logger(__name__)
router = APIRouter()


@router.get("/status")
async def premium_status(user_id: str = Depends(get_current_user)):
    svc = PremiumService()
    data = await svc.get_status(user_id)
    return ApiResponse.ok(data)


@router.get("/features")
async def premium_features(user_id: str = Depends(get_current_user)):
    svc = PremiumService()
    data = await svc.get_features(user_id)
    return ApiResponse.ok(data)


@router.post("/trial-claim")
async def claim_trial(user_id: str = Depends(get_current_user)):
    svc = PremiumService()
    data = await svc.claim_trial(user_id)
    return ApiResponse.ok(data)


@router.post("/webhook/revenuecat")
async def revenuecat_webhook(
    request: Request,
    authorization: Optional[str] = Header(None),
):
    """
    RevenueCat webhook handler.
    Auth: Authorization header RC'de tanımlanan secret ile eşleşmeli.
    RC panelinden: Project Settings → Integrations → Webhooks → Authorization header.
    """
    # 1. Webhook secret doğrulama
    expected = getattr(settings, "revenuecat_webhook_secret", None)
    if expected and authorization != expected:
        logger.warning("rc_webhook_unauthorized")
        raise HTTPException(401, detail={"code": "AUTH_REQUIRED", "message": "Unauthorized."})

    # 2. Payload parse
    body = await request.json()
    event = body.get("event", {})
    app_user_id = event.get("app_user_id")
    event_type = event.get("type")
    expiration = event.get("expiration_at_iso") or event.get("expiration_at_ms")

    if not app_user_id:
        raise HTTPException(400, detail={"code": "VALIDATION_ERROR", "message": "app_user_id eksik"})

    # 3. Event → tier map
    #   NOT: CANCELLATION geldiğinde kullanıcı expire olana kadar premium kalır.
    tier_map = {
        "INITIAL_PURCHASE": "premium",
        "RENEWAL": "premium",
        "UNCANCELLATION": "premium",
        "CANCELLATION": "premium",
        "EXPIRATION": "free",
        "NON_RENEWING_PURCHASE": "premium",
        "SUBSCRIPTION_PAUSED": "free",
        "BILLING_ISSUE": "free",
    }
    tier = tier_map.get(event_type, "free")

    # 4. Update
    rc_customer_id = event.get("original_app_user_id") or app_user_id
    svc = PremiumService()
    await svc.update_from_webhook(
        user_id=app_user_id,
        tier=tier,
        ends_at=expiration if isinstance(expiration, str) else None,
        rc_customer_id=rc_customer_id,
    )

    logger.info("rc_webhook_processed", user_id=app_user_id, event_type=event_type, new_tier=tier)
    return ApiResponse.ok({"processed": True})
