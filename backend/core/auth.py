"""
JWT authentication middleware.
Supabase issues HS256 JWTs signed with SUPABASE_JWT_SECRET.
Frontend sends 'Authorization: Bearer {access_token}'.
"""
from typing import Optional
from fastapi import Header, Depends
from jose import jwt, JWTError, ExpiredSignatureError

from config import get_settings
from core.exceptions import AuthError, PremiumRequired
from core.supabase_client import get_supabase
from core.logging import get_logger

logger = get_logger(__name__)


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
    try:
        payload = jwt.decode(
            token,
            settings.supabase_jwt_secret,
            algorithms=[settings.supabase_jwt_algorithm],
            audience=settings.supabase_jwt_audience,
        )
    except ExpiredSignatureError:
        raise AuthError("Token expired")
    except JWTError as e:
        logger.warning(f"JWT decode failed: {e}")
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
