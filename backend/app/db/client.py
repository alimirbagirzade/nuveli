from supabase import create_client, Client
from ..core.config import settings
from ..core.logging import get_logger

logger = get_logger(__name__)

_client: Client | None = None


def get_supabase() -> Client:
    """
    Supabase service role client singleton.
    Service role key ile çalışır; RLS bypass eder.
    Tüm DB işlemleri bu client üzerinden yapılır.
    """
    global _client
    if _client is None:
        _client = create_client(
            settings.supabase_url,
            settings.supabase_service_role_key,
        )
        logger.info("supabase_client_initialized")
    return _client
