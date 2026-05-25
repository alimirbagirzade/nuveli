"""
Tests for /exercise endpoints (Manual Exercise Logging — V1.1).

WELLNESS BOUNDARY: exercise calories are DISPLAY-ONLY. Tests assert the
est_calories / total_calories figures are computed via the MET formula for the
UI badge, that they are None when weight is unknown, and that NO endpoint ever
mutates a calorie budget/goal (no update/upsert on a profile calorie target).
"""
from unittest.mock import MagicMock

import pytest


@pytest.fixture
def exercise_db(mock_supabase, monkeypatch):
    """
    Bind the exercise router's Supabase handle to *this* test's mock.

    The routers do `from core.supabase_client import get_supabase`, so they
    hold an import-bound reference. conftest's `mock_supabase` only patches
    the module attribute `core.supabase_client.get_supabase` — which the
    router never re-reads. Worse, all routers bind their `get_supabase` the
    very first time any test imports `main`, so they'd otherwise be frozen to
    the *first* test's fake for the whole session.

    Patching `routers.exercise.get_supabase` directly makes data-injection
    tests deterministic regardless of suite order. Returns the same fake as
    `mock_supabase` so `.table.return_value.execute.return_value` overrides
    flow straight through to the router.
    """
    import routers.exercise as rex
    monkeypatch.setattr(rex, "get_supabase", lambda: mock_supabase)
    return mock_supabase


def _make_chain(execute_data):
    """A fully chainable Supabase-query mock whose .execute() yields the given
    data. Mirrors conftest's _chainable but returns the supplied rows."""
    m = MagicMock()
    for method in (
        "select", "insert", "update", "upsert", "delete", "eq", "neq",
        "gt", "gte", "lt", "lte", "in_", "is_", "like", "ilike", "or_",
        "order", "limit", "range", "single", "maybe_single",
    ):
        getattr(m, method).return_value = m
    m.execute.return_value = MagicMock(data=execute_data, count=len(execute_data))
    return m


@pytest.fixture
def exercise_db_by_table(mock_supabase, monkeypatch):
    """
    Like `exercise_db`, but routes `.table(name)` to a per-table chain so a
    test can supply the user's weight (user_profiles / weight_logs) separately
    from exercise_logs rows. The GET handlers now issue a weight lookup in
    addition to the exercise query, so they need distinct return values.

    Returns a setter: `set_table('user_profiles', [{'weight_kg': 70}])`.
    Tables without explicit data fall back to empty rows.
    """
    import routers.exercise as rex
    monkeypatch.setattr(rex, "get_supabase", lambda: mock_supabase)

    table_data: dict[str, list] = {}

    def _table(name):
        return _make_chain(table_data.get(name, []))

    mock_supabase.table = MagicMock(side_effect=_table)

    def set_table(name, data):
        table_data[name] = data

    return set_table


# --- Auth gates ---

def test_create_log_requires_auth(client):
    response = client.post(
        "/exercise/logs",
        json={"activity_type": "running", "duration_min": 30},
    )
    assert response.status_code in (401, 403)


def test_list_logs_requires_auth(client):
    response = client.get("/exercise/logs")
    assert response.status_code in (401, 403)


def test_delete_log_requires_auth(client):
    response = client.delete("/exercise/logs/00000000-0000-0000-0000-000000000000")
    assert response.status_code in (401, 403)


def test_today_summary_requires_auth(client):
    response = client.get("/exercise/today/summary")
    assert response.status_code in (401, 403)


def test_weekly_requires_auth(client):
    response = client.get("/exercise/weekly")
    assert response.status_code in (401, 403)


# --- Create log ---

def test_create_log_returns_201(client, auth_headers, exercise_db):
    """A successful insert echoes the stored row as ExerciseLogResponse."""
    exercise_db.table.return_value.execute.return_value = MagicMock(
        data=[{
            "id": "22222222-2222-2222-2222-222222222222",
            "user_id": "11111111-1111-1111-1111-111111111111",
            "activity_type": "running",
            "duration_min": 30,
            "intensity": "moderate",
            "note": "evening jog",
            "logged_at": "2026-05-25T18:00:00+00:00",
            "created_at": "2026-05-25T18:00:01+00:00",
        }],
        count=1,
    )
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={
            "activity_type": "running",
            "duration_min": 30,
            "intensity": "moderate",
            "note": "evening jog",
        },
    )
    assert response.status_code == 201
    body = response.json()
    assert body["activity_type"] == "running"
    assert body["duration_min"] == 30
    assert body["intensity"] == "moderate"
    # WELLNESS BOUNDARY
    assert "calories" not in body
    assert "calories_burned" not in body


