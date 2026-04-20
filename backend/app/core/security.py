from jose import JWTError, jwt

from .config import settings
from .logging import get_logger

logger = get_logger(__name__)

ALGORITHM = "HS256"


def decode_supabase_jwt(token: str) -> dict:
    """
    Supabase JWT token'ını doğrular ve payload'ı döndürür.
    Geçersiz token'da JWTError fırlatır.
    """
    try:
        payload = jwt.decode(
            token,
            settings.supabase_jwt_secret,
            algorithms=[ALGORITHM],
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
