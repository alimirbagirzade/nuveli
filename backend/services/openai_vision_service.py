"""
OpenAI GPT-4o Vision integration for meal scanning.
"""
import json
import asyncio
from openai import AsyncOpenAI, APIError, APITimeoutError, RateLimitError

from config import get_settings
from core.exceptions import ExternalServiceError, ValidationError
from core.logging import get_logger
from models.meal import MealScanResponse, DetectedFoodResponse, PortionInsightResponse
from prompts.meal_scan_prompt import build_meal_scan_messages

logger = get_logger(__name__)


def _get_client() -> AsyncOpenAI:
    settings = get_settings()
    return AsyncOpenAI(
        api_key=settings.openai_api_key,
        timeout=settings.openai_timeout_seconds,
        max_retries=settings.openai_max_retries,
    )


def _strip_json_fences(text: str) -> str:
    """Remove ```json ... ``` fences if the model added them."""
    s = text.strip()
    if s.startswith("```"):
        # remove leading fence
        lines = s.splitlines()
        if lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].startswith("```"):
            lines = lines[:-1]
        s = "\n".join(lines).strip()
    return s


async def analyze_meal_image(
    image_base64: str,
    meal_type_hint: str | None = None,
    language_code: str | None = None,
) -> MealScanResponse:
    """
    Send a meal image to GPT-4o Vision, parse JSON response, return MealScanResponse.

    `language_code` (BCP-47 from the user's profile) localizes the user-facing
    strings — food names, portions, and the portion insight — into the user's
    language; JSON keys and numbers are unchanged.

    Raises:
        ExternalServiceError: OpenAI API failure.
        ValidationError: response was not parseable JSON.
    """
    settings = get_settings()
    client = _get_client()
    messages = build_meal_scan_messages(
        image_base64, meal_type_hint, language_code=language_code
    )

    logger.info(f"Calling GPT-4o Vision (hint={meal_type_hint}, img_size={len(image_base64)})")

    try:
        response = await client.chat.completions.create(
            model=settings.openai_model_vision,
            messages=messages,
            max_tokens=1200,
            temperature=0.2,
            response_format={"type": "json_object"},
        )
    except APITimeoutError as e:
        logger.error(f"OpenAI Vision timeout: {e}")
        raise ExternalServiceError("OpenAI Vision", "Request timed out")
    except RateLimitError as e:
        logger.error(f"OpenAI rate limit: {e}")
        raise ExternalServiceError("OpenAI Vision", "Rate limit exceeded")
    except APIError as e:
        logger.error(f"OpenAI API error: {e}")
        raise ExternalServiceError("OpenAI Vision", str(e))

    raw = response.choices[0].message.content or ""
    raw = _strip_json_fences(raw)

    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        logger.error(f"Vision JSON parse failed: {e}\nRaw: {raw[:500]}")
        raise ValidationError("AI returned unparseable response — please try again")

    # Build response object — be lenient about missing optional fields
    try:
        foods = [DetectedFoodResponse(**f) for f in data.get("foods", [])]
        insight = data.get("portion_insight") or {
            "score": 50,
            "main_text": "Analysis complete",
            "highlights": [],
        }
        portion_insight = PortionInsightResponse(**insight)
        return MealScanResponse(
            foods=foods,
            total_calories=int(data.get("total_calories", sum(f.calories for f in foods))),
            total_protein_g=float(data.get("total_protein_g", sum(f.protein_g for f in foods))),
            total_carbs_g=float(data.get("total_carbs_g", sum(f.carbs_g for f in foods))),
            total_fat_g=float(data.get("total_fat_g", sum(f.fat_g for f in foods))),
            portion_insight=portion_insight,
            suggested_meal_type=data.get("suggested_meal_type"),
        )
    except Exception as e:
        logger.error(f"Vision response schema mismatch: {e}")
        raise ValidationError(f"AI response did not match expected schema: {e}")
