"""
Smoke tests for /weight endpoints (logs + goals).
"""


# --- Auth gates ---

def test_create_weight_log_requires_auth(client):
    response = client.post("/weight/logs", json={"weight_kg": 75.0})
    assert response.status_code in (401, 403)


def test_list_weight_logs_requires_auth(client):
    response = client.get("/weight/logs")
    assert response.status_code in (401, 403)


def test_delete_weight_log_requires_auth(client):
    response = client.delete("/weight/logs/00000000-0000-0000-0000-000000000000")
    assert response.status_code in (401, 403)


def test_get_goal_requires_auth(client):
    response = client.get("/weight/goal")
    assert response.status_code in (401, 403)


def test_create_goal_requires_auth(client):
    response = client.post(
        "/weight/goal",
        json={"target_kg": 70.0, "target_date": "2026-12-01"},
    )
    assert response.status_code in (401, 403)


def test_update_goal_requires_auth(client):
    response = client.patch("/weight/goal", json={"target_kg": 68.0})
    assert response.status_code in (401, 403)


# --- Authenticated happy paths ---

def test_list_weight_logs_with_auth(client, auth_headers):
    response = client.get("/weight/logs", headers=auth_headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_list_weight_logs_period_parsing(client, auth_headers):
    """Verify period query parameter is accepted in various forms."""
    for period in ("7d", "4w", "3m", "1y"):
        response = client.get(f"/weight/logs?period={period}", headers=auth_headers)
        assert response.status_code == 200, f"period={period} failed"


def test_get_goal_returns_null_when_none_set(client, auth_headers):
    """No active goal → endpoint returns null (200), not 404."""
    response = client.get("/weight/goal", headers=auth_headers)
    assert response.status_code == 200
    assert response.json() is None


# --- DB ↔ API column-name adapter tests ---
# Live DB has start_weight_kg / target_weight_kg / no `direction`.
# Pydantic + Flutter use starting_weight_kg / target_kg / direction.
# These tests pin the bidirectional mapping in _db_to_api / _api_to_db.

class TestDbApiAdapters:
    def test_db_to_api_renames_columns(self):
        from routers.weight import _db_to_api

        out = _db_to_api({
            "id": "g-1",
            "user_id": "u-1",
            "start_weight_kg": 90.0,
            "target_weight_kg": 75.0,
            "status": "active",
        })
        assert out["starting_weight_kg"] == 90.0
        assert out["target_kg"] == 75.0

    def test_db_to_api_infers_direction_lose(self):
        from routers.weight import _db_to_api
        out = _db_to_api({"start_weight_kg": 90, "target_weight_kg": 75})
        assert out["direction"] == "lose"

    def test_db_to_api_infers_direction_gain(self):
        from routers.weight import _db_to_api
        out = _db_to_api({"start_weight_kg": 60, "target_weight_kg": 70})
        assert out["direction"] == "gain"

    def test_db_to_api_infers_direction_maintain(self):
        from routers.weight import _db_to_api
        out = _db_to_api({"start_weight_kg": 75, "target_weight_kg": 75})
        assert out["direction"] == "maintain"

    def test_db_to_api_preserves_existing_direction(self):
        from routers.weight import _db_to_api
        out = _db_to_api({
            "start_weight_kg": 90,
            "target_weight_kg": 75,
            "direction": "maintain",
        })
        # Explicit value beats inference (forward-compat for if/when the
        # column is added to the DB).
        assert out["direction"] == "maintain"

    def test_api_to_db_strips_direction(self):
        from routers.weight import _api_to_db
        out = _api_to_db({
            "starting_weight_kg": 90,
            "target_kg": 75,
            "direction": "lose",
            "target_date": "2026-12-31",
        })
        assert "direction" not in out
        assert out["start_weight_kg"] == 90
        assert out["target_weight_kg"] == 75
        assert out["target_date"] == "2026-12-31"

    def test_roundtrip_db_to_api_to_db(self):
        from routers.weight import _api_to_db, _db_to_api
        original = {
            "start_weight_kg": 90.0,
            "target_weight_kg": 75.0,
            "status": "active",
        }
        api_shape = _db_to_api(original)
        back_to_db = _api_to_db(api_shape)
        assert back_to_db["start_weight_kg"] == 90.0
        assert back_to_db["target_weight_kg"] == 75.0
        assert "direction" not in back_to_db
