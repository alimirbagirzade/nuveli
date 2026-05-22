import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/auth/secure_session_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSecure extends Mock implements FlutterSecureStorage {}

const _key = 'SUPABASE_PERSIST_SESSION_KEY';

SecureSessionStorage _build(
  _MockSecure secure, {
  Map<String, Object> initialPrefs = const {},
}) {
  SharedPreferences.setMockInitialValues(
    initialPrefs.map((k, v) => MapEntry(k, v)),
  );
  return SecureSessionStorage(
    persistSessionKey: _key,
    secureStorage: secure,
  );
}

void main() {
  setUpAll(() {
    // mocktail needs a fallback for named-arg matchers
    registerFallbackValue('');
  });

  late _MockSecure secure;

  setUp(() {
    secure = _MockSecure();
  });

  group('initialize — legacy session migration', () {
    test('moves a plaintext session into secure storage and clears prefs',
        () async {
      const legacy = '{"access_token":"plaintext-jwt","refresh_token":"r"}';
      final storage = _build(secure, initialPrefs: {_key: legacy});

      when(() => secure.read(key: _key)).thenAnswer((_) async => null);
      when(() => secure.write(key: _key, value: legacy))
          .thenAnswer((_) async {});

      await storage.initialize();

      verify(() => secure.write(key: _key, value: legacy)).called(1);
      // Prefs should no longer hold the plaintext copy.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_key), isNull);
    });

    test('no-op when no legacy session exists in prefs', () async {
      final storage = _build(secure); // no initialPrefs

      await storage.initialize();

      verifyNever(() => secure.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
    });

    test('does not overwrite an existing secure-storage session', () async {
      // If both stores have a value (edge case: partial prior migration), the
      // secure copy wins. The prefs copy is still cleared to remove the leak.
      const legacy = 'legacy-prefs-value';
      const existing = 'already-migrated';
      final storage = _build(secure, initialPrefs: {_key: legacy});

      when(() => secure.read(key: _key)).thenAnswer((_) async => existing);

      await storage.initialize();

      verifyNever(() => secure.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_key), isNull,
          reason: 'legacy plaintext must be removed regardless');
    });
  });

  group('LocalStorage interface', () {
    test('hasAccessToken returns true when secure storage has a value',
        () async {
      final storage = _build(secure);
      when(() => secure.read(key: _key)).thenAnswer((_) async => 'value');
      expect(await storage.hasAccessToken(), isTrue);
    });

    test('hasAccessToken returns false when secure storage is empty', () async {
      final storage = _build(secure);
      when(() => secure.read(key: _key)).thenAnswer((_) async => null);
      expect(await storage.hasAccessToken(), isFalse);
    });

    test('accessToken reads from secure storage', () async {
      final storage = _build(secure);
      when(() => secure.read(key: _key)).thenAnswer((_) async => 'jwt');
      expect(await storage.accessToken(), equals('jwt'));
    });

    test('persistSession writes to secure storage', () async {
      final storage = _build(secure);
      when(() => secure.write(key: _key, value: 'new-session'))
          .thenAnswer((_) async {});

      await storage.persistSession('new-session');

      verify(() => secure.write(key: _key, value: 'new-session')).called(1);
    });

    test('removePersistedSession deletes from secure storage', () async {
      final storage = _build(secure);
      when(() => secure.delete(key: _key)).thenAnswer((_) async {});

      await storage.removePersistedSession();

      verify(() => secure.delete(key: _key)).called(1);
    });
  });

  group('SecureGotrueAsyncStorage', () {
    test('getItem/setItem/removeItem delegate to secure storage', () async {
      final pkce = SecureGotrueAsyncStorage(secureStorage: secure);

      when(() => secure.read(key: 'pkce_v')).thenAnswer((_) async => 'verifier');
      when(() => secure.write(key: 'pkce_v', value: 'v'))
          .thenAnswer((_) async {});
      when(() => secure.delete(key: 'pkce_v')).thenAnswer((_) async {});

      expect(await pkce.getItem(key: 'pkce_v'), equals('verifier'));
      await pkce.setItem(key: 'pkce_v', value: 'v');
      await pkce.removeItem(key: 'pkce_v');

      verify(() => secure.read(key: 'pkce_v')).called(1);
      verify(() => secure.write(key: 'pkce_v', value: 'v')).called(1);
      verify(() => secure.delete(key: 'pkce_v')).called(1);
    });
  });
}
