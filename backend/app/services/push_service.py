"""
backend/app/services/push_service.py

Push Notification Service (FCM HTTP v1).
PRD §13 Notifications, §11.4 Quiet hours, §6.4 Empty day nudge.

Design:
- FIREBASE_SERVICE_ACCOUNT_JSON env yoksa MOCK MODE (log only, no actual send)
  Bu sayede Render'a deploy bozulmaz; Firebase bağlanınca env eklenip canlı olur.
- Quiet hours user_local'de kontrol edilir (notification_preferences.timezone)
- prefs[notification_type] kapalıysa gönderilmez
- Token expired ise device_push_tokens.notifications_enabled=false işaretlenir
"""

from __future__ import annotations
import asyncio
import json
import logging
import os
from dataclasses import dataclass
from datetime import datetime, time, timedelta, timezone
from typing import Optional, Any
from zoneinfo import ZoneInfo

import httpx

logger = logging.getLogger(__name__)


# ═══════════════════════════════════════════════════════════════
# Config & types
# ═══════════════════════════════════════════════════════════════

NOTIFICATION_TYPES = (
    "meal_reminder",
    "water_reminder",
    "weekly_summary",
    "celebration",
    "coach_message",
    "empty_day_nudge",
)

# notification_type -> notification_preferences kolonu mapping
NOTIFICATION_PREF_MAP = {
    "meal_reminder": "meal_reminders",
    "water_reminder": "water_reminders",
    "weekly_summary": "weekly_summary",
    "celebration": "celebrations",
    "coach_message": "coach_messages",
    "empty_day_nudge": "empty_day_nudge",
}


@dataclass
class PushPayload:
    title: str
    body: str
    notification_type: str
    deep_link: Optional[str] = None        # nuveli://home, nuveli://coach, etc.
    data: Optional[dict] = None            # extra data payload

    def validate(self) -> None:
        if self.notification_type not in NOTIFICATION_TYPES:
            raise ValueError(f"Unknown notification_type: {self.notification_type}")
        if not self.title or not self.body:
            raise ValueError("title and body required")


@dataclass
class PushResult:
    sent: int = 0
    skipped_quiet_hours: int = 0
    skipped_prefs: int = 0
    skipped_no_token: int = 0
    failed: int = 0
    mock: bool = False
    errors: list = None

    def __post_init__(self):
        if self.errors is None:
            self.errors = []


# ═══════════════════════════════════════════════════════════════
# Service
# ═══════════════════════════════════════════════════════════════

