// lib/features/premium/providers/offerings_provider.dart
//
// RC'den mevcut offering'i çeker, PremiumOffering'e map'ler.
// Annual paketin "Save X%" yüzdesini monthly fiyat üzerinden hesaplar.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/premium_offering.dart';
import '../models/premium_package.dart';
import '../services/revenue_cat_service.dart';

final offeringsProvider = FutureProvider<PremiumOffering>((ref) async {
  final rcOffering = await RevenueCatService.instance.getDefaultOffering();
  if (rcOffering == null) {
    return PremiumOffering.empty;
  }

  final offering = PremiumOffering.fromRevenueCat(rcOffering);

  // Annual paketin savings % değerini monthly fiyatına göre hesapla
  final monthly = offering.findByType(PremiumPackageType.monthly);
  final annual = offering.findByType(PremiumPackageType.annual);

  if (monthly != null && annual != null && monthly.price > 0) {
    final yearlyAtMonthlyRate = monthly.price * 12;
    final savings = yearlyAtMonthlyRate - annual.price;
    final percent = ((savings / yearlyAtMonthlyRate) * 100).round();

    if (percent > 0) {
      // Annual paketi savings % ile değiştir
      final updatedPackages = offering.packages
          .map((p) =>
              p.type == PremiumPackageType.annual
                  ? p.withSavingsPercent(percent)
                  : p)
          .toList(growable: false);

      return PremiumOffering(
        identifier: offering.identifier,
        serverDescription: offering.serverDescription,
        packages: updatedPackages,
        defaultPackage: updatedPackages.firstWhere(
          (p) => p.type == PremiumPackageType.annual,
          orElse: () => offering.defaultPackage ?? updatedPackages.first,
        ),
      );
    }
  }

  return offering;
});
