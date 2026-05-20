// =============================================================
// GATING SNIPPETS — Mevcut Feature Ekranlarına Eklenecek Kod
// =============================================================
//
// Bu dosya bir referans dosyasıdır — kendisi build edilmez.
// Aşağıdaki blokları ilgili feature dosyalarına kopyala.
//
// ORTAK IMPORTLAR (her dosyada gerekir):
//
//   import 'package:flutter_riverpod/flutter_riverpod.dart';
//   import 'package:go_router/go_router.dart';
//
//   import '../premium/providers/premium_provider.dart';
//   import '../premium/services/premium_gate_service.dart';
//   import '../premium/widgets/premium_upsell_dialog.dart';
//
// Tüm ekranlar `ConsumerStatefulWidget` veya `ConsumerWidget` olmalı (zaten Chat 16'da).
// =============================================================


// =============================================================
// 1) AI COACH SCREEN — 2. insight talep edilince paywall
// =============================================================
// Dosya: lib/features/ai_coach/ai_coach_screen.dart
//
// Önceki davranış: "Get new insight" butonu basıldığında direkt
// /coach/generate çağrısı yapılıyordu.
//
// Yeni: free user için günde sadece 1 insight, ikinciye paywall.
//
// ▼ Bu kodu "Get new insight" buton handler'ına yapıştır:

Future<void> handleGenerateInsight(WidgetRef ref, BuildContext context) async {
  final isPremium = ref.read(isPremiumProvider);
  final todayCount = ref.read(todayInsightCountProvider); // Chat 11'deki provider

  final canAccess = PremiumGateService.instance.canAccess(
    PremiumFeature.aiInsightSecond,
    isPremium: isPremium,
    currentUsage: todayCount,
  );

  if (!canAccess) {
    // Free user, günlük 1 hakkını kullandı → paywall göster
    final goPaywall = await PremiumUpsellDialog.show(
      context,
      source: 'ai_coach',
    );
    if (goPaywall == true && context.mounted) {
      context.push('/premium?source=ai_coach');
    }
    return;
  }

  // Premium veya henüz limiti aşmamış → insight üret
  await ref.read(coachRepositoryProvider).generateInsight();
}


// =============================================================
// 2) ANALYTICS SCREEN — 8 hafta sonrası premium
// =============================================================
// Dosya: lib/features/analytics/analytics_screen.dart
//
// Önceki davranış: Time range selector (1w / 4w / 12w / 6m / 1y / All)
//
// Yeni: 12w / 6m / 1y / All seçenekleri free user için gri/kilitli.
//       Tıklayınca paywall'a yönlendir.

Widget buildTimeRangeChip({
  required String label,
  required AnalyticsTimeRange range,
  required AnalyticsTimeRange selected,
  required WidgetRef ref,
  required BuildContext context,
}) {
  final isPremium = ref.watch(isPremiumProvider);

  // Free tier: maks 8 hafta. 4 haftanın üstündeki seçenekler kilitli.
  final weeksRequested = _rangeToWeeks(range);
  final isLocked = !isPremium && weeksRequested > 8;

  return GestureDetector(
    onTap: () async {
      if (isLocked) {
        final go = await PremiumUpsellDialog.show(
          context,
          source: 'analytics',
        );
        if (go == true && context.mounted) {
          context.push('/premium?source=analytics');
        }
        return;
      }
      // Free / premium izinli → range'i güncelle
      ref.read(analyticsRangeProvider.notifier).state = range;
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: range == selected
            ? const Color(0xFF00D4FF).withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: range == selected
              ? const Color(0xFF00D4FF)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLocked) ...[
            const Icon(
              Icons.lock_rounded,
              size: 12,
              color: Color(0xFF6E7B91),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isLocked
                  ? const Color(0xFF6E7B91)
                  : (range == selected
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFFB8C5D6)),
            ),
          ),
        ],
      ),
    ),
  );
}

int _rangeToWeeks(AnalyticsTimeRange r) {
  // Chat 7'deki enum'a göre adapte et
  return switch (r) {
    AnalyticsTimeRange.oneWeek => 1,
    AnalyticsTimeRange.fourWeeks => 4,
    AnalyticsTimeRange.eightWeeks => 8,
    AnalyticsTimeRange.twelveWeeks => 12,
    AnalyticsTimeRange.sixMonths => 26,
    AnalyticsTimeRange.oneYear => 52,
    AnalyticsTimeRange.allTime => 9999,
  };
}


// =============================================================
// 3) MEAL PLANNER — AI Generate butonu premium-only
// =============================================================
// Dosya: lib/features/meal_planner/meal_planner_screen.dart
//
// "Create Plan" butonunda iki seçenek var (manuel ekle, AI generate).
// AI generate sadece premium.
//
// ▼ "AI Generate" butonu handler:

Future<void> handleAiGeneratePlan(
    WidgetRef ref, BuildContext context) async {
  final isPremium = ref.read(isPremiumProvider);

  if (!isPremium) {
    final go = await PremiumUpsellDialog.show(
      context,
      source: 'meal_planner',
    );
    if (go == true && context.mounted) {
      context.push('/premium?source=meal_planner');
    }
    return;
  }

  // Premium → AI generate akışı
  await ref.read(mealPlannerRepositoryProvider).generateWeeklyPlan();
}

// AYRICA: Free user için meal planner 1 haftayla sınırlı.
// "Next week" arrow butonunda kontrol:

