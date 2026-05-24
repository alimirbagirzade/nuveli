"""
FCM (Firebase Cloud Messaging) push helper.

Used by the daily-insights cron to nudge users when a fresh coach
insight is ready. Sends via the FCM v1 HTTP API so we don't need the
deprecated legacy server key.

Gated by env: both `FIREBASE_PROJECT_ID` and
`FIREBASE_SERVICE_ACCOUNT_JSON_B64` must be set. When they aren't,
`send_to_user` becomes a no-op that logs the skip — useful for local
dev and for staging before someone wires the service account.

Token storage: `device_tokens` table (`id, user_id, token, platform,
created_at`). One user can have many rows (iOS + Android + reinstalls
mint new tokens). Stale tokens are pruned lazily — if FCM returns
`UNREGISTERED` or `INVALID_ARGUMENT` we delete the row.
"""
from __future__ import annotations

import base64
import json
from typing import Any

import httpx

from core.logging import get_logger
from core.supabase_client import get_supabase

logger = get_logger(__name__)

_FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
_TOKEN_URL = "https://oauth2.googleapis.com/token"
_FCM_URL_TEMPLATE = "https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"

# Cache the bearer token in-process so we're not re-exchanging the JWT
# on every send. google-auth's Credentials object handles refresh
# transparently when we call `.refresh(transport)`.
_cached_credentials: Any | None = None


def _load_credentials():
    """Return a google-auth Credentials object or None when env missing."""
    global _cached_credentials
    if _cached_credentials is not None:
        return _cached_credentials

    from config import get_settings

    settings = get_settings()
    if not settings.fcm_enabled:
        return None

    try:
        from google.oauth2 import service_account
    except ImportError:
        logger.warning("google-auth not installed — FCM disabled")
        return None

    try:
        raw = base64.b64decode(settings.firebase_service_account_json_b64)
        info = json.loads(raw)
        creds = service_account.Credentials.from_service_account_info(
            info, scopes=[_FCM_SCOPE]
        )
        _cached_credentials = creds
        return creds
    except Exception as e:
        logger.error(f"FCM service account load failed: {e}")
        return None


async def _bearer_token() -> str | None:
    """Get a fresh OAuth2 bearer token for FCM (cached + auto-refresh)."""
    creds = _load_credentials()
    if creds is None:
        return None
    try:
        from google.auth.transport.requests import Request as GoogleRequest

        # google-auth's refresh is sync; run in executor to keep us
        # off the event loop. Single token lasts ~1h so this is rare.
        import asyncio

        await asyncio.get_running_loop().run_in_executor(
            None, lambda: creds.refresh(GoogleRequest())
        )
        return creds.token
    except Exception as e:
        logger.error(f"FCM bearer fetch failed: {e}")
        return None


def _list_tokens(user_id: str) -> list[dict]:
    """Pull every device_tokens row for the user."""
    supabase = get_supabase()
    try:
        res = (
            supabase.table("device_tokens")
            .select("id, token, platform")
            .eq("user_id", user_id)
            .execute()
        )
        return res.data or []
    except Exception as e:
        logger.warning(f"device_tokens fetch failed for {user_id}: {e}")
        return []


def _delete_token(token_id: str) -> None:
    supabase = get_supabase()
    try:
        supabase.table("device_tokens").delete().eq("id", token_id).execute()
    except Exception as e:
        logger.warning(f"device_tokens delete failed for {token_id}: {e}")


async def send_to_user(
    user_id: str,
    *,
    title: str,
    body: str,
    data: dict[str, str] | None = None,
) -> dict[str, int]:
    """Send one FCM notification to every device the user has registered.

    Returns a summary `{sent, skipped, pruned}`. Never raises; failures
    are logged and counted.

    `data` keys/values must be strings per the FCM v1 contract — pass
    things like `{"route": "/coach", "insight_id": "..."}` so the
    Flutter handler can deep-link on tap.
    """
    from config import get_settings

    settings = get_settings()
    if not settings.fcm_enabled:
        logger.info(f"FCM disabled — skip push for {user_id}")
        return {"sent": 0, "skipped": 1, "pruned": 0}

    tokens = _list_tokens(user_id)
    if not tokens:
        return {"sent": 0, "skipped": 1, "pruned": 0}

    bearer = await _bearer_token()
    if bearer is None:
        return {"sent": 0, "skipped": len(tokens), "pruned": 0}

    url = _FCM_URL_TEMPLATE.format(project_id=settings.firebase_project_id)
    headers = {
        "Authorization": f"Bearer {bearer}",
        "Content-Type": "application/json",
    }
    sent = 0
    pruned = 0
    async with httpx.AsyncClient(timeout=15) as client:
        for row in tokens:
            payload = {
                "message": {
                    "token": row["token"],
                    "notification": {"title": title, "body": body},
                    "data": data or {},
                }
            }
            try:
                resp = await client.post(url, headers=headers, json=payload)
                if resp.status_code == 200:
                    sent += 1
                elif resp.status_code in (400, 404):
                    # FCM returns 404 NOT_FOUND for unregistered/invalid
                    # tokens; 400 with UNREGISTERED message for same.
                    msg = resp.text
                    if "UNREGISTERED" in msg or "INVALID_ARGUMENT" in msg:
                        _delete_token(row["id"])
                        pruned += 1
                    else:
                        logger.warning(f"FCM 4xx for {row['id']}: {msg[:200]}")
                else:
                    logger.warning(
                        f"FCM {resp.status_code} for {row['id']}: {resp.text[:200]}"
                    )
            except Exception as e:
                logger.warning(f"FCM send error for {row['id']}: {e}")
    return {"sent": sent, "skipped": 0, "pruned": pruned}
