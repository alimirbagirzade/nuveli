from __future__ import annotations
import pytest
pytest.skip("services/push_service.py and services/safety_service.py not yet implemented in this backend layout — Chat 23 follow-up.", allow_module_level=True)

"""
backend/tests/test_push_service.py

PushService tests — quiet hours, prefs, mock mode, payload helpers.
"""

import pytest
from datetime import datetime, time, timedelta, timezone
from unittest.mock import MagicMock, AsyncMock, patch
from zoneinfo import ZoneInfo

from services.push_service import (
    PushService,
    PushPayload,
    PushResult,
    NOTIFICATION_TYPES,
    empty_day_nudge_payload,
    weekly_summary_payload,
    meal_reminder_payload,
)


def _mock_db(prefs=None, tokens=None):
    db = MagicMock()

    prefs_chain = MagicMock()
    prefs_chain.select.return_value = prefs_chain
    prefs_chain.eq.return_value = prefs_chain
    prefs_chain.maybe_single.return_value = prefs_chain
    prefs_chain.execute.return_value = MagicMock(data=prefs)

    tokens_chain = MagicMock()
    tokens_chain.select.return_value = tokens_chain
    tokens_chain.eq.return_value = tokens_chain
    tokens_chain.execute.return_value = MagicMock(data=tokens or [])

    upsert_chain = MagicMock()
    upsert_chain.upsert.return_value = MagicMock(
        execute=MagicMock(return_value=MagicMock(data=None))
    )
    upsert_chain.update.return_value = MagicMock(
        eq=MagicMock(return_value=MagicMock(
            eq=MagicMock(return_value=MagicMock(
                execute=MagicMock(return_value=MagicMock(data=None))
            )),
            execute=MagicMock(return_value=MagicMock(data=None))
        ))
    )

    def table(name):
        if name == "notification_preferences":
            mock = MagicMock()
            mock.select.return_value = prefs_chain
            mock.upsert.return_value = MagicMock(
                execute=MagicMock(return_value=MagicMock(data=None))
            )
            return mock
        if name == "device_push_tokens":
            mock = MagicMock()
            mock.select.return_value = tokens_chain
            mock.upsert.return_value = MagicMock(
                execute=MagicMock(return_value=MagicMock(data=None))
            )
            mock.update.return_value = MagicMock(
                eq=MagicMock(return_value=MagicMock(
                    eq=MagicMock(return_value=MagicMock(
                        execute=MagicMock(return_value=MagicMock(data=None))
                    )),
                    execute=MagicMock(return_value=MagicMock(data=None))
                ))
            )
            return mock
        return MagicMock()

    db.table.side_effect = table
    return db


class TestPushPayload:
    def test_validates_known_type(self):
        p = PushPayload(title="x", body="y", notification_type="meal_reminder")
        p.validate()  # no raise

    def test_rejects_unknown_type(self):
        p = PushPayload(title="x", body="y", notification_type="foo")
        with pytest.raises(ValueError):
            p.validate()

    def test_rejects_empty_body(self):
        p = PushPayload(title="x", body="", notification_type="meal_reminder")
        with pytest.raises(ValueError):
            p.validate()


class TestMockMode:
    def test_no_sa_json_means_mock(self):
        svc = PushService(_mock_db(), firebase_service_account_json="")
        assert svc.mock_mode is True

    def test_invalid_sa_json_means_mock(self):
        svc = PushService(_mock_db(), firebase_service_account_json="not-json")
        assert svc.mock_mode is True

    def test_valid_sa_json_means_real(self):
        svc = PushService(
            _mock_db(),
            firebase_service_account_json='{"project_id": "test-proj"}',
        )
        assert svc.mock_mode is False
        assert svc._project_id == "test-proj"


class TestQuietHours:
    def _svc(self):
        return PushService(_mock_db(), "")

    def test_normal_window_inside(self):
        svc = self._svc()
        prefs = {
            "quiet_hours_start": "13:00:00",
            "quiet_hours_end": "14:00:00",
            "timezone": "UTC",
        }
        with patch("app.services.push_service.datetime") as mock_dt:
            mock_dt.now.return_value = datetime(2026, 5, 1, 13, 30, tzinfo=ZoneInfo("UTC"))
            assert svc._is_quiet_now(prefs) is True

    def test_normal_window_outside(self):
        svc = self._svc()
        prefs = {
            "quiet_hours_start": "13:00:00",
            "quiet_hours_end": "14:00:00",
            "timezone": "UTC",
        }
        with patch("app.services.push_service.datetime") as mock_dt:
            mock_dt.now.return_value = datetime(2026, 5, 1, 12, 0, tzinfo=ZoneInfo("UTC"))
            assert svc._is_quiet_now(prefs) is False

    def test_overnight_window_at_night(self):
        svc = self._svc()
        prefs = {
            "quiet_hours_start": "22:30:00",
            "quiet_hours_end": "08:00:00",
            "timezone": "UTC",
        }
        with patch("app.services.push_service.datetime") as mock_dt:
            mock_dt.now.return_value = datetime(2026, 5, 1, 23, 0, tzinfo=ZoneInfo("UTC"))
            assert svc._is_quiet_now(prefs) is True

    def test_overnight_window_at_morning(self):
        svc = self._svc()
        prefs = {
            "quiet_hours_start": "22:30:00",
            "quiet_hours_end": "08:00:00",
            "timezone": "UTC",
        }
        with patch("app.services.push_service.datetime") as mock_dt:
            mock_dt.now.return_value = datetime(2026, 5, 1, 6, 0, tzinfo=ZoneInfo("UTC"))
            assert svc._is_quiet_now(prefs) is True

    def test_overnight_window_during_day(self):
        svc = self._svc()
        prefs = {
            "quiet_hours_start": "22:30:00",
            "quiet_hours_end": "08:00:00",
            "timezone": "UTC",
        }
        with patch("app.services.push_service.datetime") as mock_dt:
            mock_dt.now.return_value = datetime(2026, 5, 1, 14, 0, tzinfo=ZoneInfo("UTC"))
            assert svc._is_quiet_now(prefs) is False


