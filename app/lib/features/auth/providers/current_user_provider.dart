// ============================================================================
// current_user_provider.dart
// Backend'den UserProfile fetch eder.
// - Auth state değişince otomatik invalidate
// - Profile null/incomplete ise AuthGate onboarding'e yönlendirir
// - Manuel refresh (`ref.invalidate(currentUserProfileProvider)`) ile yenilenir
// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/profile_service.dart';
import 'auth_provider.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

final profileServiceProvider =
    Provider<ProfileService>((ref) => ProfileService());

// Test'te override için
final dioProvider = Provider<Dio>((ref) => Dio());

// ============================================================================
// CURRENT USER PROFILE
// ============================================================================

/// Backend'den fetch edilen kullanıcı profili.
/// - User logged out ise null döner.
/// - Token yoksa null döner.
/// - Backend ulaşılamazsa AsyncError döner (UI offline state gösterir).
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  // Auth state'i izle: değişince re-fetch.
  final authUser = ref.watch(currentAuthUserProvider);
  if (authUser == null) return null;

  final service = ref.read(profileServiceProvider);
  try {
    return await service.getCurrentProfile();
  } on ProfileServiceException catch (e) {
    // 404 → profile henüz yok (signup yeni, trigger henüz çalışmamış olabilir)
    // null dön, AuthGate onboarding'e yönlendirir.
    if (e.statusCode == 404) return null;
    rethrow;
  }
});

/// Kullanıcı onboarding tamamladı mı?
/// AuthGate bunu kullanır.
final onboardingCompletedProvider = Provider<bool>((ref) {
  final asyncProfile = ref.watch(currentUserProfileProvider);
  return asyncProfile.maybeWhen(
    data: (p) => p?.onboardingCompleted ?? false,
    orElse: () => false,
  );
});
