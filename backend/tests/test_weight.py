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
