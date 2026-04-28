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

    respond() persists both the user message and the coach reply
    internally, then we fetch the most recent two messages from the
    thread to return them to the client (frontend wants both).
    """
    svc = CoachService()
    response = await svc.respond(user_id, body.message)
    # respond() saved both user msg and coach msg; fetch them back.
    # Most recent first, so [0] is the coach reply, [1] is the user msg.
    recent = await svc.get_thread(user_id, limit=2)
    coach_msg_obj = next((m for m in recent if m.get("role") == "coach"), None)
    user_msg_obj = next((m for m in recent if m.get("role") == "user"), None)

    return ApiResponse.ok({
        "user_message": user_msg_obj,
        "coach_message": coach_msg_obj,
        "risk_mode": response["risk_level"],
    })
