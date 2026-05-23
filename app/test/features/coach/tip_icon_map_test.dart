import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/coach/widgets/tip_icon_map.dart';

void main() {
  group('TipIconMap', () {
    test('maps every backend TipIcon value to a non-default icon', () {
      // Mirrors the Literal in backend/models/ai_coach.py.
      const allBackendIcons = [
        'muscle',
        'leaf',
        'water',
        'fire',
        'moon',
        'walk',
        'scale',
        'sun',
      ];

      // Default fallback is `eco_rounded` for `leaf`. Every non-leaf
      // value should produce a *different* icon; otherwise the user
      // sees the same leaf for "muscle" and "moon", etc.
      final iconCodes = <int>{};
      for (final name in allBackendIcons) {
        iconCodes.add(TipIconMap.iconFor(name).codePoint);
      }
      // All 8 distinct => 8 unique codePoints.
      expect(iconCodes.length, 8);
    });

    test('unknown values fall back to leaf', () {
      expect(
        TipIconMap.iconFor('asdf').codePoint,
        TipIconMap.iconFor('leaf').codePoint,
      );
    });

    test('tintFor returns distinct colors per icon', () {
      const allBackendIcons = [
        'muscle',
        'leaf',
        'water',
        'fire',
        'moon',
        'walk',
        'scale',
        'sun',
      ];
      final colors = <Color>{};
      for (final name in allBackendIcons) {
        colors.add(TipIconMap.tintFor(name));
      }
      expect(colors.length, 8);
    });
  });
}
