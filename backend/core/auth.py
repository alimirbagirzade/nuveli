"""
JWT authentication middleware.

Supports BOTH:
  - HS256 (legacy symmetric): verified with SUPABASE_JWT_SECRET.
  - ES256 / RS256 (asymmetric, Supabase new signing keys): verified with the
    project's public JWK fetched from `{SUPABASE_URL}/auth/v1/.well-known/jwks.json`.

Supabase rotates signing keys between symmetric and asymmetric without warning,
so the verifier inspects each token's header to pick the right path.

Frontend sends 'Authorization: Bearer {access_token}'.
"""
import asyncio
import time
from typing import Optional, Dict, Any, Callable
from fastapi import Header, Depends
from jose import jwt, JWTError, ExpiredSignatureError
import httpx

from config import get_settings
from core.exceptions import AuthError, PremiumRequired
from core.supabase_client import get_supabase
from core.logging import get_logger

logger = get_logger(__name__)

# JWKS cache TTL — Supabase rarely rotates more often than this, and
# capping freshness means a revoked or rotated-out key is gone within
# this window even if the process never restarts.
JWKS_CACHE_TTL_SECONDS = 3600.0


class _JwksCache:
    """
    In-process JWKS cache with:

      * TTL — after `ttl_seconds` the whole keyset is considered stale
        and a request triggers a refresh. Without this, an old key that
        Supabase removed from the published JWKS would live forever in
        the dict (the prior `merge`-style refresh never evicted).
      * REPLACE semantics on refresh — revoked keys disappear.
      * Single-flight refresh under `asyncio.Lock` — N concurrent
        cache-miss requests fire one fetch, not N.

    Clock is injectable so tests can advance time without sleeping.
    """

    def __init__(
        self,
        ttl_seconds: float = JWKS_CACHE_TTL_SECONDS,
        clock: Callable[[], float] = time.monotonic,
    ):
        self._ttl = ttl_seconds
        self._clock = clock
        self._keys: Dict[str, Dict[str, Any]] = {}
        # None = never fetched. We can't use 0.0 as a sentinel because
        # monotonic clocks can legitimately read 0 in unit tests.
        self._fetched_at: Optional[float] = None
        self._lock = asyncio.Lock()

    def _is_fresh(self) -> bool:
        if self._fetched_at is None:
            return False
        return (self._clock() - self._fetched_at) < self._ttl

    async def get(self, kid: str) -> Dict[str, Any]:
        """Return the JWK for `kid`, refreshing the cache when stale.

        A fresh cache without `kid` is *not* refreshed — that would let
        an attacker amplify each invalid-token request into a JWKS fetch
        and DoS the upstream. We trust the cache for its full TTL; new
        keys are picked up within `JWKS_CACHE_TTL_SECONDS` of publication.
        """
        if not self._is_fresh():
            async with self._lock:
                # Re-check under lock — a sibling coroutine may have
                # just refreshed while we were waiting for it.
                if not self._is_fresh():
                    await self._refresh()

        if kid in self._keys:
            return self._keys[kid]
        raise AuthError(f"Signing key not found in JWKS: {kid}")

    async def _refresh(self) -> None:
        """Fetch JWKS and REPLACE the in-memory keyset."""
        settings = get_settings()
        url = f"{settings.supabase_url.rstrip('/')}/auth/v1/.well-known/jwks.json"
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(url)
            resp.raise_for_status()
            data = resp.json()
        new_keys: Dict[str, Dict[str, Any]] = {}
        for jwk in data.get("keys", []):
            kid = jwk.get("kid")
            if kid:
                new_keys[kid] = jwk
        self._keys = new_keys
        self._fetched_at = self._clock()
        logger.info(f"JWKS refreshed: {len(self._keys)} keys cached")


# Module-singleton used by the auth dependency. Tests that need a
# clean slate or a fake clock can patch this attribute directly.
_jwks_cache = _JwksCache()


async def _get_jwks_key(kid: str) -> Dict[str, Any]:
    """Thin shim kept for backward compatibility with any external callers."""
    return await _jwks_cache.get(kid)


async def get_current_user(
    authorization: Optional[str] = Header(None),
) -> str:
    """
    Decode Supabase JWT from Authorization header, return user_id (UUID str).

    Raises:
        AuthError: 401 — missing/malformed/invalid/expired token.
    """
    if not authorization:
        raise AuthError("No authorization header")

    if not authorization.startswith("Bearer "):
        raise AuthError("Invalid auth header format (expected 'Bearer <token>')")

    token = authorization.removeprefix("Bearer ").strip()
    if not token:
        raise AuthError("Empty token")

    settings = get_settings()

    # Pick verification path from the token header.
    try:
        unverified_header = jwt.get_unverified_header(token)
    except JWTError as e:
        raise AuthError(f"Invalid token header: {e}")

    alg = unverified_header.get("alg")
    kid = unverified_header.get("kid")

    try:
        if alg == "HS256":
            payload = jwt.decode(
                token,
                settings.supabase_jwt_secret,
                algorithms=["HS256"],
                audience=settings.supabase_jwt_audience,
            )
        elif alg in ("ES256", "RS256"):
            if not kid:
                raise AuthError(f"{alg} token missing kid")
            key = await _get_jwks_key(kid)
            payload = jwt.decode(
                token,
                key,
                algorithms=[alg],
                audience=settings.supabase_jwt_audience,
            )
        else:
            raise AuthError(f"Unsupported alg: {alg}")
    except ExpiredSignatureError:
        raise AuthError("Token expired")
    except JWTError as e:
        logger.warning(f"JWT decode failed (alg={alg}, kid={kid}): {e}")
        raise AuthError(f"Invalid token: {e}")

    user_id = payload.get("sub")
    if not user_id:
        raise AuthError("Token missing 'sub' (user_id)")

    return user_id


async def get_current_user_optional(
    authorization: Optional[str] = Header(None),
) -> Optional[str]:
    """Like get_current_user but returns None instead of raising on missing/invalid."""
    if not authorization:
        return None
    try:
        return await get_current_user(authorization)
    except AuthError:
        return None


async def require_premium(
    user_id: str = Depends(get_current_user),
) -> str:
    """
    Gate endpoints behind premium subscription.
    Reads user_profiles.is_premium (RevenueCat webhook keeps it fresh).
    """
    supabase = get_supabase()
    result = (
        supabase.table("user_profiles")
        .select("is_premium, premium_expires_at")
        .eq("user_id", user_id)
        .single()
        .execute()
    )
    if not result.data or not result.data.get("is_premium"):
        raise PremiumRequired()
    return user_id
