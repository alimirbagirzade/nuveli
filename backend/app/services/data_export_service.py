"""
Data Export Service
KVKK m.11 — kullanıcı tüm verilerini JSON olarak indirebilir.

Ayarlar → Gizlilik ve Güvenlik → "Verilerimi İndir" butonundan çağrılır.
"""
import json
from datetime import datetime

from ..core.logging import get_logger
from ..db.client import get_supabase

logger = get_logger(__name__)


EXPORTABLE_TABLES = [
    "profiles",
    "coach_preferences",
    "notification_preferences",
    "premium_status_cache",
    "usage_counters_daily",
    "meal_logs",
    "meal_analysis_results",
    "daily_summaries",
    "water_logs",
    "weight_logs",
    "daily_checkins",
    "coach_threads",
    "coach_messages",
    "device_tokens",
    "safety_acknowledgements",
]


class DataExportService:

    def __init__(self):
        self.db = get_supabase()

    async def export_user_data(self, user_id: str) -> dict:
        """
        Kullanıcının tüm verilerini tek bir JSON dökümü olarak döner.
        Format: yapılandırılmış, kategorilere ayrılmış, okunabilir.
        """
        export = {
            "export_metadata": {
                "user_id": user_id,
                "exported_at": datetime.utcnow().isoformat() + "Z",
                "format_version": "1.0",
                "app_name": "Nuveli",
            },
            "data": {},
        }

        for table in EXPORTABLE_TABLES:
            try:
                if table == "profiles":
                    result = self.db.table(table).select("*").eq("id", user_id).execute()
                else:
                    result = self.db.table(table).select("*").eq("user_id", user_id).execute()

                export["data"][table] = result.data or []
            except Exception as e:
                logger.warning("export_table_failed", table=table, error=str(e))
                export["data"][table] = {"error": str(e)}

        # Sayıları özet
        export["summary"] = {
            table: len(rows) if isinstance(rows, list) else 0
            for table, rows in export["data"].items()
        }

        logger.info("data_exported", user_id=user_id)
        return export

    async def export_as_json_bytes(self, user_id: str) -> bytes:
        """JSON string bytes — download endpoint için."""
        data = await self.export_user_data(user_id)
        return json.dumps(data, default=str, indent=2, ensure_ascii=False).encode("utf-8")
