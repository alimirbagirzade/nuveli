"""
Manually confirm a Supabase Auth user's email.

Why this exists
---------------
Supabase's default built-in SMTP has a hard rate limit (~2/hour free,
~4/hour paid). When the limit is hit — or no custom SMTP is configured
yet — `auth.signUp()` returns a user object and the app shows its
"verify your email" screen, but no email is actually sent. The user
is then permanently stuck on the verify screen with no way forward.

This script uses the service-role admin API to flip
`email_confirmed_at` for a given email, unblocking the user without
requiring the actual verification mail to be delivered.

Use cases
---------
* App Store / Play reviewer accounts (paired with seed_reviewer_account.py).
* Local dev when SMTP is not yet wired up.
* Recovery for real users hit by SMTP failures (last resort — the real
  fix is configuring custom SMTP).

Usage
-----
    cd backend
    source .venv311/bin/activate
    python scripts/confirm_user_email.py reviewer@nuveli.app

Safety
------
Refuses to run when APP_ENV=production unless --allow-production is
passed. Bulk-confirming real users in prod is a footgun (it skips the
consent step) — that flag exists for the one legitimate case: an
incident where confirmation mail delivery is broken and verified users
are locked out.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

# Make `backend/` importable when invoked as `python scripts/...`
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from config import get_settings  # noqa: E402
from core.supabase_client import get_supabase  # noqa: E402


def _find_user_id(supabase, email: str) -> str | None:
    """Page through auth.users to find the row matching `email`.

    The Supabase Python admin client paginates list_users; we walk every
    page so users created late in a long-lived project are still found.
    """
    page = 1
    while True:
        listing = supabase.auth.admin.list_users(page=page, per_page=200)
        users = getattr(listing, "users", None) or listing
        if not users:
            return None
        for u in users:
            user_email = getattr(u, "email", None)
            if user_email and user_email.lower() == email.lower():
                return u.id
        if len(users) < 200:
            return None
        page += 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("email", help="Email address to confirm")
    parser.add_argument(
        "--allow-production",
        action="store_true",
        help="Required when APP_ENV=production",
    )
    args = parser.parse_args()

    settings = get_settings()
    if settings.app_env == "production" and not args.allow_production:
        print(
            "Refusing to run against production without --allow-production.\n"
            "Confirming a real user's email skips the consent step — only use "
            "this during an SMTP incident or for App Review reviewer accounts.",
            file=sys.stderr,
        )
        return 2

    supabase = get_supabase()
    user_id = _find_user_id(supabase, args.email)
    if user_id is None:
        print(f"No auth user found for {args.email}", file=sys.stderr)
        return 1

    # update_user_by_id accepts email_confirm=True which sets
    # email_confirmed_at = now() server-side. No timestamp math here.
    supabase.auth.admin.update_user_by_id(user_id, {"email_confirm": True})
    print(f"✔ Confirmed {args.email} ({user_id})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
