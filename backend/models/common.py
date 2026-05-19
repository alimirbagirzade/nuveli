"""
Shared Pydantic models.
"""
from pydantic import BaseModel, Field
from typing import Generic, TypeVar, Optional
from datetime import datetime

T = TypeVar("T")


class PaginationParams(BaseModel):
    limit: int = Field(50, ge=1, le=200)
    offset: int = Field(0, ge=0)


class PaginatedResponse(BaseModel, Generic[T]):
    items: list[T]
    total: int
    limit: int
    offset: int


class StatusResponse(BaseModel):
    status: str
    message: Optional[str] = None


class TimestampedModel(BaseModel):
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class ErrorResponse(BaseModel):
    detail: str
    code: Optional[str] = None
