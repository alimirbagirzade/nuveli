"""
Pytest fixtures for backend tests.

Provides:
- `client`: FastAPI TestClient with mocked Supabase
- `auth_headers`: Bearer token headers for authenticated requests
- `mock_supabase`: MagicMock substituted for the real Supabase client
"""
import os
from datetime import datetime, timedelta
from unittest.mock import MagicMock

import pytest
from fastapi.testclient import TestClient
from jose import jwt

# --- Env vars must be set BEFORE importing the app ---
os.environ.setdefault("APP_ENV", "development")
os.environ.setdefault("SUPABASE_URL", "https://test.supabase.co")
os.environ.setdefault("SUPABASE_SERVICE_ROLE_KEY", "test-service-role")
os.environ.setdefault("SUPABASE_JWT_SECRET", "test-jwt-secret")
os.environ.setdefault("OPENAI_API_KEY", "test-openai-key")
os.environ.setdefault("CORS_ORIGINS", "*")

TEST_USER_ID = "11111111-1111-1111-1111-111111111111"
JWT_SECRET = "test-jwt-secret"


def _make_token(user_id: str = TEST_USER_ID) -> str:
    """Mint an HS256 JWT compatible with Supabase auth expectations."""
    payload = {
        "sub": user_id,
        "aud": "authenticated",
        "role": "authenticated",
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=1),
        "email": "test@nuveli.app",
    }
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")


@pytest.fixture
def mock_supabase(monkeypatch):
    """
    Replace the real Supabase client with a chainable MagicMock.
    Tests can override `.execute()` return values per-table by calling
    `.execute.return_value = MagicMock(data=[...])`.
    """
    fake = MagicMock()

    # Build a generic chainable mock for fluent query API
    def _chainable():
        m = MagicMock()
        m.select.return_value = m
        m.insert.return_value = m
        m.update.return_value = m
        m.upsert.return_value = m
        m.delete.return_value = m
        m.eq.return_value = m
        m.neq.return_value = m
        m.gt.return_value = m
        m.gte.return_value = m
        m.lt.return_value = m
        m.lte.return_value = m
        m.in_.return_value = m
        m.is_.return_value = m
        m.like.return_value = m
        m.ilike.return_value = m
        m.or_.return_value = m
        m.order.return_value = m
        m.limit.return_value = m
        m.range.return_value = m
        m.single.return_value = m
        m.maybe_single.return_value = m
        m.execute.return_value = MagicMock(data=[], count=0)
        return m

    fake.table = MagicMock(side_effect=lambda _: _chainable())

    # Patch both module-level usages
    monkeypatch.setattr("core.supabase_client.get_supabase", lambda: fake)
    monkeypatch.setattr("core.supabase_client.init_supabase", lambda: fake)
    return fake


@pytest.fixture
def client(mock_supabase):
    """FastAPI TestClient with Supabase mocked out."""
    # Import here so env vars and patches are in effect.
    from main import app

    with TestClient(app) as c:
        yield c


@pytest.fixture
def auth_headers():
    """Bearer headers carrying a valid JWT for the test user."""
    return {"Authorization": f"Bearer {_make_token()}"}


@pytest.fixture
def test_user_id():
    return TEST_USER_ID
