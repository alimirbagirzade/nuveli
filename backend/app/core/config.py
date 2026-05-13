from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Uygulama konfigürasyonu. Değerler .env dosyasından okunur."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # App
    app_env: str = "development"
    app_version: str = "1.0.0"
    log_level: str = "INFO"

    # Supabase
    supabase_url: str
    supabase_service_role_key: str
    supabase_jwt_secret: str

    # OpenAI
    openai_api_key: str = ""

    # RevenueCat
    revenuecat_webhook_secret: str = ""

    # Feature limits (free tier)
    free_meal_analyses_per_day: int = 3
    free_meal_lookups_per_day: int = 10
    free_coach_messages_per_day: int = 5

    @property
    def is_production(self) -> bool:
        return self.app_env == "production"


# Singleton — tüm modüller bu nesneyi import eder
settings = Settings()  # type: ignore[call-arg]