def test_create_log_sets_user_and_local_day(client, auth_headers, exercise_db):
    """The insert payload must carry the authenticated user_id and an explicit
    local_day so rows land in the right calendar bucket regardless of drift."""
    exercise_db.table.return_value.execute.return_value = MagicMock(
        data=[{
            "id": "22222222-2222-2222-2222-222222222222",
            "user_id": "11111111-1111-1111-1111-111111111111",
            "activity_type": "yoga",
            "duration_min": 45,
            "intensity": None,
            "note": None,
            "logged_at": "2026-05-25T07:00:00+00:00",
            "created_at": "2026-05-25T07:00:01+00:00",
        }],
        count=1,
    )
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "yoga", "duration_min": 45},
    )
    assert response.status_code == 201
    insert_call = exercise_db.table.return_value.insert.call_args
    sent = insert_call.args[0]
    assert sent["user_id"] == "11111111-1111-1111-1111-111111111111"
    assert "local_day" in sent
    # No energy/calorie field is ever sent to the DB.
    assert "calories" not in sent
    assert "calories_burned" not in sent


# --- activity_type normalization ---

def test_unknown_activity_type_normalizes_to_other(client, auth_headers, exercise_db):
    """An out-of-vocabulary activity_type is rewritten to 'other' before the
    DB ever sees it."""
    exercise_db.table.return_value.execute.return_value = MagicMock(
        data=[{
            "id": "22222222-2222-2222-2222-222222222222",
            "user_id": "11111111-1111-1111-1111-111111111111",
            "activity_type": "other",
            "duration_min": 20,
            "intensity": None,
            "note": None,
            "logged_at": "2026-05-25T10:00:00+00:00",
            "created_at": "2026-05-25T10:00:01+00:00",
        }],
        count=1,
    )
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "underwater-basket-weaving", "duration_min": 20},
    )
    assert response.status_code == 201
    sent = exercise_db.table.return_value.insert.call_args.args[0]
    assert sent["activity_type"] == "other"


def test_known_activity_type_case_insensitive(client, auth_headers, exercise_db):
    """Mixed-case / padded known types are normalized but preserved."""
    exercise_db.table.return_value.execute.return_value = MagicMock(
        data=[{
            "id": "22222222-2222-2222-2222-222222222222",
            "user_id": "11111111-1111-1111-1111-111111111111",
            "activity_type": "cycling",
            "duration_min": 60,
            "intensity": None,
            "note": None,
            "logged_at": "2026-05-25T10:00:00+00:00",
            "created_at": "2026-05-25T10:00:01+00:00",
        }],
        count=1,
    )
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "  Cycling ", "duration_min": 60},
    )
    assert response.status_code == 201
    sent = exercise_db.table.return_value.insert.call_args.args[0]
    assert sent["activity_type"] == "cycling"


# --- duration validation ---

def test_duration_zero_rejected(client, auth_headers):
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "walking", "duration_min": 0},
    )
    assert response.status_code == 422


def test_duration_over_max_rejected(client, auth_headers):
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "walking", "duration_min": 1441},
    )
    assert response.status_code == 422


def test_duration_at_max_accepted(client, auth_headers, exercise_db):
    exercise_db.table.return_value.execute.return_value = MagicMock(
        data=[{
            "id": "22222222-2222-2222-2222-222222222222",
            "user_id": "11111111-1111-1111-1111-111111111111",
            "activity_type": "walking",
            "duration_min": 1440,
            "intensity": None,
            "note": None,
            "logged_at": "2026-05-25T10:00:00+00:00",
            "created_at": "2026-05-25T10:00:01+00:00",
        }],
        count=1,
    )
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "walking", "duration_min": 1440},
    )
    assert response.status_code == 201


