// lib/features/premium/providers/premium_provider.dart
//
// Premium state'i için ana provider.
// RC'nin customerInfoStream'ini dinler → real-time sync.
//
// Kullanım:
//   final isPremium = ref.watch(premiumProvider).valueOrNull ?? false;
//   await ref.read(premiumProvider.notifier).refresh();

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenue_cat_service.dart';

class PremiumNotifier extends AsyncNotifier<bool> {
  StreamSubscription<CustomerInfo>? _subscription;

  @override
  Future<bool> build() async {
    final service = RevenueCatService.instance;

    // Stream'i dinle — RC tarafından gelen her CustomerInfo update'inde
    // state'i yeniden hesapla.
    _subscription = service.customerInfoStream.listen((info) {
      final isPremium =
          info.entitlements.active.containsKey(RevenueCatService.entitlementId);
      state = AsyncValue.data(isPremium);
    });

    // Dispose'da subscription'ı temizle
    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    // İlk değer
    return await service.isPremium();
  }

  /// Network'ten taze CustomerInfo çek.
  /// Webhook gecikmesi varsa veya başka cihazda subscribe olduysa kullan.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final info = await RevenueCatService.instance.refreshCustomerInfo();
      final isPremium = info != null &&
          info.entitlements.active
              .containsKey(RevenueCatService.entitlementId);
      state = AsyncValue.data(isPremium);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Premium expire tarihini getir (UI'da göstermek için).
  Future<DateTime?> expiresAt() {
    return RevenueCatService.instance.premiumExpiresAt();
  }
}

/// Boolean isPremium state.
/// `ref.watch(premiumProvider)` → AsyncValue<bool>
final premiumProvider = AsyncNotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

/// Sync convenience — UI'da tek satır check için.
/// `ref.watch(isPremiumProvider)` → bool (false default'lu)
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).valueOrNull ?? false;
});
