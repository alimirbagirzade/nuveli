"""
backend/tests/test_checkin_service.py
"""

from __future__ import annotations
import pytest
from datetime import date
from unittest.mock import MagicMock

from app.services.checkin_service import (
    CheckinService,
    CheckinInput,
    VALID_TYPES,
    VALID_VALUES_BY_TYPE,
)


def _mock_db(checkins_data=None, meals_data=None, meals_count=0):
    db = MagicMock()

    checkins_chain = MagicMock()
    checkins_chain.select.return_value = checkins_chain
    checkins_chain.eq.return_value = checkins_chain
    checkins_chain.gte.return_value = checkins_chain
    checkins_chain.order.return_value = checkins_chain
    checkins_chain.execute.return_value = MagicMock(data=checkins_data or [])

    meals_chain = MagicMock()
    meals_chain.select.return_value = meals_chain
    meals_chain.eq.return_value = meals_chain
    meals_chain.gte.return_value = meals_chain
    meals_chain.limit.return_value = meals_chain
    meals_res = MagicMock(data=meals_data or [])
    meals_res.count = meals_count
    meals_chain.execute.return_value = meals_res

    upsert_res = MagicMock(data=[{"id": "c-1", "type": "mood", "value": "okay"}])

    def table(name):
        if name == "daily_checkins":
            mock = MagicMock()
            mock.select.return_value = checkins_chain
            mock.upsert.return_value = MagicMock(
                execute=MagicMock(return_value=upsert_res)
            )
            return mock
        if name == "meals":
            return meals_chain
        return MagicMock()

    db.table.side_effect = table
    return db


class TestValidation:
    def test_valid_input(self):
        inp = CheckinInput(type="mood", value="okay")
        inp.validate()  # no raise

    def test_unknown_type(self):
        inp = CheckinInput(type="invalid", value="x")
        with pytest.raises(ValueError):
            inp.validate()

    def test_invalid_value_for_type(self):
        inp = CheckinInput(type="mood", value="amazing")  # not in allowed
        with pytest.raises(ValueError):
            inp.validate()

    def test_all_types_have_values(self):
        for t in VALID_TYPES:
            assert t in VALID_VALUES_BY_TYPE
            assert len(VALID_VALUES_BY_TYPE[t]) > 0


class TestCreate:
    @pytest.mark.asyncio
    async def test_create_mood(self):
        svc = CheckinService(_mock_db())
        result = await svc.create("u-1", CheckinInput(type="mood", value="okay"))
        assert result["ok"] is True

    @pytest.mark.asyncio
    async def test_create_empty_day(self):
        svc = CheckinService(_mock_db())
        result = await svc.create(
            "u-1", CheckinInput(type="empty_day", value="acknowledged")
        )
        assert result["ok"] is True

    @pytest.mark.asyncio
    async def test_create_with_payload(self):
        svc = CheckinService(_mock_db())
        result = await svc.create(
            "u-1",
            CheckinInput(
                type="craving",
                value="passed",
                payload={"trigger": "stress", "duration_min": 15},
            ),
        )
        assert result["ok"] is True


class TestQueries:
    @pytest.mark.asyncio
    async def test_get_today_empty(self):
        svc = CheckinService(_mock_db(checkins_data=[]))
        result = await svc.get_today("u-1")
        assert result["checkins"] == []
        assert "date" in result

    @pytest.mark.asyncio
    async def test_get_today_with_data(self):
        svc = CheckinService(_mock_db(checkins_data=[
            {"type": "mood", "value": "okay", "payload": {}, "created_at": "2026-05-01T10:00:00Z"}
        ]))
        result = await svc.get_today("u-1")
        assert len(result["checkins"]) == 1

    @pytest.mark.asyncio
    async def test_get_recent(self):
        svc = CheckinService(_mock_db(checkins_data=[
            {"checkin_date": "2026-04-30", "type": "mood", "value": "great", "payload": {}},
            {"checkin_date": "2026-04-29", "type": "mood", "value": "okay", "payload": {}},
        ]))
        result = await svc.get_recent("u-1", days=7)
        assert len(result["checkins"]) == 2


class TestEmptyDay:
    @pytest.mark.asyncio
    async def test_empty_day_when_no_meals(self):
        svc = CheckinService(_mock_db(meals_count=0))
        is_empty = await svc.is_empty_day("u-1")
        assert is_empty is True

    @pytest.mark.asyncio
    async def test_not_empty_when_meals_exist(self):
        svc = CheckinService(_mock_db(meals_count=3))
        is_empty = await svc.is_empty_day("u-1")
        assert is_empty is False