class PushService:
    """FCM push sender + quiet hours + prefs check."""

    def __init__(self, db, firebase_service_account_json: str = ""):
        self.db = db
        self._sa_json = firebase_service_account_json
        self._project_id: Optional[str] = None
        self._access_token: Optional[str] = None
        self._token_expires_at: Optional[datetime] = None
        self.mock_mode = not bool(firebase_service_account_json)

        if self.mock_mode:
            logger.warning(
                "PushService: FIREBASE_SERVICE_ACCOUNT_JSON not set, running in MOCK MODE"
            )
        else:
            try:
                sa = json.loads(firebase_service_account_json)
                self._project_id = sa.get("project_id")
                if not self._project_id:
                    logger.error("Firebase SA JSON missing project_id")
                    self.mock_mode = True
            except Exception as e:
                logger.error("Firebase SA JSON parse failed: %s — falling back to MOCK", e)
                self.mock_mode = True

    # ───────────────────────────────────────────────────
    # Public API
    # ───────────────────────────────────────────────────

    async def send_to_user(
        self, user_id: str, payload: PushPayload
    ) -> PushResult:
        """Tek kullanıcıya push gönder. Quiet hours + prefs kontrolü dahil."""
        payload.validate()
        result = PushResult(mock=self.mock_mode)

        # 1. Tercih kontrolü
        prefs = await self._get_preferences(user_id)
        if not prefs:
            # Default'ları kullan, gönder
            prefs = self._default_prefs()

        pref_key = NOTIFICATION_PREF_MAP[payload.notification_type]
        if not prefs.get(pref_key, True):
            result.skipped_prefs += 1
            return result

        # 2. Quiet hours kontrolü
        if self._is_quiet_now(prefs):
            # Coach_message ve celebration HER ZAMAN sessize alınır quiet hours'ta
            # (high_risk hariç, ama o ayrı bir feature — şimdilik basit)
            if payload.notification_type in (
                "meal_reminder",
                "water_reminder",
                "empty_day_nudge",
                "celebration",
            ):
                result.skipped_quiet_hours += 1
                return result
            # weekly_summary, coach_message → bekletilebilir, ama şimdilik atla
            result.skipped_quiet_hours += 1
            return result

        # 3. Token bul
        tokens = await self._get_active_tokens(user_id)
        if not tokens:
            result.skipped_no_token += 1
            return result

        # 4. Gönder
        for token_row in tokens:
            try:
                ok = await self._send_one(
                    fcm_token=token_row["fcm_token"],
                    platform=token_row["platform"],
                    payload=payload,
                )
                if ok:
                    result.sent += 1
                else:
                    result.failed += 1
            except FCMTokenInvalid:
                # Bu token artık geçersiz — disable
                await self._disable_token(token_row["id"])
                result.failed += 1
            except Exception as e:
                logger.error("FCM send error: %s", e)
                result.failed += 1
                result.errors.append(str(e))

        return result

    async def send_to_users(
        self, user_ids: list[str], payload: PushPayload
    ) -> PushResult:
        """Toplu gönderim (ör. weekly summary cron job)."""
        agg = PushResult(mock=self.mock_mode)
        for uid in user_ids:
            r = await self.send_to_user(uid, payload)
            agg.sent += r.sent
            agg.skipped_quiet_hours += r.skipped_quiet_hours
            agg.skipped_prefs += r.skipped_prefs
            agg.skipped_no_token += r.skipped_no_token
            agg.failed += r.failed
            agg.errors.extend(r.errors)
        return agg

    # ───────────────────────────────────────────────────
    # Token mgmt
    # ───────────────────────────────────────────────────

    async def register_token(
        self,
        user_id: str,
        fcm_token: str,
        platform: str,
        device_info: Optional[dict] = None,
    ) -> dict:
        """App, FCM token aldığında bunu çağırır."""
        if platform not in ("ios", "android"):
            raise ValueError("platform must be 'ios' or 'android'")

        device_info = device_info or {}
        record = {
            "user_id": user_id,
            "fcm_token": fcm_token,
            "platform": platform,
            "notifications_enabled": True,
            "device_id": device_info.get("device_id"),
            "device_model": device_info.get("device_model"),
            "app_version": device_info.get("app_version"),
            "os_version": device_info.get("os_version"),
            "last_active_at": datetime.now(timezone.utc).isoformat(),
        }

        try:
            self.db.table("device_push_tokens").upsert(
                record, on_conflict="user_id,fcm_token"
            ).execute()
            return {"ok": True, "registered": True}
        except Exception as e:
            logger.error("Token register failed: %s", e)
            raise

    async def unregister_token(self, user_id: str, fcm_token: str) -> dict:
        try:
            self.db.table("device_push_tokens").update(
                {"notifications_enabled": False}
            ).eq("user_id", user_id).eq("fcm_token", fcm_token).execute()
            return {"ok": True}
        except Exception as e:
            logger.error("Token unregister failed: %s", e)
            raise

    # ───────────────────────────────────────────────────
    # Internals
    # ───────────────────────────────────────────────────

    async def _get_preferences(self, user_id: str) -> Optional[dict]:
        try:
            res = (
                self.db.table("notification_preferences")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            return res.data
        except Exception as e:
            logger.warning("Preferences fetch failed: %s", e)
            return None

    def _default_prefs(self) -> dict:
        return {
            "meal_reminders": True,
            "water_reminders": True,
            "weekly_summary": True,
            "celebrations": True,
            "coach_messages": True,
            "empty_day_nudge": True,
            "quiet_hours_start": "22:30:00",
            "quiet_hours_end": "08:00:00",
            "timezone": "Europe/Istanbul",
        }

    def _is_quiet_now(self, prefs: dict) -> bool:
        """Kullanıcı zamanında quiet hours içinde miyiz?"""
        try:
            tz_name = prefs.get("timezone") or "Europe/Istanbul"
            tz = ZoneInfo(tz_name)
            now_local = datetime.now(tz).time()

            start = self._parse_time(prefs.get("quiet_hours_start") or "22:30:00")
            end = self._parse_time(prefs.get("quiet_hours_end") or "08:00:00")

            if start <= end:
                # Aynı gün içinde (örn 13:00 → 14:00)
                return start <= now_local < end
            else:
                # Gece bölünmüş (örn 22:30 → 08:00)
                return now_local >= start or now_local < end
        except Exception as e:
            logger.warning("Quiet hours check failed: %s", e)
            return False

    def _parse_time(self, s: str) -> time:
        parts = s.split(":")
        return time(int(parts[0]), int(parts[1]), int(parts[2]) if len(parts) > 2 else 0)

    async def _get_active_tokens(self, user_id: str) -> list[dict]:
        try:
            res = (
                self.db.table("device_push_tokens")
                .select("id, fcm_token, platform")
                .eq("user_id", user_id)
                .eq("notifications_enabled", True)
                .execute()
            )
            return res.data or []
        except Exception as e:
            logger.warning("Token fetch failed: %s", e)
            return []

    async def _disable_token(self, token_id: str):
        try:
            self.db.table("device_push_tokens").update(
                {"notifications_enabled": False}
            ).eq("id", token_id).execute()
        except Exception as e:
            logger.warning("Token disable failed: %s", e)

    async def _send_one(
        self, fcm_token: str, platform: str, payload: PushPayload
    ) -> bool:
        """Tek device'a FCM HTTP v1 ile gönder. Mock mode'da log."""
        if self.mock_mode:
            logger.info(
                "[MOCK PUSH] platform=%s token=%s... title=%r body=%r type=%s",
                platform, fcm_token[:8], payload.title, payload.body, payload.notification_type,
            )
            return True

        access_token = await self._get_access_token()
        url = f"https://fcm.googleapis.com/v1/projects/{self._project_id}/messages:send"

        message = self._build_message(fcm_token, platform, payload)
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json; UTF-8",
        }

        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.post(url, json={"message": message}, headers=headers)

        if resp.status_code == 200:
            return True

        if resp.status_code == 404:
            # Token registration not found → expired
            raise FCMTokenInvalid(fcm_token)
        if resp.status_code == 400:
            try:
                err = resp.json()
                detail = err.get("error", {}).get("status", "")
                if detail in ("UNREGISTERED", "INVALID_ARGUMENT"):
                    raise FCMTokenInvalid(fcm_token)
            except FCMTokenInvalid:
                raise
            except Exception:
                pass

        logger.warning("FCM send non-200: %s — %s", resp.status_code, resp.text[:200])
        return False

    def _build_message(
        self, fcm_token: str, platform: str, payload: PushPayload
    ) -> dict:
        data = payload.data or {}
        if payload.deep_link:
            data["deep_link"] = payload.deep_link
        data["notification_type"] = payload.notification_type

        msg = {
            "token": fcm_token,
            "notification": {
                "title": payload.title,
                "body": payload.body,
            },
            "data": {k: str(v) for k, v in data.items()},
        }

        # iOS-specific
        if platform == "ios":
            msg["apns"] = {
                "headers": {"apns-priority": "10"},
                "payload": {
                    "aps": {
                        "sound": "default",
                        "badge": 1,
                    }
                },
            }
        # Android-specific
        elif platform == "android":
            msg["android"] = {
                "priority": "high",
                "notification": {
                    "channel_id": payload.notification_type,
                    "default_sound": True,
                },
            }

        return msg

    async def _get_access_token(self) -> str:
        """Service account JWT → OAuth2 access token. 1 saat cache."""
        now = datetime.now(timezone.utc)
        if (
            self._access_token
            and self._token_expires_at
            and now < self._token_expires_at - timedelta(minutes=5)
        ):
            return self._access_token

        # Lazy import — only when sending real push
        try:
            from google.oauth2 import service_account
            from google.auth.transport.requests import Request as GoogleRequest
        except ImportError:
            raise RuntimeError(
                "google-auth not installed. Add 'google-auth' to requirements.txt"
            )

        sa_info = json.loads(self._sa_json)
        creds = service_account.Credentials.from_service_account_info(
            sa_info,
            scopes=["https://www.googleapis.com/auth/firebase.messaging"],
        )
        # auth requests are sync, run in thread
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(None, creds.refresh, GoogleRequest())

        self._access_token = creds.token
        self._token_expires_at = creds.expiry.replace(tzinfo=timezone.utc) if creds.expiry else now + timedelta(hours=1)
        return self._access_token


