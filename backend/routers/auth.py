"""
Auth endpoints.

Right now this file exists for ONE reason: Supabase's default built-in SMTP
has a hard rate limit (~2/hour free, ~4/hour paid) and is unreliable for
production signup mail. The result was that real users — and App Review
reviewers — saw "verify your email" but never received the mail and were
permanently stuck.

`POST /auth/signup` uses the service-role admin API to create the user with
`email_confirm=True` so the account is born verified. The Flutter client
then immediately calls `signInWithPassword` and lands on the onboarding
wizard with zero friction.

When custom SMTP (Resend/Postmark/SES) is wired up in production, switch
the Flutter client back to `Supabase.auth.signUp` directly and either
remove this endpoint or gate it behind a feature flag. The behaviour here
is intentionally identical to "user verified their email" — there is no
spam-account mitigation built in beyond the rate limit below.
"""
from fastapi import APIRouter, Request, status
from pydantic import BaseModel, EmailStr, Field

from core.exceptions import ValidationError
from core.logging import get_logger
from core.rate_limit import limiter
from core.supabase_client import get_supabase

logger = get_logger(__name__)
router = APIRouter()


class SignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)


class SignupResponse(BaseModel):
    user_id: str
    email: EmailStr
    already_existed: bool = False


@router.post(
    "/signup",
    response_model=SignupResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create user with auto-confirmed email (SMTP workaround)",
)
@limiter.limit("5/minute")
async def signup(request: Request, body: SignupRequest):
    """
    Provision a Supabase auth user without going through the email-verify
    flow. The Flutter side calls this then `signInWithPassword` to obtain
    a normal session — RLS works as if the user had clicked a verify link.

    Idempotent: if the email already exists, we DO NOT create a new row;
    we return its UUID with `already_existed=True` so the Flutter client
    can still attempt password sign-in (which is the correct UX —
    "you already have an account, just log in").

    Rate-limited 5/minute per IP to slow spammers while custom SMTP isn't
    yet wired up.
    """
    supabase = get_supabase()
    email = body.email.lower().strip()

    # Idempotency: walk pages of admin.list_users to find any existing row
    # for this address. The admin list endpoint isn't filterable, so we
    # paginate. We bail at 200 pages worth so a corrupted prod can't loop.
    existing_id = _find_user_id(supabase, email)
    if existing_id is not None:
        logger.info(f"Signup for existing email {email} → returning {existing_id}")
        return SignupResponse(
            user_id=existing_id, email=email, already_existed=True
        )

    try:
        created = supabase.auth.admin.create_user(
            {
                "email": email,
                "password": body.password,
                "email_confirm": True,
            }
        )
    except Exception as exc:  # noqa: BLE001 — Supabase wraps many error types
        logger.warning(f"admin.create_user failed for {email}: {exc}")
        raise ValidationError(f"Could not create account: {exc}") from exc

    user = getattr(created, "user", None) or created
    user_id = getattr(user, "id", None)
    if user_id is None:
        raise ValidationError("Signup succeeded but no user ID returned")

    logger.info(f"Created auto-confirmed user {user_id} for {email}")
    return SignupResponse(user_id=str(user_id), email=email, already_existed=False)


def _find_user_id(supabase, email: str) -> str | None:
    """Linear scan over admin.list_users. Returns the UUID or None."""
    page = 1
    while page <= 200:
        listing = supabase.auth.admin.list_users(page=page, per_page=200)
        users = getattr(listing, "users", None) or listing
        if not users:
            return None
        for u in users:
            user_email = getattr(u, "email", None)
            if user_email and user_email.lower() == email:
                return str(u.id)
        if len(users) < 200:
            return None
        page += 1
    return None
