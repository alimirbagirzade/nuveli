"""
Smoke tests for /coach AI insight endpoints.
"""


def test_coach_today_requires_auth(client):
    response = client.get("/coach/today")
    assert response.status_code in (401, 403)


def test_coach_generate_requires_auth(client):
    response = client.post("/coach/generate", json={})
    assert response.status_code in (401, 403)


def test_coach_apply_tip_requires_auth(client):
    response = client.post(
        "/coach/apply-tip",
        json={"tip_id": "tip_1", "action_type": "log_water", "action_payload": {"amount_ml": 250}},
    )
    assert response.status_code in (401, 403)
