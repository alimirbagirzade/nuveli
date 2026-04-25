import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/core/utils/app_validators.dart';

void main() {
  group('AppValidators.email', () {
    test('null returns required error', () {
      expect(AppValidators.email(null), 'Email gerekli');
    });

    test('empty string returns required error', () {
      expect(AppValidators.email(''), 'Email gerekli');
      expect(AppValidators.email('   '), 'Email gerekli');
    });

    test('missing @ returns format error', () {
      expect(AppValidators.email('user.com'), 'Geçerli bir email gir');
    });

    test('missing TLD returns format error', () {
      expect(AppValidators.email('user@host'), 'Geçerli bir email gir');
    });

    test('valid email returns null', () {
      expect(AppValidators.email('user@example.com'), null);
      expect(AppValidators.email('a.b+c@example.co.uk'), null);
      expect(AppValidators.email('user_name@host.io'), null);
    });

    test('trims whitespace', () {
      expect(AppValidators.email('  user@example.com  '), null);
    });

    test('rejects spaces inside', () {
      expect(
        AppValidators.email('user @example.com'),
        'Geçerli bir email gir',
      );
    });
  });

  group('AppValidators.password', () {
    test('null/empty returns required', () {
      expect(AppValidators.password(null), 'Şifre gerekli');
      expect(AppValidators.password(''), 'Şifre gerekli');
    });

    test('5 chars returns length error', () {
      expect(AppValidators.password('12345'), 'En az 6 karakter');
    });

    test('exactly 6 chars passes', () {
      expect(AppValidators.password('123456'), null);
    });

    test('long password passes', () {
      expect(AppValidators.password('aLongPassword!23'), null);
    });
  });

  group('AppValidators.passwordStrong', () {
    test('< 8 chars fails', () {
      expect(AppValidators.passwordStrong('abc1234'), 'En az 8 karakter');
    });

    test('no digit fails', () {
      expect(
        AppValidators.passwordStrong('abcdefgh'),
        'En az bir rakam içermeli',
      );
    });

    test('no letter fails', () {
      expect(
        AppValidators.passwordStrong('12345678'),
        'En az bir harf içermeli',
      );
    });

    test('Turkish letter counts', () {
      expect(AppValidators.passwordStrong('şifre1234'), null);
    });

    test('valid strong password passes', () {
      expect(AppValidators.passwordStrong('Aa1234567'), null);
    });
  });

  group('AppValidators.passwordMatch', () {
    test('mismatch returns error', () {
      final validator = AppValidators.passwordMatch('original');
      expect(validator('different'), 'Şifreler eşleşmiyor');
    });

    test('match returns null', () {
      final validator = AppValidators.passwordMatch('mypassword');
      expect(validator('mypassword'), null);
    });

    test('null confirm returns required', () {
      final validator = AppValidators.passwordMatch('any');
      expect(validator(null), 'Şifreyi tekrar gir');
      expect(validator(''), 'Şifreyi tekrar gir');
    });
  });

  group('AppValidators.required', () {
    test('factory returns custom field name in message', () {
      final validator = AppValidators.required('Ad');
      expect(validator(null), 'Ad gerekli');
      expect(validator(''), 'Ad gerekli');
    });

    test('non-empty value passes', () {
      final validator = AppValidators.required('Ad');
      expect(validator('John'), null);
    });
  });

  group('AppValidators.numeric', () {
    test('non-numeric string fails', () {
      expect(AppValidators.numeric()('abc'), 'Sayı gir');
    });

    test('respects min/max bounds', () {
      final v = AppValidators.numeric(min: 18, max: 100);
      expect(v('17'), 'En az 18 olmalı');
      expect(v('101'), 'En fazla 100 olmalı');
      expect(v('50'), null);
    });
  });

  group('AppValidators.age', () {
    test('under 18 fails (gate yıllarca koruyacak)', () {
      expect(AppValidators.age('17'), 'En az 18 olmalı');
    });

    test('18 passes', () {
      expect(AppValidators.age('18'), null);
    });

    test('above 100 fails', () {
      expect(AppValidators.age('150'), 'En fazla 100 olmalı');
    });
  });

  group('AppValidators.weight', () {
    test('rejects too low/high', () {
      expect(AppValidators.weight('25'), 'En az 30 olmalı');
      expect(AppValidators.weight('400'), 'En fazla 300 olmalı');
    });

    test('valid range passes', () {
      expect(AppValidators.weight('70'), null);
    });
  });

  group('AppValidators.height', () {
    test('rejects below 100cm', () {
      expect(AppValidators.height('80'), 'En az 100 olmalı');
    });

    test('valid height passes', () {
      expect(AppValidators.height('175'), null);
    });
  });
}
