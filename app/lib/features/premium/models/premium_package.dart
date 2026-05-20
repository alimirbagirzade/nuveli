// lib/features/premium/models/premium_package.dart
//
// RevenueCat `Package` → UI'a hazır PremiumPackage.
// Fiyat formatlama, savings yüzdesi, badge bilgisi burada hesaplanır.

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

/// Paket tipi — UI'da kart sıralaması ve "Most Popular" gibi badge'ler için.
enum PremiumPackageType {
  monthly,
  annual,
  lifetime,
  unknown,
}

@immutable
class PremiumPackage {
  /// RC Package referansı — purchase çağrısında bu gerekir.
  final rc.Package raw;

  /// Tip (UI mantığı için).
  final PremiumPackageType type;

  /// Localized fiyat string'i (örn: "$9.99", "₺319.99").
  final String priceString;

  /// Sayısal fiyat (USD/EUR/TRY — currencyCode ile birlikte).
  final double price;

  /// ISO currency code (örn: "USD", "TRY").
  final String currencyCode;

  /// İnsan-okunabilir başlık (örn: "Monthly", "Annual", "Lifetime").
  final String title;

  /// Açıklama (örn: "Billed monthly", "Billed yearly").
  final String description;

  /// Annual paket için aylık eşdeğer string'i (Apple kuralı).
  /// Örn: "$4.99/month, billed annually" → "4.99"
  final String? monthlyEquivalentString;

  /// Yıllık vs aylık karşılaştırmadan hesaplanan tasarruf % (annual için).
  /// Örn: 50 → "%50 off" badge'i.
  final int? savingsPercent;

  /// Free trial gün sayısı (varsa).
  final int? freeTrialDays;

  const PremiumPackage({
    required this.raw,
    required this.type,
    required this.priceString,
    required this.price,
    required this.currencyCode,
    required this.title,
    required this.description,
    this.monthlyEquivalentString,
    this.savingsPercent,
    this.freeTrialDays,
  });

  factory PremiumPackage.fromRevenueCat(rc.Package package) {
    final product = package.storeProduct;
    final type = _detectType(package);

    return PremiumPackage(
      raw: package,
      type: type,
      priceString: product.priceString,
      price: product.price,
      currencyCode: product.currencyCode,
      title: _titleFor(type),
      description: _descriptionFor(type),
      monthlyEquivalentString:
          type == PremiumPackageType.annual ? _monthlyEquivalent(product) : null,
      savingsPercent: null, // Offering seviyesinde set edilir (annual vs monthly)
      freeTrialDays: _detectFreeTrialDays(product),
    );
  }

  /// Annual paketin aylık eşdeğer fiyat string'i.
  /// Örn: $59.99/yıl → "$5.00/mo"
  static String? _monthlyEquivalent(rc.StoreProduct product) {
    if (product.price <= 0) return null;
    final perMonth = product.price / 12;
    // Price string'in başındaki currency symbol'u koruyalım
    final symbol = product.priceString.replaceAll(RegExp(r'[\d.,\s]'), '');
    final formatted = perMonth.toStringAsFixed(2);
    return '$symbol$formatted/mo';
  }

  /// Package identifier'dan veya storeProduct.subscriptionPeriod'dan
  /// paket tipini çıkar.
  static PremiumPackageType _detectType(rc.Package package) {
    final id = package.identifier.toLowerCase();
    final productId = package.storeProduct.identifier.toLowerCase();

    // RC default identifier'ları
    if (id.contains('monthly') || id == r'$rc_monthly') {
      return PremiumPackageType.monthly;
    }
    if (id.contains('annual') ||
        id.contains('yearly') ||
        id == r'$rc_annual') {
      return PremiumPackageType.annual;
    }
    if (id.contains('lifetime') || id == r'$rc_lifetime') {
      return PremiumPackageType.lifetime;
    }

    // Fallback: product ID'den ipucu
    if (productId.contains('monthly')) return PremiumPackageType.monthly;
    if (productId.contains('annual') || productId.contains('yearly')) {
      return PremiumPackageType.annual;
    }
    if (productId.contains('lifetime')) return PremiumPackageType.lifetime;

    return PremiumPackageType.unknown;
  }

  static String _titleFor(PremiumPackageType type) {
    return switch (type) {
      PremiumPackageType.monthly => 'Monthly',
      PremiumPackageType.annual => 'Annual',
      PremiumPackageType.lifetime => 'Lifetime',
      PremiumPackageType.unknown => 'Premium',
    };
  }

  static String _descriptionFor(PremiumPackageType type) {
    return switch (type) {
      PremiumPackageType.monthly => 'Billed monthly',
      PremiumPackageType.annual => 'Billed once a year',
      PremiumPackageType.lifetime => 'One-time payment',
      PremiumPackageType.unknown => '',
    };
  }

  /// StoreProduct.introductoryPrice → trial days
  static int? _detectFreeTrialDays(rc.StoreProduct product) {
    final intro = product.introductoryPrice;
    if (intro == null) return null;
    if (intro.price > 0) return null; // Discount yok, ücretsiz trial var mı?
    // RC 8.x: periodUnit is now a PeriodUnit enum (not a String).
    final cycles = intro.cycles;
    final periodNumber = intro.periodNumberOfUnits;
    final perCycle = switch (intro.periodUnit) {
      rc.PeriodUnit.day => periodNumber,
      rc.PeriodUnit.week => periodNumber * 7,
      rc.PeriodUnit.month => periodNumber * 30,
      rc.PeriodUnit.year => periodNumber * 365,
      _ => 0,
    };
    return perCycle * cycles;
  }

  /// Annual paket için tasarruf yüzdesi hesapla.
  /// Annual ve monthly her ikisi varsa kullanılabilir.
  PremiumPackage withSavingsPercent(int? percent) {
    return PremiumPackage(
      raw: raw,
      type: type,
      priceString: priceString,
      price: price,
      currencyCode: currencyCode,
      title: title,
      description: description,
      monthlyEquivalentString: monthlyEquivalentString,
      savingsPercent: percent,
      freeTrialDays: freeTrialDays,
    );
  }

  /// "Most Popular" badge gösterilsin mi (annual'da default)
  bool get isMostPopular => type == PremiumPackageType.annual;

  /// "Best Value" — lifetime'da göster
  bool get isBestValue => type == PremiumPackageType.lifetime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumPackage && raw.identifier == other.raw.identifier;

  @override
  int get hashCode => raw.identifier.hashCode;
}
