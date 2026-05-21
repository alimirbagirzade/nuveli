"""
Rate limiter setup. Decorate cost-sensitive endpoints with
`@limiter.limit("10/minute")` to cap abuse.

Key function uses the JWT `sub` claim when present (so per-user limiting
works for authed traffic), and falls back to the remote IP for anonymous
endpoints (`/health`, `/`). The `sub` is read WITHOUT signature verification
— rate limiting buckets are not a security boundary, so trusting the claim
to pick a bucket is safe. The real auth check still happens in
`get_current_user` and rejects forged tokens with 401 before the endpoint
body runs.
"""
from fastapi import Request
from jose import jwt
from slowapi import Limiter
from slowapi.util import get_remote_address


def _user_or_ip_key(request: Request) -> str:
    auth = request.headers.get("authorization", "")
    if auth.startswith("Bearer "):
        token = auth.removeprefix("Bearer ").strip()
        try:
            sub = jwt.get_unverified_claims(token).get("sub")
            if sub:
                return f"user:{sub}"
        except Exception:
            # Malformed JWT — fall through to IP. Auth dep will reject it.
            pass
    return f"ip:{get_remote_address(request)}"


limiter = Limiter(key_func=_user_or_ip_key)
