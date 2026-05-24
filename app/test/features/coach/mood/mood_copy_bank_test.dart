// Verifies the copy bank resolves a non-empty, distinct line for every
// persona × situation pair, in every shipped locale. Catches a missing or
// mis-wired l10n key the moment it regresses.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/coach/mood/data/mood_copy_bank.dart';
import 'package:nuveli/features/coach/mood/models/coach_persona.dart';
import 'package:nuveli/features/coach/mood/models/mood_situation.dart';
import 'package:nuveli/l10n/generated/app_localizations.dart';
import 'package:nuveli/l10n/generated/app_localizations_en.dart';
import 'package:nuveli/l10n/generated/app_localizations_tr.dart';

void main() {
  final locales = <String, AppLocalizations>{
    'en': AppLocalizationsEn(),
    'tr': AppLocalizationsTr(),
  };

  group('MoodCopyBank.resolve', () {
    for (final entry in locales.entries) {
      final lang = entry.key;
      final l10n = entry.value;

      test('$lang: every persona × situation resolves to non-empty copy', () {
        for (final persona in CoachPersona.values) {
          for (final situation in MoodSituation.values) {
            final line = MoodCopyBank.resolve(l10n, persona, situation);
            expect(line.trim(), isNotEmpty,
                reason: '$lang $persona $situation is empty');
          }
        }
      });

      test('$lang: the 24 lines are all distinct', () {
        final lines = <String>{};
        for (final persona in CoachPersona.values) {
          for (final situation in MoodSituation.values) {
            lines.add(MoodCopyBank.resolve(l10n, persona, situation));
          }
        }
        expect(lines.length, 24, reason: '$lang has duplicate copy lines');
      });
    }

    test('the same pair differs across locales (actually translated)', () {
      final en = MoodCopyBank.resolve(
          locales['en']!, CoachPersona.gentle, MoodSituation.mealUnder);
      final tr = MoodCopyBank.resolve(
          locales['tr']!, CoachPersona.gentle, MoodSituation.mealUnder);
      expect(en, isNot(equals(tr)));
    });
  });
}
