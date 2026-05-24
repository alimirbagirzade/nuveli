import '../../../../l10n/generated/app_localizations.dart';
import '../models/coach_persona.dart';
import '../models/mood_situation.dart';

/// Resolves a (persona × situation) pair to a localized line.
///
/// The copy lives in the `coachBubble*` l10n keys (all 7 locales), so the
/// returned string already follows the active app locale. This is a pure
/// lookup — no rotation, no state — which keeps it trivially testable.
///
/// One line per pair (24 total). Freshness comes from situation variety
/// and the fact that bubbles only fire on real user events, not from
/// per-line rotation.
class MoodCopyBank {
  const MoodCopyBank._();

  static String resolve(
    AppLocalizations l10n,
    CoachPersona persona,
    MoodSituation situation,
  ) {
    switch (persona) {
      case CoachPersona.gentle:
        return _gentle(l10n, situation);
      case CoachPersona.funny:
        return _funny(l10n, situation);
      case CoachPersona.direct:
        return _direct(l10n, situation);
      case CoachPersona.calm:
        return _calm(l10n, situation);
    }
  }

  static String _gentle(AppLocalizations l, MoodSituation s) {
    switch (s) {
      case MoodSituation.mealUnder:
        return l.coachBubbleGentleMealUnder;
      case MoodSituation.mealOver:
        return l.coachBubbleGentleMealOver;
      case MoodSituation.mealOnTrack:
        return l.coachBubbleGentleMealOnTrack;
      case MoodSituation.waterLow:
        return l.coachBubbleGentleWaterLow;
      case MoodSituation.streakMilestone:
        return l.coachBubbleGentleStreakMilestone;
      case MoodSituation.firstMeal:
        return l.coachBubbleGentleFirstMeal;
    }
  }

  static String _funny(AppLocalizations l, MoodSituation s) {
    switch (s) {
      case MoodSituation.mealUnder:
        return l.coachBubbleFunnyMealUnder;
      case MoodSituation.mealOver:
        return l.coachBubbleFunnyMealOver;
      case MoodSituation.mealOnTrack:
        return l.coachBubbleFunnyMealOnTrack;
      case MoodSituation.waterLow:
        return l.coachBubbleFunnyWaterLow;
      case MoodSituation.streakMilestone:
        return l.coachBubbleFunnyStreakMilestone;
      case MoodSituation.firstMeal:
        return l.coachBubbleFunnyFirstMeal;
    }
  }

  static String _direct(AppLocalizations l, MoodSituation s) {
    switch (s) {
      case MoodSituation.mealUnder:
        return l.coachBubbleDirectMealUnder;
      case MoodSituation.mealOver:
        return l.coachBubbleDirectMealOver;
      case MoodSituation.mealOnTrack:
        return l.coachBubbleDirectMealOnTrack;
      case MoodSituation.waterLow:
        return l.coachBubbleDirectWaterLow;
      case MoodSituation.streakMilestone:
        return l.coachBubbleDirectStreakMilestone;
      case MoodSituation.firstMeal:
        return l.coachBubbleDirectFirstMeal;
    }
  }

  static String _calm(AppLocalizations l, MoodSituation s) {
    switch (s) {
      case MoodSituation.mealUnder:
        return l.coachBubbleCalmMealUnder;
      case MoodSituation.mealOver:
        return l.coachBubbleCalmMealOver;
      case MoodSituation.mealOnTrack:
        return l.coachBubbleCalmMealOnTrack;
      case MoodSituation.waterLow:
        return l.coachBubbleCalmWaterLow;
      case MoodSituation.streakMilestone:
        return l.coachBubbleCalmStreakMilestone;
      case MoodSituation.firstMeal:
        return l.coachBubbleCalmFirstMeal;
    }
  }
}
