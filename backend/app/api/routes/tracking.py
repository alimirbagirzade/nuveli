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
