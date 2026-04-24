import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/premium_service.dart';
import '../screens/trial_gift_modal.dart';

/// Trial gift modal'ı yaşam döngüsü yönetimi.
///
/// Modal şu koşullarda tek seferlik gösterilir:
/// - Kullanıcı şu anda `free` tier
/// - Bu cihazda henüz trial hediyesi gösterilmedi
///
/// Home screen post-frame'de [maybeShow] çağırır.
class TrialGiftTrigger {
  static const _prefsKey = 'trial_gift_shown_v1';

  /// Home ekranı ilk yüklendiğinde çağrılır.
  /// Uygun koşullar varsa modal'ı tek seferlik gösterir.
  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // 1. Premium durumuna bak
    final status = ref.read(premiumStatusProvider).valueOrNull;
    if (status == null || !status.isFree) return;

    // 2. Daha önce gösterildi mi?
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefsKey) == true) return;

    // 3. Göster + flag'i set et
    if (!context.mounted) return;
    await TrialGiftModal.show(context);
    await prefs.setBool(_prefsKey, true);
  }

  /// Flag'i sıfırla (test/debug için).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