Future<void> handleNextWeek(WidgetRef ref, BuildContext context) async {
  final isPremium = ref.read(isPremiumProvider);
  final currentWeekOffset = ref.read(mealPlannerWeekOffsetProvider);

  final canAccess = PremiumGateService.instance.canAccess(
    PremiumFeature.mealPlannerBeyondOneWeek,
    isPremium: isPremium,
    currentUsage: currentWeekOffset, // 0 = bu hafta, 1 = sonraki, ...
  );

  if (!canAccess) {
    final go = await PremiumUpsellDialog.show(
      context,
      source: 'meal_planner',
    );
    if (go == true && context.mounted) {
      context.push('/premium?source=meal_planner');
    }
    return;
  }

  ref.read(mealPlannerWeekOffsetProvider.notifier).state++;
}


// =============================================================
// 4) HABITS SCREEN — 5+ habit için premium
// =============================================================
// Dosya: lib/features/habits/habits_screen.dart
//
// "Add custom habit" butonuna basılınca habit count check:

Future<void> handleAddCustomHabit(
    WidgetRef ref, BuildContext context) async {
  final isPremium = ref.read(isPremiumProvider);
  final habitCount =
      ref.read(habitsProvider).valueOrNull?.length ?? 0; // Chat 10

  final canAccess = PremiumGateService.instance.canAccess(
    PremiumFeature.habitCustomBeyond5,
    isPremium: isPremium,
    currentUsage: habitCount,
  );

  if (!canAccess) {
    final go = await PremiumUpsellDialog.show(
      context,
      source: 'habits',
    );
    if (go == true && context.mounted) {
      context.push('/premium?source=habits');
    }
    return;
  }

  // Ekle dialog'unu aç
  await _showAddHabitDialog(context, ref);
}


// =============================================================
// 5) MEAL SCAN — Günde 5'ten fazla scan için premium
// =============================================================
// Dosya: lib/features/meal_scan/meal_scan_screen.dart
//
// Fotoğraf çekildiğinde, /meals/scan endpoint'ine göndermeden ÖNCE kontrol:

Future<void> handleScanMeal(
    WidgetRef ref, BuildContext context, XFile imageFile) async {
  final isPremium = ref.read(isPremiumProvider);
  final todayScanCount = ref.read(todayScanCountProvider); // yeni provider

  final canAccess = PremiumGateService.instance.canAccess(
    PremiumFeature.mealScanBeyond5Daily,
    isPremium: isPremium,
    currentUsage: todayScanCount,
  );

  if (!canAccess) {
    final go = await PremiumUpsellDialog.show(
      context,
      source: 'meal_scan',
    );
    if (go == true && context.mounted) {
      context.push('/premium?source=meal_scan');
    }
    return;
  }

  // Scan akışına devam
  await ref.read(mealScanRepositoryProvider).analyzeImage(imageFile);
}

// ▼ Yeni provider — günlük scan sayacını backend'den çeker.
// lib/features/meal_scan/providers/scan_count_provider.dart
//
// final todayScanCountProvider = FutureProvider<int>((ref) async {
//   final api = ref.read(apiClientProvider);
//   final res = await api.get('/meals/scan-count-today');
//   return (res.data as Map)['count'] as int;
// });


// =============================================================
// HEADER "REMAINING SCANS" BANNER (opsiyonel, conversion için)
// =============================================================
// Free user'a kalan hakkını göstermek = conversion'ı %15-20 artırır.

Widget buildRemainingScansBanner({required WidgetRef ref}) {
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) return const SizedBox.shrink();

  final todayCount = ref.watch(todayScanCountProvider).valueOrNull ?? 0;
  final remaining = PremiumGateService.instance.remainingFree(
    PremiumFeature.mealScanBeyond5Daily,
    currentUsage: todayCount,
  );

  if (remaining == null) return const SizedBox.shrink();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: remaining == 0
          ? const Color(0xFFFF5C5C).withOpacity(0.12)
          : const Color(0xFF00D4FF).withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: remaining == 0
            ? const Color(0xFFFF5C5C).withOpacity(0.3)
            : const Color(0xFF00D4FF).withOpacity(0.2),
      ),
    ),
    child: Row(
      children: [
        Icon(
          remaining == 0
              ? Icons.lock_outline_rounded
              : Icons.info_outline_rounded,
          size: 16,
          color: remaining == 0
              ? const Color(0xFFFF5C5C)
              : const Color(0xFF4DDBFF),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            remaining == 0
                ? 'You\'ve used all 5 daily scans. Upgrade for unlimited.'
                : '$remaining of 5 free scans left today',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB8C5D6),
            ),
          ),
        ),
      ],
    ),
  );
}


// =============================================================
// NOTLAR — TÜM EKRANLARDA ORTAK
// =============================================================
//
// 1. `isPremiumProvider` sync ve cache'li — `ref.watch` kullanmaktan çekinme.
// 2. `currentUsage` sayıcılarını backend'den çekmek ÇOK önemli — local
//    sayım hatalı (uninstall/reinstall, cihaz değişikliği).
// 3. Bir feature gate'i değiştirmek istersen TEK YERDE değiştir:
//    PremiumGateService.limits map'i. Tüm UI otomatik adapte olur.
// 4. PremiumUpsellDialog.show(source: '...') → source aynı zamanda
//    backend analytics'e gider (Chat 19 sonrası: subscription_events).
// 5. Backend de aynı limit'leri kontrol etmeli (frontend bypass edilebilir).
//    Bunun için backend tarafında /coach/generate vs.'de require_premium
//    dependency'sini kullan (Chat 14'te tanımlandı, KISIM C'de aktif edildi).
// =============================================================
