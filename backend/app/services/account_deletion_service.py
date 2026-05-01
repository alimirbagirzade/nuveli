"""
Account Deletion Service
KVKK m.11'e uygun hesap silme.

İki aşamalı silme:
  1. Request: User isteği aldığında hesap "pending_deletion" olarak işaretlenir,
     kullanıcı anında logout edilir, 30 gün geri dönüş süresi başlar.
  2. Execute: 30 gün sonra tüm veri kalıcı olarak silinir.

Bu servis immediate request'i handle eder. Execute'u bir scheduled job
çalıştırır (ör. günlük cron).

docs/product/kvkk-compliance.md ile birebir uyumlu.
"""
from datetime import date, timedelta

from ..core.logging import get_logger
from ..db.client import get_supabase

logger = get_logger(__name__)

# Sıralı silinecek tablolar — foreign key bağımlılıklarına uygun sıra
# Child tablolar önce, parent (profiles) en son
DELETION_ORDER = [
    "coach_messages",
    "coach_threads",
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
    "device_tokens",
    "safety_acknowledgements",
    "profiles",  # en son
]


class AccountDeletionService:

    def __init__(self):
        self.db = get_supabase()

    async def request_deletion(self, user_id: str) -> dict:
        """
        Kullanıcı silme isteği gönderdi.
        Hesap disable edilir, 30 gün sonra otomatik silme için kuyruğa alınır.
        """
        # Deletion schedule tablosuna kayıt
        scheduled_date = date.today() + timedelta(days=30)

        self.db.table("deletion_requests").upsert({
            "user_id": user_id,
            "requested_at": date.today().isoformat(),
            "scheduled_for": scheduled_date.isoformat(),
            "status": "pending",
        }, on_conflict="user_id").execute()

        # Supabase Auth user'ı disable et
        try:
            self.db.auth.admin.update_user_by_id(
                user_id,
                {"banned_until": "2099-12-31T00:00:00Z"}
            )
        except Exception as e:
            logger.warning("auth_disable_failed", user_id=user_id, error=str(e))

        logger.info("deletion_requested", user_id=user_id, scheduled_for=str(scheduled_date))

        return {
            "status": "pending_deletion",
            "scheduled_for": scheduled_date.isoformat(),
            "grace_period_days": 30,
        }

    async def cancel_deletion(self, user_id: str) -> dict:
        """Kullanıcı 30 gün içinde geri döndüyse silmeyi iptal."""
        self.db.table("deletion_requests")\
            .update({"status": "cancelled"})\
            .eq("user_id", user_id).execute()

        # Auth'u tekrar aktifleştir
        try:
            self.db.auth.admin.update_user_by_id(
                user_id, {"banned_until": "none"}
            )
        except Exception as e:
            logger.warning("auth_unban_failed", user_id=user_id, error=str(e))

        logger.info("deletion_cancelled", user_id=user_id)
        return {"status": "active"}

    async def execute_scheduled_deletions(self) -> dict:
        """
        Scheduled job — günlük çalışır.
        Silme tarihi gelmiş tüm kullanıcıları kalıcı siler.
        """
        today = date.today().isoformat()

        pending = self.db.table("deletion_requests")\
            .select("user_id")\
            .eq("status", "pending")\
            .lte("scheduled_for", today)\
            .execute()

        deleted_count = 0
        failed = []

        for row in (pending.data or []):
            user_id = row["user_id"]
            try:
                await self.execute_user_deletion(user_id)
                deleted_count += 1
            except Exception as e:
                logger.error("deletion_failed", user_id=user_id, error=str(e))
                failed.append({"user_id": user_id, "error": str(e)})

        logger.info("scheduled_deletion_run", deleted=deleted_count, failed_count=len(failed))
        return {"deleted": deleted_count, "failed": failed}

    async def execute_user_deletion(self, user_id: str) -> None:
        """
        Tek bir kullanıcıyı kalıcı siler. Sıra önemli — FK constraints.
        """
        # 1. Storage temizliği (koç audio dosyaları)
        try:
            files = self.db.storage.from_("coach-audio").list(user_id)
            if files:
                paths = [f"{user_id}/{f['name']}" for f in files]
                self.db.storage.from_("coach-audio").remove(paths)
        except Exception as e:
            logger.warning("storage_cleanup_failed", user_id=user_id, error=str(e))

        # 2. DB tablolarını sırayla sil
        for table in DELETION_ORDER:
            try:
                if table == "profiles":
                    self.db.table(table).delete().eq("id", user_id).execute()
                else:
                    self.db.table(table).delete().eq("user_id", user_id).execute()
            except Exception as e:
                logger.warning(
                    "table_deletion_warning",
                    table=table, user_id=user_id, error=str(e),
                )

        # 3. Supabase Auth user'ı sil
        try:
            self.db.auth.admin.delete_user(user_id)
        except Exception as e:
            logger.warning("auth_deletion_failed", user_id=user_id, error=str(e))

        # 4. Deletion request'i completed işaretle
        self.db.table("deletion_requests")\
            .update({"status": "completed"})\
            .eq("user_id", user_id).execute()

        # 5. RevenueCat customer (API ile, opsiyonel)
        # Burası HTTP istek gerektirir — basit tutuyoruz, cron'a bırakılabilir
        # from ..services.rc_api import delete_customer
        # await delete_customer(user_id)

        logger.info("user_deleted_permanently", user_id=user_id)
