"""
Smoke tests for meta endpoints (/health, /).
These verify the app boots and the router graph is wired up.
"""


def test_health_endpoint(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data
    assert "env" in data


def test_root_endpoint(client):
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["name"]
    assert data["docs"] == "/docs"


def test_openapi_docs_available(client):
    response = client.get("/docs")
    assert response.status_code == 200


def test_openapi_schema_valid(client):
    response = client.get("/openapi.json")
    assert response.status_code == 200
    schema = response.json()
    assert schema["info"]["title"]
    # Ensure all 10 routers are mounted
    paths = schema["paths"]
    assert any(p.startswith("/me") for p in paths)
    assert any(p.startswith("/meals") for p in paths)
    assert any(p.startswith("/water") for p in paths)
    assert any(p.startswith("/habits") for p in paths)
    assert any(p.startswith("/weight") for p in paths)
    assert any(p.startswith("/meal-plans") for p in paths)
    assert any(p.startswith("/coach") for p in paths)
    assert any(p.startswith("/analytics") for p in paths)
    assert any(p.startswith("/achievements") for p in paths)
    assert any(p.startswith("/premium") for p in paths)
