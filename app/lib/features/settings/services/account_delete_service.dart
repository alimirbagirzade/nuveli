import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/authed_dio_provider.dart';

/// Permanently delete the signed-in account.
///
/// Apple App Store Guideline 5.1.1(v) — in-app account deletion is mandatory.
/// GDPR Article 17 (Right to Erasure) — user can request full data removal.
///
/// Flow:
///   1. Backend `DELETE /me` — service-role client deletes auth.users + cascade
///      (user_profiles, meals, water_logs, etc. via FK ON DELETE CASCADE).
///   2. Local `supabase.auth.signOut()` — clears cached session so the next
///      screen renders the welcome flow instead of a stale "logged in" UI.
class AccountDeleteService {
  final Dio _dio;
  final SupabaseClient _supabase;

  AccountDeleteService({
    required Dio dio,
    SupabaseClient? supabase,
  })  : _dio = dio,
        _supabase = supabase ?? Supabase.instance.client;

  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/me');
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }

    // Sign out is best-effort: even if it throws, the server-side data is
    // already gone, so we don't want a transient network blip to leave the
    // user trapped on the confirmation screen.
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // Local session clear will happen on next app launch anyway.
    }
  }
}

final accountDeleteServiceProvider = Provider<AccountDeleteService>((ref) {
  final dio = ref.watch(authedDioProvider);
  return AccountDeleteService(dio: dio);
});
