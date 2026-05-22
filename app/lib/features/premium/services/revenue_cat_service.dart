// lib/features/premium/services/revenue_cat_service.dart
//
// RevenueCat SDK wrapper.
// Tüm in-app purchase işlemleri buradan geçer.
//
// Kullanım:
//   await RevenueCatService.instance.init(userId: supabaseUserId);
//   final isPro = await RevenueCatService.instance.isPremium();
//   final offerings = await RevenueCatService.instance.getOfferings();
//   await RevenueCatService.instance.purchase(package);

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/config/app_config.dart';

class RevenueCatService {
  // Singleton
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  // RevenueCat entitlement adı (dashboard'da tek entitlement: "premium")
  static const String entitlementId = 'premium';

  // Stream controllers — CustomerInfo değişikliklerini broadcast eder
  final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  /// CustomerInfo değişim stream'i. Provider'lar bunu dinler.
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Compile-time API key from AppConfig.
  /// iOS → RC_APPLE_KEY, Android → RC_GOOGLE_KEY (injected via
  /// --dart-define-from-file=.env.<env> at build time).
  String get _apiKey {
    if (Platform.isIOS || Platform.isMacOS) {
      const k = AppConfig.revenueCatAppleKey;
      if (k.isEmpty) {
        throw StateError(
          'RC_APPLE_KEY not set. Rebuild with '
          '--dart-define-from-file=.env.production '
          '(see nuveli_credentials_guide.md §5.1)',
        );
      }
      return k;
    } else if (Platform.isAndroid) {
      const k = AppConfig.revenueCatGoogleKey;
      if (k.isEmpty) {
        throw StateError(
          'RC_GOOGLE_KEY not set. Rebuild with '
          '--dart-define-from-file=.env.production '
          '(see nuveli_credentials_guide.md §5.2)',
        );
      }
      return k;
    } else {
      throw UnsupportedError(
        'RevenueCat is only supported on iOS and Android.',
      );
    }
  }

  /// Login sonrası çağrılır. Idempotent.
  /// [userId] Supabase user_id (uuid string).
  Future<void> init({required String userId}) async {
    if (_initialized) {
      // Zaten init'liyse sadece user değiştir (login sonrası gerekirse)
      await _logInWithSupabaseId(userId);
      return;
    }

    // Debug log seviyesi
    await Purchases.setLogLevel(
      kDebugMode ? LogLevel.debug : LogLevel.info,
    );

    final configuration = PurchasesConfiguration(_apiKey)
      ..appUserID = userId; // RC user_id = Supabase user_id (eşle)

    await Purchases.configure(configuration);

    // CustomerInfo listener — premium durum değişince state güncellenir
    Purchases.addCustomerInfoUpdateListener((info) {
      if (!_customerInfoController.isClosed) {
        _customerInfoController.add(info);
      }
    });

    _initialized = true;
    debugPrint('[RC] Initialized with appUserID=$userId');
  }

