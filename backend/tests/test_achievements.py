"""
Smoke tests for /achievements endpoints.
"""
from unittest.mock import AsyncMock, patch


def test_list_achievements_requires_auth(client):
    response = client.get("/achievements")
    assert response.status_code in (401, 403)


def test_check_achievements_requires_auth(client):
    response = client.post("/achievements/check")
    assert response.status_code in (401, 403)


def test_list_achievements_with_auth(client, auth_headers):
    """
    The router calls `services.achievement_service.list_user_achievements`.
    We mock it so the test is a pure auth + shape check.
    """
    fake_rows = [
        {
            "id": None,
            "code": "first_meal",
            "title": "First Meal",
            "description": "Log your first meal",
            "icon": "fork",
            "category": "milestone",
            "target_value": 1,
            "current_progress": 1,
            "percent_complete": 100,
            "unlocked": True,
            "unlocked_at": "2026-05-01T00:00:00Z",
        }
    ]
    with patch(
        "routers.achievements.list_user_achievements",
        new=AsyncMock(return_value=fake_rows),
    ):
        response = client.get("/achievements", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert isinstance(body, list)
    assert body[0]["code"] == "first_meal"
    assert body[0]["unlocked"] is True


def test_check_achievements_with_auth_no_new_unlocks(client, auth_headers):
    with patch(
        "routers.achievements.check_and_unlock",
        new=AsyncMock(return_value=[]),
    ), patch(
        "routers.achievements.list_user_achievements",
        new=AsyncMock(return_value=[]),
    ):
        response = client.post("/achievements/check", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["newly_unlocked"] == []
    assert body["total_unlocked"] == 0
    assert body["total_available"] == 0


def test_list_achievements_swallows_service_error_as_500(client, auth_headers):
    """Service failure surfaces as 500, not a stacktrace leak."""
    with patch(
        "routers.achievements.list_user_achievements",
        new=AsyncMock(side_effect=RuntimeError("db down")),
    ):
        response = client.get("/achievements", headers=auth_headers)
    assert response.status_code == 500
    assert "Failed to load achievements" in response.json().get("detail", "")
