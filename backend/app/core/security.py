"""
JWT verification for Supabase tokens.

Supports both:
1. Legacy HS256 (shared secret, symmetric)
2. Modern ES256/RS256/EdDSA (publishable key, asymmetric via JWKS)

The token's header tells us which algorithm was used. We pick the right
verification method based on that.

JWKS endpoint is fetched once at startup and cached.
"""

from typing import Any

import httpx
from jose import JWTError, jwt
from jose.utils import base64url_decode

from .config import settings
from .logging import get_logger

logger = get_logger(__name__)

ALLOWED_ALGORITHMS = ["HS256", "ES256", "RS256", "EdDSA"]

# JWKS cache — populated at first JWT verification, kept in memory
_jwks_cache: dict[str, Any] | None = None


def _get_jwks_url() -> str:
    """Supabase JWKS endpoint URL."""
    base = settings.supabase_url.rstrip("/")
    return f"{base}/auth/v1/.well-known/jwks.json"


def _fetch_jwks() -> dict:
    """Fetch JWKS (JSON Web Key Set) from Supabase. Cached after first call."""
    global _jwks_cache
    if _jwks_cache is not None:
        return _jwks_cache

    url = _get_jwks_url()
    try:
        with httpx.Client(timeout=5.0) as client:
            response = client.get(url)
            response.raise_for_status()
            _jwks_cache = response.json()
            logger.info("jwks_fetched", url=url, key_count=len(_jwks_cache.get("keys", [])))
            return _jwks_cache
    except Exception as e:
        logger.error("jwks_fetch_failed", url=url, error=str(e))
        raise


def _find_key_for_kid(kid: str) -> dict | None:
    """Find JWK matching the given key ID."""
    jwks = _fetch_jwks()
    for key in jwks.get("keys", []):
        if key.get("kid") == kid:
            return key
    return None


def decode_supabase_jwt(token: str) -> dict:
    """
    Verify Supabase JWT and return payload.

    Strategy:
    1. Read token header to get algorithm + key ID
    2. If HS256 → use shared secret from settings
    3. If ES256/RS256/EdDSA → fetch matching public key from JWKS
    4. Verify signature, return payload

    Raises JWTError on invalid token.
    """
    try:
        # Parse header to determine algorithm
        unverified_header = jwt.get_unverified_header(token)
        alg = unverified_header.get("alg")
        kid = unverified_header.get("kid")

        if alg not in ALLOWED_ALGORITHMS:
            logger.warning("jwt_unsupported_algorithm", alg=alg)
            raise JWTError(f"Unsupported algorithm: {alg}")

        # Pick the right key
        if alg == "HS256":
            # Symmetric: use shared JWT secret
            key = settings.supabase_jwt_secret
        else:
            # Asymmetric: fetch public key from JWKS using kid
            if not kid:
                raise JWTError("Asymmetric JWT missing 'kid' header")

            jwk = _find_key_for_kid(kid)
            if jwk is None:
                # Maybe JWKS was updated since we cached — invalidate and retry
                global _jwks_cache
                _jwks_cache = None
                jwk = _find_key_for_kid(kid)
                if jwk is None:
                    raise JWTError(f"No matching key found for kid={kid}")

            # jose library accepts JWK dict directly for asymmetric keys
            key = jwk

        payload = jwt.decode(
            token,
            key,
            algorithms=[alg],
            options={"verify_aud": False},
        )
        return payload

    except JWTError as e:
        logger.warning("jwt_decode_failed", error=str(e))
        raise
    except Exception as e:
        logger.error("jwt_unexpected_error", error=str(e), error_type=type(e).__name__)
        raise JWTError(f"Token verification failed: {e}") from e


def extract_user_id(payload: dict) -> str:
    """Extract user_id (sub claim) from JWT payload."""
    user_id = payload.get("sub")
    if not user_id:
        raise ValueError("JWT payload missing 'sub' field")
    return user_id
