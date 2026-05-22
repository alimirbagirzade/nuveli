"""
Tests for the JWKS cache: TTL expiry, REPLACE-on-refresh semantics, and
the asyncio.Lock that coalesces concurrent cache-miss refreshes.

The audit (BULGU #2) flagged that the previous module-level dict had:
  - no TTL → revoked keys lived forever
  - merge semantics → keys removed by Supabase never evicted
  - no lock → thundering-herd refresh storms

This file exercises the new _JwksCache class directly without touching
the HTTP layer; refresh() is monkey-patched per-test to control timing.
"""
import asyncio

import pytest

from core.auth import _JwksCache
from core.exceptions import AuthError


def _jwk(kid: str) -> dict:
    """Minimal JWK shape — content irrelevant for cache tests."""
    return {"kid": kid, "kty": "EC", "crv": "P-256"}


class _Clock:
    """Hand-cranked monotonic clock so tests don't sleep."""
    def __init__(self, t: float = 0.0):
        self.t = t

    def __call__(self) -> float:
        return self.t

    def advance(self, seconds: float) -> None:
        self.t += seconds


def _wire_fake_refresh(cache: _JwksCache, keysets):
    """Replace `_refresh` to return a sequence of fake keysets.

    Each call to refresh consumes the next keyset from `keysets`,
    a list of {kid: jwk} dicts. Lets a test simulate Supabase changing
    its JWKS between two refresh windows.
    """
    iterator = iter(keysets)
    call_count = {"n": 0}

    async def _fake_refresh():
        call_count["n"] += 1
        cache._keys = dict(next(iterator))
        cache._fetched_at = cache._clock()

    cache._refresh = _fake_refresh
    return call_count


# ---------------------------------------------------------------------------
# Fast-path: fresh cache + present kid returns without refreshing
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_fast_path_returns_cached_key_without_refresh():
    clock = _Clock(100.0)
    cache = _JwksCache(ttl_seconds=3600, clock=clock)
    calls = _wire_fake_refresh(cache, [{"kid-A": _jwk("kid-A")}])

    # Manually seed so we don't burn a refresh just to populate.
    cache._keys = {"kid-A": _jwk("kid-A")}
    cache._fetched_at = clock()

    jwk = await cache.get("kid-A")
    assert jwk["kid"] == "kid-A"
    assert calls["n"] == 0, "fast path must not call refresh"


# ---------------------------------------------------------------------------
# TTL expiry triggers refresh
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_expired_cache_triggers_refresh():
    clock = _Clock(0.0)
    cache = _JwksCache(ttl_seconds=3600, clock=clock)
    calls = _wire_fake_refresh(
        cache,
        [
            {"kid-A": _jwk("kid-A")},  # first refresh
        ],
    )

    # No prior fetch → not fresh → refresh fires
    jwk = await cache.get("kid-A")
    assert jwk["kid"] == "kid-A"
    assert calls["n"] == 1

    # Within TTL → no second refresh
    clock.advance(3000)
    await cache.get("kid-A")
    assert calls["n"] == 1


@pytest.mark.asyncio
async def test_ttl_boundary_refresh():
    clock = _Clock(0.0)
    cache = _JwksCache(ttl_seconds=3600, clock=clock)
    calls = _wire_fake_refresh(
        cache,
        [
            {"kid-A": _jwk("kid-A")},
            {"kid-B": _jwk("kid-B")},  # second refresh produces different key
        ],
    )

    await cache.get("kid-A")
    assert calls["n"] == 1

    # Step past TTL → next call must refresh again
    clock.advance(3601)
    with pytest.raises(AuthError):
        # New JWKS no longer contains kid-A — verify the request reaches refresh
        # AND that REPLACE semantics drop kid-A.
        await cache.get("kid-A")
    assert calls["n"] == 2


# ---------------------------------------------------------------------------
# REPLACE semantics — revoked keys must disappear
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_revoked_key_evicted_after_refresh():
    """Audit complaint: the old `merge` refresh left removed keys behind."""
    clock = _Clock(0.0)
    cache = _JwksCache(ttl_seconds=10, clock=clock)
    _wire_fake_refresh(
        cache,
        [
            {"kid-A": _jwk("kid-A"), "kid-B": _jwk("kid-B")},
            {"kid-B": _jwk("kid-B")},  # kid-A revoked
        ],
    )

    await cache.get("kid-A")  # first refresh — both present
    assert "kid-A" in cache._keys

    clock.advance(11)  # past TTL
    with pytest.raises(AuthError):
        await cache.get("kid-A")
    # kid-A should be gone after refresh, kid-B should remain
    assert "kid-A" not in cache._keys
    assert "kid-B" in cache._keys


# ---------------------------------------------------------------------------
# Fresh cache + missing kid → reject WITHOUT refresh (DoS guard)
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_fresh_cache_missing_kid_does_not_refresh():
    """An attacker spamming tokens with random invalid kids must not amplify
    each request into a JWKS fetch."""
    clock = _Clock(0.0)
    cache = _JwksCache(ttl_seconds=3600, clock=clock)
    calls = _wire_fake_refresh(
        cache,
        [{"kid-A": _jwk("kid-A")}],  # only one refresh ever allowed
    )

    await cache.get("kid-A")
    assert calls["n"] == 1

    # Hammer the cache with unknown kids — must not call refresh again
    for i in range(20):
        with pytest.raises(AuthError):
            await cache.get(f"unknown-{i}")
    assert calls["n"] == 1, "missing kid in fresh cache must not amplify refresh"


# ---------------------------------------------------------------------------
# Concurrent refresh under lock — only one fetch
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_concurrent_misses_coalesce_into_single_refresh():
    """Twenty coroutines hit get() simultaneously on an empty cache. The
    asyncio.Lock must serialize so only one refresh actually fires."""
    clock = _Clock(0.0)
    cache = _JwksCache(ttl_seconds=3600, clock=clock)

    refresh_count = {"n": 0}

    async def _slow_refresh():
        refresh_count["n"] += 1
        # Yield to event loop so other coroutines see the pre-refresh
        # state while we're "fetching" — exercising the re-check under lock.
        await asyncio.sleep(0)
        cache._keys = {"kid-A": _jwk("kid-A")}
        cache._fetched_at = cache._clock()

    cache._refresh = _slow_refresh

    results = await asyncio.gather(
        *[cache.get("kid-A") for _ in range(20)]
    )
    assert all(r["kid"] == "kid-A" for r in results)
    assert refresh_count["n"] == 1, "lock must coalesce concurrent misses"
