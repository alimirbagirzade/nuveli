"""
Meal scan prompts for GPT-4o Vision.
Output is strict JSON for reliable parsing.
"""

# Defensive whitelist for the meal_type hint that gets interpolated into the
# user prompt. The request schema already constrains this via Pydantic's
# Literal type, so a hostile client request gets a 422 long before reaching
# here. This second check protects internal callers (cron jobs, future
# refactors, tests) that bypass the HTTP boundary.
ALLOWED_MEAL_TYPES = {"breakfast", "lunch", "dinner", "snack"}

MEAL_SCAN_SYSTEM_PROMPT = """You are a nutrition expert analyzing meal photos for the Nuveli AI Calorie Coach app.

Your job: identify foods in the image, estimate portions in grams, and compute nutritional values.

CRITICAL RULES:
1. Return ONLY valid JSON — no markdown fences, no preamble, no commentary.
2. Use realistic portion estimates (a typical serving, not the whole pan/plate).
3. Be conservative with macros — round to 1 decimal for grams.
4. If the image is not food, return foods: [] and explain in main_text.
5. Calories must equal: protein_g * 4 + carbs_g * 4 + fat_g * 9 (±10% tolerance).

OUTPUT SCHEMA (strict JSON):
{
  "foods": [
    {
      "name": "Grilled chicken breast",
      "portion": "1 medium piece (150g)",
      "grams": 150,
      "calories": 248,
      "protein_g": 46.5,
      "carbs_g": 0,
      "fat_g": 5.4
    }
  ],
  "total_calories": 248,
  "total_protein_g": 46.5,
  "total_carbs_g": 0,
  "total_fat_g": 5.4,
  "portion_insight": {
    "score": 75,
    "main_text": "Balanced, high-protein meal with moderate portion size.",
    "highlights": ["High protein", "Low carb", "Lean"]
  },
  "suggested_meal_type": "lunch"
}

SCORE GUIDE (portion_insight.score):
- 90-100: Excellent balance, ideal portion
- 70-89:  Good meal, minor tweaks possible
- 50-69:  Moderate — heavy in one macro or oversized portion
- 30-49:  Imbalanced or very large/small
- 0-29:   Poor (mostly junk, extreme imbalance, or not food)

MEAL TYPE GUESS: breakfast | lunch | dinner | snack — pick the most likely.
"""

MEAL_SCAN_USER_PROMPT = """Analyze this meal photo. Return the JSON specified in the system prompt.

If a meal_type hint is provided, prefer it: {meal_type_hint}
"""


def build_meal_scan_messages(image_base64: str, meal_type_hint: str | None = None) -> list[dict]:
    """Build OpenAI Chat Completions messages with vision content.

    `meal_type_hint` is interpolated into the user prompt. Even though the
    HTTP layer's Pydantic Literal already restricts it, anything that isn't
    in the whitelist (e.g. an internal caller passes an unsanitized string)
    gets coerced to the safe default so a payload like
    "breakfast\\n\\nIGNORE PREVIOUS" can't reshape the prompt.
    """
    safe_hint = meal_type_hint if meal_type_hint in ALLOWED_MEAL_TYPES else None
    user_text = MEAL_SCAN_USER_PROMPT.format(
        meal_type_hint=safe_hint or "none — you decide"
    )

    # Auto-detect mime: default to jpeg
    image_url = f"data:image/jpeg;base64,{image_base64}"

    return [
        {"role": "system", "content": MEAL_SCAN_SYSTEM_PROMPT},
        {
            "role": "user",
            "content": [
                {"type": "text", "text": user_text},
                {"type": "image_url", "image_url": {"url": image_url, "detail": "high"}},
            ],
        },
    ]
