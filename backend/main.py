"""
Nuveli Backend — FastAPI entry point.

Mounts all 10 routers, configures CORS, structured logging, exception handlers,
and a /health endpoint for Render.com health checks.

Run locally:
    uvicorn main:app --reload --port 8000
"""
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

from config import get_settings
from core.logging import setup_logging, get_logger
from core.supabase_client import init_supabase
from core.exceptions import NuveliException
from core.rate_limit import limiter

from routers import (
    auth,
    profiles,
    meals,
    water,
    habits,
    weight,
    meal_planner,
    ai_coach,
    analytics,
    achievements,
    premium,
)

settings = get_settings()
setup_logging()
logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup / shutdown hooks."""
    logger.info(f"Starting {settings.app_name} v{settings.app_version} [{settings.app_env}]")
    # Verify Supabase connection at startup so we fail fast on bad credentials.
    try:
        init_supabase()
        logger.info("Supabase client initialized")
    except Exception as e:
        logger.error(f"Supabase init failed: {e}")
        # In production we still want the app to start so /health can report.
        if not settings.is_production:
            raise

    # Sentry init (optional)
    if settings.sentry_dsn:
        try:
            import sentry_sdk
            from sentry_sdk.integrations.fastapi import FastApiIntegration

            sentry_sdk.init(
                dsn=settings.sentry_dsn,
                environment=settings.app_env,
                integrations=[FastApiIntegration()],
                traces_sample_rate=0.1,
            )
            logger.info("Sentry initialized")
        except ImportError:
            logger.warning("sentry_dsn set but sentry_sdk not installed")
        except Exception as e:
            logger.warning(f"Sentry init failed: {e}")

    yield
    logger.info("Shutting down")


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="Nuveli AI Calorie Coach — Backend API",
    lifespan=lifespan,
    # Hide Swagger / ReDoc / openapi.json in production. They make API
    # surface enumeration trivial for an attacker and there's no reason
    # an end-user needs them. Dev / staging keep them on for ergonomics.
    docs_url=None if settings.is_production else "/docs",
    redoc_url=None if settings.is_production else "/redoc",
    openapi_url=None if settings.is_production else "/openapi.json",
)

# --- Rate limiter ---
# H-2: defense-in-depth for AI endpoint cost-blowout. Decorators live on
# the individual routes (see routers/meals.py /scan, routers/ai_coach.py,
# routers/meal_planner.py /meal-plans/generate). The handler turns 429s
# into the same JSON shape as our other errors.
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)


# --- CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- Exception handlers ---
@app.exception_handler(NuveliException)
async def nuveli_exception_handler(request: Request, exc: NuveliException):
    """Map domain exceptions to JSON responses."""
    logger.warning(f"{exc.__class__.__name__} on {request.url.path}: {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": exc.__class__.__name__, "detail": exc.detail},
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    """Catch-all for unexpected errors. Logs full trace, returns sanitized message.

    DEBUG: Temporarily exposes exception class + message in the response body so
    QA can diagnose 500s on prod without Render dashboard access. Revert this
    block before App Store / Play Store submission — exposing exception class
    names can leak schema names and is a soft information-disclosure issue.
    """
    logger.exception(f"Unhandled exception on {request.url.path}")
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "InternalServerError",
            "detail": "An unexpected error occurred",
            "_debug_exc": f"{type(exc).__name__}: {str(exc)[:500]}",
        },
    )


# --- Routers ---
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(profiles.router, prefix="/me", tags=["profiles"])
app.include_router(meals.router, prefix="/meals", tags=["meals"])
app.include_router(water.router, prefix="/water", tags=["water"])
app.include_router(habits.router, prefix="/habits", tags=["habits"])
app.include_router(weight.router, prefix="/weight", tags=["weight"])
# meal_planner already defines /meal-plans and /recipes paths internally
app.include_router(meal_planner.router, prefix="", tags=["meal-planner"])
app.include_router(ai_coach.router, prefix="/coach", tags=["ai-coach"])
app.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
app.include_router(achievements.router, prefix="/achievements", tags=["achievements"])
app.include_router(premium.router, prefix="/premium", tags=["premium"])


# --- Health & root ---
@app.get("/health", tags=["meta"])
async def health():
    """Liveness probe for Render.com and uptime monitors."""
    return {
        "status": "ok",
        "version": settings.app_version,
        "env": settings.app_env,
    }


@app.get("/", tags=["meta"])
async def root():
    """Root endpoint — points to docs."""
    return {
        "name": settings.app_name,
        "version": settings.app_version,
        "docs": "/docs",
        "health": "/health",
    }
