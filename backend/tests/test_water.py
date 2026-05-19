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
