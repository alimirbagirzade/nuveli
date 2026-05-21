"""
Tests for `_verify_webhook_auth` in routers.premium.

Pins three behaviours we depend on for a safe RevenueCat webhook:
  1. Valid secret → no raise (timing-safe comparison succeeds)
  2. Wrong secret → 401 (rejects the forged event)
  3. Production-mode + missing secret → 503 (fail closed, NOT silently accept)
"""
import importlib
import os

import pytest
from fastapi import HTTPException


def _reload_premium_router():
    """Re-import config + premium so the monkeypatched env is picked up."""
    import config as _config
    importlib.reload(_config)
    from routers import premium as _premium
    importlib.reload(_premium)
    return _premium


class TestWebhookAuth:
    def test_accepts_matching_secret(self, monkeypatch):
        monkeypatch.setenv("REVENUECAT_WEBHOOK_SECRET", "shhh")
        monkeypatch.setenv("APP_ENV", "production")
        premium = _reload_premium_router()

        # No raise expected — same secret, normalized whitespace
        premium._verify_webhook_auth("Bearer shhh")
        premium._verify_webhook_auth("shhh")

    def test_rejects_wrong_secret(self, monkeypatch):
        monkeypatch.setenv("REVENUECAT_WEBHOOK_SECRET", "shhh")
        monkeypatch.setenv("APP_ENV", "production")
        premium = _reload_premium_router()

        with pytest.raises(HTTPException) as exc:
            premium._verify_webhook_auth("Bearer wrong")
        assert exc.value.status_code == 401

    def test_rejects_missing_header(self, monkeypatch):
        monkeypatch.setenv("REVENUECAT_WEBHOOK_SECRET", "shhh")
        monkeypatch.setenv("APP_ENV", "production")
        premium = _reload_premium_router()

        with pytest.raises(HTTPException) as exc:
            premium._verify_webhook_auth(None)
        assert exc.value.status_code == 401

    def test_production_with_missing_secret_fails_closed(self, monkeypatch):
        monkeypatch.delenv("REVENUECAT_WEBHOOK_SECRET", raising=False)
        monkeypatch.setenv("APP_ENV", "production")
        premium = _reload_premium_router()

        # In production, an unset secret means we MUST refuse rather than
        # silently accept anything. 503 surfaces the misconfiguration.
        with pytest.raises(HTTPException) as exc:
            premium._verify_webhook_auth("Bearer anything")
        assert exc.value.status_code == 503

    def test_dev_with_missing_secret_still_accepts(self, monkeypatch):
        monkeypatch.delenv("REVENUECAT_WEBHOOK_SECRET", raising=False)
        monkeypatch.setenv("APP_ENV", "development")
        premium = _reload_premium_router()

        # Dev/staging: loud warning logged, but local testing isn't blocked.
        premium._verify_webhook_auth("Bearer anything")
        premium._verify_webhook_auth(None)
