from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError

from .security import decode_supabase_jwt, extract_user_id

bearer_scheme = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> str:
    """
    FastAPI dependency — her korunan endpoint'te kullanılır.
    Supabase JWT'yi doğrular ve user_id döndürür.

    Kullanım:
        @router.get("/profile")
        async def get_profile(user_id: str = Depends(get_current_user)):
            ...
    """
    try:
        payload = decode_supabase_jwt(credentials.credentials)
        user_id = extract_user_id(payload)
        return user_id
    except (JWTError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "AUTH_REQUIRED", "message": "Geçersiz veya süresi dolmuş oturum."},
            headers={"WWW-Authenticate": "Bearer"},
        )
