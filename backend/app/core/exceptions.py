"""Custom exception sınıfları."""


class NuveliError(Exception):
    """Tüm domain hatalarının base class'ı."""
    code: str = "NUVELI_ERROR"
    status_code: int = 400

    def __init__(self, message: str = ""):
        super().__init__(message)
        self.message = message


class LimitExceededError(NuveliError):
    code = "LIMIT_EXCEEDED"
    status_code = 429

    def __init__(self, feature: str, limit: int):
        super().__init__(f"Günlük {feature} limitine ulaştın ({limit}).")
        self.feature = feature
        self.limit = limit


class AnalysisFailedError(NuveliError):
    code = "ANALYSIS_FAILED"
    status_code = 422


class NotFoundError(NuveliError):
    code = "NOT_FOUND"
    status_code = 404


class ValidationError(NuveliError):
    code = "VALIDATION_ERROR"
    status_code = 400


class AuthError(NuveliError):
    code = "AUTH_REQUIRED"
    status_code = 401


class SafetyBlockError(NuveliError):
    """AI yanıt üretemez — sabit safety mesajı dönülür."""
    code = "SAFETY_BLOCK"
    status_code = 200  # özel: 200 döner, error alanında taşınır
