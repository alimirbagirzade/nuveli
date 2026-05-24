import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../notifications/providers/notifications_provider.dart'
    show sharedPreferencesProvider;

/// De-duplication for bubbles that would otherwise re-fire on every
/// rebuild/refresh (currently only the streak-milestone celebration).
///
/// Persisting the last-celebrated streak value means a user who hits a
/// 7-day streak sees the celebration once, not again on each pull-to-
/// refresh while still at 7.
class MoodSeenStore {
  MoodSeenStore(this._prefs);

  final SharedPreferences _prefs;

  static const _streakKey = 'nuveli.coach.streakCelebrated.v1';

  int get lastCelebratedStreak => _prefs.getInt(_streakKey) ?? 0;

  bool shouldCelebrateStreak(int days) => lastCelebratedStreak != days;

  Future<void> markStreakCelebrated(int days) async {
    try {
      await _prefs.setInt(_streakKey, days);
    } catch (_) {
      // Non-fatal: at worst the celebration repeats on next refresh.
    }
  }
}

final moodSeenStoreProvider = Provider<MoodSeenStore>((ref) {
  return MoodSeenStore(ref.watch(sharedPreferencesProvider));
});
