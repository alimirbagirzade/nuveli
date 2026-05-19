"""
Shared FastAPI dependencies.
Re-exports commonly used deps for convenience.
"""
from core.auth import get_current_user, get_current_user_optional, require_premium
from core.supabase_client import get_supabase

__all__ = [
    "get_current_user",
    "get_current_user_optional",
    "require_premium",
    "get_supabase",
]
