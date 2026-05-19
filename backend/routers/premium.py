"""
Premium / RevenueCat router.
- POST /premium/webhook : RevenueCat webhook handler (auth via Bearer)
- GET  /premium/status  : Current user's premium state
"""
from datetime import datetime
from typing import Any, Optional

from fastapi import APIRouter, Depends, HTTPException, Header, Request, status

from core.auth import get_current_user
from core.supabase_client import get_supabase
from core.logging import get_logger
from config import get_settings
from models.achievement import PremiumStatusResponse

logger = get_logger(__name__)
router = APIRouter()
settings = get_settings()


# RevenueCat event types that grant premium access.
ACTIVATING_EVENTS = {
    "INITIAL_PURCHASE",
    "RENEWAL",
    "PRODUCT_CHANGE",
    "UNCANCELLATION",
    "NON_RENEWING_PURCHASE",
}

# RevenueCat event types that revoke premium access immediately.
DEACTIVATING_EVENTS = {
    "EXPIRATION",
    "REFUND",
    "SUBSCRIPTION_PAUSED",
}

# CANCELLATION = user disabled auto-renew but still has access until expiration.
CANCELLATION_EVENTS = {"CANCELLATION"}


def _verify_webhook_auth(authorization: Optional[str]) -> None:
    """Verify the Bearer token from RevenueCat matches the configured secret."""
    if not settings.revenuecat_webhook_secret:
        logger.warning("REVENUECAT_WEBHOOK_SECRET not configured — webhook is open")
        return

    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization header",
        )

    expected = settings.revenuecat_webhook_secret
    # Accept either raw secret or "Bearer <secret>"
    expected_normalized = expected.removeprefix("Bearer ").strip()
    received_normalized = authorization.removeprefix("Bearer ").strip()

    if received_normalized != expected_normalized:
        logger.warning("RevenueCat webhook auth mismatch")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid webhook authorization",
        )


def _resolve_user_id(event: dict[str, Any]) -> Optional[str]:
    """
    RevenueCat sends `app_user_id` (set by the client SDK). For Nuveli we sync
    Supabase user UUID -> RevenueCat app_user_id, so they should match.
    Fallback to `original_app_user_id` for legacy events.
    """
    return event.get("app_user_id") or event.get("original_app_user_id")


def _ms_to_iso(ms: Optional[int]) -> Optional[str]:
    if ms is None:
        return None
    try:
        return datetime.utcfromtimestamp(ms / 1000).isoformat()
    except (TypeError, ValueError, OSError):
        return None


@router.post("/webhook", status_code=status.HTTP_200_OK)
async def revenuecat_webhook(
    request: Request,
    authorization: Optional[str] = Header(default=None),
):
    """
    Receive RevenueCat events and sync premium state to user_profiles.

    Payload shape (RevenueCat v1):
    {
      "event": {
        "type": "INITIAL_PURCHASE" | "RENEWAL" | "EXPIRATION" | ...,
        "app_user_id": "<supabase user uuid>",
        "product_id": "nuveli_premium_monthly",
        "expiration_at_ms": 1234567890000,
        ...
      }
    }
    """
    _verify_webhook_auth(authorization)

    try:
        payload = await request.json()
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid JSON",
        )

    event = payload.get("event") or {}
    event_type = event.get("type")
    user_id = _resolve_user_id(event)

    if not event_type or not user_id:
        logger.warning(f"Webhook missing event type or user_id: {event_type=}, {user_id=}")
        # RevenueCat retries on non-2xx; return 200 so they don't retry malformed events.
        return {"status": "ignored", "reason": "missing_fields"}

    logger.info(f"RevenueCat webhook: type={event_type} user={user_id}")

    supabase = get_supabase()
    product_id = event.get("product_id")
    expires_at = _ms_to_iso(event.get("expiration_at_ms"))

    update_fields: dict[str, Any] = {}

    if event_type in ACTIVATING_EVENTS:
        update_fields = {
            "is_premium": True,
            "premium_expires_at": expires_at,
            "premium_product_id": product_id,
            "premium_will_renew": True,
            "premium_source": "revenuecat",
        }
    elif event_type in CANCELLATION_EVENTS:
        # Keep premium until expiration_at_ms; only flip will_renew.
        update_fields = {
            "premium_will_renew": False,
            "premium_expires_at": expires_at,
        }
    elif event_type in DEACTIVATING_EVENTS:
        update_fields = {
            "is_premium": False,
            "premium_will_renew": False,
            "premium_expires_at": expires_at,
        }
    elif event_type == "BILLING_ISSUE":
        # Don't revoke immediately; RevenueCat will send EXPIRATION if grace period ends.
        logger.info(f"Billing issue for user {user_id}; awaiting expiration event")
        return {"status": "noted", "type": event_type}
    else:
        logger.info(f"Unhandled RevenueCat event type: {event_type}")
        return {"status": "ignored", "type": event_type}

    try:
        supabase.table("user_profiles").update(update_fields).eq("user_id", user_id).execute()
    except Exception as e:
        logger.error(f"Failed to update profile for {user_id} on {event_type}: {e}")
        # Return 500 so RevenueCat retries.
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Database update failed",
        )

    return {"status": "ok", "type": event_type, "user_id": user_id}


@router.get("/status", response_model=PremiumStatusResponse)
async def get_premium_status(user: dict = Depends(get_current_user)):
    """Return the current user's premium subscription status."""
    user_id = user["sub"]
    supabase = get_supabase()

    res = (
        supabase.table("user_profiles")
        .select(
            "is_premium, premium_expires_at, premium_product_id, "
            "premium_will_renew, premium_source"
        )
        .eq("user_id", user_id)
        .maybe_single()
        .execute()
    )

    row = res.data or {}
    expires_raw = row.get("premium_expires_at")
    expires_dt: Optional[datetime] = None
    if expires_raw:
        try:
            expires_dt = datetime.fromisoformat(expires_raw.replace("Z", "+00:00"))
        except (ValueError, AttributeError):
            expires_dt = None

    # If expiration has passed, report as not premium even if flag is stale.
    is_premium = bool(row.get("is_premium"))
    if is_premium and expires_dt and expires_dt < datetime.utcnow().replace(tzinfo=expires_dt.tzinfo):
        is_premium = False

    return PremiumStatusResponse(
        is_premium=is_premium,
        expires_at=expires_dt,
        product_id=row.get("premium_product_id"),
        will_renew=bool(row.get("premium_will_renew")),
        source=row.get("premium_source"),
    )
