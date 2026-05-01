"""
backend/app/services/checkin_service.py

Daily check-in service.
PRD §6.4 Empty day, §6.5 Recovery day, §11.3 Mood/craving tracking.

Check-in types:
- empty_day:               'acknowledged' | 'snoozed' | 'tomorrow'
- mood:                    'great' | 'okay' | 'tough' | 'overwhelmed'
- craving:                 'passed' | 'gave_in' | 'replaced' (özgün cevap free text)
- recovery_day_acknowledge:'yes' (kullanıcı recovery day'i kabul etti)
"""

from __future__ import annotations
import logging
from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone
from typing import Optional

logger = logging.getLogger(__name__)


VALID_TYPES = ("empty_day", "mood", "craving", "recovery_day_acknowledge")

VALID_VALUES_BY_TYPE = {
    "empty_day": ("acknowledged", "snoozed", "tomorrow"),
    "mood": ("great", "okay", "tough", "overwhelmed"),
    "craving": ("passed", "gave_in", "replaced"),
    "recovery_day_acknowledge": ("yes",),
}


@dataclass
class CheckinInput:
    type: str
    value: str
    payload: Optional[dict] = None
    checkin_date: Optional[str] = None  # ISO date, default today

    def validate(self) -> None:
        if self.type not in VALID_TYPES:
            raise ValueError(f"Invalid type: {self.type}")
        valid_values = VALID_VALUES_BY_TYPE.get(self.type, ())
        if valid_values and self.value not in valid_values:
            raise ValueError(
                f"Invalid value '{self.value}' for type '{self.type}'. "
                f"Allowed: {valid_values}"
            )


class CheckinService:
    def __init__(self, db):
        self.db = db

    async def create(self, user_id: str, inp: CheckinInput) -> dict:
        inp.validate()

        d = inp.checkin_date or date.today().isoformat()
        record = {
            "user_id": user_id,
            "checkin_date": d,
            "type": inp.type,
            "value": inp.value,
            "payload": inp.payload or {},
        }

        try:
            res = (
                self.db.table("daily_checkins")
                .upsert(record, on_conflict="user_id,checkin_date,type")
                .execute()
            )
            return {"ok": True, "checkin": res.data[0] if res.data else record}
        except Exception as e:
            logger.error("Checkin create failed: %s", e)
            raise

    async def get_today(self, user_id: str) -> dict:
        d = date.today().isoformat()
        try:
            res = (
                self.db.table("daily_checkins")
                .select("type, value, payload, created_at")
                .eq("user_id", user_id)
                .eq("checkin_date", d)
                .execute()
            )
            return {"date": d, "checkins": res.data or []}
        except Exception as e:
            logger.warning("Checkin fetch failed: %s", e)
            return {"date": d, "checkins": []}

    async def get_recent(self, user_id: str, days: int = 7) -> dict:
        start = (date.today() - timedelta(days=days)).isoformat()
        try:
            res = (
                self.db.table("daily_checkins")
                .select("checkin_date, type, value, payload")
                .eq("user_id", user_id)
                .gte("checkin_date", start)
                .order("checkin_date", desc=True)
                .execute()
            )
            return {"since": start, "checkins": res.data or []}
        except Exception as e:
            logger.warning("Checkin recent fetch failed: %s", e)
            return {"since": start, "checkins": []}

    async def is_empty_day(self, user_id: str) -> bool:
        """Son 24 saatte hiç meal log'u yok mu?

        Bu, home screen'de empty_day_screen tetiklenmesi için kullanılır.
        """
        try:
            yesterday = (datetime.now(timezone.utc) - timedelta(hours=24)).isoformat()
            res = (
                self.db.table("meals")
                .select("id", count="exact")
                .eq("user_id", user_id)
                .gte("created_at", yesterday)
                .limit(1)
                .execute()
            )
            count = res.count if hasattr(res, "count") else len(res.data or [])
            return count == 0
        except Exception as e:
            logger.warning("Empty day check failed: %s", e)
            return False
