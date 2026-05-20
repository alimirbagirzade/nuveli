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
from typing import Optional, Dict, Any
from fastapi import Header, Depends
from jose import jwt, JWTError, ExpiredSignatureError
import httpx

from config import get_settings
from core.exceptions import AuthError, PremiumRequired
from core.supabase_client import get_supabase
from core.logging import get_logger

logger = get_logger(__name__)

# Module-level JWKS cache: { kid -> jwk_dict }. Refreshed lazily on cache miss.
_jwks_cache: Dict[str, Dict[str, Any]] = {}


async def _refresh_jwks() -> None:
    """Fetch Supabase JWKS and merge into the in-process cache."""
    settings = get_settings()
    url = f"{settings.supabase_url.rstrip('/')}/auth/v1/.well-known/jwks.json"
    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(url)
        resp.raise_for_status()
        data = resp.json()
    for jwk in data.get("keys", []):
        kid = jwk.get("kid")
        if kid:
            _jwks_cache[kid] = jwk
    logger.info(f"JWKS refreshed: {len(_jwks_cache)} keys cached")


async def _get_jwks_key(kid: str) -> Dict[str, Any]:
    """Return the JWK matching `kid`. Refreshes JWKS once if not found."""
    if kid in _jwks_cache:
        return _jwks_cache[kid]
    await _refresh_jwks()
    if kid in _jwks_cache:
        return _jwks_cache[kid]
    raise AuthError(f"Signing key not found in JWKS: {kid}")


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
