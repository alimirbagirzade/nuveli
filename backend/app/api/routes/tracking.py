from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from datetime import date
from ...core.dependencies import get_current_user
from ...db.client import get_supabase
from ...schemas.common import ApiResponse

router = APIRouter()


# ─── Water ────────────────────────
class WaterAddRequest(BaseModel):
    amount_ml: int
    local_day: Optional[str] = None


@router.post("/water")
async def add_water(body: WaterAddRequest, user_id: str = Depends(get_current_user)):
    db = get_supabase()
    row = db.table("water_logs").insert({
        "user_id": user_id,
        "local_day": body.local_day or str(date.today()),
        "amount_ml": body.amount_ml,
    }).execute()
    # invalidate summary
    db.table("daily_summaries").delete()\
        .eq("user_id", user_id).eq("local_day", body.local_day or str(date.today())).execute()
    return ApiResponse.ok(row.data[0])


@router.get("/water")
async def list_water(local_day: str | None = None, user_id: str = Depends(get_current_user)):
    db = get_supabase()
    day = local_day or str(date.today())
    result = db.table("water_logs")\
        .select("*").eq("user_id", user_id).eq("local_day", day).execute()
    total = sum((w["amount_ml"] or 0) for w in (result.data or []))
    return ApiResponse.ok({"entries": result.data or [], "total_ml": total})


@router.get("/water/history")
async def water_history(
    days: int = 30,
    user_id: str = Depends(get_current_user),
):
    """Daily water totals for the last N days.

    Returns a list of {local_day, total_ml} sorted newest-first. Days
    with no entries are still included with total_ml=0 so the UI can
    plot a continuous chart without gaps.
    """
    from datetime import datetime, timedelta

    db = get_supabase()
    # Clamp days to a reasonable range so a malicious client can't
    # request 10000 days and pull the whole history.
    days = max(1, min(days, 90))

    today = date.today()
    start_day = today - timedelta(days=days - 1)
    start_str = str(start_day)

    # Pull every entry in the window in one query, then aggregate
    # client-side. Faster than N round-trips and Supabase free-tier
    # friendly.
    result = (
        db.table("water_logs")
        .select("local_day, amount_ml")
        .eq("user_id", user_id)
        .gte("local_day", start_str)
        .execute()
    )

    # Initialise every day in the window to 0 so the chart has a point
    # for empty days too.
    totals: dict[str, int] = {}
    for i in range(days):
        d = today - timedelta(days=i)
        totals[str(d)] = 0
    for row in (result.data or []):
        d = row.get("local_day")
        if d in totals:
            totals[d] += int(row.get("amount_ml") or 0)

    # Sort newest-first to match weight_history's convention.
    entries = [
        {"local_day": d, "total_ml": ml}
        for d, ml in sorted(totals.items(), reverse=True)
    ]
    avg = sum(e["total_ml"] for e in entries) // max(1, len(entries))

    return ApiResponse.ok({
        "entries": entries,
        "average_ml": avg,
        "days": days,
    })


# ─── Weight ───────────────────────
class WeightRequest(BaseModel):
    weight_kg: float
    local_day: Optional[str] = None


@router.post("/weight")
async def add_weight(body: WeightRequest, user_id: str = Depends(get_current_user)):
    db = get_supabase()
    row = db.table("weight_logs").upsert({
        "user_id": user_id,
        "local_day": body.local_day or str(date.today()),
        "weight_kg": body.weight_kg,
    }, on_conflict="user_id,local_day").execute()
    return ApiResponse.ok(row.data[0])


@router.get("/weight/history")
async def weight_history(user_id: str = Depends(get_current_user)):
    db = get_supabase()
    result = db.table("weight_logs")\
        .select("*").eq("user_id", user_id).order("local_day", desc=True).limit(90).execute()
    return ApiResponse.ok(result.data or [])


# ─── Check-in ─────────────────────
class CheckinRequest(BaseModel):
    mood: str
    note: Optional[str] = None
    local_day: Optional[str] = None


@router.post("/checkins")
async def checkin(body: CheckinRequest, user_id: str = Depends(get_current_user)):
    db = get_supabase()
    row = db.table("daily_checkins").upsert({
        "user_id": user_id,
        "local_day": body.local_day or str(date.today()),
        "mood": body.mood,
        "note": body.note,
    }, on_conflict="user_id,local_day").execute()
    return ApiResponse.ok(row.data[0])
