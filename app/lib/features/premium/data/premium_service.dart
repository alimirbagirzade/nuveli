// app/lib/features/premium/data/premium_service.dart
//
// Premium Service — RevenueCat ile uygulamanin tek arayuzu.
// PRD §7 Premium ve RevenueCat, §6.4 Trial sirasi.

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:nuveli/core/config/app_config.dart';
import 'package:nuveli/core/network/api_client.dart';

enum PremiumTier { free, trial, premium, expired, unknown }

class PremiumStatus {
  final PremiumTier tier;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final String? activeProductId;
  final bool day2GiftAvailable;

  const PremiumStatus({
    required this.tier,
    this.trialEndsAt,
    this.currentPeriodEnd,
    this.activeProductId,
    this.day2GiftAvailable = false,
  });

  factory PremiumStatus.unknown() => const PremiumStatus(tier: PremiumTier.unknown);
  factory PremiumStatus.free() => const PremiumStatus(tier: PremiumTier.free);

  bool get isPremium => tier == PremiumTier.premium || tier == PremiumTier.trial;
  bool get isInTrial =>
      tier == PremiumTier.trial &&
      trialEndsAt != null &&
      trialEndsAt!.isAfter(DateTime.now());
  bool get isFree => tier == PremiumTier.free;
}

class PremiumOffering {
  final String identifier;
  final String productId;
  final String displayPrice;
  final String periodLabel;
  final bool hasFreeTrial;
  final int? trialDays;
  final Package package;

  const PremiumOffering({
    required this.identifier,
    required this.productId,
    required this.displayPrice,
    required this.periodLabel,
    required this.hasFreeTrial,
    this.trialDays,
    required this.package,
  });
}

class PurchaseResult {
  final bool success;
  final String? errorCode;
  final String? userMessage;
  final bool userCancelled;
  final PremiumStatus? newStatus;

  const PurchaseResult({
    required this.success,
    this.errorCode,
    this.userMessage,
    this.userCancelled = false,
    this.newStatus,
  });

  factory PurchaseResult.successResult(PremiumStatus status) =>
      PurchaseResult(success: true, newStatus: status);
  factory PurchaseResult.cancelled() => const PurchaseResult(
      success: false, userCancelled: true, userMessage: 'Satin alma iptal edildi');
  factory PurchaseResult.failed(String code, String message) =>
      PurchaseResult(success: false, errorCode: code, userMessage: message);
}

class PremiumService {
  final Dio _dio;
  bool _initialized = false;
  final _stateController = StreamController<PremiumStatus>.broadcast();
  PremiumStatus _currentStatus = PremiumStatus.unknown();

  PremiumService(this._dio);

  Stream<PremiumStatus> get statusStream => _stateController.stream;
  PremiumStatus get currentStatus => _currentStatus;

  Future<void> initialize({required String userId}) async {
    if (_initialized) {
      await Purchases.logIn(userId);
      await _refreshFromCustomerInfo();
      return;
    }

    final apiKey = defaultTargetPlatform == TargetPlatform.iOS
        ? AppConfig.revenueCatAppleKey
        : AppConfig.revenueCatGoogleKey;

    if (apiKey.isEmpty) {
      debugPrint('PremiumService: RevenueCat API key empty, stub mode');
      _currentStatus = PremiumStatus.free();
      _stateController.add(_currentStatus);
      _initialized = true;
      return;
    }

    await Purchases.setLogLevel(
        AppConfig.isDevelopment ? LogLevel.debug : LogLevel.warn);

    final configuration = PurchasesConfiguration(apiKey)..appUserID = userId;
    await Purchases.configure(configuration);

    Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
    _initialized = true;
    await _refreshFromCustomerInfo();
  }

  void _handleCustomerInfoUpdate(CustomerInfo info) {
    final status = _statusFromCustomerInfo(info);
    _currentStatus = status;
    _stateController.add(status);
    unawaited(_syncToBackend(info));
  }

