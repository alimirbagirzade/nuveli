"""
Premium / RevenueCat router.

Endpoints:
- POST /premium/webhook : RevenueCat webhook handler (auth via Bearer)
- GET  /premium/status  : Current user's premium state
- POST /premium/sync    : Manuel refresh — RC API'den taze çek (Chat 19)

Chat 19 eklemeleri (eski kodun üstüne):
- subscription_events audit tablosuna idempotent insert
- rc_event_id ile duplicate dedup
- processed_at / processing_error tracking
- /sync endpoint (RevenueCatService kullanır)
"""
from datetime import datetime
from typing import Any, Optional

from fastapi import APIRouter, Depends, HTTPException, Header, Request, status

from core.auth import get_current_user
from core.supabase_client import get_supabase
from core.logging import get_logger
from config import get_settings
from models.achievement import PremiumStatusResponse
from services.revenuecat_service import get_revenuecat_service, RevenueCatService

logger = get_logger(__name__)
router = APIRouter()
settings = get_settings()


# ─────────────────────────────────────────────────────────────
# Event taxonomy
# ─────────────────────────────────────────────────────────────

# RevenueCat event types that grant premium access.
ACTIVATING_EVENTS = {
    "INITIAL_PURCHASE",
    "RENEWAL",
    "PRODUCT_CHANGE",
    "UNCANCELLATION",
    "NON_RENEWING_PURCHASE",
    "TRANSFER",
}

# RevenueCat event types that revoke premium access immediately.
DEACTIVATING_EVENTS = {
    "EXPIRATION",
    "REFUND",
    "SUBSCRIPTION_PAUSED",
}

# CANCELLATION = user disabled auto-renew but still has access until expiration.
CANCELLATION_EVENTS = {"CANCELLATION"}

# Chat 19: TEST event'leri için ayrı set (audit'e yazılır ama profile'a dokunmaz)
TEST_EVENTS = {"TEST"}


# ─────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────

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

    Anonymous RC IDs ("$RCAnonymousID:...") are filtered out.
    """
    for candidate in (event.get("app_user_id"), event.get("original_app_user_id")):
        if not candidate:
            continue
        if isinstance(candidate, str) and candidate.startswith("$RCAnonymousID:"):
            continue
        return candidate
    return None


def _ms_to_iso(ms: Optional[int]) -> Optional[str]:
    if ms is None:
        return None
    try:
        return datetime.utcfromtimestamp(ms / 1000).isoformat()
    except (TypeError, ValueError, OSError):
        return None


def _store_to_platform(store: Optional[str]) -> Optional[str]:
    """RC `store` field → user_profiles.premium_platform value."""
    if not store:
        return None
    return {
        "APP_STORE": "app_store",
        "PLAY_STORE": "play_store",
        "STRIPE": "stripe",
        "MAC_APP_STORE": "app_store",
        "AMAZON": "amazon",
        "PROMOTIONAL": "promotional",
    }.get(store)


# ─────────────────────────────────────────────────────────────
# Chat 19: Audit log helpers (subscription_events tablosu)
# ─────────────────────────────────────────────────────────────

def _audit_log_event(event: dict[str, Any], user_id: Optional[str]) -> bool:
    """
    Insert the webhook event into subscription_events.
    Returns True if newly inserted, False if duplicate (rc_event_id UNIQUE).

    Best-effort: if insert fails for any other reason, log and return False
    (do NOT break the webhook — RC will retry on 500).
    """
    supabase = get_supabase()
    payload = {
        "rc_event_id": event.get("id"),
        "event_type": event.get("type"),
        "rc_app_user_id": event.get("app_user_id"),
        "user_id": user_id,
        "product_id": event.get("product_id"),
        "entitlement_id": (event.get("entitlement_ids") or [None])[0],
        "store": event.get("store"),
        "platform": _store_to_platform(event.get("store")),
        "price_in_purchased_currency": event.get("price_in_purchased_currency"),
        "currency": event.get("currency"),
        "purchased_at_ms": event.get("purchased_at_ms"),
        "expiration_at_ms": event.get("expiration_at_ms"),
        "event_timestamp_ms": event.get("event_timestamp_ms"),
        "is_trial_period": event.get("period_type") == "TRIAL",
        "is_sandbox": event.get("environment") == "SANDBOX",
        "raw_payload": event,
        "is_processed": False,
    }

    try:
        supabase.table("subscription_events").insert(payload).execute()
        return True
    except Exception as e:
        msg = str(e).lower()
        if "duplicate" in msg or "23505" in msg or "unique" in msg:
            logger.info(f"Webhook duplicate (rc_event_id={event.get('id')}) — already logged")
            return False
        logger.warning(f"audit_log_event insert failed: {e}")
        return False


def _audit_mark_processed(event_id: Optional[str]) -> None:
    if not event_id:
        return
    try:
        get_supabase().table("subscription_events").update({
            "is_processed": True,
            "processed_at": datetime.utcnow().isoformat(),
        }).eq("rc_event_id", event_id).execute()
    except Exception as e:
        logger.warning(f"audit_mark_processed failed: {e}")


def _audit_mark_error(event_id: Optional[str], error: str) -> None:
    if not event_id:
        return
    try:
        get_supabase().table("subscription_events").update({
            "is_processed": False,
            "processing_error": error[:500],
        }).eq("rc_event_id", event_id).execute()
    except Exception as e:
        logger.warning(f"audit_mark_error failed: {e}")


# ─────────────────────────────────────────────────────────────
# Endpoints
# ─────────────────────────────────────────────────────────────

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
        "id": "<rc event uuid>",
        "app_user_id": "<supabase user uuid>",
        "product_id": "nuveli_premium_monthly",
        "expiration_at_ms": 1234567890000,
        "store": "APP_STORE" | "PLAY_STORE",
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
    event_id = event.get("id")
    user_id = _resolve_user_id(event)

    if not event_type or not user_id:
        logger.warning(
            f"Webhook missing event type or user_id: {event_type=}, {user_id=}"
        )
        # RevenueCat retries on non-2xx; return 200 so they don't retry malformed events.
        return {"status": "ignored", "reason": "missing_fields"}

    logger.info(f"RevenueCat webhook: type={event_type} user={user_id} id={event_id}")

    # ── Chat 19: audit log (dedup'lu insert) ─────────────────
    inserted = _audit_log_event(event, user_id)
    if not inserted and event_id:
        # Duplicate event (RC retry) — sessizce başarı dön
        logger.info(f"Duplicate webhook ignored: {event_id}")
        return {"status": "duplicate", "type": event_type}

    # ── TEST event'leri (RC dashboard'dan "Send Test"): sadece audit'e gir ─
    if event_type in TEST_EVENTS:
        _audit_mark_processed(event_id)
        return {"status": "ok", "type": event_type, "test": True}

    # ── Profile update ───────────────────────────────────────
    supabase = get_supabase()
    product_id = event.get("product_id")
    expires_at = _ms_to_iso(event.get("expiration_at_ms"))
    platform = _store_to_platform(event.get("store"))

    update_fields: dict[str, Any] = {}

    if event_type in ACTIVATING_EVENTS:
        update_fields = {
            "is_premium": True,
            "premium_expires_at": expires_at,
            "premium_product_id": product_id,
            "premium_will_renew": True,
            "premium_source": "revenuecat",
        }
        if platform is not None:
            update_fields["premium_platform"] = platform
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
        _audit_mark_processed(event_id)
        return {"status": "noted", "type": event_type}
    else:
        logger.info(f"Unhandled RevenueCat event type: {event_type}")
        _audit_mark_processed(event_id)
        return {"status": "ignored", "type": event_type}

    try:
        supabase.table("user_profiles").update(update_fields).eq(
            "user_id", user_id
        ).execute()
    except Exception as e:
        logger.error(
            f"Failed to update profile for {user_id} on {event_type}: {e}"
        )
        _audit_mark_error(event_id, f"profile_update_failed: {e}")
        # Return 500 so RevenueCat retries.
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Database update failed",
        )

    _audit_mark_processed(event_id)
    return {"status": "ok", "type": event_type, "user_id": user_id}


@router.get("/status", response_model=PremiumStatusResponse)
async def get_premium_status(user_id: str = Depends(get_current_user)):
    """Return the current user's premium subscription status."""
    
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
    if (
        is_premium
        and expires_dt
        and expires_dt < datetime.utcnow().replace(tzinfo=expires_dt.tzinfo)
    ):
        is_premium = False

    return PremiumStatusResponse(
        is_premium=is_premium,
        expires_at=expires_dt,
        product_id=row.get("premium_product_id"),
        will_renew=bool(row.get("premium_will_renew")),
        source=row.get("premium_source"),
    )


