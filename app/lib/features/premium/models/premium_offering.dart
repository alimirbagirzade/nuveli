// lib/features/premium/models/premium_offering.dart
//
// RevenueCat'in `Offering` nesnesini wrap eden domain model.
// Provider'lar bu nesneyi expose eder; UI doğrudan SDK tiplerine bağımlı olmaz.

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

import 'premium_package.dart';

@immutable
class PremiumOffering {
  /// Offering identifier (RC dashboard'da tanımlı, örn: "default").
  final String identifier;

  /// İnsan-okunabilir başlık (RC dashboard'dan).
  final String? serverDescription;

  /// Bu offering'in içerdiği paketler.
  final List<PremiumPackage> packages;

  /// Default olarak seçili gelmesi gereken paket (varsa annual).
  /// Yoksa ilk paket.
  final PremiumPackage? defaultPackage;

  const PremiumOffering({
    required this.identifier,
    required this.packages,
    this.serverDescription,
    this.defaultPackage,
  });

  factory PremiumOffering.fromRevenueCat(rc.Offering offering) {
    final pkgs = offering.availablePackages
        .map(PremiumPackage.fromRevenueCat)
        .toList(growable: false);

    // Default seçim önceliği: annual > lifetime > monthly > ilk
    PremiumPackage? defaultPkg;
    for (final type in [
      PremiumPackageType.annual,
      PremiumPackageType.lifetime,
      PremiumPackageType.monthly,
    ]) {
      try {
        defaultPkg = pkgs.firstWhere((p) => p.type == type);
        break;
      } catch (_) {
        // Bu type yok, devam et
      }
    }
    defaultPkg ??= pkgs.isNotEmpty ? pkgs.first : null;

    return PremiumOffering(
      identifier: offering.identifier,
      serverDescription: offering.serverDescription,
      packages: pkgs,
      defaultPackage: defaultPkg,
    );
  }

  /// Boş offering (loading/error state için).
  static const empty = PremiumOffering(
    identifier: '_empty',
    packages: [],
  );

  bool get isEmpty => packages.isEmpty;
  bool get isNotEmpty => packages.isNotEmpty;

  /// Type'a göre paket bul.
  PremiumPackage? findByType(PremiumPackageType type) {
    try {
      return packages.firstWhere((p) => p.type == type);
    } catch (_) {
      return null;
    }
  }
}
