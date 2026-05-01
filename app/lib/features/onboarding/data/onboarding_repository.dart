import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'onboarding_data.dart';

/// Onboarding backend operasyonları.
class OnboardingRepository {
  OnboardingRepository(this._dio);

  final Dio _dio;

  /// Profil + hedef + fiziksel bilgileri kaydet.
  /// Backend calorie target'ı Mifflin-St Jeor ile hesaplayıp döner.
  Future<Map<String, dynamic>> saveProfile(OnboardingData data) async {
    final response = await _dio.post(
      '/profile/onboarding',
      data: data.toOnboardingPayload(),
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  /// Koç persona tercihini kaydet.
  Future<void> saveCoachPersona(String persona) async {
    await _dio.post(
      '/profile/coach-preferences',
      data: {'coach_persona': persona},
    );
  }

  /// Notification preferences kaydet.
  Future<void> saveNotificationPrefs(OnboardingData data) async {
    await _dio.post(
      '/profile/notification-preferences',
      data: data.toNotifPayload(),
    );
  }

  /// Onboarding'i tamamlandı işaretle. Premium status'u 'free' olarak başlatır.
  Future<void> completeOnboarding() async {
    await _dio.post('/profile/complete-onboarding');
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(apiClientProvider));
});
