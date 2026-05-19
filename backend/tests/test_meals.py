"""
Smoke tests for /meals endpoints.
"""


def test_list_meals_requires_auth(client):
    response = client.get("/meals")
    assert response.status_code in (401, 403)


def test_today_summary_requires_auth(client):
    response = client.get("/meals/today/summary")
    assert response.status_code in (401, 403)


def test_meal_scan_requires_auth(client):
    response = client.post("/meals/scan", json={"image_base64": "abc"})
    assert response.status_code in (401, 403)


def test_create_meal_requires_auth(client):
    response = client.post(
        "/meals",
        json={"meal_type": "breakfast", "foods": []},
    )
    assert response.status_code in (401, 403)


def test_list_meals_with_auth_empty(client, auth_headers):
    """With valid auth and empty mock results, should return empty list."""
    response = client.get("/meals", headers=auth_headers)
    # Either 200 with [] or a structured paginated empty payload
    assert response.status_code == 200
