"""
Supabase client wrapper.
Backend uses SERVICE_ROLE key which bypasses RLS;
manual user_id filtering is applied in every router.
"""
from functools import lru_cache
from supabase import create_client, Client
from config import get_settings
from core.logging import get_logger

logger = get_logger(__name__)


@lru_cache
def get_supabase() -> Client:
    """Cached Supabase client (service role)."""
    settings = get_settings()
    return create_client(
        settings.supabase_url,
        settings.supabase_service_role_key,
    )


def init_supabase() -> None:
    """Startup health check — verifies Supabase is reachable."""
    client = get_supabase()
    try:
        # Lightweight ping: select 1 row from user_profiles
        client.table("user_profiles").select("id").limit(1).execute()
        logger.info("✅ Supabase connection OK")
    except Exception as e:
        logger.error(f"❌ Supabase connection failed: {e}")
        raise


def supabase_user_ctx(user_id: str) -> dict:
    """Helper: standard user filter dict for table queries."""
    return {"user_id": user_id}
