"""
Meal Service
Yemek analizi, kayıt, düzenleme, silme ve günlük liste.
"""
import base64
from datetime import date
from openai import OpenAI

from ..core.config import settings
from ..core.exceptions import LimitExceededError
from ..core.logging import get_logger
from ..db.client import get_supabase

logger = get_logger(__name__)

ANALYSIS_SYSTEM_PROMPT = """Sen bir yemek analizi asistanısın. 
Kullanıcının yemek fotoğrafını veya açıklamasını analiz ederek yaklaşık besin değerlerini tahmin et.
Yanıtını SADECE aşağıdaki JSON formatında ver, başka hiçbir şey yazma:
{
  "name": "yemek adı",
  "calories": 0,
  "protein_g": 0.0,
  "carb_g": 0.0,
  "fat_g": 0.0,
  "confidence": "high|medium|low",
  "notes": "varsa kısa not"
}
Orta porsiyon varsay. Kesin değil yaklaşık tahmin ver. Yemeği yargılama."""


class MealService:

    def __init__(self):
        self.db = get_supabase()
        self.openai = OpenAI(api_key=settings.openai_api_key) if settings.openai_api_key else None

    async def analyze(self, user_id: str, image_b64: str | None, description: str | None) -> dict:
        """OpenAI Vision ile yemek analizi yapar."""
        # Limit kontrolü (free tier)
        from .premium_service import PremiumService
        premium = await PremiumService(self.db).get_status(user_id)
        if premium["status"] == "free":
            current = await self._get_usage(user_id, "meal_analyses")
            if current >= settings.free_meal_analyses_per_day:
                raise LimitExceededError(
                    "meal_analyses",
                    settings.free_meal_analyses_per_day,
                )

        await self._check_and_increment_usage(user_id, "meal_analyses")

        try:
            result = await self._call_openai(image_b64, description)
            confidence = result.get("confidence", "medium")
        except Exception as e:
            import traceback
            error_msg = str(e)
            tb = traceback.format_exc()
            # Render loglarında görünmesi için print kullan
            print(f"🔴 MEAL ANALYSIS FAILED user_id={user_id}")
            print(f"🔴 Error: {error_msg}")
            print(f"🔴 Traceback:\n{tb}")
            logger.warning("meal_analysis_failed", user_id=user_id, error=error_msg)
            result = {}
            confidence = "failed"

        # AI sonucunu değiştirilemez şekilde kaydet
        analysis_row = self.db.table("meal_analysis_results").insert({
            "user_id": user_id,
            "raw_response": result,
            "confidence": confidence,
            "suggested_name": result.get("name"),
            "suggested_calories": result.get("calories"),
            "suggested_protein_g": result.get("protein_g"),
            "suggested_carb_g": result.get("carb_g"),
            "suggested_fat_g": result.get("fat_g"),
        }).execute()

        analysis_id = analysis_row.data[0]["id"] if analysis_row.data else None

        return {
            "analysis_id": analysis_id,
            "confidence": confidence,
            "suggestion": result,
        }

    async def confirm(self, user_id: str, analysis_id: str, local_day: str, meal_type: str) -> dict:
        """AI analizini olduğu gibi onaylar ve meal_log oluşturur."""
        analysis = self.db.table("meal_analysis_results")\
            .select("*").eq("id", analysis_id).eq("user_id", user_id).single().execute()

        if not analysis.data:
            raise ValueError("Analiz bulunamadı")

        a = analysis.data
        row = self.db.table("meal_logs").insert({
            "user_id": user_id,
            "local_day": local_day,
            "meal_type": meal_type,
            "name": a["suggested_name"] or "Bilinmeyen yemek",
            "calories": a["suggested_calories"] or 0,
            "protein_g": a["suggested_protein_g"],
            "carb_g": a["suggested_carb_g"],
            "fat_g": a["suggested_fat_g"],
            "source": "ai_confirmed",
            "analysis_id": analysis_id,
        }).execute()

        await self._invalidate_summary(user_id, local_day)
        return row.data[0]

    async def edit_and_save(self, user_id: str, analysis_id: str, edits: dict) -> dict:
        """Kullanıcı düzenlemesiyle meal_log kaydeder."""
        row = self.db.table("meal_logs").insert({
            "user_id": user_id,
            "local_day": edits.get("local_day", str(date.today())),
            "meal_type": edits.get("meal_type", "snack"),
            "name": edits["name"],
            "calories": edits["calories"],
            "protein_g": edits.get("protein_g"),
            "carb_g": edits.get("carb_g"),
            "fat_g": edits.get("fat_g"),
            "source": "ai_edited",
            "analysis_id": analysis_id,
        }).execute()

        await self._invalidate_summary(user_id, edits.get("local_day", str(date.today())))
        return row.data[0]

    async def manual_entry(self, user_id: str, data: dict) -> dict:
        """Manuel öğün girişi."""
        local_day = data.get("local_day", str(date.today()))
        row = self.db.table("meal_logs").insert({
            "user_id": user_id,
            "local_day": local_day,
            "meal_type": data.get("meal_type", "snack"),
            "name": data["name"],
            "calories": data["calories"],
            "protein_g": data.get("protein_g"),
            "carb_g": data.get("carb_g"),
            "fat_g": data.get("fat_g"),
            "source": "manual",
        }).execute()

        await self._invalidate_summary(user_id, local_day)
        return row.data[0]

    async def list_meals(self, user_id: str, local_day: str) -> list:
        result = self.db.table("meal_logs")\
            .select("*")\
            .eq("user_id", user_id)\
            .eq("local_day", local_day)\
            .order("created_at")\
            .execute()
        return result.data or []

    async def delete_meal(self, user_id: str, meal_id: str) -> None:
        meal = self.db.table("meal_logs")\
            .select("local_day").eq("id", meal_id).eq("user_id", user_id).single().execute()
        if meal.data:
            self.db.table("meal_logs").delete().eq("id", meal_id).execute()
            await self._invalidate_summary(user_id, meal.data["local_day"])

    async def _call_openai(self, image_b64: str | None, description: str | None) -> dict:
        import json
        if not self.openai:
            return {"name": description or "Bilinmeyen", "calories": 300, "confidence": "low"}

        messages = [{"role": "system", "content": ANALYSIS_SYSTEM_PROMPT}]
        content = []
        if image_b64:
            content.append({"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{image_b64}"}})
        if description:
            content.append({"type": "text", "text": description})
        messages.append({"role": "user", "content": content})

        resp = self.openai.chat.completions.create(
            model="gpt-4o",
            messages=messages,
            max_tokens=300,
            response_format={"type": "json_object"},
        )
        return json.loads(resp.choices[0].message.content)

    async def _check_and_increment_usage(self, user_id: str, counter: str) -> None:
        """Kullanım sayacını arttırır. Schema: her feature ayrı satır."""
        today = str(date.today())
        try:
            self.db.rpc("increment_usage_counter", {
                "p_user_id": user_id,
                "p_date": today,
                "p_feature": counter,
            }).execute()
        except Exception:
            current = await self._get_usage(user_id, counter)
            existing = (
                self.db.table("usage_counters_daily")
                .select("id")
                .eq("user_id", user_id)
                .eq("local_day", today)
                .eq("feature", counter)
                .execute()
            )
            if existing.data:
                self.db.table("usage_counters_daily").update({
                    "count": current + 1,
                }).eq("id", existing.data[0]["id"]).execute()
            else:
                self.db.table("usage_counters_daily").insert({
                    "user_id": user_id,
                    "local_day": today,
                    "feature": counter,
                    "count": 1,
                }).execute()

    async def _get_usage(self, user_id: str, counter: str) -> int:
        """Bugünkü feature kullanım sayısı. Schema: her feature ayrı satır."""
        today = str(date.today())
        res = self.db.table("usage_counters_daily")\
            .select("count")\
            .eq("user_id", user_id)\
            .eq("local_day", today)\
            .eq("feature", counter)\
            .execute()
        if res.data:
            return res.data[0].get("count") or 0
        return 0
    async def _invalidate_summary(self, user_id: str, local_day: str) -> None:
        """Summary'yi yeniden hesaplar (cache silip beklemek yerine proaktif)."""
        from .summary_generator import SummaryGenerator
        await SummaryGenerator().regenerate_day(user_id, local_day)
