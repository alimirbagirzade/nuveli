// Unit + widget tests for PasswordStrength.evaluate + the
// PasswordStrengthIndicator widget that renders it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/auth/widgets/password_strength_indicator.dart';

void main() {
  group('PasswordStrength.evaluate (pure logic)', () {
    test('empty string → score 0 + empty label + no suggestions', () {
      final r = PasswordStrength.evaluate('');
      expect(r.score, 0);
      expect(r.label, '');
      expect(r.suggestions, isEmpty);
    });

    test('very short password ("abc") → score 0, "Weak" once non-empty', () {
      // 0 length-credit, 0 digit, 0 mixed-case, 0 symbol → score 0 BUT
      // password is non-empty so suggestions get populated.
      final r = PasswordStrength.evaluate('abc');
      expect(r.score, 0);
      expect(r.suggestions, isNotEmpty);
      expect(r.suggestions.length, lessThanOrEqualTo(2));
    });

    test('lowercase-only 8 chars ("password") → score 1 ("Weak")', () {
      // length≥8 (+1), no digit, no mixed-case, no symbol = 1
      final r = PasswordStrength.evaluate('password');
      expect(r.score, 1);
      expect(r.label, 'Weak');
    });

    test('8 chars + mixed case ("Password") → score 2 ("Fair")', () {
      final r = PasswordStrength.evaluate('Password');
      expect(r.score, 2);
      expect(r.label, 'Fair');
    });

    test('9 chars + mixed case + digit ("Password1") → score 3 ("Strong")', () {
      final r = PasswordStrength.evaluate('Password1');
      expect(r.score, 3);
      expect(r.label, 'Strong');
    });

    test('all 5 criteria triggered ("Password1!Abc") → score capped at 4', () {
      // length≥8, length≥12, digit, mixed-case, symbol = 5 → capped to 4
      final r = PasswordStrength.evaluate('Password1!Abc');
      expect(r.score, 4);
      expect(r.label, 'Very strong');
      expect(r.suggestions, isEmpty);
    });

    test('suggestions list is capped at 2 entries', () {
      // 'abc' has 4 missing criteria (length/digit/case/symbol) → 4
      // suggestions inside the function → take(2) outside.
      final r = PasswordStrength.evaluate('abc');
      expect(r.suggestions.length, lessThanOrEqualTo(2));
    });

    test('suggestions are user-actionable strings', () {
      final r = PasswordStrength.evaluate('abc');
      expect(
        r.suggestions,
        contains('Use at least 8 characters'),
      );
    });
  });

  group('PasswordStrengthIndicator widget', () {
    testWidgets('empty password → renders nothing visible (SizedBox.shrink)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: ''),
          ),
        ),
      );
      // No score label, no bars row visible.
      expect(find.text('Weak'), findsNothing);
      expect(find.text('Strong'), findsNothing);
    });

    testWidgets('strong password renders the matching label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: 'Password1'),
          ),
        ),
      );
      expect(find.text('Strong'), findsOneWidget);
    });

    testWidgets('very-strong password renders "Very strong" + no suggestions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: 'Password1!Abc'),
          ),
        ),
      );
      expect(find.text('Very strong'), findsOneWidget);
      expect(find.text('Use at least 8 characters'), findsNothing);
    });
  });
}
