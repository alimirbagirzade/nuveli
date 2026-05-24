/// The user-moment a mood bubble reacts to.
///
/// Kept deliberately small and deterministic — each value maps to exactly
/// one copy line per [CoachPersona] in the local copy bank. Detection of
/// which situation applies lives in `mood_bubble_controller.dart`; this
/// enum is just the axis.
///
/// Wellness boundary note: [mealOver] copy must never shame, dramatise a
/// deficit, or imply compensation (purging / extra exercise). See
/// `docs/protocols/safety-wellness-boundary.md`.
enum MoodSituation {
  /// A meal was logged and the day is still comfortably under target —
  /// there is room left to eat.
  mealUnder,

  /// A meal was logged and the day is now over the calorie target.
  /// Non-judgmental, "one meal doesn't define the day" framing only.
  mealOver,

  /// A meal was logged and the day sits near the target — balanced.
  mealOnTrack,

  /// Water intake is meaningfully behind target for the time of day.
  waterLow,

  /// A logging streak reached a noteworthy length (celebrate).
  streakMilestone,

  /// The first meal of the day was just logged — fresh-start framing.
  firstMeal;

  /// Stable index used to seed daily rotation deterministically.
  int get rotationSeed => index;
}
