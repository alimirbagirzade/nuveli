"""
Smoke tests for /habits endpoints.
"""


# --- Auth gates ---

def test_list_habits_requires_auth(client):
    response = client.get("/habits")
    assert response.status_code in (401, 403)


def test_create_habit_requires_auth(client):
    response = client.post(
        "/habits",
        json={"name": "Drink water", "icon": "water"},
    )
    assert response.status_code in (401, 403)


def test_update_habit_requires_auth(client):
    response = client.patch(
        "/habits/00000000-0000-0000-0000-000000000000",
        json={"name": "Renamed"},
    )
    assert response.status_code in (401, 403)


def test_delete_habit_requires_auth(client):
    response = client.delete("/habits/00000000-0000-0000-0000-000000000000")
    assert response.status_code in (401, 403)


def test_complete_habit_requires_auth(client):
    response = client.post("/habits/00000000-0000-0000-0000-000000000000/complete")
    assert response.status_code in (401, 403)


def test_uncomplete_habit_requires_auth(client):
    response = client.delete("/habits/00000000-0000-0000-0000-000000000000/complete")
    assert response.status_code in (401, 403)


def test_weekly_consistency_requires_auth(client):
    response = client.get("/habits/weekly")
    assert response.status_code in (401, 403)


def test_habit_streak_requires_auth(client):
    response = client.get("/habits/streak")
    assert response.status_code in (401, 403)


# --- Authenticated happy paths ---

def test_list_habits_with_auth_empty(client, auth_headers):
    response = client.get("/habits", headers=auth_headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_weekly_consistency_with_auth(client, auth_headers):
    response = client.get("/habits/weekly", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "days" in data
    assert len(data["days"]) == 7
    assert "week_avg_percent" in data


def test_complete_nonexistent_habit_returns_404(client, auth_headers, mock_supabase):
    """IDOR + not-found guard: completing an unowned habit must 404, not silently succeed."""
    response = client.post(
        "/habits/00000000-0000-0000-0000-000000000000/complete",
        headers=auth_headers,
    )
    # mock_supabase returns empty for the ownership check → NotFound → 404
    assert response.status_code == 404