def test_invalid_intensity_rejected(client, auth_headers):
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "gym", "duration_min": 30, "intensity": "extreme"},
    )
    assert response.status_code == 422


# --- List by date ---

def test_list_logs_with_auth_empty(client, auth_headers):
    response = client.get("/exercise/logs", headers=auth_headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_list_logs_filters_by_local_day(client, auth_headers, exercise_db):
    """A ?date= query filters on local_day for that exact calendar day."""
    exercise_db.table.return_value.execute.return_value = MagicMock(
        data=[{
            "id": "22222222-2222-2222-2222-222222222222",
            "user_id": "11111111-1111-1111-1111-111111111111",
            "activity_type": "swimming",
            "duration_min": 40,
            "intensity": "vigorous",
            "note": None,
            "logged_at": "2026-05-20T12:00:00+00:00",
            "created_at": "2026-05-20T12:00:01+00:00",
        }],
        count=1,
    )
    response = client.get("/exercise/logs?date=2026-05-20", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert len(body) == 1
    assert body[0]["activity_type"] == "swimming"
    # local_day equality filter was applied with the requested date.
    eq_args = [c.args for c in exercise_db.table.return_value.eq.call_args_list]
    assert ("local_day", "2026-05-20") in eq_args
    # No calorie data leaks into list responses.
    for row in body:
        assert "calories" not in row
        assert "calories_burned" not in row


# --- Delete ---

def test_delete_existing_log_returns_204(client, auth_headers, exercise_db):
    exercise_db.table.return_value.execute.return_value = MagicMock(
        data=[{"id": "22222222-2222-2222-2222-222222222222"}],
        count=1,
    )
    response = client.delete(
        "/exercise/logs/22222222-2222-2222-2222-222222222222",
        headers=auth_headers,
    )
    assert response.status_code == 204


def test_delete_nonexistent_log_returns_404(client, auth_headers, exercise_db):
    """Owner-scoped delete returning no rows → NotFound, not silent success."""
    # Default mock returns data=[] → NotFound.
    response = client.delete(
        "/exercise/logs/00000000-0000-0000-0000-000000000000",
        headers=auth_headers,
    )
    assert response.status_code == 404


# --- Today summary ---

def test_today_summary_with_auth_empty(client, auth_headers):
    response = client.get("/exercise/today/summary", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["total_minutes"] == 0
    assert body["sessions_count"] == 0
    assert body["active"] is False
    assert body["activity_types"] == []
    assert "calories" not in body
    assert "calories_burned" not in body


def test_today_summary_aggregates(client, auth_headers, exercise_db):
    """Totals sum minutes, count sessions, list distinct types, set active."""
    exercise_db.table.return_value.execute.return_value = MagicMock(
        data=[
            {"activity_type": "running", "duration_min": 30},
            {"activity_type": "yoga", "duration_min": 45},
            {"activity_type": "running", "duration_min": 15},
        ],
        count=3,
    )
    response = client.get("/exercise/today/summary", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["total_minutes"] == 90
    assert body["sessions_count"] == 3
    assert body["active"] is True
    # Distinct, first-seen order.
    assert body["activity_types"] == ["running", "yoga"]
    assert "calories" not in body
    assert "calories_burned" not in body


# --- Weekly ---

def test_weekly_returns_seven_buckets(client, auth_headers):
    """Always 7 day buckets even on a fresh user — chart needs a stable strip."""
    response = client.get("/exercise/weekly", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert "days" in body
    assert len(body["days"]) == 7
    assert body["week_total_minutes"] == 0
    assert body["active_days"] == 0
    for d in body["days"]:
        assert "day" in d
        assert "total_minutes" in d
        assert "sessions_count" in d
        assert d["total_minutes"] == 0
        assert d["sessions_count"] == 0
    # No calorie/budget keys anywhere in the weekly payload.
    assert "calories" not in body
    assert "week_calories" not in body


def test_weekly_aggregates_minutes_and_active_days(client, auth_headers, exercise_db):
    """Two sessions on one day collapse into a single active day; week total
    sums all minutes."""
    today = __import__("datetime").date.today()
    d1 = today.isoformat()
    d2 = (today - __import__("datetime").timedelta(days=2)).isoformat()
    exercise_db.table.return_value.execute.return_value = MagicMock(
        data=[
            {"duration_min": 30, "local_day": d1},
            {"duration_min": 20, "local_day": d1},
            {"duration_min": 50, "local_day": d2},
        ],
        count=3,
    )
    response = client.get("/exercise/weekly", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert len(body["days"]) == 7
    assert body["week_total_minutes"] == 100
    assert body["active_days"] == 2
    # The most-recent bucket (today) holds the two collapsed sessions.
    assert body["days"][-1]["total_minutes"] == 50
    assert body["days"][-1]["sessions_count"] == 2


# =============================================================================
# DISPLAY-ONLY calorie estimate (MET-based). See services/exercise_calories.py.
# =============================================================================

# --- Pure helper unit tests (no HTTP) ---

def test_estimate_calories_known_case_running():
    """running 30min moderate @ 70kg → 9.0 MET × 70 × 0.5 = 315 kcal."""
    from services.exercise_calories import estimate_calories
    assert estimate_calories("running", 30, "moderate", 70) == 315


def test_estimate_calories_null_intensity_is_moderate():
    """Null intensity uses the moderate (1.0) multiplier."""
    from services.exercise_calories import estimate_calories
    # walking 60min @ 70kg, moderate: 3.5 × 70 × 1.0 = 245
    assert estimate_calories("walking", 60, None, 70) == 245


def test_estimate_calories_intensity_multipliers():
    """light=0.8, moderate=1.0, vigorous=1.25 scale the base MET."""
    from services.exercise_calories import estimate_calories
    # cycling 60min @ 80kg, base MET 7.5 → effective 7.5 × mult × 80
    light = estimate_calories("cycling", 60, "light", 80)       # 7.5×0.8×80 = 480
    moderate = estimate_calories("cycling", 60, "moderate", 80)  # 7.5×1.0×80 = 600
    vigorous = estimate_calories("cycling", 60, "vigorous", 80)  # 7.5×1.25×80 = 750
    assert light == 480
    assert moderate == 600
    assert vigorous == 750


def test_estimate_calories_none_when_weight_unknown():
    """No weight → None (we never guess a default weight)."""
    from services.exercise_calories import estimate_calories
    assert estimate_calories("running", 30, "moderate", None) is None
    assert estimate_calories("running", 30, "moderate", 0) is None


def test_estimate_calories_unknown_activity_uses_other_met():
    """An activity_type not in the MET table falls back to 'other' (4.0)."""
    from services.exercise_calories import estimate_calories
    # 'other' 60min @ 70kg moderate: 4.0 × 70 × 1.0 = 280
    assert estimate_calories("other", 60, "moderate", 70) == 280
    assert estimate_calories("not-a-real-type", 60, "moderate", 70) == 280


def test_estimate_calories_new_activity_types_have_met():
    """Each newly-added activity type yields a positive estimate."""
    from services.exercise_calories import estimate_calories, BASE_MET
    for at in ("hiking", "pilates", "dancing", "hiit", "jump_rope", "rowing"):
        assert at in BASE_MET
        assert estimate_calories(at, 30, "moderate", 70) > 0


# --- est_calories echoed on POST /logs ---

def test_create_log_echoes_est_calories(client, auth_headers, exercise_db_by_table):
    """POST /logs echoes a DISPLAY-ONLY est_calories computed from the user's
    weight. running 30min moderate @ 70kg → 315 kcal."""
    exercise_db_by_table("user_profiles", [{"weight_kg": 70}])
    exercise_db_by_table("exercise_logs", [{
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": "11111111-1111-1111-1111-111111111111",
        "activity_type": "running",
        "duration_min": 30,
        "intensity": "moderate",
        "note": None,
        "logged_at": "2026-05-25T18:00:00+00:00",
        "created_at": "2026-05-25T18:00:01+00:00",
    }])
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "running", "duration_min": 30, "intensity": "moderate"},
    )
    assert response.status_code == 201
    body = response.json()
    assert body["est_calories"] == 315
    # WELLNESS BOUNDARY: estimate is display-only; no budget/goal key present.
    assert "calories_burned" not in body
    assert "calorie_target" not in body
    assert "calorie_budget" not in body


def test_create_log_est_calories_none_without_weight(client, auth_headers, exercise_db_by_table):
    """No profile weight and no weight_logs → est_calories is None."""
    # Both weight sources empty (default).
    exercise_db_by_table("exercise_logs", [{
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": "11111111-1111-1111-1111-111111111111",
        "activity_type": "running",
        "duration_min": 30,
        "intensity": "moderate",
        "note": None,
        "logged_at": "2026-05-25T18:00:00+00:00",
        "created_at": "2026-05-25T18:00:01+00:00",
    }])
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "running", "duration_min": 30, "intensity": "moderate"},
    )
    assert response.status_code == 201
    assert response.json()["est_calories"] is None


def test_create_log_weight_falls_back_to_weight_logs(client, auth_headers, exercise_db_by_table):
    """When profile has no weight, the most recent weight_logs row is used."""
    # user_profiles empty → fall back to weight_logs.
    exercise_db_by_table("weight_logs", [{"weight_kg": 70, "logged_at": "2026-05-24T08:00:00+00:00"}])
    exercise_db_by_table("exercise_logs", [{
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": "11111111-1111-1111-1111-111111111111",
        "activity_type": "running",
        "duration_min": 30,
        "intensity": "moderate",
        "note": None,
        "logged_at": "2026-05-25T18:00:00+00:00",
        "created_at": "2026-05-25T18:00:01+00:00",
    }])
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "running", "duration_min": 30, "intensity": "moderate"},
    )
    assert response.status_code == 201
    assert response.json()["est_calories"] == 315


