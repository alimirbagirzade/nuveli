"""
Nutrition score: deterministic 0-100 calculation.
Components:
  - Calorie compliance:  40 pts
  - Macro balance:       30 pts
  - Hydration:           15 pts
  - Habits:              15 pts
"""
from typing import Any


def _calorie_score(avg_kcal: float, target: float) -> int:
    """Full 40 if within ±10% of target; linear decline outside."""
    if target <= 0:
        return 0
    deviation = abs(avg_kcal - target) / target
    if deviation <= 0.10:
        return 40
    if deviation >= 0.40:
        return 0
    # linear between 10% (40 pts) and 40% (0 pts)
    return int(40 * (1 - (deviation - 0.10) / 0.30))


def _macro_score(
    avg_protein: float | None,
    avg_carbs: float | None,
    avg_fat: float | None,
    target_protein: float | None,
    target_carbs: float | None,
    target_fat: float | None,
) -> int:
    """10 pts per macro within ±20% of target."""
    score = 0
    for actual, target in (
        (avg_protein, target_protein),
        (avg_carbs, target_carbs),
        (avg_fat, target_fat),
    ):
        if actual is None or target is None or target <= 0:
            # No target set — give partial credit if value is present
            if actual is not None:
                score += 5
            continue
        dev = abs(actual - target) / target
        if dev <= 0.20:
            score += 10
        elif dev <= 0.40:
            score += 5
    return score


def _water_score(avg_water_ml: float, target_ml: float = 2500) -> int:
    """15 pts at target_ml; linear below."""
    if target_ml <= 0:
        return 0
    ratio = min(avg_water_ml / target_ml, 1.0)
    return int(15 * ratio)


def _habits_score(completion_rate: float) -> int:
    """completion_rate is 0..1; scaled to 15 pts."""
    return int(15 * max(0, min(1, completion_rate)))


def compute_nutrition_score(user_data: dict[str, Any]) -> dict[str, Any]:
    """
    Compute deterministic nutrition score from a 7-day aggregate.

    Expected user_data fields:
      avg_daily_calories, target_calories
      avg_daily_protein_g, avg_daily_carbs_g, avg_daily_fat_g
      target_protein_g, target_carbs_g, target_fat_g
      avg_daily_water_ml, target_water_ml
      habit_completion_rate
    """
    cal = _calorie_score(
        user_data.get("avg_daily_calories", 0),
        user_data.get("target_calories", 2000),
    )
    macro = _macro_score(
        user_data.get("avg_daily_protein_g"),
        user_data.get("avg_daily_carbs_g"),
        user_data.get("avg_daily_fat_g"),
        user_data.get("target_protein_g"),
        user_data.get("target_carbs_g"),
        user_data.get("target_fat_g"),
    )
    water = _water_score(
        user_data.get("avg_daily_water_ml", 0),
        user_data.get("target_water_ml", 2500),
    )
    habits = _habits_score(user_data.get("habit_completion_rate", 0))

    total = min(100, cal + macro + water + habits)

    return {
        "total": total,
        "calorie_score": cal,
        "macro_score": macro,
        "water_score": water,
        "habits_score": habits,
        "components": {
            "calorie_pct_of_max": round(cal / 40 * 100, 1),
            "macro_pct_of_max": round(macro / 30 * 100, 1),
            "water_pct_of_max": round(water / 15 * 100, 1),
            "habits_pct_of_max": round(habits / 15 * 100, 1),
        },
    }
