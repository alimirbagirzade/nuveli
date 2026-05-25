"""
Exercise calorie ESTIMATE helper (Manual Exercise Logging — V1.1).

WELLNESS BOUNDARY (hard rule, founder-locked):
  These calorie figures are **DISPLAY-ONLY**. They exist so the UI can show an
  informational "~N kcal" badge next to a logged activity. They are NEVER added
  to or subtracted from the user's calorie target/budget, never produce a
  "you earned calories / eat more" message, and no endpoint mutates any calorie
  goal because of them. See docs/protocols/safety-wellness-boundary.md.

Estimate model (MET-based, standard wellness approximation):

    kcal           = MET_effective * weight_kg * (duration_min / 60)
    MET_effective  = BASE_MET[activity_type] * INTENSITY_MULTIPLIER[intensity]

Where intensity is the user's *perceived* effort, used only as a coarse
multiplier here (light=0.8, moderate=1.0, vigorous=1.25). A null/unknown
intensity is treated as moderate (1.0).

If the user's weight is unknown we return None rather than guessing a default
weight — a wrong number is worse than no number for a wellness display badge.
"""
from typing import Optional

# Base MET (Metabolic Equivalent of Task) values per activity type. These are
# coarse, public wellness-grade approximations — NOT a medical/clinical figure.
# Any activity_type not in this map falls back to the 'other' value.
BASE_MET: dict[str, float] = {
    "walking": 3.5,
    "running": 9.0,
    "cycling": 7.5,
    "hiking": 6.0,
    "swimming": 7.0,
    "gym": 5.0,
    "yoga": 2.5,
    "pilates": 3.0,
    "dancing": 5.0,
    "hiit": 8.0,
    "jump_rope": 11.0,
    "rowing": 7.0,
    "sports": 7.0,
    "other": 4.0,
}

# Perceived-effort multiplier. Null/unknown intensity → moderate (1.0).
INTENSITY_MULTIPLIER: dict[str, float] = {
    "light": 0.8,
    "moderate": 1.0,
    "vigorous": 1.25,
}

_DEFAULT_MET = BASE_MET["other"]
_DEFAULT_INTENSITY_MULT = INTENSITY_MULTIPLIER["moderate"]


def estimate_calories(
    activity_type: Optional[str],
    duration_min: Optional[int],
    intensity: Optional[str],
    weight_kg: Optional[float],
) -> Optional[int]:
    """
    Compute a DISPLAY-ONLY estimated calories-burned for one activity.

    Returns the kcal rounded to the nearest int, or None when it cannot be
    computed (no weight, or non-positive duration). The returned value must
    never be folded into a calorie budget/target — it is for UI display only.

    Args:
        activity_type: normalized activity type (unknown → treated as 'other').
        duration_min:  session length in minutes.
        intensity:     'light' | 'moderate' | 'vigorous' | None (None → moderate).
        weight_kg:     user's current weight; None → returns None (no guessing).
    """
    if weight_kg is None:
        return None
    try:
        weight = float(weight_kg)
    except (TypeError, ValueError):
        return None
    if weight <= 0:
        return None

    if not duration_min or duration_min <= 0:
        return None

    base_met = BASE_MET.get((activity_type or "other"), _DEFAULT_MET)
    intensity_mult = INTENSITY_MULTIPLIER.get(intensity or "", _DEFAULT_INTENSITY_MULT)

    met_effective = base_met * intensity_mult
    kcal = met_effective * weight * (duration_min / 60.0)
    return round(kcal)
