import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/data/settings_repository.dart';
import '../../features/settings/providers/settings_providers.dart';
import '../../features/streak/data/streak_repository.dart';
import 'local_notification_service.dart';

/// Streak veya tercih değişimine tepki vererek local notification
/// schedule'ını otomatik günceller.
///
/// Bu provider başka bir widget tarafından watch edildiği sürece aktif
/// kalır — ana ekranın `build()` metodunda watch edilmesi yeterli.
/// Hiçbir state üretmez (`void`); sadece side-effect olarak schedule
/// günceller. autoDispose **değil** çünkü tüm app lifecycle'ı boyunca
/// aktif kalmalı.
///
/// Tetiklenen senaryolar:
/// 1. streakProvider güncellenirse (öğün ekle/sil, app açılış)
/// 2. notificationPrefsProvider güncellenirse (kullanıcı tercih değiştirdi)
final notificationSyncProvider = Provider<void>((ref) {
  // Bu provider sadece desktop/iOS/Android'de anlamlı; web'de skip et.
  if (!Platform.isAndroid && !Platform.isIOS) return;

  // Streak değişimini dinle
  ref.listen<AsyncValue<StreakInfo>>(streakProvider, (previous, next) {
    next.whenData((streak) async {
      final prefs = await _readPrefsOrNull(ref);
      if (prefs == null) return;
      await LocalNotificationService.instance.scheduleStreakRisk(
        streak,
        prefs,
      );
    });
  });

  // Tercih değişimini dinle
  ref.listen<AsyncValue<NotificationPrefs>>(notificationPrefsProvider,
      (previous, next) {
    next.whenData((prefs) async {
      // Tercih değişti — meal reminders ve weekly summary'yi de yenile.
      // streak için ayrı schedule yapacak listener zaten var.
      await LocalNotificationService.instance.scheduleMealReminders(prefs);
      await LocalNotificationService.instance.scheduleWeeklySummary(prefs);
    });
  });
});

/// notificationPrefsProvider'ı best-effort oku — yüklenmemişse null.
Future<NotificationPrefs?> _readPrefsOrNull(Ref ref) async {
  try {
    final async = ref.read(notificationPrefsProvider);
    return async.valueOrNull ?? await ref.read(notificationPrefsProvider.future);
  } catch (_) {
    return null;
  }
}
