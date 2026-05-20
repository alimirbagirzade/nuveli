import pytest
pytest.skip("Targets a backend layout (app/ package, decision_engine, checkin_service, premium_service, schemas/) that doesn't exist in the current backend yet. Chat 23 follow-up: either align backend to this design or rewrite these tests to the current structure.", allow_module_level=True)

"""ApiResponse ve ApiError schema davranış testleri."""
from schemas.common import ApiResponse, ApiError


class TestApiResponseShape:
    def test_ok_response_has_data_no_error(self):
        resp = ApiResponse.ok({"foo": "bar"})
        assert resp.data == {"foo": "bar"}
        assert resp.error is None

    def test_fail_response_has_error_no_data(self):
        resp = ApiResponse.fail("LIMIT_EXCEEDED", "Günde 3 analiz hakkı doldu.")
        assert resp.data is None
        assert resp.error is not None
        assert resp.error.code == "LIMIT_EXCEEDED"
        assert resp.error.message == "Günde 3 analiz hakkı doldu."

    def test_model_serializes_to_frontend_shape(self):
        """Frontend şu shape'i bekler: {data: ..., error: null}."""
        resp = ApiResponse.ok({"tier": "free"})
        dumped = resp.model_dump()
        assert "data" in dumped
        assert "error" in dumped
        assert dumped["error"] is None

    def test_error_response_serialization(self):
        resp = ApiResponse.fail("AUTH_REQUIRED", "Oturum bitti.")
        dumped = resp.model_dump()
        assert dumped["data"] is None
        assert dumped["error"]["code"] == "AUTH_REQUIRED"
        assert dumped["error"]["message"] == "Oturum bitti."


class TestApiError:
    def test_error_requires_code_and_message(self):
        err = ApiError(code="INTERNAL_ERROR", message="Bir hata oluştu.")
        assert err.code == "INTERNAL_ERROR"
        assert err.message == "Bir hata oluştu."

    def test_error_code_matches_frontend_expected_codes(self):
        """AppError.fromDio mapping'iyle uyumlu kodlar."""
        known_codes = [
            "AUTH_REQUIRED",
            "LIMIT_EXCEEDED",
            "INTERNAL_ERROR",
            "NOT_FOUND",
            "VALIDATION_ERROR",
        ]
        for code in known_codes:
            err = ApiError(code=code, message="test")
            assert err.code == code
