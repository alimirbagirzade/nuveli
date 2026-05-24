import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../notifications/providers/notifications_provider.dart'
    show sharedPreferencesProvider;
import '../models/coach_persona.dart';

/// Persisted coach persona for the local mood-bubble layer.
///
/// Local-only (SharedPreferences). Reads synchronously off the already
/// warmed-up [sharedPreferencesProvider] so the very first bubble has the
/// right voice without an async gap. Defaults to [CoachPersona.gentle].
class CoachPersonaController extends StateNotifier<CoachPersona> {
  CoachPersonaController(this._prefs)
      : super(CoachPersona.fromCode(_prefs.getString(_storageKey)));

  final SharedPreferences _prefs;

  static const _storageKey = 'nuveli.coach.persona.v1';

  /// Change the active persona and persist it. Best-effort write — if the
  /// disk write fails the in-memory state still updates so the UI is never
  /// stuck on the old voice.
  Future<void> setPersona(CoachPersona persona) async {
    if (persona == state) return;
    state = persona;
    try {
      await _prefs.setString(_storageKey, persona.code);
    } catch (_) {
      // Non-fatal: persona is cosmetic. Next launch falls back to default.
    }
  }
}

final coachPersonaProvider =
    StateNotifierProvider<CoachPersonaController, CoachPersona>((ref) {
  return CoachPersonaController(ref.watch(sharedPreferencesProvider));
});