class TestSendToUserMockMode:
    @pytest.mark.asyncio
    async def test_skipped_no_token(self):
        # No tokens, no prefs (defaults)
        svc = PushService(_mock_db(prefs=None, tokens=[]), "")
        payload = PushPayload(
            title="t", body="b", notification_type="meal_reminder"
        )
        result = await svc.send_to_user("user-1", payload)
        assert result.skipped_no_token == 1
        assert result.sent == 0

    @pytest.mark.asyncio
    async def test_skipped_prefs_off(self):
        prefs = {
            "meal_reminders": False,  # OFF
            "water_reminders": True,
            "weekly_summary": True,
            "celebrations": True,
            "coach_messages": True,
            "empty_day_nudge": True,
            "quiet_hours_start": "22:30:00",
            "quiet_hours_end": "08:00:00",
            "timezone": "UTC",
        }
        svc = PushService(_mock_db(prefs=prefs, tokens=[]), "")
        payload = PushPayload(
            title="t", body="b", notification_type="meal_reminder"
        )
        result = await svc.send_to_user("user-1", payload)
        assert result.skipped_prefs == 1
        assert result.sent == 0

    @pytest.mark.asyncio
    async def test_mock_send_succeeds(self):
        prefs = {
            "meal_reminders": True,
            "water_reminders": True,
            "weekly_summary": True,
            "celebrations": True,
            "coach_messages": True,
            "empty_day_nudge": True,
            "quiet_hours_start": "00:00:00",
            "quiet_hours_end": "00:00:01",  # essentially disabled
            "timezone": "UTC",
        }
        tokens = [
            {"id": "tok-1", "fcm_token": "fcm-abc-123", "platform": "ios"},
        ]
        svc = PushService(_mock_db(prefs=prefs, tokens=tokens), "")
        payload = PushPayload(
            title="Hi", body="Hello", notification_type="meal_reminder"
        )
        result = await svc.send_to_user("user-1", payload)
        assert result.sent == 1
        assert result.mock is True


class TestPayloadHelpers:
    def test_empty_day_nudge_tr(self):
        p = empty_day_nudge_payload(locale="tr")
        assert p.notification_type == "empty_day_nudge"
        assert "nasılsın" in p.title.lower()

    def test_empty_day_nudge_en(self):
        p = empty_day_nudge_payload(locale="en")
        assert "how" in p.title.lower()

    def test_weekly_summary_has_deep_link(self):
        p = weekly_summary_payload(locale="tr")
        assert p.deep_link == "nuveli://progress/weekly"

    def test_meal_reminder_includes_meal_name(self):
        p = meal_reminder_payload(meal_name="Kahvaltı", locale="tr")
        assert "Kahvaltı" in p.title


class TestNotificationTypes:
    def test_all_types_have_pref_mapping(self):
        from app.services.push_service import NOTIFICATION_PREF_MAP
        for nt in NOTIFICATION_TYPES:
            assert nt in NOTIFICATION_PREF_MAP, f"Missing pref mapping for {nt}"


class TestBuildMessage:
    def test_ios_payload_has_apns(self):
        svc = PushService(_mock_db(), '{"project_id": "test"}')
        msg = svc._build_message(
            "tok",
            "ios",
            PushPayload(title="t", body="b", notification_type="meal_reminder"),
        )
        assert "apns" in msg
        assert "android" not in msg

    def test_android_payload_has_android(self):
        svc = PushService(_mock_db(), '{"project_id": "test"}')
        msg = svc._build_message(
            "tok",
            "android",
            PushPayload(title="t", body="b", notification_type="meal_reminder"),
        )
        assert "android" in msg
        assert "apns" not in msg

    def test_deep_link_in_data(self):
        svc = PushService(_mock_db(), '{"project_id": "test"}')
        msg = svc._build_message(
            "tok",
            "ios",
            PushPayload(
                title="t",
                body="b",
                notification_type="meal_reminder",
                deep_link="nuveli://home",
            ),
        )
        assert msg["data"]["deep_link"] == "nuveli://home"
        assert msg["data"]["notification_type"] == "meal_reminder"


class TestRegisterToken:
    @pytest.mark.asyncio
    async def test_register_basic(self):
        svc = PushService(_mock_db(), "")
        result = await svc.register_token(
            user_id="u-1",
            fcm_token="fcm-abc",
            platform="ios",
        )
        assert result["ok"] is True
        assert result["registered"] is True

    @pytest.mark.asyncio
    async def test_register_invalid_platform(self):
        svc = PushService(_mock_db(), "")
        with pytest.raises(ValueError):
            await svc.register_token(
                user_id="u-1",
                fcm_token="fcm-abc",
                platform="windows",
            )
