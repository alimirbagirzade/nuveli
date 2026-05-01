// app/lib/features/premium/data/premium_service.dart
//
// Premium Service — RevenueCat ile uygulamanın tek arayüzü.
// PRD §7 Premium ve RevenueCat, §6.4 Trial sırası.
//
// Sorumluluğu:
// - Purchases SDK initialize
// - Offerings çekme, satın alma, restore
// - Entitlement değişikliklerini stream et
// - Backend'e sync et (premium_status_cache cache'i)
//
// Bu servis tek bir static instance gibi davranır (Riverpod provider ile).

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:nuveli/core/config/app_config.dart';
import 'package:nuveli/core/network/api_client.dart';
import 'package:nuveli/core/network/app_error.dart';

// ═══════════════════════════════════════════════════════════════
// Models
// ═══════════════════════════════════════════════════════════════

enum PremiumStatus { free, trial, premium, expired, unknown }

class PremiumState {
  final PremiumStatus status;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final String? activeProductId;
  final bool day2GiftAvailable;

  const PremiumState({
    required this.status,
    this.trialEndsAt,
    this.currentPeriodEnd,
    this.activeProductId,
    this.day2GiftAvailable = false,
  });

  factory PremiumState.unknown() =>
      const PremiumState(status: PremiumStatus.unknown);

  factory PremiumState.free() =>
      const PremiumState(status: PremiumStatus.free);

  bool get isPremium =>
      status == PremiumStatus.premium || status == PremiumStatus.trial;

  bool get isInTrial =>
      status == PremiumStatus.trial &&
      trialEndsAt != null &&
      trialEndsAt!.isAfter(DateTime.now());

  PremiumState copyWith({
    PremiumStatus? status,
    DateTime? trialEndsAt,
    DateTime? currentPeriodEnd,
    String? activeProductId,
    bool? day2GiftAvailable,
  }) =>
      PremiumState(
        status: status ?? this.status,
        trialEndsAt: trialEndsAt ?? this.trialEndsAt,
        currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
        activeProductId: activeProductId ?? this.activeProductId,
        day2GiftAvailable: day2GiftAvailable ?? this.day2GiftAvailable,
      );
}

class PremiumOffering {
  final String identifier;       // 'monthly' | 'yearly'
  final String productId;
  final String displayPrice;     // "₺149,00 / yıl"
  final String periodLabel;      // "Yıllık"
  final bool hasFreeTrial;
  final int? trialDays;
  final Package package;          // RevenueCat raw Package (purchase için)

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
  final PremiumState? newState;

  const PurchaseResult({
    required this.success,
    this.errorCode,
    this.userMessage,
    this.userCancelled = false,
    this.newState,
  });

  factory PurchaseResult.success(PremiumState state) =>
      PurchaseResult(success: true, newState: state);

  factory PurchaseResult.cancelled() =>
      const PurchaseResult(
        success: false,
        userCancelled: true,
        userMessage: 'Satın alma iptal edildi',
      );

  factory PurchaseResult.failed(String code, String message) =>
      PurchaseResult(success: false, errorCode: code, userMessage: message);
}

// ═══════════════════════════════════════════════════════════════
// Service
// ═══════════════════════════════════════════════════════════════

class PremiumService {
  final AppConfig _config;
  final ApiClient _api;

  bool _initialized = false;
  final _stateController = StreamController<PremiumState>.broadcast();
  PremiumState _currentState = PremiumState.unknown();

  PremiumService(this._config, this._api);

  Stream<PremiumState> get stateStream => _stateController.stream;
  PremiumState get currentState => _currentState;

  // ───────────────────────────────────────────────────
  // Initialize
  // ───────────────────────────────────────────────────

  /// Uygulama açılırken bir kez çağrılır.
  /// userId Supabase auth user UUID'si.
  Future<void> initialize({required String userId}) async {
    if (_initialized) {
      // Login değişikliklerinde re-identify
      await Purchases.logIn(userId);
      await _refreshFromCustomerInfo();
      return;
    }

    final apiKey = defaultTargetPlatform == TargetPlatform.iOS
        ? _config.revenueCatAppleKey
        : _config.revenueCatGoogleKey;

    if (apiKey.isEmpty) {
      debugPrint('PremiumService: RevenueCat API key empty, running in stub mode');
      _currentState = PremiumState.free();
      _stateController.add(_currentState);
      return;
    }

    await Purchases.setLogLevel(
      _config.isDebug ? LogLevel.debug : LogLevel.warn,
    );

    final configuration = PurchasesConfiguration(apiKey)
      ..appUserID = userId;
    await Purchases.configure(configuration);

    Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);

