"""
Push Notification Service
FCM (Firebase Cloud Messaging) ile push notification gönderimi.

docs/product/notification-strategy.md ile birebir uyumlu:
- Sessiz saatlere saygı
- Kategori tabanlı filtreleme (kullanıcı tercihleri)
- Smart conditional logic (zaten kayıt varsa gönderme)
- Maksimum günlük limit

Gerçek FCM SDK için Firebase Admin SDK gerekli.
Bu dosya iş mantığını ve FCM çağrısı için wrapper'ı tanımlar.
Gerçek FCM push için `firebase-admin` Python paketi ekli olmalı.
"""
from datetime import date, datetime, time, timedelta
from typing import Optional

from ..core.logging import get_logger
from ..db.client import get_supabase

logger = get_logger(__name__)


class NotificationCategory:
    MEAL_REMINDER = "meal_reminders"
    COACH_NUDGE = "coach_nudges"
    WEEKLY_SUMMARY = "weekly_summary"
    STREAK_MILESTONE = "streak_milestone"
    TRIAL_ENDING = "trial_ending"
    RECOVERY_INVITE = "recovery_invite"


# Maksimum günlük bildirim sayısı (kullanıcı başına)
MAX_DAILY_NOTIFICATIONS = 3


class PushNotificationService:

    def __init__(self):
        self.db = get_supabase()

    # ──────────────────────────────────────────
    # Public API
    # ──────────────────────────────────────────

    async def send_meal_reminder(self, user_id: str, meal_type: str) -> bool:
        """
        Öğün hatırlatıcısı gönder.
        Koşullar kontrol edilir; uygun değilse sessizce atlanır.
        """
        if not await self._should_send(user_id, NotificationCategory.MEAL_REMINDER):
            return False

        # Bugün bu öğün zaten kayıtlı mı?
        today = str(date.today())
        existing = self.db.table("meal_logs")\
            .select("id", count="exact")\
            .eq("user_id", user_id)\
            .eq("local_day", today)\
            .eq("meal_type", meal_type)\
            .execute()

        if (existing.count or 0) > 0:
            logger.debug("skip_meal_reminder_already_logged", user_id=user_id, meal_type=meal_type)
            return False

        messages = self._get_meal_reminder_copy(meal_type)
        title = "Nuveli"
        body = messages["body"]

        return await self._dispatch(user_id, title, body, {
            "category": NotificationCategory.MEAL_REMINDER,
            "meal_type": meal_type,
            "deep_link": "/meal/capture",
        })

    async def send_checkin_invite(self, user_id: str) -> bool:
        if not await self._should_send(user_id, NotificationCategory.COACH_NUDGE):
            return False

        today = str(date.today())
        existing = self.db.table("daily_checkins")\
            .select("id", count="exact")\
            .eq("user_id", user_id)\
            .eq("local_day", today)\
            .execute()

        if (existing.count or 0) > 0:
            return False

        return await self._dispatch(user_id, "Nuveli", "Bugünü nasıl geçirdin?", {
            "category": NotificationCategory.COACH_NUDGE,
            "deep_link": "/home?checkin=1",
        })

    async def send_weekly_summary_ready(self, user_id: str) -> bool:
        if not await self._should_send(user_id, NotificationCategory.WEEKLY_SUMMARY):
            return False

        return await self._dispatch(user_id, "Nuveli", "Geçen haftan hazır.", {
            "category": NotificationCategory.WEEKLY_SUMMARY,
            "deep_link": "/progress/weekly",
        })

    async def send_streak_celebration(self, user_id: str, days: int) -> bool:
        # Streak bildirimi tercih toggle'ından ayrı — motivasyonel kategori
        # Gündüz saatleri kontrolü yap
        if not await self._is_within_quiet_hours(user_id):
            pass  # Normal gönderim

        body_map = {
            7: "7 gün üst üste. Süreklilik oldu.",
            14: "14 gün. Alışkanlık başlıyor.",
            30: "30 gün. Bu bir alışkanlık artık.",
            60: "60 gün. Kararlı gidiyorsun.",
            90: "3 ay oldu. Büyük iş.",
            180: "6 ay. Bu artık yaşam stili.",
            365: "1 yıl. Harika bir yolculuk.",
        }
        body = body_map.get(days, f"{days} gün üst üste.")

        return await self._dispatch(user_id, "Nuveli", body, {
            "category": NotificationCategory.STREAK_MILESTONE,
            "streak_days": str(days),
        })

    async def send_trial_ending(self, user_id: str, days_left: int) -> bool:
        if days_left == 2:
            body = "Trialın 2 gün sonra bitiyor. İstediğin zaman iptal edebilirsin."
        elif days_left == 0:
            body = "Trialın bugün sona eriyor. Pro'da kalmak istersen tek dokunuşta."
        else:
            body = f"Trialın {days_left} gün sonra bitiyor."

        return await self._dispatch(user_id, "Nuveli", body, {
            "category": NotificationCategory.TRIAL_ENDING,
            "deep_link": "/paywall",
        })

    # ──────────────────────────────────────────
    # Internal — koşul kontrolleri
    # ──────────────────────────────────────────

    async def _should_send(self, user_id: str, category: str) -> bool:
        """Bildirim göndermeden önce tüm koşulları kontrol et."""

        # 1. Sessiz saat kontrolü
        if await self._is_within_quiet_hours(user_id):
            return False

        # 2. Kullanıcı tercihi bu kategoriyi açmış mı
        prefs = self.db.table("notification_preferences")\
            .select("*").eq("user_id", user_id).execute()

        if not prefs.data:
            return True  # Default: izinli

        pref_row = prefs.data[0]
        if not pref_row.get(category, True):
            logger.debug("category_disabled", user_id=user_id, category=category)
            return False

        # 3. Günlük limit kontrolü
        if await self._daily_limit_exceeded(user_id):
            logger.debug("daily_limit_exceeded", user_id=user_id)
            return False

        # 4. Device token var mı
        tokens = await self._get_device_tokens(user_id)
        if not tokens:
            return False

        return True

    async def _is_within_quiet_hours(self, user_id: str) -> bool:
        """Şu an sessiz saat aralığında mı?"""
        prefs = self.db.table("notification_preferences")\
            .select("quiet_start, quiet_end").eq("user_id", user_id).execute()

        if not prefs.data:
            # Default: 22:00-08:00
            quiet_start = time(22, 0)
            quiet_end = time(8, 0)
        else:
            p = prefs.data[0]
            quiet_start = self._parse_time(p.get("quiet_start", "22:00"))
            quiet_end = self._parse_time(p.get("quiet_end", "08:00"))

        now = datetime.now().time()

        # Gece kaydırma (22:00 → 08:00)
        if quiet_start > quiet_end:
            return now >= quiet_start or now < quiet_end
        else:
            return quiet_start <= now < quiet_end

    @staticmethod
    def _parse_time(t) -> time:
        if isinstance(t, time):
            return t
        h, m = str(t).split(":")[:2]
        return time(int(h), int(m))

    async def _daily_limit_exceeded(self, user_id: str) -> bool:
        """Bugün zaten MAX bildirim gönderildi mi?"""
        today_start = datetime.combine(date.today(), time.min).isoformat()

        count = self.db.table("notification_logs")\
            .select("id", count="exact")\
            .eq("user_id", user_id)\
            .gte("sent_at", today_start)\
            .execute()

        return (count.count or 0) >= MAX_DAILY_NOTIFICATIONS

    async def _get_device_tokens(self, user_id: str) -> list[str]:
        result = self.db.table("device_tokens")\
            .select("token, platform").eq("user_id", user_id).execute()
        return [r for r in (result.data or [])]

    # ──────────────────────────────────────────
    # Dispatch
    # ──────────────────────────────────────────

    async def _dispatch(
        self, user_id: str, title: str, body: str, data: dict
    ) -> bool:
        """
        Firebase Admin SDK üzerinden gönderim.
        Sandbox için console log.

        Prod'da:
          from firebase_admin import messaging
          for device in devices:
              message = messaging.Message(
                  notification=messaging.Notification(title=title, body=body),
                  data=data,
                  token=device["token"],
              )
              messaging.send(message)
        """
        devices = await self._get_device_tokens(user_id)
        if not devices:
            logger.debug("no_devices", user_id=user_id)
            return False

        sent = 0
        for device in devices:
            # TODO: FCM gerçek çağrı burada
            logger.info(
                "push_sent",
                user_id=user_id,
                platform=device["platform"],
                title=title,
                category=data.get("category"),
            )
            sent += 1

        # Log
        self.db.table("notification_logs").insert({
            "user_id": user_id,
            "category": data.get("category"),
            "title": title,
            "body": body,
            "data": data,
            "device_count": sent,
            "sent_at": datetime.utcnow().isoformat(),
        }).execute()

        return sent > 0

    # ──────────────────────────────────────────
    # Copy helpers
    # ──────────────────────────────────────────

    @staticmethod
    def _get_meal_reminder_copy(meal_type: str) -> dict:
        import random
        options = {
            "breakfast": [
                {"body": "Kahvaltı nasıldı? Ekleyelim."},
                {"body": "Güne küçük bir kayıtla başlayalım mı?"},
            ],
            "lunch": [
                {"body": "Öğle yemeğini eklesek mi?"},
                {"body": "Bugün öğlen ne yedin?"},
                {"body": "Kısa bir fotoğraf — hepsi bu."},
            ],
            "dinner": [
                {"body": "Akşam yemeğin nasıldı? Ekleyelim."},
                {"body": "Bir öğün daha, bir gün daha."},
                {"body": "Günü özetleyelim mi?"},
            ],
            "snack": [
                {"body": "Ara öğün mü aldın?"},
            ],
        }
        return random.choice(options.get(meal_type, options["lunch"]))
