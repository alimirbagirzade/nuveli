from typing import Any, Generic, Optional, TypeVar
from pydantic import BaseModel

T = TypeVar("T")


class ApiResponse(BaseModel, Generic[T]):
    """
    Tüm endpoint'lerin standart response formatı.

    Başarı: { "data": {...}, "error": null }
    Hata:   { "data": null, "error": {"code": "...", "message": "..."} }
    """

    data: Optional[T] = None
    error: Optional["ApiError"] = None

    @classmethod
    def ok(cls, data: T) -> "ApiResponse[T]":
        return cls(data=data, error=None)

    @classmethod
    def fail(cls, code: str, message: str) -> "ApiResponse[None]":
        return cls(data=None, error=ApiError(code=code, message=message))


class ApiError(BaseModel):
    code: str
    message: str


class PaginatedResponse(BaseModel, Generic[T]):
    """Sayfalı liste response'u."""
    items: list[T]
    total: int
    page: int
    page_size: int
    has_more: bool
