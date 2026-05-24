// CoachPersona enum + persisted CoachPersonaController.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/coach/mood/models/coach_persona.dart';
import 'package:nuveli/features/coach/mood/providers/coach_persona_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CoachPersona.fromCode', () {
    test('round-trips every code', () {
      for (final p in CoachPersona.values) {
        expect(CoachPersona.fromCode(p.code), p);
      }
    });

    test('null / unknown falls back to gentle (default)', () {
      expect(CoachPersona.fromCode(null), CoachPersona.gentle);
      expect(CoachPersona.fromCode('telepath'), CoachPersona.gentle);
      expect(CoachPersona.defaultPersona, CoachPersona.gentle);
    });
  });

  group('CoachPersonaController persistence', () {
    test('default initial state is gentle on a clean install', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final controller = CoachPersonaController(prefs);
      expect(controller.state, CoachPersona.gentle);
    });

    test('reads a previously-saved persona synchronously at construction',
        () async {
      SharedPreferences.setMockInitialValues({
        'nuveli.coach.persona.v1': 'direct',
      });
      final prefs = await SharedPreferences.getInstance();
      final controller = CoachPersonaController(prefs);
      expect(controller.state, CoachPersona.direct);
    });

    test('setPersona flips state and persists the code', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final controller = CoachPersonaController(prefs);

      await controller.setPersona(CoachPersona.funny);
      expect(controller.state, CoachPersona.funny);
      expect(prefs.getString('nuveli.coach.persona.v1'), 'funny');
    });

    test('setting the same persona is a no-op (no redundant write churn)',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final controller = CoachPersonaController(prefs);

      await controller.setPersona(CoachPersona.gentle); // == default
      expect(prefs.getString('nuveli.coach.persona.v1'), isNull);
    });
  });
}
