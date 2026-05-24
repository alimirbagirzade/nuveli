import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../data/mood_copy_bank.dart';
import '../models/coach_persona.dart';
import '../models/mood_situation.dart';
import '../providers/coach_persona_provider.dart';

/// Persona-tinted accent for the bubble's edge + glyph. Purely cosmetic —
/// gives each voice a subtly different feel without new assets.
Color _accentFor(CoachPersona persona) {
  switch (persona) {
    case CoachPersona.gentle:
      return AppColors.accentSeafoam;
    case CoachPersona.funny:
      return AppColors.warning;
    case CoachPersona.direct:
      return AppColors.primary;
    case CoachPersona.calm:
      return AppColors.info;
  }
}

/// Shows a coach mood bubble for [situation] using the user's chosen
/// persona and the active app locale.
///
/// No-op (silently) if localizations aren't available yet — the bubble is
/// cosmetic and must never throw into a save flow. Returns the resolved
/// line for callers/tests that want to assert what was shown.
String? showMoodBubble(
  BuildContext context,
  WidgetRef ref,
  MoodSituation situation,
) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return null;

  final persona = ref.read(coachPersonaProvider);
  final text = MoodCopyBank.resolve(l10n, persona, situation);
  final accent = _accentFor(persona);

  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return text;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        padding: EdgeInsets.zero,
        content: MoodBubbleContent(text: text, accent: accent),
      ),
    );
  return text;
}

/// The visual speech-bubble. Split out from [showMoodBubble] so it can be
/// rendered in a widget test or embedded elsewhere (e.g. the Coach screen)
/// without the SnackBar plumbing.
class MoodBubbleContent extends StatelessWidget {
  const MoodBubbleContent({
    super.key,
    required this.text,
    required this.accent,
  });

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.spa_rounded, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
