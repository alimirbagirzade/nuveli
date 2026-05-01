from functools import lru_cache
import os
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError

from .security import decode_supabase_jwt, extract_user_id

bearer_scheme = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> str:
    """
    FastAPI dependency. Returns user_id (string).
    Backwards-compatible name; new code uses get_current_user_id alias below.
    """
    try:
        payload = decode_supabase_jwt(credentials.credentials)
        user_id = extract_user_id(payload)
        return user_id
    except (JWTError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "AUTH_REQUIRED", "message": "Gecersiz veya suresi dolmus oturum."},
            headers={"WWW-Authenticate": "Bearer"},
        )


# Yeni isim — Sprint 1 kodu bunu kullaniyor
get_current_user_id = get_current_user


# ============================================================
# Service factories (Sprint 1)
# ============================================================

@lru_cache()
def get_supabase_client():
    """Supabase client. Wraps app.db.client.get_supabase()."""
    from app.db.client import get_supabase
    return get_supabase()


def get_coach_service():
    """CoachService factory with all required engines."""
    from app.services.decision_engine import DecisionEngine
    from app.services.prompt_engine import PromptEngine
    from app.services.safety_service import SafetyService
    from app.services.fallback_copy_service import FallbackCopyService
    from app.services.coach_service import CoachService
    
    db = get_supabase_client()
    return CoachService(
        decision_engine=DecisionEngine(db),
        prompt_engine=PromptEngine(),
        safety_service=SafetyService(),
        fallback_copy_service=FallbackCopyService(),
    )


def get_premium_service():
    """PremiumService factory."""
    from app.services.premium_service import PremiumService
    db = get_supabase_client()
    webhook_secret = os.getenv("REVENUECAT_WEBHOOK_SECRET", "")
    return PremiumService(db, webhook_secret=webhook_secret)


def get_push_service():
    """PushService factory."""
    from app.services.push_service import PushService
    db = get_supabase_client()
    sa_json = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON", "")
    return PushService(db, firebase_service_account_json=sa_json)


def get_checkin_service():
    """CheckinService factory."""
    from app.services.checkin_service import CheckinService
    db = get_supabase_client()
    return CheckinService(db)
