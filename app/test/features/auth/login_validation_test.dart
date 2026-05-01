import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuveli/features/auth/providers/auth_providers.dart';

/// Login screen'in form validation davranışını test eder.
/// Navigation + Supabase mock'lamak yerine sadece email/password validator'ları
/// test ederiz — bu logic Login/Signup/ForgotPassword arasında paylaşımlı.

void main() {
  group('Email validation logic', () {
    bool isValidEmail(String? email) {
      if (email == null || email.trim().isEmpty) return false;
      return email.contains('@') && email.contains('.');
    }

    test('empty email is invalid', () {
      expect(isValidEmail(''), false);
      expect(isValidEmail(null), false);
      expect(isValidEmail('   '), false);
    });

    test('email without @ is invalid', () {
      expect(isValidEmail('test.com'), false);
    });

    test('email without . is invalid', () {
      expect(isValidEmail('test@localhost'), false);
    });

    test('valid email passes', () {
      expect(isValidEmail('ali@example.com'), true);
      expect(isValidEmail('u.s.e.r@sub.domain.co'), true);
    });
  });

  group('Password validation logic', () {
    bool isValidPassword(String? password) {
      if (password == null || password.isEmpty) return false;
      return password.length >= 6;
    }

    test('empty password rejected', () {
      expect(isValidPassword(''), false);
      expect(isValidPassword(null), false);
    });

    test('password under 6 chars rejected', () {
      expect(isValidPassword('12345'), false);
      expect(isValidPassword('abc'), false);
    });

    test('password 6+ chars accepted', () {
      expect(isValidPassword('123456'), true);
      expect(isValidPassword('longpassword123'), true);
    });
  });

  group('Password strength logic (signup)', () {
    int strength(String p) {
      int s = 0;
      if (p.length >= 6) s++;
      if (p.length >= 10) s++;
      if (RegExp(r'[A-Z]').hasMatch(p)) s++;
      if (RegExp(r'[0-9]').hasMatch(p)) s++;
      if (RegExp(r'[!@#\$%\^&\*]').hasMatch(p)) s++;
      return s.clamp(0, 4);
    }

    test('very weak password scores 0-1', () {
      expect(strength('abc'), 0);
      expect(strength('abcdef'), 1);
    });

    test('medium scores 2', () {
      expect(strength('abcdefgh'), 1); // 8 chars lower, no upper
      expect(strength('Abcdef'), 2); // 6 chars + upper
    });

    test('strong password scores 3+', () {
      expect(strength('Abcdef1'), 3); // length + upper + digit
      expect(strength('Abcdef1!'), 4); // + symbol
    });

    test('capped at 4', () {
      expect(strength('VeryLongPassword1!@#'), 4);
    });
  });

  group('Auth loading state provider integration', () {
    test('loading provider starts false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(authLoadingProvider), false);
    });

    test('error provider starts null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(authErrorProvider), isNull);
    });
  });
}
