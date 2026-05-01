// app/lib/features/premium/utils/trial_gift_trigger.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/features/premium/data/premium_service.dart';
import 'package:nuveli/features/premium/screens/trial_gift_modal.dart';

class TrialGiftTrigger {
  static bool _shownThisSession = false;

  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref, {
    String? userFirstName,
    int? mealsLoggedYesterday,
  }) async {
    if (_shownThisSession) return;

    final svc = ref.read(premiumServiceProvider);

    if (svc.currentStatus.isPremium) return;

    final eligible = await svc.isDay2GiftEligible();
    if (!eligible) return;

    if (mealsLoggedYesterday != null && mealsLoggedYesterday < 1) return;

    if (!context.mounted) return;
    _shownThisSession = true;

    final hook = _buildPersonalizedHook(
      firstName: userFirstName,
      mealsLogged: mealsLoggedYesterday ?? 0,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) return;

    await TrialGiftModal.show(context, personalizedHook: hook);
  }

  static String _buildPersonalizedHook({
    String? firstName,
    int mealsLogged = 0,
  }) {
    final name = firstName?.trim();

    if (name != null && name.isNotEmpty) {
      if (mealsLogged == 1) {
        return '$name, dun ilk ogununu kaydettin. Iyi bir baslangic.';
      } else if (mealsLogged > 1) {
        return '$name, dun $mealsLogged ogun kaydettin. Devam ediyoruz.';
      }
      return '$name, ilk gunden iyiydi.';
    }

    if (mealsLogged == 1) {
      return 'Dun ilk ogununu kaydettin. Iyi bir baslangic.';
    } else if (mealsLogged > 1) {
      return 'Dun $mealsLogged ogun kaydettin. Devam ediyoruz.';
    }
    return 'Ilk gunden iyiydi.';
  }

  static void resetForTesting() {
    _shownThisSession = false;
  }
}
