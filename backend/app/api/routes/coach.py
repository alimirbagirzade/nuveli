from fastapi import APIRouter, Depends
from pydantic import BaseModel
from ...core.dependencies import get_current_user
from ...services.coach_service import CoachService
from ...schemas.common import ApiResponse

router = APIRouter()


class RespondRequest(BaseModel):
    message: str
    want_audio: bool = False


class ThreadMessageRequest(BaseModel):
    message: str


@router.post("/respond")
async def coach_respond(body: RespondRequest, user_id: str = Depends(get_current_user)):
    """Koçtan tek seferlik yanıt al (thread'e yazmaz)."""
    svc = CoachService()
    data = await svc.respond(user_id, body.message, body.want_audio)
    return ApiResponse.ok(data)


@router.get("/thread")
async def get_thread(user_id: str = Depends(get_current_user)):
    svc = CoachService()
    messages = await svc.get_thread(user_id)
    return ApiResponse.ok({"messages": messages})


@router.post("/thread/message")
async def post_thread_message(body: ThreadMessageRequest, user_id: str = Depends(get_current_user)):
    """Thread'de koçla konuşma — user mesajı + koç yanıtı kaydedilir."""
    svc = CoachService()
    # User mesajını kaydet
    user_msg = await svc.save_message(user_id, "user", body.message)
    # Yanıt üret
    response = await svc.respond(user_id, body.message)
    # Koç yanıtını kaydet
    coach_msg = await svc.save_message(
        user_id, "coach", response["message"], is_fallback=response["is_fallback"]
    )
    return ApiResponse.ok({
        "user_message": user_msg,
        "coach_message": coach_msg,
        "risk_mode": response["risk_mode"],
    })
