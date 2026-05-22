// Secure persistence for Supabase session tokens.
//
// Replaces the default `SharedPreferencesLocalStorage`, which stores JWTs
// in plaintext. JWTs are now held in:
//   * iOS: Keychain (Secure Enclave-backed where available)
//   * Android: EncryptedSharedPreferences (AES-256 via Jetpack Security)
//
// On first launch after upgrade, `initialize()` migrates an existing
// plaintext session out of SharedPreferences so logged-in users stay
// logged in without surfacing a re-auth screen.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Default platform-encryption options. Exposed as a top-level constant so
/// tests can substitute a no-op `FlutterSecureStorage()` without dragging
/// platform channels into the test environment.
const _defaultAndroidOptions = AndroidOptions(
  encryptedSharedPreferences: true,
);
const _defaultIOSOptions = IOSOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
);

class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({
    required this.persistSessionKey,
    FlutterSecureStorage? secureStorage,
    Future<SharedPreferences> Function()? sharedPreferencesFactory,
  })  : _secure = secureStorage ??
            const FlutterSecureStorage(
              aOptions: _defaultAndroidOptions,
              iOptions: _defaultIOSOptions,
            ),
        _prefsFactory = sharedPreferencesFactory ?? SharedPreferences.getInstance;

  final String persistSessionKey;
  final FlutterSecureStorage _secure;
  final Future<SharedPreferences> Function() _prefsFactory;

  @override
  Future<void> initialize() async {
    final prefs = await _prefsFactory();
    final legacy = prefs.getString(persistSessionKey);
    if (legacy == null) return;

    final alreadyMigrated = await _secure.read(key: persistSessionKey);
    if (alreadyMigrated == null) {
      await _secure.write(key: persistSessionKey, value: legacy);
    }
    await prefs.remove(persistSessionKey);
  }

  @override
  Future<bool> hasAccessToken() async {
    final value = await _secure.read(key: persistSessionKey);
    return value != null;
  }

  @override
  Future<String?> accessToken() => _secure.read(key: persistSessionKey);

  @override
  Future<void> removePersistedSession() =>
      _secure.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _secure.write(key: persistSessionKey, value: persistSessionString);
}

/// PKCE code-verifier storage. Without this, the verifier sits in
/// SharedPreferences plaintext during OAuth flows — a narrow but real
/// interception window on rooted/jailbroken devices.
class SecureGotrueAsyncStorage extends GotrueAsyncStorage {
  SecureGotrueAsyncStorage({FlutterSecureStorage? secureStorage})
      : _secure = secureStorage ??
            const FlutterSecureStorage(
              aOptions: _defaultAndroidOptions,
              iOptions: _defaultIOSOptions,
            );

  final FlutterSecureStorage _secure;

  @override
  Future<String?> getItem({required String key}) => _secure.read(key: key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _secure.write(key: key, value: value);

  @override
  Future<void> removeItem({required String key}) => _secure.delete(key: key);
}
