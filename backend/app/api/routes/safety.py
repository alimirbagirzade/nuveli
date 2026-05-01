from fastapi import APIRouter, Depends
from pydantic import BaseModel
from ...core.dependencies import get_current_user
from ...db.client import get_supabase
from ...schemas.common import ApiResponse

router = APIRouter()


SAFETY_RESOURCES_TR = [
    {
        "name": "ALO 182 — Psikolojik Destek Hattı",
        "phone": "182",
        "description": "7/24 ücretsiz psikolojik destek hattı.",
        "country": "TR",
    },
    {
        "name": "Türk Psikologlar Derneği",
        "url": "https://www.psikolog.org.tr",
        "description": "Lisanslı psikolog bulmak için.",
        "country": "TR",
    },
    {
        "name": "Türkiye Psikiyatri Derneği",
        "url": "https://www.psikiyatri.org.tr",
        "description": "Psikiyatri destek kaynakları.",
        "country": "TR",
    },
]


class AcknowledgeRequest(BaseModel):
    risk_level: str


@router.get("/safety/status")
async def safety_status(user_id: str = Depends(get_current_user)):
    db = get_supabase()
    result = db.table("coach_preferences")\
        .select("risk_mode").eq("user_id", user_id).execute()
    risk = result.data[0]["risk_mode"] if result.data else "normal"
    return ApiResponse.ok({"risk_mode": risk})


@router.get("/safety/resources")
async def safety_resources():
    """Authentication gerektirmeyen açık kaynak listesi."""
    return ApiResponse.ok({"resources": SAFETY_RESOURCES_TR})


@router.post("/safety/acknowledge")
async def safety_acknowledge(body: AcknowledgeRequest, user_id: str = Depends(get_current_user)):
    db = get_supabase()
    db.table("safety_acknowledgements").insert({
        "user_id": user_id,
        "risk_level": body.risk_level,
    }).execute()
    return ApiResponse.ok({"acknowledged": True})


# ─── Delete Account (with 30-day grace period) ────────────────────

@router.delete("/account")
async def request_account_deletion(user_id: str = Depends(get_current_user)):
    """
    Hesap silme isteği başlatır.
    Hesap 30 gün içinde kalıcı silinir. Bu süre içinde aynı e-posta ile
    giriş yaparsa cancel_deletion endpoint'ine yönlendirilir.
    """
    from ...services.account_deletion_service import AccountDeletionService
    result = await AccountDeletionService().request_deletion(user_id)
    return ApiResponse.ok(result)


@router.post("/account/cancel-deletion")
async def cancel_account_deletion(user_id: str = Depends(get_current_user)):
    """Silme isteğini iptal et — 30 gün içinde geri dönen kullanıcı için."""
    from ...services.account_deletion_service import AccountDeletionService
    result = await AccountDeletionService().cancel_deletion(user_id)
    return ApiResponse.ok(result)


@router.get("/account/deletion-status")
async def get_deletion_status(user_id: str = Depends(get_current_user)):
    """Kullanıcının bekleyen silme isteği var mı?"""
    db = get_supabase()
    result = db.table("deletion_requests")\
        .select("*").eq("user_id", user_id)\
        .eq("status", "pending").execute()
    if result.data:
        return ApiResponse.ok({
            "has_pending_deletion": True,
            "scheduled_for": result.data[0]["scheduled_for"],
        })
    return ApiResponse.ok({"has_pending_deletion": False})


# ─── Data Export (KVKK m.11) ────────────────────

@router.get("/account/export")
async def export_account_data(user_id: str = Depends(get_current_user)):
    """
    Kullanıcının tüm verilerini JSON olarak döner.
    Response Content-Type: application/json
    """
    from fastapi.responses import Response
    from ...services.data_export_service import DataExportService

    body = await DataExportService().export_as_json_bytes(user_id)
    filename = f"nuveli-export-{user_id[:8]}.json"
    return Response(
        content=body,
        media_type="application/json",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
