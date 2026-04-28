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
    """Thread'de koçla konuşma — user mesajı + koç yanıtı kaydedilir.

    Note: respond() already persists both the user message and the coach
    reply via save_message internally, so we don't double-save here.
    We just call respond() and reshape its return into the format
    the Flutter coach_chat_screen expects.
    """
    svc = CoachService()
    response = await svc.respond(user_id, body.message)
    # respond() saves both messages internally and returns:
    #   message, is_fallback, risk_level, audio_url, message_id
    return ApiResponse.ok({
        "coach_message": {
            "id": response["message_id"],
            "content": response["message"],
            "role": "coach",
            "is_fallback": response["is_fallback"],
            "audio_url": response.get("audio_url"),
        },
        "risk_mode": response["risk_level"],
    })
