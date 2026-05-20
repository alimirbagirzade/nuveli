// lib/features/premium/providers/purchase_provider.dart
//
// Satın alma akışı için state machine.
// Paywall UI bunu dinler: idle, loading, success, cancelled, failed.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/premium_package.dart';
import '../services/revenue_cat_service.dart';
import 'premium_provider.dart';

@immutable
sealed class PurchaseState {
  const PurchaseState();
}

class PurchaseIdle extends PurchaseState {
  const PurchaseIdle();
}

/// Loading — `package` null ise restore akışı, doluysa purchase akışı.
class PurchaseLoading extends PurchaseState {
  final PremiumPackage? package;
  const PurchaseLoading({this.package});

  bool get isRestore => package == null;
}

class PurchaseSuccessful extends PurchaseState {
  /// Restore mu purchase mı (UI farklı mesaj göstersin diye).
  final bool wasRestore;
  const PurchaseSuccessful({this.wasRestore = false});
}

class PurchaseUserCancelled extends PurchaseState {
  const PurchaseUserCancelled();
}

class PurchaseErrored extends PurchaseState {
  final String message;
  const PurchaseErrored(this.message);
}

// ────────────────────────────────────────────────────────────

class PurchaseNotifier extends Notifier<PurchaseState> {
  @override
  PurchaseState build() => const PurchaseIdle();

  /// Bir paketi satın al. State otomatik güncellenir.
  Future<bool> purchase(PremiumPackage package) async {
    state = PurchaseLoading(package: package);

    final outcome = await RevenueCatService.instance.purchase(package.raw);

    if (outcome.isSuccess) {
      state = const PurchaseSuccessful();
      // premiumProvider stream'i zaten yakalayacak ama gecikme olabilir
      await ref.read(premiumProvider.notifier).refresh();
      return true;
    } else if (outcome.isCancelled) {
      state = const PurchaseUserCancelled();
      return false;
    } else {
      state = PurchaseErrored(outcome.errorMessage ?? 'Purchase failed');
      return false;
    }
  }

  /// Restore akışı (App Store kuralı: paywall'da Restore butonu zorunlu).
  Future<bool> restore() async {
    state = const PurchaseLoading(); // package null → restore

    final outcome = await RevenueCatService.instance.restore();

    if (outcome.isSuccess) {
      state = const PurchaseSuccessful(wasRestore: true);
      await ref.read(premiumProvider.notifier).refresh();
      return true;
    } else {
      state = PurchaseErrored(
        outcome.errorMessage ?? 'No active purchases to restore',
      );
      return false;
    }
  }

  void reset() {
    state = const PurchaseIdle();
  }
}

final purchaseProvider =
    NotifierProvider<PurchaseNotifier, PurchaseState>(PurchaseNotifier.new);