# ─────────────────────────────────────────────────────────────
# Chat 19: POST /sync — Manuel RC refresh
# ─────────────────────────────────────────────────────────────

@router.post("/sync", response_model=PremiumStatusResponse)
async def sync_from_revenuecat(
    user_id: str = Depends(get_current_user),
    rc: RevenueCatService = Depends(get_revenuecat_service),
):
    """
    Force-refresh premium status from RevenueCat REST API.

    Use when:
    - Webhook delivery delayed/failed
    - User subscribed on another device
    - User pressed "Refresh subscription" in Settings

    Rate-limit recommendation: client-side debounce (e.g. once per minute).
    Backend is intentionally not rate-limited here — abuse via auth'd
    endpoints is low-risk (RC API is cheap).
    """
    
    snap = await rc.get_subscriber(user_id)

    supabase = get_supabase()

    if snap is None or not snap.is_premium:
        # RC'de premium yok → user'ı free'ye düşür
        update = {
            "is_premium": False,
            "premium_expires_at": (
                snap.expires_at.isoformat() if snap and snap.expires_at else None
            ),
        }
        if snap is None or not snap.is_premium:
            update["premium_will_renew"] = False
        try:
            supabase.table("user_profiles").update(update).eq(
                "user_id", user_id
            ).execute()
        except Exception as e:
            logger.error(f"sync: profile update failed for {user_id}: {e}")
        return PremiumStatusResponse(
            is_premium=False,
            expires_at=snap.expires_at if snap else None,
            product_id=None,
            will_renew=False,
            source="revenuecat" if snap else None,
        )

    # Premium aktif → DB'yi senkronize et
    update = {
        "is_premium": True,
        "premium_expires_at": (
            snap.expires_at.isoformat() if snap.expires_at else None
        ),
        "premium_product_id": snap.product_id,
        "premium_will_renew": snap.will_renew,
        "premium_source": "revenuecat",
    }
    if snap.platform:
        update["premium_platform"] = snap.platform

    try:
        supabase.table("user_profiles").update(update).eq(
            "user_id", user_id
        ).execute()
    except Exception as e:
        logger.error(f"sync: profile update failed for {user_id}: {e}")

    return PremiumStatusResponse(
        is_premium=True,
        expires_at=snap.expires_at,
        product_id=snap.product_id,
        will_renew=snap.will_renew,
        source="revenuecat",
    )
