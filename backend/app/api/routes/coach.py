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
    internally. We then fetch the two most recent rows from
    coach_messages directly (desc order, limit 2) so we always get
    the just-saved pair regardless of how long the thread already is.
    """
    svc = CoachService()
    response = await svc.respond(user_id, body.message)

    # Get the thread id for this user
    thread = svc.db.table("coach_threads").select("id").eq("user_id", user_id).execute()
    thread_id = thread.data[0]["id"] if thread.data else None

    user_msg_obj = None
    coach_msg_obj = None
    if thread_id:
        recent = svc.db.table("coach_messages")\
            .select("*")\
            .eq("thread_id", thread_id)\
            .order("created_at", desc=True)\
            .limit(2)\
            .execute()
        rows = recent.data or []
        # rows[0] is the most recent (coach reply), rows[1] is user msg
        for row in rows:
            if row.get("role") == "coach" and coach_msg_obj is None:
                coach_msg_obj = row
            elif row.get("role") == "user" and user_msg_obj is None:
                user_msg_obj = row

    return ApiResponse.ok({
        "user_message": user_msg_obj,
        "coach_message": coach_msg_obj,
        "risk_mode": response["risk_level"],
    })
