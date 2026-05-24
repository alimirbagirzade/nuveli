/// Coach voice/personality for the local mood-bubble layer.
///
/// This is a **local** preference (stored in SharedPreferences) — the
/// backend has no `coach_prefs` column, so persona never round-trips to
/// the server. It only flavours the instant, on-device mood bubbles; the
/// daily OpenAI insight (`/coach/today`) is untouched by it.
///
/// The four voices mirror the long-standing (previously unwired) persona
/// l10n strings: `personaGentle`, `personaFunny`, `personaDirect`,
/// `personaCalm`.
enum CoachPersona {
  gentle('gentle'),
  funny('funny'),
  direct('direct'),
  calm('calm');

  const CoachPersona(this.code);

  /// Stable string persisted to SharedPreferences. Never localise this —
  /// it is an identifier, not display text.
  final String code;

  /// Resolve a persisted code back to a persona, defaulting to [gentle]
  /// when the value is missing or unrecognised (e.g. a future rename).
  static CoachPersona fromCode(String? code) {
    return CoachPersona.values.firstWhere(
      (p) => p.code == code,
      orElse: () => CoachPersona.gentle,
    );
  }

  /// Default voice for users who have never opened the picker.
  static const CoachPersona defaultPersona = CoachPersona.gentle;
}