# ═══════════════════════════════════════════════════════════════
# Exceptions
# ═══════════════════════════════════════════════════════════════

class FCMTokenInvalid(Exception):
    """Token expired/unregistered, should be disabled."""
    pass


# ═══════════════════════════════════════════════════════════════
# Pre-built payload helpers
# ═══════════════════════════════════════════════════════════════

def empty_day_nudge_payload(persona: str = "gentle", locale: str = "tr") -> PushPayload:
    """24 saat aktivite yoksa gönderilir (PRD §6.4)."""
    if locale == "en":
        title = "How are you today?"
        body = "Just checking in. No pressure."
    else:
        title = "Bugün nasılsın?"
        body = "Sadece selam vermek istedim. Yoğun bir gün de olabilir."
    return PushPayload(
        title=title, body=body,
        notification_type="empty_day_nudge",
        deep_link="nuveli://home",
    )


def weekly_summary_payload(locale: str = "tr") -> PushPayload:
    if locale == "en":
        return PushPayload(
            title="Your weekly recap is ready",
            body="A quick look at the past 7 days.",
            notification_type="weekly_summary",
            deep_link="nuveli://progress/weekly",
        )
    return PushPayload(
        title="Haftalık özetin hazır",
        body="Son 7 günün kısa bir bakışı.",
        notification_type="weekly_summary",
        deep_link="nuveli://progress/weekly",
    )


def meal_reminder_payload(meal_name: str, locale: str = "tr") -> PushPayload:
    if locale == "en":
        return PushPayload(
            title=f"{meal_name} time?",
            body="When you're ready, snap or describe it.",
            notification_type="meal_reminder",
            deep_link="nuveli://meal/capture",
        )
    return PushPayload(
        title=f"{meal_name} vakti mi?",
        body="Hazır olduğunda fotoğraf çek veya yaz.",
        notification_type="meal_reminder",
        deep_link="nuveli://meal/capture",
    )
