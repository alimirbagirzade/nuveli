"""
Smoke tests for /analytics endpoints.

Covers auth gating and that authenticated calls return the documented
shape on empty data — important because the dashboard endpoint is the
first thing called on app open and silent shape drift would crash UI.
"""


def test_dashboard_requires_auth(client):
    response = client.get("/analytics/dashboard")
    assert response.status_code in (401, 403)


def test_weekly_requires_auth(client):
    response = client.get("/analytics/weekly")
    assert response.status_code in (401, 403)


def test_weight_trend_requires_auth(client):
    response = client.get("/analytics/weight-trend")
    assert response.status_code in (401, 403)


def test_macro_breakdown_requires_auth(client):
    response = client.get("/analytics/macro-breakdown")
    assert response.status_code in (401, 403)


def test_dashboard_with_auth_returns_expected_shape(client, auth_headers):
    response = client.get("/analytics/dashboard", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    # Contract: app expects these keys regardless of data presence
    for key in (
        "today_summary",
        "streak_days",
        "recent_meals",
        "water_consumed_ml",
        "water_target_ml",
    ):
        assert key in data, f"missing key: {key}"


def test_weekly_with_auth_returns_seven_days(client, auth_headers):
    response = client.get("/analytics/weekly", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "days" in data
    assert len(data["days"]) == 7
    assert "avg_daily_calories" in data
    assert "avg_macro_breakdown" in data


def test_weight_trend_with_auth(client, auth_headers):
    response = client.get("/analytics/weight-trend?period=4w", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "points" in data
    assert data["period_days"] == 28


def test_weight_trend_default_period_is_8w(client, auth_headers):
    response = client.get("/analytics/weight-trend", headers=auth_headers)
    assert response.status_code == 200
    assert response.json()["period_days"] == 56


def test_macro_breakdown_with_auth(client, auth_headers):
    response = client.get("/analytics/macro-breakdown?period=7d", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["period_days"] == 7
    assert "average" in data
    assert "daily" in data


def test_macro_breakdown_empty_data_returns_zero_average(client, auth_headers):
    """Empty meal history should not divide-by-zero — it returns 0% across the board."""
    response = client.get("/analytics/macro-breakdown", headers=auth_headers)
    assert response.status_code == 200
    avg = response.json()["average"]
    assert avg["protein_percent"] == 0
    assert avg["carbs_percent"] == 0
    assert avg["fat_percent"] == 0
