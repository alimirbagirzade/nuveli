// Device-level verification of the secure-storage migration (PR #96).
//
// Runs on a real iOS simulator / Android emulator (not in a host-side
// flutter_test sandbox), so the calls below hit the actual Keychain
// (iOS) or EncryptedSharedPreferences (Android) MethodChannels. That
// is the property we cannot prove from host-side widget tests.
//
// Run: flutter test integration_test/secure_storage_device_test.dart
//
// What this proves:
//   1. SecureSessionStorage round-trip: write → read → delete works
//      against the real native crypto store.
//   2. Migration: a pre-seeded plaintext session in SharedPreferences
//      moves into secure storage and the prefs copy is removed.
//   3. Migration is idempotent on a second `initialize()` call.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nuveli/core/auth/secure_session_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'SUPABASE_PERSIST_SESSION_KEY';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Use the same secure-storage config the production code uses (Keychain
  // accessibility = first_unlock_this_device, Android EncryptedSharedPrefs).
  // We do NOT inject a mock — the whole point is to exercise the real
  // native plugin.
  late FlutterSecureStorage secure;

  setUp(() async {
    secure = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    // Clean slate for every test — neither store should carry residue
    // from a prior run.
    await secure.delete(key: _key);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  });

  group('SecureSessionStorage roundtrip (real native store)', () {
    testWidgets('persistSession → accessToken returns the same value',
        (tester) async {
      final storage = SecureSessionStorage(persistSessionKey: _key);

      await storage.persistSession('{"access_token":"jwt-abc","user":"u1"}');

      expect(await storage.hasAccessToken(), isTrue);
      expect(
        await storage.accessToken(),
        equals('{"access_token":"jwt-abc","user":"u1"}'),
      );
    });

    testWidgets('removePersistedSession clears the token', (tester) async {
      final storage = SecureSessionStorage(persistSessionKey: _key);
      await storage.persistSession('something');

      await storage.removePersistedSession();

      expect(await storage.hasAccessToken(), isFalse);
      expect(await storage.accessToken(), isNull);
    });
  });

  group('one-shot migration from plaintext SharedPreferences', () {
    testWidgets('initialize() moves legacy session into Keychain',
        (tester) async {
      const legacy = '{"access_token":"legacy-jwt"}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, legacy);

      final storage = SecureSessionStorage(persistSessionKey: _key);
      await storage.initialize();

      // Plaintext copy must be gone.
      expect(prefs.getString(_key), isNull);
      // Secure copy must hold the same value.
      expect(await secure.read(key: _key), equals(legacy));
    });

    testWidgets('initialize() is a no-op when no legacy session exists',
        (tester) async {
      final storage = SecureSessionStorage(persistSessionKey: _key);
      await storage.initialize();

      expect(await secure.read(key: _key), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_key), isNull);
    });

    testWidgets('initialize() is idempotent — second call does not overwrite',
        (tester) async {
      // First migration moves legacy → secure
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, 'first-payload');

      final storage = SecureSessionStorage(persistSessionKey: _key);
      await storage.initialize();
      expect(await secure.read(key: _key), equals('first-payload'));

      // Simulate a SECOND launch where some other code path wrote a new
      // session into secure storage. A fresh legacy entry in prefs
      // must not clobber the newer secure value.
      await secure.write(key: _key, value: 'newer-payload');
      await prefs.setString(_key, 'stale-from-prior-build');

      await storage.initialize();

      expect(await secure.read(key: _key), equals('newer-payload'));
      // Stale prefs copy still gets removed regardless.
      expect(prefs.getString(_key), isNull);
    });
  });
}
