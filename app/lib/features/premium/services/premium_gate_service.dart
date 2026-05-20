// lib/features/premium/services/premium_gate_service.dart
//
// Premium gating logic — hangi feature'ın free tier'da kaç hakkı var.
// Tek bir merkezi yerde tutuyoruz ki UI'da tutarlı kalsın.
//
// Kullanım örneği:
//   final gate = PremiumGateService();
//   if (!gate.canAccess(PremiumFeature.aiInsightSecond, isPremium: false,
//                       currentUsage: 1)) {
//     // Paywall göster
//   }

import 'package:flutter/foundation.dart';

/// Premium ile gating'lenen feature'lar.
enum PremiumFeature {
  /// Günde 1 AI insight free; sonrası premium.
  aiInsightSecond,

  /// Son 8 hafta'lık analytics free; sonrası premium.
  analyticsBeyond8Weeks,

  /// Meal Planner: 1 hafta free, sonrası premium.
  mealPlannerBeyondOneWeek,

  /// Meal Planner: AI generate butonu sadece premium.
  mealPlannerAiGenerate,

  /// Custom habit: 5 tane free, sonrası premium.
  habitCustomBeyond5,

  /// AI meal scan: günde 5 free, sonrası premium.
  mealScanBeyond5Daily,

  /// Recipe library: 50 public free, custom recipes premium.
  recipeCustom,

  /// Weight goal: 1 aktif free, multiple goals premium.
  weightGoalMultiple,

  /// Export data CSV/PDF — premium only.
  dataExport,

  /// Apple Health / Google Fit sync — premium only.
  healthIntegration,

  /// Premium themes (renkli skinler) — premium only.
  premiumThemes,
}

/// Her feature'ın free tier limit'i ve premium-only davranışı.
@immutable
class FreeTierLimit {
  /// Free tier'da izin verilen miktar. 0 = premium only.
  final int free;

  /// Premium'da izin verilen miktar. null = sınırsız.
  final int? premium;

  /// İnsan-okunabilir açıklama (paywall'da göstermek için).
  final String label;

  const FreeTierLimit({
    required this.free,
    required this.premium,
    required this.label,
  });

  bool get isPremiumOnly => free == 0;
  bool get isPremiumUnlimited => premium == null;
}

class PremiumGateService {
  // Singleton (state'siz, ama tutarlılık için)
  PremiumGateService._();
  static final PremiumGateService instance = PremiumGateService._();
  factory PremiumGateService() => instance;

  /// Feature'ların free tier konfigürasyonu.
  /// TEK KAYNAK — UI burası ile senkron olmalı.
  static const Map<PremiumFeature, FreeTierLimit> limits = {
    PremiumFeature.aiInsightSecond: FreeTierLimit(
      free: 1,
      premium: null,
      label: 'Daily AI Coach insights',
    ),
    PremiumFeature.analyticsBeyond8Weeks: FreeTierLimit(
      free: 8,
      premium: null,
      label: 'Analytics history (weeks)',
    ),
    PremiumFeature.mealPlannerBeyondOneWeek: FreeTierLimit(
      free: 1,
      premium: null,
      label: 'Meal planner range (weeks)',
    ),
    PremiumFeature.mealPlannerAiGenerate: FreeTierLimit(
      free: 0,
      premium: null,
      label: 'AI-generated meal plans',
    ),
    PremiumFeature.habitCustomBeyond5: FreeTierLimit(
      free: 5,
      premium: null,
      label: 'Custom habits',
    ),
    PremiumFeature.mealScanBeyond5Daily: FreeTierLimit(
      free: 5,
      premium: null,
      label: 'AI meal scans per day',
    ),
    PremiumFeature.recipeCustom: FreeTierLimit(
      free: 0,
      premium: null,
      label: 'Custom recipes',
    ),
    PremiumFeature.weightGoalMultiple: FreeTierLimit(
      free: 1,
      premium: null,
      label: 'Active weight goals',
    ),
    PremiumFeature.dataExport: FreeTierLimit(
      free: 0,
      premium: null,
      label: 'Export data (CSV / PDF)',
    ),
    PremiumFeature.healthIntegration: FreeTierLimit(
      free: 0,
      premium: null,
      label: 'Apple Health / Google Fit sync',
    ),
    PremiumFeature.premiumThemes: FreeTierLimit(
      free: 0,
      premium: null,
      label: 'Premium themes',
    ),
  };

  /// Kullanıcının bu feature'a şu an erişip erişemediği.
  ///
  /// [isPremium]: Mevcut premium durumu (premiumProvider'dan).
  /// [currentUsage]: Bu döngüde (gün/hafta) zaten kullanılmış sayı. null ise
  ///                 sayım önemli değil (premium-only feature'lar için).
  bool canAccess(
    PremiumFeature feature, {
    required bool isPremium,
    int currentUsage = 0,
  }) {
    if (isPremium) {
      // Premium'da pratik olarak sınırsız (premium == null ise)
      final premiumCap = limits[feature]?.premium;
      if (premiumCap == null) return true;
      return currentUsage < premiumCap;
    }

    final limit = limits[feature];
    if (limit == null) {
      // Tanımsız feature: güvenli taraf → engelle
      return false;
    }

    if (limit.isPremiumOnly) return false;
    return currentUsage < limit.free;
  }

  /// Free user için kalan hak. Premium ise null döner.
  int? remainingFree(PremiumFeature feature, {required int currentUsage}) {
    final limit = limits[feature];
    if (limit == null || limit.isPremiumOnly) return 0;
    final remaining = limit.free - currentUsage;
    return remaining < 0 ? 0 : remaining;
  }

  /// Free tier limit metni (UI'da göstermek için).
  /// Örn: "1/day" veya "Premium only" veya "5 max"
  String freeTierLabel(PremiumFeature feature) {
    final limit = limits[feature];
    if (limit == null) return '—';
    if (limit.isPremiumOnly) return 'Premium only';
    return _formatLimitForFeature(feature, limit.free);
  }

  String _formatLimitForFeature(PremiumFeature feature, int n) {
    switch (feature) {
      case PremiumFeature.aiInsightSecond:
        return '$n / day';
      case PremiumFeature.mealScanBeyond5Daily:
        return '$n / day';
      case PremiumFeature.analyticsBeyond8Weeks:
        return 'Last $n weeks';
      case PremiumFeature.mealPlannerBeyondOneWeek:
        return '$n week${n == 1 ? '' : 's'}';
      case PremiumFeature.habitCustomBeyond5:
        return '$n max';
      case PremiumFeature.weightGoalMultiple:
        return '$n active';
      default:
        return n.toString();
    }
  }

  /// Premium'da bu feature için human-readable benefit.
  /// Paywall'da listede gösterilir. Örn: "Unlimited AI insights"
  String premiumBenefitLabel(PremiumFeature feature) {
    final limit = limits[feature];
    if (limit == null) return '';
    final name = limit.label;
    if (limit.isPremiumUnlimited) return 'Unlimited $name';
    return '${limit.premium} $name';
  }
}
