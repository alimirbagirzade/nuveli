"""
Smoke tests for /water endpoints.
"""


def test_water_logs_requires_auth(client):
    response = client.get("/water/logs")
    assert response.status_code in (401, 403)


def test_water_today_summary_requires_auth(client):
    response = client.get("/water/today/summary")
    assert response.status_code in (401, 403)


def test_water_reminders_requires_auth(client):
    response = client.get("/water/reminders")
    assert response.status_code in (401, 403)


def test_water_insights_requires_auth(client):
    response = client.get("/water/insights")
    assert response.status_code in (401, 403)


def test_water_log_create_requires_auth(client):
    response = client.post("/water/logs", json={"amount_ml": 250})
    assert response.status_code in (401, 403)


def test_water_logs_with_auth(client, auth_headers):
    response = client.get("/water/logs", headers=auth_headers)
    assert response.status_code == 200


# --- /water/weekly ---

def test_water_weekly_requires_auth(client):
    response = client.get("/water/weekly")
    assert response.status_code in (401, 403)


def test_water_weekly_returns_seven_day_buckets(client, auth_headers):
    """Always 7 days, even on a fresh user with no logs — chart needs
    a stable 7-bar strip."""
    response = client.get("/water/weekly", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert "days" in body
    assert len(body["days"]) == 7
    assert "target_ml" in body
    # Each day has the documented shape
    for d in body["days"]:
        assert "day" in d
        assert "total_ml" in d
        assert "target_ml" in d
        assert d["total_ml"] >= 0


def test_water_weekly_defaults_target_when_no_profile(client, auth_headers):
    """Without a profile row the endpoint falls back to 2500 ml."""
    response = client.get("/water/weekly", headers=auth_headers)
    assert response.status_code == 200
    # default target appears on both top-level and per-day
    assert response.json()["target_ml"] == 2500
