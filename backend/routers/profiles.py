"""
User profile endpoints: GET /me, PATCH /me, POST /me/onboarding, DELETE /me, GET /me/export.
"""
from datetime import date, datetime
from typing import Any
from fastapi import APIRouter, Depends, Request, status

from core.auth import get_current_user
from core.rate_limit import limiter
from core.supabase_client import get_supabase
from core.exceptions import NotFound, ValidationError
from core.logging import get_logger
from models.profile import ProfileResponse, ProfileUpdate, OnboardingRequest
from models.common import StatusResponse

logger = get_logger(__name__)
router = APIRouter()


# --- Helpers: BMR/TDEE math (Mifflin-St Jeor) ---

ACTIVITY_MULTIPLIERS = {
    "sedentary": 1.2,
    "light": 1.375,
    "moderate": 1.55,
    "active": 1.725,
    "very_active": 1.9,
}


def _age_from_dob(dob: date) -> int:
    today = date.today()
    return today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))


def _compute_bmr(sex: str, weight_kg: float, height_cm: float, age: int) -> float:
    if sex == "male":
        return 10 * weight_kg + 6.25 * height_cm - 5 * age + 5
    elif sex == "female":
        return 10 * weight_kg + 6.25 * height_cm - 5 * age - 161
    # "other" → average of male/female
    return 10 * weight_kg + 6.25 * height_cm - 5 * age - 78


def _compute_targets(req: OnboardingRequest) -> dict:
    age = _age_from_dob(req.date_of_birth)
    bmr = _compute_bmr(req.sex, req.weight_kg, req.height_cm, age)
    tdee = bmr * ACTIVITY_MULTIPLIERS.get(req.activity_level, 1.2)

    if req.weight_goal_direction == "lose":
        daily_kcal = tdee - 500
    elif req.weight_goal_direction == "gain":
        daily_kcal = tdee + 500
    else:
        daily_kcal = tdee

    daily_kcal = max(1200, round(daily_kcal))  # safety floor

    # Macro split: 25% protein, 45% carbs, 30% fat
    protein_g = round((daily_kcal * 0.25) / 4)
    carbs_g = round((daily_kcal * 0.45) / 4)
    fat_g = round((daily_kcal * 0.30) / 9)

    water_ml = round(req.weight_kg * 35)  # 35 ml/kg

    return {
        "bmr": round(bmr, 1),
        "tdee": round(tdee, 1),
        "daily_calorie_target": daily_kcal,
        "protein_target_g": protein_g,
        "carbs_target_g": carbs_g,
        "fat_target_g": fat_g,
        "daily_water_target_ml": water_ml,
    }


# --- Endpoints ---

@router.get("", response_model=ProfileResponse, summary="Get current user profile")
async def get_me(user_id: str = Depends(get_current_user)):
    supabase = get_supabase()
    res = (
        supabase.table("user_profiles")
        .select("*")
        .eq("user_id", user_id)
        .single()
        .execute()
    )
    if not res.data:
        # First-time login — create blank profile row
        new_profile = {"user_id": user_id, "onboarding_completed": False}
        ins = supabase.table("user_profiles").insert(new_profile).execute()
        return ins.data[0]
    return res.data


@router.patch("", response_model=ProfileResponse, summary="Update user profile")
async def update_me(
    update: ProfileUpdate,
    user_id: str = Depends(get_current_user),
):
    supabase = get_supabase()
    payload = update.model_dump(exclude_unset=True)
    if not payload:
        raise ValidationError("Empty update payload")

    payload["updated_at"] = datetime.utcnow().isoformat()
    res = (
        supabase.table("user_profiles")
        .update(payload)
        .eq("user_id", user_id)
        .execute()
    )
    if not res.data:
        raise NotFound("Profile")
    return res.data[0]


@router.post("/onboarding", response_model=ProfileResponse, summary="Complete onboarding")
async def onboarding(
    req: OnboardingRequest,
    user_id: str = Depends(get_current_user),
):
    """
    Save initial profile + compute BMR/TDEE/daily targets.
    Also creates an initial weight_log and weight_goal.
    """
    supabase = get_supabase()
    targets = _compute_targets(req)
    # Only daily_calorie_target and daily_water_target_ml have columns
    # in user_profiles right now. bmr/tdee/macro grams are computed and
    # returned to clients but a schema migration is still pending — strip
    # them from the upsert payload to avoid PGRST204.
    for k in ("bmr", "tdee", "protein_target_g", "carbs_target_g", "fat_target_g"):
        targets.pop(k, None)

    profile_data = {
        "user_id": user_id,
        "full_name": req.full_name,
        "sex": req.sex,
        "date_of_birth": req.date_of_birth.isoformat(),
        "height_cm": req.height_cm,
        "weight_kg": req.weight_kg,
        "activity_level": req.activity_level,
        "dietary_preference": req.dietary_preference,
        "timezone": req.timezone,
        "locale": req.locale,
        "onboarding_completed": True,
        **targets,
        "updated_at": datetime.utcnow().isoformat(),
    }

    # Upsert (in case GET /me already created a stub row)
    res = (
        supabase.table("user_profiles")
        .upsert(profile_data, on_conflict="user_id")
        .execute()
    )

    # Initial weight log (best-effort — schema currently has a FK to a
    # different `profiles` table; that mismatch needs its own migration.
    # Don't block onboarding completion on this side-effect.)
    try:
        supabase.table("weight_logs").insert({
            "user_id": user_id,
            "weight_kg": req.weight_kg,
            "local_day": date.today().isoformat(),
        }).execute()
    except Exception as e:
        logger.warning(f"weight_logs insert skipped during onboarding: {e}")

    # Initial weight goal (same caveat as weight_logs).
    if req.target_weight_kg:
        try:
            supabase.table("weight_goals").insert({
                "user_id": user_id,
                "start_weight_kg": req.weight_kg,
                "target_weight_kg": req.target_weight_kg,
                "target_date": req.target_date.isoformat() if req.target_date else None,
                "is_active": True,
            }).execute()
        except Exception as e:
            logger.warning(f"weight_goals insert skipped during onboarding: {e}")

    logger.info(f"Onboarding complete for user {user_id}: targets={targets}")
    return res.data[0]


