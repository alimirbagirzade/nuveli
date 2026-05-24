"""
Nuveli Backend Configuration
Pydantic Settings ile environment variable yönetimi.
"""
from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache
from typing import Literal


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # --- App ---
    app_env: Literal["development", "staging", "production"] = "development"
    app_name: str = "Nuveli API"
    app_version: str = "1.0.0"
    log_level: str = "INFO"

    # --- Supabase ---
    supabase_url: str
    supabase_service_role_key: str
    supabase_jwt_secret: str
    supabase_jwt_algorithm: str = "HS256"
    supabase_jwt_audience: str = "authenticated"

    # --- OpenAI ---
    openai_api_key: str
    openai_model_chat: str = "gpt-4o"
    openai_model_vision: str = "gpt-4o"
    openai_timeout_seconds: float = 30.0
    openai_max_retries: int = 2

    # --- RevenueCat ---
    revenuecat_webhook_secret: str | None = None

    # --- Sentry (optional) ---
    sentry_dsn: str | None = None

    # --- FCM push (Coach insight notifications) ---
    # Firebase project id (e.g. "nuveli-prod") + the full service
    # account JSON base64-encoded. Grab JSON from:
    # Firebase Console → Project Settings → Service accounts →
    # Generate new private key. Then `base64 -i key.json | pbcopy`.
    firebase_project_id: str | None = None
    firebase_service_account_json_b64: str | None = None

    @property
    def fcm_enabled(self) -> bool:
        return bool(
            self.firebase_project_id and self.firebase_service_account_json_b64
        )

    # --- Internal cron ---
    # In-process APScheduler trigger for daily Coach insight generation.
    # Default ON in production (one Render web instance) — turn OFF if
    # you wire a separate Render Cron Service (see docs/ops/cron.md) or
    # scale to multiple instances (which would fire the job N times).
    app_enable_internal_cron: bool = True

    # --- CORS ---
    cors_origins: str = "*"  # comma-separated; "*" in dev

    @property
    def is_production(self) -> bool:
        return self.app_env == "production"

    @property
    def cors_origin_list(self) -> list[str]:
        if self.cors_origins == "*":
            return ["*"]
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    """Cached settings singleton."""
    return Settings()
