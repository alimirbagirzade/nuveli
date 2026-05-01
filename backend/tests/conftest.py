"""Test fixtures for backend tests."""
import pytest


@pytest.fixture
def sample_user_id():
    """Valid UUID for user mocking."""
    return "00000000-0000-0000-0000-000000000001"


@pytest.fixture
def sample_profile():
    """Typical profile shape returned from DB."""
    return {
        "id": "00000000-0000-0000-0000-000000000001",
        "display_name": "Test User",
        "birth_year": 1990,
        "gender": "female",
        "height_cm": 165.0,
        "weight_kg": 60.0,
        "goal": "lose",
        "activity_level": "moderate",
        "special_conditions": [],
        "daily_calorie_target": 1650,
        "onboarding_completed": True,
    }
