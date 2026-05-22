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


# ---------------------------------------------------------------------------
# ES256 / JWKS branch — when Supabase rotates to asymmetric keys, tokens
# arrive signed with EC P-256. The verifier fetches public JWKs from the
# project's /.well-known/jwks.json. We bypass the live fetch by seeding
# the in-process _jwks_cache directly with a public key we generated.
# ---------------------------------------------------------------------------


def _generate_es256_keypair_and_jwk(kid: str):
    """Return (private_key_pem, jwk_dict) for ES256 signing tests."""
    from cryptography.hazmat.primitives.asymmetric import ec
    from cryptography.hazmat.primitives import serialization
    from jose.utils import base64url_encode

    private_key = ec.generate_private_key(ec.SECP256R1())
    private_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    ).decode()

    public_numbers = private_key.public_key().public_numbers()
    jwk = {
        "kty": "EC",
        "crv": "P-256",
        "kid": kid,
        "x": base64url_encode(public_numbers.x.to_bytes(32, "big")).decode(),
        "y": base64url_encode(public_numbers.y.to_bytes(32, "big")).decode(),
        "use": "sig",
        "alg": "ES256",
    }
    return private_pem, jwk


def test_es256_valid_token_accepted_via_jwks_cache(client):
    """ES256 path: token signed with EC private key; matching public
    JWK seeded in the in-process JWKS cache lets verification pass."""
    from core.auth import _jwks_cache

    kid = "test-es256-kid"
    private_pem, jwk = _generate_es256_keypair_and_jwk(kid)

    # Seed and mark fresh so the cache fast-path returns the JWK
    # without triggering a real HTTP fetch.
    _jwks_cache._keys[kid] = jwk
    _jwks_cache._fetched_at = _jwks_cache._clock()
    try:
        token = jwt.encode(
            _valid_payload(),
            private_pem,
            algorithm="ES256",
            headers={"kid": kid},
        )

        with pytest.raises(IndexError):
            # auth passes → handler hits the empty mocked Supabase chain.
            client.get(
                "/me",
                headers={"Authorization": f"Bearer {token}"},
            )
    finally:
        _jwks_cache._keys.pop(kid, None)


def test_es256_unknown_kid_rejected(client):
    """ES256 token with a kid that's not in the (fresh) JWKS cache must 401.

    Marking the cache fresh means the verifier trusts the current keyset
    and does not refetch — so a kid we never seeded stays unknown."""
    from core.auth import _jwks_cache

    _jwks_cache._keys = {}
    _jwks_cache._fetched_at = _jwks_cache._clock()  # fresh-but-empty

    private_pem, _ = _generate_es256_keypair_and_jwk("ignored")
    token = jwt.encode(
        _valid_payload(),
        private_pem,
        algorithm="ES256",
        headers={"kid": "definitely-not-in-jwks-12345"},
    )

    response = client.get(
        "/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401
