from jose import JWTError, jwt

from .config import settings
from .logging import get_logger

logger = get_logger(__name__)

# Supabase'in eski sistemi HS256 kullanıyor (legacy JWT secret),
# yeni sistemi ES256 / RS256 kullanıyor (publishable/asymmetric keys).
# Hangisi geliyorsa onu kabul ediyoruz.
ALLOWED_ALGORITHMS = ["HS256", "ES256", "RS256", "EdDSA"]


def decode_supabase_jwt(token: str) -> dict:
    """
    Supabase JWT token'ını doğrular ve payload'ı döndürür.
    Geçersiz token'da JWTError fırlatır.

    Birden fazla algorithm destekler:
    - HS256: Legacy JWT secret (symmetric)
    - ES256/RS256/EdDSA: Yeni publishable key sistemi (asymmetric)
    """
    try:
        payload = jwt.decode(
            token,
            settings.supabase_jwt_secret,
            algorithms=ALLOWED_ALGORITHMS,
            options={"verify_aud": False},
        )
        return payload
    except JWTError as e:
        logger.warning("jwt_decode_failed", error=str(e))
        raise


def extract_user_id(payload: dict) -> str:
    """JWT payload'ından user_id (sub) çıkarır."""
    user_id = payload.get("sub")
    if not user_id:
        raise ValueError("JWT payload içinde 'sub' alanı bulunamadı")
    return user_id