  Future<void> _refreshFromCustomerInfo() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _handleCustomerInfoUpdate(info);
    } catch (e) {
      debugPrint('PremiumService.refresh failed: $e');
      _currentStatus = PremiumStatus.free();
      _stateController.add(_currentStatus);
    }
  }

  PremiumStatus _statusFromCustomerInfo(CustomerInfo info) {
    const entitlementId = 'premium';
    final ent = info.entitlements.active[entitlementId];
    if (ent == null) {
      final hadEntitlement = info.entitlements.all.containsKey(entitlementId);
      return PremiumStatus(
          tier: hadEntitlement ? PremiumTier.expired : PremiumTier.free);
    }
    final isTrial = ent.periodType == PeriodType.trial;
    return PremiumStatus(
      tier: isTrial ? PremiumTier.trial : PremiumTier.premium,
      trialEndsAt: isTrial && ent.expirationDate != null
          ? DateTime.tryParse(ent.expirationDate!)
          : null,
      currentPeriodEnd: ent.expirationDate != null
          ? DateTime.tryParse(ent.expirationDate!)
          : null,
      activeProductId: ent.productIdentifier,
    );
  }

  Future<List<PremiumOffering>> getOfferings() async {
    if (!_initialized) throw Exception('Premium servis baslatilmadi');
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return [];
      return current.availablePackages.map(_packageToOffering).toList();
    } on PlatformException catch (e) {
      throw Exception('Premium secenekleri yuklenemedi: ${e.message}');
    }
  }

  PremiumOffering _packageToOffering(Package pkg) {
    final product = pkg.storeProduct;
    final periodLabel = _periodLabel(pkg.packageType);
    final intro = product.introductoryPrice;
    final hasTrial = intro != null && intro.price == 0;
    final trialDays = hasTrial ? _periodToDays(intro.period) : null;
    return PremiumOffering(
      identifier: pkg.identifier,
      productId: product.identifier,
      displayPrice: '${product.priceString} / $periodLabel',
      periodLabel: periodLabel,
      hasFreeTrial: hasTrial,
      trialDays: trialDays,
      package: pkg,
    );
  }

  String _periodLabel(PackageType type) {
    switch (type) {
      case PackageType.annual:
        return 'yil';
      case PackageType.monthly:
        return 'ay';
      case PackageType.weekly:
        return 'hafta';
      case PackageType.lifetime:
        return 'tek seferlik';
      default:
        return '';
    }
  }

  int? _periodToDays(String? period) {
    if (period == null) return null;
    final dayMatch = RegExp(r'P(\d+)D').firstMatch(period);
    if (dayMatch != null) return int.tryParse(dayMatch.group(1)!);
    final weekMatch = RegExp(r'P(\d+)W').firstMatch(period);
    if (weekMatch != null) {
      final w = int.tryParse(weekMatch.group(1)!);
      return w != null ? w * 7 : null;
    }
    return null;
  }

  Future<PurchaseResult> purchase(PremiumOffering offering) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(offering.package);
      final newStatus = _statusFromCustomerInfo(purchaseResult);
      _currentStatus = newStatus;
      _stateController.add(newStatus);
      unawaited(_syncToBackend(purchaseResult));
      return PurchaseResult.successResult(newStatus);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled();
      }
      return PurchaseResult.failed(
          errorCode.name, _userMessageFromError(errorCode));
    } catch (e) {
      return PurchaseResult.failed(
          'unknown', 'Beklenmedik bir sorun oldu, tekrar dener misin?');
    }
  }

  Future<PurchaseResult> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      final newStatus = _statusFromCustomerInfo(info);
      _currentStatus = newStatus;
      _stateController.add(newStatus);
      unawaited(_syncToBackend(info));
      return PurchaseResult.successResult(newStatus);
    } on PlatformException catch (_) {
      return PurchaseResult.failed(
          'restore_failed', 'Geri yukleme basarisiz oldu');
    }
  }

  String _userMessageFromError(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Bu cihazda satin alma izni yok';
      case PurchasesErrorCode.networkError:
        return 'Baglanti kurulamadi';
      case PurchasesErrorCode.paymentPendingError:
        return 'Odeme onayi bekleniyor';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Bu plan su an satin alinamiyor';
      default:
        return 'Satin alma tamamlanamadi';
    }
  }

  Future<void> _syncToBackend(CustomerInfo info) async {
    try {
      await _dio.post('/premium/sync', data: {
        'rc_customer_id': info.originalAppUserId,
        'active_entitlement_ids': info.entitlements.active.keys.toList(),
        'active_product_id': info.entitlements.active.values.isNotEmpty
            ? info.entitlements.active.values.first.productIdentifier
            : null,
        'expiration_date': info.entitlements.active.values.isNotEmpty
            ? info.entitlements.active.values.first.expirationDate
            : null,
        'period_type': info.entitlements.active.values.isNotEmpty
            ? info.entitlements.active.values.first.periodType.name
            : null,
      });
    } catch (e) {
      debugPrint('PremiumService._syncToBackend failed: $e');
    }
  }

  Future<bool> isDay2GiftEligible() async {
    try {
      final res = await _dio.get('/premium/day2-gift-status');
      return (res.data?['eligible'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<PurchaseResult> claimDay2Gift() async {
    final offerings = await getOfferings();
    if (offerings.isEmpty) {
      return PurchaseResult.failed(
          'no_offerings', 'Henuz hediye hazir degil');
    }
    final yearly = offerings.firstWhere(
      (o) =>
          o.identifier.toLowerCase().contains('annual') ||
          o.identifier.toLowerCase().contains('yearly'),
      orElse: () => offerings.first,
    );
    final result = await purchase(yearly);
    if (result.success) {
      try {
        await _dio.post('/premium/day2-gift-claim',
            data: {'product_id': yearly.productId});
      } catch (_) {}
    }
    return result;
  }

  void dispose() {
    _stateController.close();
  }
}

final premiumServiceProvider = Provider<PremiumService>((ref) {
  final dio = ref.watch(apiClientProvider);
  final svc = PremiumService(dio);
  ref.onDispose(svc.dispose);
  return svc;
});

final premiumStatusProvider = StreamProvider<PremiumStatus>((ref) {
  return ref.watch(premiumServiceProvider).statusStream;
});
