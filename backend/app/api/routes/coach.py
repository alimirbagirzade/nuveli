"""
backend/app/api/routes/coach.py

Coach Routes — ince HTTP katmanı.
Tüm logic CoachService'te. Bu dosya sadece HTTP <-> service çevirisi yapar.
"""

from __future__ import annotations
from typing import Optional
import logging

from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field

from app.core.dependencies import get_current_user_id, get_coach_service
from app.services.coach_service import CoachService, CoachResponse
from app.services.decision_engine import Surface

logger = logging.getLogger(__name__)
router = APIRouter()


# ═══════════════════════════════════════════════════════════════
# Request / Response models
# ═══════════════════════════════════════════════════════════════

class CoachRespondRequest(BaseModel):
    surface: Optional[str] = Field(None, description="home_card | chat_response | meal_reaction | weekly_summary | empty_day | recovery_day | celebration")
    message: Optional[str] = Field(None, description="Chat surface'inde kullanıcı mesajı")
    meal_context: Optional[dict] = Field(None, description="Meal reaction surface'inde öğün")
    weekly_data: Optional[dict] = Field(None, description="Weekly summary surface'inde 7 günlük")
    request_voice: bool = Field(False, description="TTS isteniyor mu?")


class CoachRespondResponse(BaseModel):
    text: str
    mode: str
    persona: str
    surface: str
    is_fallback: bool
    fallback_reason: Optional[str] = None
    voice_url: Optional[str] = None
    show_resources: bool
    show_premium_upsell: bool
    show_day2_gift: bool
    usage_remaining: Optional[int] = None
    error_code: Optional[str] = None
    metadata: dict = {}


# ═══════════════════════════════════════════════════════════════
# Endpoints
# ═══════════════════════════════════════════════════════════════

@router.post("/respond", response_model=CoachRespondResponse)
async def coach_respond(
    body: CoachRespondRequest,
    request: Request,
    user_id: str = Depends(get_current_user_id),
    coach: CoachService = Depends(get_coach_service),
):
    """
    Ana coach endpoint. Tüm AI cevap akışı buradan geçer.
    PRD §7.2 boru hattı: Decision → Prompt → Model → Safety → Response
    """
    if not body.surface:
        raise HTTPException(status_code=400, detail="surface required for /respond")
    try:
        surface = Surface(body.surface)
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid surface: {body.surface}",
        )

    # Accept-Language header'dan dil kodu cikar (tr-TR -> tr)
    accept_lang = request.headers.get("accept-language", "tr")
    locale_override = accept_lang.split(",")[0].split("-")[0].lower()
    if locale_override not in ["tr", "en", "de", "fr", "es", "ru", "it"]:
        locale_override = "tr"

    response: CoachResponse = await coach.respond(
        user_id=user_id,
        surface=surface,
        user_message=body.message,
        meal_context=body.meal_context,
        weekly_data=body.weekly_data,
        request_voice=body.request_voice,
        locale_override=locale_override,
    )

    return CoachRespondResponse(
        text=response.text,
        mode=response.mode,
        persona=response.persona,
        surface=response.surface,
        is_fallback=response.is_fallback,
        fallback_reason=response.fallback_reason,
        voice_url=response.voice_url,
        show_resources=response.show_resources,
        show_premium_upsell=response.show_premium_upsell,
        show_day2_gift=response.show_day2_gift,
        usage_remaining=response.usage_remaining,
        error_code=response.error_code,
        metadata=response.metadata,
    )


@router.get("/thread")
async def get_coach_thread(
    request: Request,
    user_id: str = Depends(get_current_user_id),
):
    """
    Mevcut chat thread'ini getir. coach_threads + coach_messages'tan oku.
    """
    from app.db.client import get_supabase
    db = get_supabase()
    
    # Thread bul, yoksa olustur
    thread_res = db.table("coach_threads")\
        .select("id")\
        .eq("user_id", user_id)\
        .order("updated_at", desc=True)\
        .limit(1)\
        .execute()
    
    if thread_res.data:
        thread_id = thread_res.data[0]["id"]
    else:
        new_thread = db.table("coach_threads").insert({
            "user_id": user_id,
        }).execute()
        thread_id = new_thread.data[0]["id"] if new_thread.data else None
    
    # Mesajlari getir
    messages = []
    if thread_id:
        msg_res = db.table("coach_messages")\
            .select("*")\
            .eq("thread_id", thread_id)\
            .order("created_at", desc=False)\
            .limit(50)\
            .execute()
        messages = msg_res.data or []
    
    return {
        "data": {
            "thread_id": thread_id,
            "messages": messages,
        }
    }


@router.post("/thread/message")
async def post_coach_message(
    body: CoachRespondRequest,
    request: Request,
    user_id: str = Depends(get_current_user_id),
    coach: CoachService = Depends(get_coach_service),
):
    """
    Chat'te mesaj gönderme. /respond ile aynı boru hattını kullanır
    ama mesajı + cevabı coach_messages tablosuna yazar.
    """
    from datetime import datetime, timezone
    from app.db.client import get_supabase
    
    if not body.message:
        raise HTTPException(status_code=400, detail="message required")
    
    # 1. AI cevabı al
    # Accept-Language header'dan dil kodu cikar (tr-TR -> tr)
    accept_lang = request.headers.get("accept-language", "tr")
    locale_override = accept_lang.split(",")[0].split("-")[0].lower()
    if locale_override not in ["tr", "en", "de", "fr", "es", "ru", "it"]:
        locale_override = "tr"

    surface = Surface.CHAT_RESPONSE
    response = await coach.respond(
        user_id=user_id,
        surface=surface,
        user_message=body.message,
        request_voice=body.request_voice,
        locale_override=locale_override,
    )

    # 2. Thread bul/yarat
    db = get_supabase()
    thread_res = db.table("coach_threads")\
        .select("id")\
        .eq("user_id", user_id)\
        .order("updated_at", desc=True)\
        .limit(1)\
        .execute()
    
    if thread_res.data:
        thread_id = thread_res.data[0]["id"]
    else:
        new_thread = db.table("coach_threads").insert({
            "user_id": user_id,
        }).execute()
        thread_id = new_thread.data[0]["id"] if new_thread.data else None

    # 3. coach_messages tablosuna user mesaji + AI cevabi yaz
    user_msg = None
    coach_msg = None
    if thread_id:
        try:
            user_insert = db.table("coach_messages").insert({
                "thread_id": thread_id,
                "user_id": user_id,
                "role": "user",
                "content": body.message,
            }).execute()
            user_msg = user_insert.data[0] if user_insert.data else None
            
            coach_insert = db.table("coach_messages").insert({
                "thread_id": thread_id,
                "user_id": user_id,
                "role": "coach",
                "content": response.text,
            }).execute()
            coach_msg = coach_insert.data[0] if coach_insert.data else None
            
            # Thread updated_at guncelle
            db.table("coach_threads").update({
                "updated_at": datetime.now(timezone.utc).isoformat(),
            }).eq("id", thread_id).execute()
        except Exception as e:
            logger.warning(f"coach_messages insert failed: {e}")

    # Fallback: insert fail olursa mock messages
    if not user_msg:
        user_msg = {
            "id": "temp-user",
            "role": "user",
            "content": body.message,
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
    if not coach_msg:
        coach_msg = {
            "id": "temp-coach",
            "role": "coach",
            "content": response.text,
            "created_at": datetime.now(timezone.utc).isoformat(),
        }

    return {
        "data": {
            "user_message": user_msg,
            "coach_message": coach_msg,
            "risk_mode": response.metadata.get("risk_mode", "normal") if response.metadata else "normal",
        }
    }