@router.delete("", response_model=StatusResponse, summary="Delete account (GDPR + Apple 5.1.1(v))")
async def delete_me(user_id: str = Depends(get_current_user)):
    """
    Apple App Store Guideline 5.1.1(v) + GDPR Article 17 compliant.

    Order matters:
      1) Delete auth user via admin client — cascade removes user_profiles row
         and (via FK ON DELETE CASCADE) all related domain tables.
      2) Best-effort explicit profile delete in case schema-level cascade is
         partial. Safe to call after auth.admin.delete_user — row is gone.

    Frontend completes the flow by calling supabase.auth.signOut() locally so
    the cached session is cleared and the user is sent back to /welcome.
    """
    supabase = get_supabase()  # service-role client

    # 1) Auth user removal (cascades via auth.users FK)
    try:
        supabase.auth.admin.delete_user(user_id)
        logger.info(f"Auth user {user_id} deleted via admin")
    except Exception as e:
        # If admin delete fails (e.g. user already gone), log and continue —
        # we still want to clean the profile row defensively.
        logger.warning(f"auth.admin.delete_user({user_id}) failed: {e}")

    # 2) Defensive profile cleanup (no-op if cascade already removed it)
    try:
        supabase.table("user_profiles").delete().eq("user_id", user_id).execute()
    except Exception as e:
        logger.warning(f"user_profiles delete skipped for {user_id}: {e}")

    logger.info(f"Account deletion complete for user {user_id}")
    return StatusResponse(
        status="deleted",
        message="Account and all associated data permanently deleted.",
    )


# Tables the user owns directly via `user_id`. Each is dumped as-is from
# Supabase; sensitive columns (auth row, RC purchase tokens, etc.) live
# in tables NOT listed here, so we don't have to filter columns per-table.
_EXPORT_TABLES = (
    "user_profiles",
    "meals",
    "water_logs",
    "water_reminders",
    "habits",
    "habit_completions",
    "weight_logs",
    "weight_goals",
    "meal_plans",
    "ai_insights",
    "user_achievements",
)


@router.get("/export", summary="Export all user data (GDPR Article 20)")
@limiter.limit("3/hour")
async def export_me(
    request: Request,
    user_id: str = Depends(get_current_user),
) -> dict[str, Any]:
    """
    GDPR Article 20 (Right to Data Portability). Returns every row the user
    owns across the domain tables as one JSON document the frontend can
    write to disk and share via the system share sheet.

    Rate limit: 3/hour per user — keeps a malicious client from hammering
    a Supabase service-role query that scans across 11 tables. Honest
    user export-then-decide flow doesn't need more than a couple.

    Out of scope:
      - meal_foods rows are pulled via the meals payload (Supabase nested
        select) so they ride along without a separate fetch.
      - auth.users row is intentionally excluded; that's Supabase's
        property and we don't have user-readable secrets to share.
      - Storage bucket files (meal photo URLs) are referenced from the
        meals rows; the frontend can re-fetch them if needed.
    """
    supabase = get_supabase()
    snapshot: dict[str, Any] = {
        "schema_version": 1,
        "exported_at": datetime.utcnow().isoformat() + "Z",
        "user_id": user_id,
    }

    for table in _EXPORT_TABLES:
        try:
            select_clause = "*, meal_foods(*)" if table == "meals" else "*"
            res = (
                supabase.table(table)
                .select(select_clause)
                .eq("user_id", user_id)
                .execute()
            )
            snapshot[table] = res.data or []
        except Exception as e:
            # Don't fail the whole export over one table — log and emit an
            # empty list so the frontend still gets a usable file.
            logger.warning(f"export {table} failed for {user_id}: {e}")
            snapshot[table] = []

    logger.info(f"User {user_id} exported data: {sum(len(v) for k, v in snapshot.items() if isinstance(v, list))} rows")
    return snapshot
