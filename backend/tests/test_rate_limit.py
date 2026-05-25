"""
Tests for the H-2 rate limiter.

The limiter is configured globally in `core.rate_limit` with a custom key
function that prefers JWT `sub` over IP. Tests below exercise both paths.
"""
from unittest.mock import patch

import pytest
from fastapi import Request
from jose import jwt
from slowapi.util import get_remote_address

from core.rate_limit import _user_or_ip_key, limiter

from .conftest import _make_token, TEST_USER_ID


def _make_request(headers: dict | None = None, client_host: str = "1.2.3.4") -> Request:
    """Build a bare-bones starlette Request without going through TestClient."""
    scope = {
        "type": "http",
        "method": "POST",
        "path": "/meals/scan",
        "headers": [(k.lower().encode(), v.encode()) for k, v in (headers or {}).items()],
        "client": (client_host, 12345),
    }
    return Request(scope)


class TestKeyFunction:
    """`_user_or_ip_key` should prefer JWT sub, fall back to IP."""

    def test_uses_jwt_sub_when_token_present(self):
        token = _make_token()
        req = _make_request({"authorization": f"Bearer {token}"})
        assert _user_or_ip_key(req) == f"user:{TEST_USER_ID}"

    def test_falls_back_to_ip_without_token(self):
        req = _make_request(client_host="10.0.0.5")
        # `get_remote_address` returns the host as-is in this synthetic scope.
        assert _user_or_ip_key(req) == "ip:10.0.0.5"

    def test_falls_back_to_ip_on_malformed_token(self):
        req = _make_request(
            {"authorization": "Bearer not-a-real-jwt"},
            client_host="10.0.0.5",
        )
        assert _user_or_ip_key(req) == "ip:10.0.0.5"

    def test_falls_back_to_ip_on_token_without_sub(self):
        # Encode a token that omits `sub` so get_unverified_claims returns no sub.
        token = jwt.encode({"foo": "bar"}, "x", algorithm="HS256")
        req = _make_request(
            {"authorization": f"Bearer {token}"},
            client_host="10.0.0.5",
        )
        assert _user_or_ip_key(req) == "ip:10.0.0.5"

    def test_ignores_non_bearer_authorization_header(self):
        req = _make_request(
            {"authorization": "Basic dXNlcjpwYXNz"},
            client_host="10.0.0.5",
        )
        assert _user_or_ip_key(req) == "ip:10.0.0.5"


class TestLimiterEnforcement:
    """Hammer /meals/scan past the 10/minute cap and check we get 429."""

    @pytest.fixture(autouse=True)
    def reset_limiter(self):
        """Storage is shared between tests; clear it before each one."""
        limiter.reset()
        yield
        limiter.reset()

    def test_scan_meal_429_after_11th_call(
        self, client, auth_headers, monkeypatch
    ):
        # Stub the OpenAI Vision call so we don't hit the real API.
        # Return a shape that matches MealScanResponse — minimum viable.
        async def fake_analyze(_image, _hint, language_code=None):
            return {
                "foods": [],
                "total_calories": 0,
                "total_protein_g": 0.0,
                "total_carbs_g": 0.0,
                "total_fat_g": 0.0,
                "portion_insight": {
                    "score": 0,
                    "main_text": "stubbed",
                    "highlights": [],
                },
                "suggested_meal_type": None,
            }

        monkeypatch.setattr(
            "routers.meals.analyze_meal_image", fake_analyze
        )

        payload = {"image_base64": "aGVsbG8=", "meal_type_hint": "lunch"}

        # First 10 should sail through.
        for i in range(10):
            r = client.post("/meals/scan", json=payload, headers=auth_headers)
            assert r.status_code == 200, f"call #{i + 1} got {r.status_code}: {r.text}"

        # 11th flips to 429.
        r = client.post("/meals/scan", json=payload, headers=auth_headers)
        assert r.status_code == 429, f"expected 429, got {r.status_code}: {r.text}"
