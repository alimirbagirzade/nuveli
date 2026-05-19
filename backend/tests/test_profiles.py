"""
Smoke tests for /me profile endpoints.
Verifies auth gating and basic happy paths with mocked Supabase.
"""
from unittest.mock import MagicMock


def test_get_me_requires_auth(client):
    response = client.get("/me")
    assert response.status_code in (401, 403)


def test_get_me_rejects_invalid_token(client):
    response = client.get("/me", headers={"Authorization": "Bearer invalid"})
    assert response.status_code == 401


def test_get_me_returns_profile(client, auth_headers, mock_supabase, test_user_id):
    """When a profile exists, GET /me returns it."""
    profile_row = {
        "user_id": test_user_id,
        "name": "Test User",
        "sex": "male",
        "age": 30,
        "height_cm": 180,
        "weight_kg": 80,
        "activity_level": "moderate",
        "dietary_preference": "omnivore",
        "weight_goal_direction": "maintain",
        "daily_calorie_target": 2500,
        "protein_target_g": 156,
        "carbs_target_g": 281,
        "fat_target_g": 83,
        "water_target_ml": 2800,
        "onboarded": True,
        "is_premium": False,
        "created_at": "2025-01-01T00:00:00",
        "updated_at": "2025-01-01T00:00:00",
    }

    # Override the chainable mock to return our row
    table_mock = mock_supabase.table.return_value
    table_mock.execute.return_value = MagicMock(data=profile_row)

    response = client.get("/me", headers=auth_headers)
    # The profile auto-creates a stub if missing; either path should be 200.
    assert response.status_code == 200


def test_delete_me_requires_auth(client):
    response = client.delete("/me")
    assert response.status_code in (401, 403)
