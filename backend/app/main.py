from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .api.router import api_router
from .core.config import settings
from .core.exceptions import NuveliError
from .core.logging import configure_logging, get_logger

logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup ve shutdown lifecycle."""
    configure_logging()
    logger.info("nuveli_backend_starting", version=settings.app_version, env=settings.app_env)
    yield
    logger.info("nuveli_backend_shutdown")


app = FastAPI(
    title="Nuveli API",
    version=settings.app_version,
    description="Nuveli AI Calorie Coach — Backend API",
    lifespan=lifespan,
    # Production'da docs'u kapat
    docs_url=None if settings.is_production else "/docs",
    redoc_url=None if settings.is_production else "/redoc",
)

# CORS — Flutter dev için açık; prod'da daraltılmalı
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if not settings.is_production else ["https://nuveli.com.tr"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(NuveliError)
async def nuveli_exception_handler(request: Request, exc: NuveliError):
    """Domain-specific hata -> standart ApiResponse formatı."""
    logger.info("domain_error", path=request.url.path, code=exc.code, message=exc.message)
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "data": None,
            "error": {"code": exc.code, "message": exc.message},
        },
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Yakalanmayan tüm hatalar için güvenli fallback response."""
    logger.error("unhandled_exception", path=request.url.path, error=str(exc))
    return JSONResponse(
        status_code=500,
        content={
            "data": None,
            "error": {
                "code": "INTERNAL_ERROR",
                "message": "Bir şeyler ters gitti. Lütfen tekrar dene.",
            },
        },
    )


# Tüm route'ları bağla
app.include_router(api_router)