  /// Login akışında user değiştiğinde (örn: logout + login).
  Future<void> _logInWithSupabaseId(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      debugPrint(
        '[RC] logIn → created=${result.created} '
        'userId=${result.customerInfo.originalAppUserId}',
      );
    } on PlatformException catch (e) {
      debugPrint('[RC] logIn failed: ${e.message}');
    }
  }

  /// Logout sırasında çağrılır.
  /// RC anonymous user'a düşer; sonraki login'de yeniden eşleşir.
  Future<void> logOut() async {
    if (!_initialized) return;
    try {
      await Purchases.logOut();
      debugPrint('[RC] logOut OK');
    } on PlatformException catch (e) {
      // Zaten anonymous ise hata atmaz; ignore
      debugPrint('[RC] logOut: ${e.message}');
    }
  }

  // ────────────────────────────────────────────────────────
  // Premium durumu
  // ────────────────────────────────────────────────────────

  /// Anlık premium kontrolü (cache'den okur, network call yapmaz).
  Future<bool> isPremium() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return _hasPremiumEntitlement(info);
    } catch (e) {
      debugPrint('[RC] isPremium error: $e');
      return false; // Hata → free olarak davran
    }
  }

  /// Network'ten yeni CustomerInfo çek (cache'i invalid et).
  Future<CustomerInfo?> refreshCustomerInfo() async {
    try {
      await Purchases.invalidateCustomerInfoCache();
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('[RC] refresh failed: $e');
      return null;
    }
  }

  bool _hasPremiumEntitlement(CustomerInfo info) {
    return info.entitlements.active.containsKey(entitlementId);
  }

  /// Premium expiration tarihi (varsa).
  Future<DateTime?> premiumExpiresAt() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final ent = info.entitlements.active[entitlementId];
      if (ent?.expirationDate == null) return null;
      return DateTime.tryParse(ent!.expirationDate!);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────
  // Offerings (paketler)
  // ────────────────────────────────────────────────────────

  /// RC dashboard'da tanımlı "default" offering'i getir.
  Future<Offering?> getDefaultOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current; // dashboard'da "current" işaretli olan
    } on PlatformException catch (e) {
      debugPrint('[RC] getOfferings failed: ${e.message}');
      return null;
    }
  }

  /// Tüm offerings (gelişmiş kullanım için).
  Future<Offerings?> getAllOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[RC] getAllOfferings failed: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────────────
  // Purchase
  // ────────────────────────────────────────────────────────

  /// Satın alma akışı.
  /// Dönüş: true = premium oldu, false = user iptal etti / başarısız.
  /// Hata atarsa = network/store hatası (UI'da göster).
  Future<PurchaseOutcome> purchase(Package package) async {
    try {
      // RC 8.x: purchasePackage returns CustomerInfo directly (not wrapped).
      // (v9+ will introduce PurchaseResult — when upgrading, adapt back.)
      final customerInfo = await Purchases.purchasePackage(package);
      final granted = _hasPremiumEntitlement(customerInfo);

      debugPrint(
        '[RC] purchase OK → granted=$granted '
        'productId=${package.storeProduct.identifier}',
      );

      return granted
          ? PurchaseOutcome.success(customerInfo)
          : const PurchaseOutcome.failed('Entitlement not granted');
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);

      if (code == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[RC] purchase cancelled by user');
        return const PurchaseOutcome.cancelled();
      }

      debugPrint('[RC] purchase error: ${e.message} (code=$code)');
      return PurchaseOutcome.failed(
        _humanReadableError(code, e.message ?? 'Unknown error'),
      );
    }
  }

  /// Restore purchases (yeni cihaz / reinstall).
  /// App Store kuralı: paywall'da "Restore" butonu zorunlu.
  Future<PurchaseOutcome> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      final granted = _hasPremiumEntitlement(info);
      debugPrint('[RC] restore → granted=$granted');
      return granted
          ? PurchaseOutcome.success(info)
          : const PurchaseOutcome.failed('No active purchases to restore');
    } on PlatformException catch (e) {
      debugPrint('[RC] restore failed: ${e.message}');
      return PurchaseOutcome.failed(e.message ?? 'Restore failed');
    }
  }

  // ────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────

  String _humanReadableError(PurchasesErrorCode code, String fallback) {
    switch (code) {
      case PurchasesErrorCode.networkError:
        return 'Network error. Please check your connection.';
      case PurchasesErrorCode.storeProblemError:
        return 'App Store / Play Store is having issues. Try again later.';
      case PurchasesErrorCode.paymentPendingError:
        return 'Payment is pending approval.';
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return 'You already own this product. Try Restore Purchases.';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'This receipt is linked to another account.';
      case PurchasesErrorCode.ineligibleError:
        return 'You\'re not eligible for this offer.';
      case PurchasesErrorCode.insufficientPermissionsError:
        return 'Permissions issue. Please check your store account.';
      case PurchasesErrorCode.invalidCredentialsError:
        return 'Invalid credentials. Please re-login to your store account.';
      default:
        return fallback;
    }
  }

  // Test/cleanup için
  Future<void> dispose() async {
    if (!_customerInfoController.isClosed) {
      await _customerInfoController.close();
    }
  }
}

// ────────────────────────────────────────────────────────────
// Result type for purchase / restore
// ────────────────────────────────────────────────────────────

sealed class PurchaseOutcome {
  const PurchaseOutcome();

  const factory PurchaseOutcome.success(CustomerInfo info) = PurchaseSuccess;
  const factory PurchaseOutcome.cancelled() = PurchaseCancelled;
  const factory PurchaseOutcome.failed(String message) = PurchaseFailed;

  bool get isSuccess => this is PurchaseSuccess;
  bool get isCancelled => this is PurchaseCancelled;
  bool get isFailed => this is PurchaseFailed;

  String? get errorMessage =>
      switch (this) { PurchaseFailed(:final message) => message, _ => null };
}

final class PurchaseSuccess extends PurchaseOutcome {
  final CustomerInfo info;
  const PurchaseSuccess(this.info);
}

final class PurchaseCancelled extends PurchaseOutcome {
  const PurchaseCancelled();
}

final class PurchaseFailed extends PurchaseOutcome {
  final String message;
  const PurchaseFailed(this.message);
}
