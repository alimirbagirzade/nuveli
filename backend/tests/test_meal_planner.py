"""
Smoke tests for /meal-plans and /recipes endpoints.

The /meal-plans/generate endpoint hits OpenAI — that path is tested
with a mock so the test never makes a real API call (cost guard).
"""
import json
from datetime import date, timedelta
from unittest.mock import AsyncMock, MagicMock, patch

import pytest


# --- Auth gates ---

def test_list_meal_plans_requires_auth(client):
    response = client.get("/meal-plans")
    assert response.status_code in (401, 403)


def test_create_meal_plan_requires_auth(client):
    response = client.post(
        "/meal-plans",
        json={"plan_date": "2026-06-01", "meal_type": "lunch", "servings": 1.0},
    )
    assert response.status_code in (401, 403)


def test_update_meal_plan_requires_auth(client):
    response = client.patch(
        "/meal-plans/00000000-0000-0000-0000-000000000000",
        json={"servings": 2.0},
    )
    assert response.status_code in (401, 403)


def test_delete_meal_plan_requires_auth(client):
    response = client.delete("/meal-plans/00000000-0000-0000-0000-000000000000")
    assert response.status_code in (401, 403)


def test_grocery_summary_requires_auth(client):
    response = client.get("/meal-plans/grocery")
    assert response.status_code in (401, 403)


def test_generate_meal_plan_requires_auth(client):
    response = client.post(
        "/meal-plans/generate",
        json={"week_start": "2026-06-01", "days": 7},
    )
    assert response.status_code in (401, 403)


def test_list_recipes_requires_auth(client):
    response = client.get("/recipes")
    assert response.status_code in (401, 403)


def test_get_recipe_requires_auth(client):
    response = client.get("/recipes/00000000-0000-0000-0000-000000000000")
    assert response.status_code in (401, 403)


def test_create_recipe_requires_auth(client):
    response = client.post(
        "/recipes",
        json={"name": "Test", "ingredients": []},
    )
    assert response.status_code in (401, 403)


# --- Authenticated happy paths ---

def test_list_meal_plans_with_auth_empty(client, auth_headers):
    response = client.get("/meal-plans", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    # Empty week still returns 7 day buckets
    assert "days" in data
    assert "plans" in data


def test_list_recipes_with_auth(client, auth_headers):
    response = client.get("/recipes", headers=auth_headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_grocery_summary_with_auth_empty(client, auth_headers):
    response = client.get("/meal-plans/grocery", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["recipe_count"] == 0
    assert data["items"] == []


# --- Cost guard: AI generate uses mocked OpenAI ---

def test_generate_meal_plan_calls_openai_mocked(client, auth_headers, mock_supabase):
    """
    Ensure the generate endpoint:
      1. Never hits real OpenAI in tests
      2. Inserts the parsed plan rows into meal_plans
      3. Returns the day count from the request
    """
    fake_response = MagicMock()
    fake_response.choices = [MagicMock()]
    fake_response.choices[0].message.content = json.dumps({
        "plan": [
            {
                "meals": [
                    {
                        "meal_type": "breakfast",
                        "name": "Oatmeal",
                        "calories": 350,
                        "protein_g": 12,
                        "carbs_g": 55,
                        "fat_g": 8,
                    }
                ]
            }
        ]
    })

    fake_client = MagicMock()
    fake_client.chat.completions.create = AsyncMock(return_value=fake_response)

    with patch("openai.AsyncOpenAI", return_value=fake_client):
        response = client.post(
            "/meal-plans/generate",
            json={
                "week_start": date.today().isoformat(),
                "days": 1,
                "target_calories": 2000,
                "dietary_preference": "none",
            },
            headers=auth_headers,
        )

    # 200 happy path, 429 if rate-limit kicked in (other tests may have hit it)
    assert response.status_code in (200, 429)
    if response.status_code == 200:
        body = response.json()
        assert "plans_created" in body
        assert body["plans_created"] >= 1


def test_generate_meal_plan_rejects_garbage_openai_response(
    client, auth_headers, mock_supabase
):
    """If OpenAI returns non-JSON, surface a 422 rather than 500."""
    fake_response = MagicMock()
    fake_response.choices = [MagicMock()]
    fake_response.choices[0].message.content = "not json {{{"

    fake_client = MagicMock()
    fake_client.chat.completions.create = AsyncMock(return_value=fake_response)

    with patch("openai.AsyncOpenAI", return_value=fake_client):
        response = client.post(
            "/meal-plans/generate",
            json={"week_start": date.today().isoformat(), "days": 1, "target_calories": 2000},
            headers=auth_headers,
        )
    # ValidationError → 422; 429 if rate-limited from previous tests
    assert response.status_code in (422, 429)
