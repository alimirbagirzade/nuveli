// app/lib/features/premium/utils/trial_gift_trigger.dart
//
// Day 2 Trial Gift Trigger Logic
// PRD §6.4: ikinci pencere, "beni hatırlıyor" hissi.
//
// Trigger koşulları (her birinin AND olması gerekir):
// 1. Backend /premium/day2-gift-status -> eligible: true
// 2. Kullanıcı şu an home ekranında (modal akışı bozmamak)
// 3. Kullanıcı en az 1 öğün loglamış (yoksa "hatırlıyoruz" yalan olur)
// 4. Aynı session'da daha önce gösterilmedi
//
// Backend zaten "offered_at" mark eder, dolayısıyla aynı kullanıcıya
// ikinci kez gösterilmez. Bu utility sadece tetikleme mantığı.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/features/premium/data/premium_service.dart';
import 'package:nuveli/features/premium/screens/trial_gift_modal.dart';

class TrialGiftTrigger {
  // Aynı session'da iki kez göstermemek için flag
  static bool _shownThisSession = false;

  /// Home ekranı initState'inde çağır.
  /// Modal'ı uygunsa otomatik gösterir.
  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref, {
    String? userFirstName,
    int? mealsLoggedYesterday,
  }) async {
    if (_shownThisSession) return;

    final svc = ref.read(premiumServiceProvider);

    // Önce premium state — zaten premium ise gösterme
    if (svc.currentState.isPremium) return;

    // Backend'e sor
    final eligible = await svc.isDay2GiftEligible();
    if (!eligible) return;

    // Bağlam yokken gösterme — kullanıcı hiç log girmediyse
    // "ilerlemen güzel" mesajı yalan olur
    if (mealsLoggedYesterday == null || mealsLoggedYesterday < 1) return;

    if (!context.mounted) return;
    _shownThisSession = true;

    final hook = _buildPersonalizedHook(
      firstName: userFirstName,
      mealsLogged: mealsLoggedYesterday,
    );

    // Akışı bozmamak için kısa bir gecikme
    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) return;

    await TrialGiftModal.show(context, personalizedHook: hook);
  }

  static String _buildPersonalizedHook({
    String? firstName,
    int? mealsLogged,
  }) {
    final name = firstName?.trim();
    final meals = mealsLogged ?? 0;

    if (name != null && name.isNotEmpty) {
      if (meals == 1) {
        return '$name, dün ilk öğününü kaydettin. İyi bir başlangıç.';
      } else if (meals > 1) {
        return '$name, dün $meals öğün kaydettin. Devam ediyoruz.';
      }
      return '$name, ilk günden iyiydin.';
    }

    if (meals == 1) {
      return 'Dün ilk öğününü kaydettin. İyi bir başlangıç.';
    } else if (meals > 1) {
      return 'Dün $meals öğün kaydettin. Devam ediyoruz.';
    }
    return 'İlk günden iyiydin.';
  }

  /// Test/debug için reset
  static void resetForTesting() {
    _shownThisSession = false;
  }
}
