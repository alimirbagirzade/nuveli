// Unit tests for AuthValidators — the form-level validation that gates
// every signup, login, and password-reset flow. Returning the wrong
// error string is annoying; returning null when the input is invalid
// would let bad data hit Supabase. Treat as critical-path.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/auth/widgets/auth_text_field.dart';

void main() {
  group('AuthValidators.email', () {
    test('null → "Email is required"', () {
      expect(AuthValidators.email(null), 'Email is required');
    });

    test('empty / whitespace-only → "Email is required"', () {
      expect(AuthValidators.email(''), 'Email is required');
      expect(AuthValidators.email('   '), 'Email is required');
    });

    test('valid plain email → null', () {
      expect(AuthValidators.email('user@example.com'), null);
      expect(AuthValidators.email('alice.smith@gmail.com'), null);
      expect(AuthValidators.email('a@b.co'), null);
    });

    test('trims surrounding whitespace before validating', () {
      expect(AuthValidators.email('  user@example.com  '), null);
    });

    test('rejects missing @', () {
      expect(AuthValidators.email('userexample.com'), 'Enter a valid email');
    });

    test('rejects missing TLD', () {
      expect(AuthValidators.email('user@example'), 'Enter a valid email');
    });

    test('rejects single-letter TLD', () {
      expect(AuthValidators.email('user@example.c'), 'Enter a valid email');
    });

    // Documented behaviour, not necessarily desired: the current regex
    // `[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}` does not match `+` so Gmail
    // tags like alice+test@gmail.com are rejected. If this changes,
    // update both the regex and this test.
    test('plus-aliased email is REJECTED (regex limitation)', () {
      expect(
        AuthValidators.email('alice+test@gmail.com'),
        'Enter a valid email',
      );
    });
  });

  group('AuthValidators.password (signup-strength)', () {
    test('null / empty → "Password is required"', () {
      expect(AuthValidators.password(null), 'Password is required');
      expect(AuthValidators.password(''), 'Password is required');
    });

    test('< 8 chars → "At least 8 characters"', () {
      expect(AuthValidators.password('a1b2c3'), 'At least 8 characters');
      expect(AuthValidators.password('1234567'), 'At least 8 characters');
    });

    test('no digit → "Include at least one number"', () {
      expect(
        AuthValidators.password('abcdefgh'),
        'Include at least one number',
      );
    });

    test('valid: 8+ chars with at least one digit → null', () {
      expect(AuthValidators.password('hunter12'), null);
      expect(AuthValidators.password('Chat22Test!'), null);
    });

    test('digit at any position is accepted', () {
      expect(AuthValidators.password('1abcdefg'), null);
      expect(AuthValidators.password('abcdefg1'), null);
      expect(AuthValidators.password('abc1defg'), null);
    });
  });

  group('AuthValidators.passwordSimple (sign-in)', () {
    // Sign-in is more forgiving — we don't want to lock out users
    // whose pre-existing password doesn't pass the stricter signup rule.
    test('null / empty → "Password is required"', () {
      expect(AuthValidators.passwordSimple(null), 'Password is required');
      expect(AuthValidators.passwordSimple(''), 'Password is required');
    });

    test('< 6 chars → "At least 6 characters"', () {
      expect(AuthValidators.passwordSimple('abc'), 'At least 6 characters');
      expect(AuthValidators.passwordSimple('12345'), 'At least 6 characters');
    });

    test('6+ chars (any composition) → null', () {
      expect(AuthValidators.passwordSimple('123456'), null);
      expect(AuthValidators.passwordSimple('hunter'), null);
      expect(AuthValidators.passwordSimple('abcdef'), null);
    });
  });

  group('AuthValidators.confirmPassword', () {
    test('null / empty → "Please confirm password"', () {
      final other = TextEditingController(text: 'hunter12');
      addTearDown(other.dispose);
      final validator = AuthValidators.confirmPassword(other);
      expect(validator(null), 'Please confirm password');
      expect(validator(''), 'Please confirm password');
    });

    test('different value → "Passwords do not match"', () {
      final other = TextEditingController(text: 'hunter12');
      addTearDown(other.dispose);
      final validator = AuthValidators.confirmPassword(other);
      expect(validator('hunter13'), 'Passwords do not match');
    });

    test('matching value → null', () {
      final other = TextEditingController(text: 'hunter12');
      addTearDown(other.dispose);
      final validator = AuthValidators.confirmPassword(other);
      expect(validator('hunter12'), null);
    });

    test('reads from controller at call time (not at validator creation)', () {
      final other = TextEditingController(text: 'first');
      addTearDown(other.dispose);
      final validator = AuthValidators.confirmPassword(other);
      // Change controller after the validator is built.
      other.text = 'second';
      expect(validator('first'), 'Passwords do not match');
      expect(validator('second'), null);
    });
  });

  group('AuthValidators.required', () {
    test('null / empty / whitespace → "<field> is required"', () {
      expect(AuthValidators.required(null), 'Field is required');
      expect(AuthValidators.required(''), 'Field is required');
      expect(AuthValidators.required('   '), 'Field is required');
    });

    test('custom field name appears in the error message', () {
      expect(
        AuthValidators.required(null, fieldName: 'Name'),
        'Name is required',
      );
    });

    test('non-empty value → null', () {
      expect(AuthValidators.required('Ali'), null);
      expect(AuthValidators.required('a'), null);
    });
  });
}
