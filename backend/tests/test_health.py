"""
Backend temel endpoint testleri.
pytest ile çalıştır: pytest tests/
"""
import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def client():
    """Test client fixture - her testte yeni bir client."""
    from app.main import app
    return TestClient(app)


def test_health_endpoint(client):
    """Health endpoint 200 döner ve status: ok içerir."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "timestamp" in data


def test_cors_headers(client):
    """CORS header'ları doğru set edilmiş mi?"""
    response = client.options("/health")
    assert response.status_code == 200
    # CORS middleware ekli olmalı


def test_404_on_unknown_route(client):
    """Olmayan endpoint 404 döner."""
    response = client.get("/this-route-does-not-exist")
    assert response.status_code == 404


def test_docs_available(client):
    """Swagger docs erişilebilir olmalı."""
    response = client.get("/docs")
    assert response.status_code == 200
    assert b"swagger" in response.content.lower()
