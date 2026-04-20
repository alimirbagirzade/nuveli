import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

/// Premium durum modeli.
class PremiumStatus {
  final String tier; // free | trial | premium
  final DateTime? trialEndsAt;
  final DateTime? subscriptionEndsAt;

  const PremiumStatus({
    required this.tier,
    this.trialEndsAt,
    this.subscriptionEndsAt,
  });

  bool get isPremium => tier == 'premium' || tier == 'trial';
  bool get isTrialing => tier == 'trial';
  bool get isFree => tier == 'free';

  factory PremiumStatus.fromJson(Map<String, dynamic> j) => PremiumStatus(
        tier: j['tier'] as String? ?? 'free',
        trialEndsAt: j['trial_ends_at'] != null
            ? DateTime.tryParse(j['trial_ends_at'] as String)
            : null,
        subscriptionEndsAt: j['subscription_ends_at'] != null
            ? DateTime.tryParse(j['subscription_ends_at'] as String)
            : null,
      );

  factory PremiumStatus.free() => const PremiumStatus(tier: 'free');
}

/// RevenueCat yaşam döngüsü yöneticisi.
class RevenueCatService {
  RevenueCatService(this._dio);
  final Dio _dio;

  bool _configured = false;

  /// Uygulama açılışında çağır. Supabase user ID ile RevenueCat'i başlatır.
  Future<void> configure(String supabaseUserId) async {
    if (_configured) return;

    try {
      PurchasesConfiguration config;
      if (Platform.isIOS) {
        config = PurchasesConfiguration(AppConfig.revenueCatAppleKey);
      } else {
        config = PurchasesConfiguration(AppConfig.revenueCatGoogleKey);
      }
      config.appUserID = supabaseUserId;

      await Purchases.configure(config);
      _configured = true;
    } catch (e) {
      // RevenueCat key yoksa veya hata olursa uygulama yine çalışsın
      // ignore: avoid_print
      print('RevenueCat configure failed: $e');
    }
  }

  /// RC offerings'i getir. "default" offering kullanılır.
  Future<Offering?> getDefaultOffering() async {
    if (!_configured) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (e) {
      return null;
    }
  }

  /// Paket satın al.
  /// Başarılı olursa RevenueCat webhook backend'i günceller.
  /// UI client-side state için [fetchStatusFromBackend] ile status'u çekmeli.
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (!_configured) return PurchaseResult.notConfigured();

    try {
      final purchaseInfo = await Purchases.purchasePackage(package);
      final hasPremium = purchaseInfo.entitlements.active.containsKey('premium');
      return PurchaseResult.success(hasPremium: hasPremium);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled();
      }
      return PurchaseResult.failure(e.message ?? 'Satın alma başarısız.');
    }
  }

  /// Önceki satın almaları geri yükle (cihaz değiştirdiyse).
  Future<PurchaseResult> restorePurchases() async {
    if (!_configured) return PurchaseResult.notConfigured();
    try {
      final info = await Purchases.restorePurchases();
      final hasPremium = info.entitlements.active.containsKey('premium');
      return PurchaseResult.success(hasPremium: hasPremium);
    } catch (e) {
      return PurchaseResult.failure(e.toString());
    }
  }

  /// Backend'den premium status çek (source of truth).
  Future<PremiumStatus> fetchStatusFromBackend() async {
    try {
      final resp = await _dio.get('/premium/status');
      return PremiumStatus.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// Backend trial claim — 7 gün premium erişim.
  Future<bool> claimTrial() async {
    try {
      final resp = await _dio.post('/premium/trial-claim');
      final data = resp.data['data'] as Map<String, dynamic>;
      return data['claimed'] as bool? ?? false;
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}

/// Satın alma sonucu.
sealed class PurchaseResult {
  const PurchaseResult();
  factory PurchaseResult.success({required bool hasPremium}) = PurchaseSuccess;
  factory PurchaseResult.cancelled() = PurchaseCancelled;
  factory PurchaseResult.failure(String message) = PurchaseFailure;
  factory PurchaseResult.notConfigured() = PurchaseNotConfigured;
}

class PurchaseSuccess extends PurchaseResult {
  const PurchaseSuccess({required this.hasPremium});
  final bool hasPremium;
}

class PurchaseCancelled extends PurchaseResult {
  const PurchaseCancelled();
}

class PurchaseFailure extends PurchaseResult {
  const PurchaseFailure(this.message);
  final String message;
}

class PurchaseNotConfigured extends PurchaseResult {
  const PurchaseNotConfigured();
}

// ─── Providers ──────────────────────

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService(ref.watch(apiClientProvider));
});

/// Premium durum — backend'den çekilir, source of truth.
final premiumStatusProvider = FutureProvider<PremiumStatus>((ref) async {
  final rc = ref.watch(revenueCatServiceProvider);
  return rc.fetchStatusFromBackend();
});

/// RC offerings'i getir.
final revenueCatOfferingProvider = FutureProvider<Offering?>((ref) async {
  final rc = ref.watch(revenueCatServiceProvider);
  // Supabase user bağlıysa configure et
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    await rc.configure(user.id);
  }
  return rc.getDefaultOffering();
});
