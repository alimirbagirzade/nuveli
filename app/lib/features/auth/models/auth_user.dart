// ============================================================================
// auth_user.dart
// Supabase User'ı uygulamaya özel alanlarla zenginleştiren immutable wrapper.
// Hazırlık dosyası: nuveli_chat15_hazirlik.md → models/auth_user.dart
// ============================================================================

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Uygulamaya özel kullanıcı modeli.
/// Supabase `User` objesini sarmalar, ancak Riverpod cache'lemesi için
/// immutable / equatable bir hale getirir.
class AuthUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final bool isAppleSignIn;
  final DateTime createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.createdAt,
    this.displayName,
    this.avatarUrl,
    this.isAppleSignIn = false,
  });

  // --------------------------------------------------------------------------
  // Supabase User → AuthUser
  // --------------------------------------------------------------------------
  factory AuthUser.fromSupabase(sb.User user) {
    final meta = user.userMetadata ?? <String, dynamic>{};
    final identities = user.identities ?? <sb.UserIdentity>[];
    final isApple = identities.any((i) => i.provider == 'apple');

    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: meta['full_name'] as String? ??
          meta['name'] as String? ??
          meta['display_name'] as String?,
      avatarUrl: meta['avatar_url'] as String? ?? meta['picture'] as String?,
      isAppleSignIn: isApple,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  // --------------------------------------------------------------------------
  // copyWith
  // --------------------------------------------------------------------------
  AuthUser copyWith({
    String? email,
    String? displayName,
    String? avatarUrl,
  }) =>
      AuthUser(
        id: id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isAppleSignIn: isAppleSignIn,
        createdAt: createdAt,
      );

  // --------------------------------------------------------------------------
  // Equatable benzeri eşitlik
  // --------------------------------------------------------------------------
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      (displayName?.hashCode ?? 0) ^
      (avatarUrl?.hashCode ?? 0);

  @override
  String toString() =>
      'AuthUser(id: $id, email: $email, displayName: $displayName)';
}