# --- est_calories on GET /logs ---

def test_list_logs_annotates_est_calories(client, auth_headers, exercise_db_by_table):
    """Each listed log gets a display-only est_calories from a single weight read."""
    exercise_db_by_table("user_profiles", [{"weight_kg": 70}])
    exercise_db_by_table("exercise_logs", [{
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": "11111111-1111-1111-1111-111111111111",
        "activity_type": "running",
        "duration_min": 30,
        "intensity": "moderate",
        "note": None,
        "logged_at": "2026-05-25T18:00:00+00:00",
        "created_at": "2026-05-25T18:00:01+00:00",
    }])
    response = client.get("/exercise/logs", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert len(body) == 1
    assert body[0]["est_calories"] == 315


# --- total_calories on GET /today/summary ---

def test_today_summary_total_calories(client, auth_headers, exercise_db_by_table):
    """total_calories sums per-session MET estimates (display-only).

    running 30min moderate (315) + yoga 60min vigorous (2.5×1.25×70×1.0=219)
    @ 70kg → 534."""
    exercise_db_by_table("user_profiles", [{"weight_kg": 70}])
    exercise_db_by_table("exercise_logs", [
        {"activity_type": "running", "duration_min": 30, "intensity": "moderate"},
        {"activity_type": "yoga", "duration_min": 60, "intensity": "vigorous"},
    ])
    response = client.get("/exercise/today/summary", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["total_minutes"] == 90
    # 315 + round(2.5 × 1.25 × 70 × 1.0) = 315 + 219 = 534
    assert body["total_calories"] == 534


def test_today_summary_total_calories_none_without_weight(client, auth_headers, exercise_db_by_table):
    """No weight available → total_calories is None (not 0)."""
    exercise_db_by_table("exercise_logs", [
        {"activity_type": "running", "duration_min": 30, "intensity": "moderate"},
    ])
    response = client.get("/exercise/today/summary", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["total_minutes"] == 30
    assert body["total_calories"] is None


# --- total_calories on GET /weekly ---

def test_weekly_total_calories(client, auth_headers, exercise_db_by_table):
    """Per-day and week calorie totals are display-only sums of MET estimates."""
    today = __import__("datetime").date.today()
    d1 = today.isoformat()
    exercise_db_by_table("user_profiles", [{"weight_kg": 70}])
    exercise_db_by_table("exercise_logs", [
        {"duration_min": 30, "local_day": d1, "activity_type": "running", "intensity": "moderate"},
        {"duration_min": 60, "local_day": d1, "activity_type": "walking", "intensity": None},
    ])
    response = client.get("/exercise/weekly", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    # running 315 + walking 60min moderate (3.5×70×1.0=245) = 560
    assert body["week_total_calories"] == 560
    assert body["days"][-1]["total_calories"] == 560


def test_weekly_total_calories_none_without_weight(client, auth_headers, exercise_db_by_table):
    """No weight → week + per-day calorie totals are None, minutes still report."""
    today = __import__("datetime").date.today()
    exercise_db_by_table("exercise_logs", [
        {"duration_min": 30, "local_day": today.isoformat(),
         "activity_type": "running", "intensity": "moderate"},
    ])
    response = client.get("/exercise/weekly", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["week_total_minutes"] == 30
    assert body["week_total_calories"] is None
    assert all(d["total_calories"] is None for d in body["days"])


# --- new activity types accepted end-to-end ---

@pytest.mark.parametrize("activity", ["hiking", "pilates", "dancing", "hiit", "jump_rope", "rowing"])
def test_new_activity_types_accepted(client, auth_headers, exercise_db_by_table, activity):
    """The 6 newly-added activity types log without normalizing to 'other'."""
    exercise_db_by_table("exercise_logs", [{
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": "11111111-1111-1111-1111-111111111111",
        "activity_type": activity,
        "duration_min": 30,
        "intensity": None,
        "note": None,
        "logged_at": "2026-05-25T18:00:00+00:00",
        "created_at": "2026-05-25T18:00:01+00:00",
    }])
    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": activity, "duration_min": 30},
    )
    assert response.status_code == 201
    # Validator kept the type (it's in the allowed set), not normalized away.
    from models.exercise import ACTIVITY_TYPES
    assert activity in ACTIVITY_TYPES


def test_activity_validator_normalizes_unknown_to_other():
    """Model-level: unknown activity_type → 'other'; known preserved."""
    from models.exercise import ExerciseLogCreate
    assert ExerciseLogCreate(activity_type="quidditch", duration_min=30).activity_type == "other"
    assert ExerciseLogCreate(activity_type="  Jump_Rope ", duration_min=30).activity_type == "jump_rope"
    assert ExerciseLogCreate(activity_type="HIIT", duration_min=30).activity_type == "hiit"


# --- WELLNESS BOUNDARY: estimate never mutates a budget/goal ---

def test_no_endpoint_mutates_calorie_goal(client, auth_headers, exercise_db_by_table):
    """Logging exercise must NOT write to any calorie target/budget. The only
    table the create path may write to is exercise_logs (insert); weight tables
    are read-only here, and user_profiles is never updated with a calorie goal."""
    import routers.exercise as rex

    writes: list[tuple] = []

    exercise_db_by_table("user_profiles", [{"weight_kg": 70}])
    exercise_db_by_table("exercise_logs", [{
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": "11111111-1111-1111-1111-111111111111",
        "activity_type": "running",
        "duration_min": 30,
        "intensity": "moderate",
        "note": None,
        "logged_at": "2026-05-25T18:00:00+00:00",
        "created_at": "2026-05-25T18:00:01+00:00",
    }])

    sb = rex.get_supabase()
    orig_table = sb.table

    def recording_table(name):
        chain = orig_table(name)
        real_insert, real_update, real_upsert = chain.insert, chain.update, chain.upsert

        def rec_insert(*a, **k):
            writes.append(("insert", name))
            return real_insert(*a, **k)

        def rec_update(*a, **k):
            writes.append(("update", name))
            return real_update(*a, **k)

        def rec_upsert(*a, **k):
            writes.append(("upsert", name))
            return real_upsert(*a, **k)

        chain.insert = rec_insert
        chain.update = rec_update
        chain.upsert = rec_upsert
        return chain

    sb.table = recording_table

    response = client.post(
        "/exercise/logs",
        headers=auth_headers,
        json={"activity_type": "running", "duration_min": 30, "intensity": "moderate"},
    )
    assert response.status_code == 201
    # The ONLY write is the exercise_logs insert. No write to user_profiles,
    # weight_logs, or any calorie-goal-bearing table.
    assert writes == [("insert", "exercise_logs")]
    written_tables = {name for _, name in writes}
    assert "user_profiles" not in written_tables
    assert "weight_logs" not in written_tables
