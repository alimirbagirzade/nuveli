"""
Tests for core.auth.get_current_user — the JWT verifier the whole
backend authz path depends on.

Coverage:
- HS256 happy path (legacy symmetric, what conftest's _make_token uses)
- Missing/malformed/empty Authorization header → 401
- Expired token → 401
- Unsupported alg (HS512 here) → 401
- Token without `sub` claim → 401

The ES256/JWKS path needs a live mock of the JWKS endpoint; that's
left for a follow-up. The HS256 branch is what the production
backend has been running until Chat 22's dual-alg work landed, so
locking it down here is the right baseline.
"""

from datetime import datetime, timedelta, timezone

import pytest
from jose import jwt


JWT_SECRET = "test-jwt-secret"


def _hs256(payload: dict) -> str:
    """Mint an HS256 token signed with the test JWT secret."""
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")


def _valid_payload() -> dict:
    return {
        "sub": "user-abc-123",
        "aud": "authenticated",
        "iat": datetime.now(timezone.utc),
        "exp": datetime.now(timezone.utc) + timedelta(hours=1),
        "email": "test@nuveli.app",
    }


# ---------------------------------------------------------------------------
# Endpoint-level tests — exercise get_current_user via the /me dependency.
# The client fixture mocks Supabase out, so a 200 response means the token
# was accepted; a 401 means it was rejected.
# ---------------------------------------------------------------------------


def test_no_authorization_header_returns_401(client):
    response = client.get("/me")
    # FastAPI returns 401 from our AuthError; 403 if FastAPI handles the
    # missing-header itself as forbidden.
    assert response.status_code in (401, 403)


def test_bearer_prefix_required(client):
    response = client.get("/me", headers={"Authorization": "Token abc.def.ghi"})
    assert response.status_code == 401


def test_empty_bearer_value_rejected(client):
    response = client.get("/me", headers={"Authorization": "Bearer "})
    assert response.status_code == 401


def test_malformed_jwt_rejected(client):
    response = client.get(
        "/me",
        headers={"Authorization": "Bearer not-a-valid-jwt"},
    )
    assert response.status_code == 401


def test_hs256_valid_token_accepted(client):
    """The legacy-symmetric path: a freshly minted HS256 token signed
    with the same secret the backend reads from env should pass
    verification and reach the endpoint body.

    We assert "auth passed" indirectly: control flow reaches the
    endpoint handler, which then trips an IndexError against the
    default (empty) mocked Supabase chain. The point is that the
    request did NOT short-circuit at the auth dependency."""
    token = _hs256(_valid_payload())
    with pytest.raises(IndexError):
        client.get(
            "/me",
            headers={"Authorization": f"Bearer {token}"},
        )


def test_expired_token_rejected(client):
    payload = _valid_payload()
    payload["exp"] = datetime.now(timezone.utc) - timedelta(hours=1)
    token = _hs256(payload)
    response = client.get(
        "/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401


def test_unsupported_algorithm_rejected(client):
    """HS512 is not in our allowed set {HS256, ES256, RS256}; verifier
    must refuse it even though the secret would technically check out."""
    payload = _valid_payload()
    token = jwt.encode(payload, JWT_SECRET, algorithm="HS512")
    response = client.get(
        "/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401


def test_token_without_sub_claim_rejected(client):
    payload = _valid_payload()
    del payload["sub"]
    token = _hs256(payload)
    response = client.get(
        "/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401


def test_wrong_audience_rejected(client):
    payload = _valid_payload()
    payload["aud"] = "different-audience"
    token = _hs256(payload)
    response = client.get(
        "/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401