    _initialized = true;
    await _refreshFromCustomerInfo();
  }

  void _handleCustomerInfoUpdate(CustomerInfo info) {
    final state = _stateFromCustomerInfo(info);
    _currentState = state;
    _stateController.add(state);
    // Async backend sync — fire and forget
    unawaited(_syncToBackend(info));
  }

  Future<void> _refreshFromCustomerInfo() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _handleCustomerInfoUpdate(info);
    } catch (e, st) {
      debugPrint('PremiumService.refresh failed: $e\n$st');
      _currentState = PremiumState.free();
      _stateController.add(_currentState);
    }
  }

  PremiumState _stateFromCustomerInfo(CustomerInfo info) {
    // RevenueCat entitlement adı: 'premium' (RevenueCat dashboard'da bunu kur)
    const entitlementId = 'premium';
    final ent = info.entitlements.active[entitlementId];

    if (ent == null) {
      // Aktif entitlement yok → free veya expired
      final hadEntitlement = info.entitlements.all.containsKey(entitlementId);
      return PremiumState(
        status: hadEntitlement ? PremiumStatus.expired : PremiumStatus.free,
      );
    }

    final isTrial = ent.periodType == PeriodType.trial;
    return PremiumState(
      status: isTrial ? PremiumStatus.trial : PremiumStatus.premium,
      trialEndsAt: isTrial && ent.expirationDate != null
          ? DateTime.tryParse(ent.expirationDate!)
          : null,
      currentPeriodEnd: ent.expirationDate != null
          ? DateTime.tryParse(ent.expirationDate!)
          : null,
      activeProductId: ent.productIdentifier,
    );
  }

  // ───────────────────────────────────────────────────
  // Offerings
  // ───────────────────────────────────────────────────

  Future<List<PremiumOffering>> getOfferings() async {
    if (!_initialized) {
      throw const AppError(
        code: 'premium_not_initialized',
        message: 'Premium servis başlatılmadı',
      );
    }

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        return [];
      }

      final result = <PremiumOffering>[];
      for (final pkg in current.availablePackages) {
        result.add(_packageToOffering(pkg));
      }
      return result;
    } on PlatformException catch (e) {
      throw AppError(
        code: 'offerings_fetch_failed',
        message: 'Premium seçenekleri yüklenemedi',
        cause: e,
      );
    }
  }

  PremiumOffering _packageToOffering(Package pkg) {
    final product = pkg.storeProduct;
    final periodLabel = _periodLabel(pkg.packageType);

    // Trial bilgisi
    final intro = product.introductoryPrice;
    final hasTrial = intro != null && intro.priceAmount == 0;
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
        return 'yıl';
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
    // ISO 8601 duration: P7D, P1W, P1M
    final dayMatch = RegExp(r'P(\d+)D').firstMatch(period);
    if (dayMatch != null) return int.tryParse(dayMatch.group(1)!);
    final weekMatch = RegExp(r'P(\d+)W').firstMatch(period);
    if (weekMatch != null) {
      final w = int.tryParse(weekMatch.group(1)!);
      return w != null ? w * 7 : null;
    }
    return null;
  }

  // ───────────────────────────────────────────────────
  // Purchase & Restore
  // ───────────────────────────────────────────────────

  Future<PurchaseResult> purchase(PremiumOffering offering) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(offering.package);
      // CustomerInfo otomatik update'lenir, listener tetiklenir
      final newState = _stateFromCustomerInfo(purchaseResult);
      _currentState = newState;
      _stateController.add(newState);
      unawaited(_syncToBackend(purchaseResult));
      return PurchaseResult.success(newState);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled();
      }
      return PurchaseResult.failed(
        errorCode.name,
        _userMessageFromError(errorCode),
      );
    } catch (e) {
      return PurchaseResult.failed(
        'unknown',
        'Beklenmedik bir sorun oldu, tekrar dener misin?',
      );
    }
  }

  Future<PurchaseResult> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      final newState = _stateFromCustomerInfo(info);
      _currentState = newState;
      _stateController.add(newState);
      unawaited(_syncToBackend(info));
      return PurchaseResult.success(newState);
    } on PlatformException catch (e) {
      return PurchaseResult.failed(
        'restore_failed',
        'Geri yükleme başarısız oldu, biraz sonra dener misin?',
      );
    }
  }

  String _userMessageFromError(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Bu cihazda satın alma izni yok';
      case PurchasesErrorCode.networkError:
        return 'Bağlantı kurulamadı, tekrar dener misin?';
      case PurchasesErrorCode.paymentPendingError:
        return 'Ödeme onayı bekleniyor';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Bu plan şu an satın alınamıyor';
      default:
        return 'Satın alma tamamlanamadı';
    }
  }

  // ───────────────────────────────────────────────────
  // Backend Sync
  // ───────────────────────────────────────────────────

  Future<void> _syncToBackend(CustomerInfo info) async {
    try {
      await _api.post(
        '/premium/sync',
        data: {
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
        },
      );
    } catch (e) {
      // Sync hatası satın almayı bozmaz — backend cache eninde sonunda güncellenir
      debugPrint('PremiumService._syncToBackend failed (non-fatal): $e');
    }
  }

  // ───────────────────────────────────────────────────
  // Day 2 Trial Gift
  // ───────────────────────────────────────────────────

  /// Backend'den day2 gift uygunluğunu sorgular.
  Future<bool> isDay2GiftEligible() async {
    try {
      final res = await _api.get('/premium/day2-gift-status');
      return (res.data?['eligible'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Trial'ı yıllık plan üzerinden başlatır.
  Future<PurchaseResult> claimDay2Gift() async {
    final offerings = await getOfferings();
    final yearly = offerings.firstWhere(
      (o) => o.identifier.toLowerCase().contains('annual') ||
             o.identifier.toLowerCase().contains('yearly'),
      orElse: () => offerings.first,
    );

    final result = await purchase(yearly);
    if (result.success) {
      try {
        await _api.post('/premium/day2-gift-claim', data: {
          'product_id': yearly.productId,
        });
      } catch (_) {/* non-fatal */}
    }
    return result;
  }

  void dispose() {
    _stateController.close();
  }
}

// ═══════════════════════════════════════════════════════════════
// Riverpod providers
// ═══════════════════════════════════════════════════════════════

final premiumServiceProvider = Provider<PremiumService>((ref) {
  // app_config / api_client mevcut provider'larından gelmeli
  // Senin AppConfig + ApiClient provider isimlerine göre uyarla:
  final config = ref.watch(appConfigProvider);
  final api = ref.watch(apiClientProvider);
  final svc = PremiumService(config, api);
  ref.onDispose(svc.dispose);
  return svc;
});

final premiumStateProvider = StreamProvider<PremiumState>((ref) {
  return ref.watch(premiumServiceProvider).stateStream;
});
