# Chat 11a — AI Coach Insights (Flutter UI)

**Hedef:** Görsel 8'in birebir UI'ı, mock data ile çalışır halde.
**Backend (Chat 11b):** Henüz yok. Provider `kCoachMockMode = true` ile mock data kullanıyor.

---

## 📁 Üretilen Dosyalar (13 adet)

```
lib/features/ai_coach/
├── ai_coach_screen.dart                          (ana screen)
├── models/
│   ├── ai_insight.dart                           (AIInsight + InsightTone)
│   ├── nutrition_score.dart                      (NutritionScore + ScoreBreakdown + TodaysMacros)
│   └── coach_recommendation.dart                 (CoachRecommendation + DailyRecap + AICoachData)
├── data/
│   └── mock_coach_data.dart                      (Görsel 8 ile 1:1 mock)
├── providers/
│   └── ai_coach_provider.dart                    (AsyncNotifier + applyTip + refresh)
└── widgets/
    ├── coach_header.dart                         (← AI Coach ⚙️)
    ├── nutrition_score_ring.dart                 (animasyonlu halka, CustomPaint)
    ├── todays_insight_card.dart                  (sol cyan accent + lightbulb)
    ├── insights_grid.dart                        (2x2 küçük kartlar)
    ├── todays_summary_mini.dart                  (4 makro mini)
    ├── recommended_for_you_card.dart             (Apply Tip + See Details)
    └── daily_recap_card.dart                     (kompakt durum)
```

---

## 🔗 Chat 1-3'ten Beklenen Import'lar

Bu chat **hiçbir Chat 1-3 dosyasını yeniden yaratmadı**. Dosyalar derlenirken aşağıdaki sembollerin var olduğunu varsayar:

### `package:nuveli/core/theme/`
```dart
// app_colors.dart → class AppColors
AppColors.primaryCyan          // #00D4FF
AppColors.cyanGlow             // #4DDBFF
AppColors.textPrimary          // #FFFFFF
AppColors.textSecondary        // #B8C5D6
AppColors.cardBackground       // rgba(20,35,70,0.6)
AppColors.protein              // #3DDC97 veya #4ECDC4
AppColors.success              // #3DDC97
AppColors.warning              // #FFC857

// app_typography.dart → class AppTypography
AppTypography.heroNumber       // 36-48px bold (kullanım: NutritionScoreRing sayı)
AppTypography.cardTitle        // 18-20px semibold
AppTypography.bodyMedium       // 14-16px regular
AppTypography.caption          // 12px regular

// app_spacing.dart → class AppSpacing
AppSpacing.sm                  // 8
AppSpacing.md                  // 16

// app_radius.dart → class AppRadius
AppRadius.card                 // 16-20
AppRadius.md                   // 12
AppRadius.button               // 28
```

### `package:nuveli/shared/widgets/`
```dart
NuveliBackground               // underwater gradient wrapper
NuveliCard                     // glass card (padding param)
NuveliButton.primary(label, onPressed)    // cyan filled
NuveliButton.secondary(label, onPressed)  // outline
NuveliBottomNav(currentIndex, onTap)      // bottom nav
```

> ⚠️ **Eğer Chat 1-3'teki naming farklıysa** (örn. `AppColors.primary` vs `AppColors.primaryCyan`), find/replace ile 30 saniyede uyumlanır. En çok import edilen dosya `app_colors.dart` — orayı kontrol et.

---

## 📦 Pubspec Bağımlılığı

Bu chat **tek yeni paket** istiyor — Riverpod (Chat 1-3'te zaten varsa ekstra bir şey yok):

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
```

---

## 🚀 Hızlı Test

`main.dart`'a şu route'u geçici ekleyerek görebilirsin:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuveli/features/ai_coach/ai_coach_screen.dart';

void main() {
  runApp(const ProviderScope(child: TestApp()));
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AICoachScreen(),
    );
  }
}
```

Açtığında:
1. ~350ms skeleton görünür.
2. NutritionScoreRing 0 → 86 animasyonu (1.2s easeOutCubic) ile dolar.
3. Aşağıda 4 küçük insight, makro özet, "Try adding avocado..." önerisi var.
4. **Apply Tip** butonu → 250ms fade ile "Applied ✓" pill'e dönüşür.
5. Pull-to-refresh → skeleton tekrar 350ms.

---

## 🎨 Görsel 8 Uyum Kontrol Listesi

| Bölüm | Mock değer | Görsel 8 uyumu |
|---|---|---|
| Nutrition Score | 86 "Great" | ✅ |
| Today's Insight | "On track for weight loss goal…" | ✅ |
| 4 küçük öneri | Protein power / Hydration / Smart snack / Mindful eating | ✅ |
| Today's Summary | 1480 kcal / 95p / 160c / 48f | ✅ Dashboard ile tutarlı |
| Recommendation | "Try adding avocado…" | ✅ |
| Daily Recap | "You're on track. Keep going!" (onTrack) | ✅ |

---

## 🔌 Chat 11b Geçişi (ileride yapılacak)

`ai_coach_provider.dart`'taki tek değişiklik:

```dart
const bool kCoachMockMode = false;     // ← false yap

// build() içindeki TODO bloğunu aç:
final response = await ref.read(coachRepositoryProvider).getToday();
return response;
```

`applyTip()` da o zaman `POST /coach/apply-tip` çağıracak.

---

## ✅ Test Senaryoları (manuel)

1. **Animasyon:** Skor halkasının cyan dolgusu 0'dan başlayıp 86'ya kadar pürüzsüz büyümeli, içerideki sayı da senkron sayılmalı.
2. **Apply Tip idempotent:** Birden fazla tıklamak hata vermemeli (provider check ediyor).
3. **Refresh:** Aşağıya çek → skeleton → tekrar mock döner. Apply'lanmış state sıfırlanır (yeni gün davranışı).
4. **Skor → label mapping:** `mock_coach_data.dart`'ta `value: 60` yap → "Good"; `45` → "Fair"; `30` → "Needs work".
5. **InsightTone değişimi:** `mainInsight.tone`'u `warning` yap → sol accent stripe turuncu olur.

---

## 🐛 Olası Pitfall'lar

| Sorun | Çözüm |
|---|---|
| `AppColors.protein` yok | Chat 1'de eklemeyi unutmuşuz; `mock_coach_data.dart`'ta geçici olarak `AppColors.success` kullan |
| `AppTypography.heroNumber` yok | `NutritionScoreRing` içinde inline `TextStyle(fontSize: 48, fontWeight: FontWeight.w700)` kullanılabilir |
| `NuveliButton.secondary` yok | Chat 1'de sadece primary varsa → outline variant ekle veya bu chat'te inline `OutlinedButton` |
| Bottom nav 4 yerine 5 item | `currentIndex: 3` değişebilir; Chat 12'de zaten elden geçecek |

---

## 📝 Sonraki Adım

- [ ] `~/Development/nuveli/lib/features/ai_coach/` altına bu klasörü kopyala
- [ ] `flutter pub get` (Riverpod yoksa pubspec'e ekle)
- [ ] Yukarıdaki test snippet'i ile manuel görsel kontrol
- [ ] GitHub: `feature/chat-11a-ai-coach-ui` branch + commit
- [ ] Master plan: Chat 11a satırını ✅ işaretle
- [ ] **Sonraki chat: Chat 11b** (Backend GPT-4o + cron + Supabase) — hazırlık dosyasının açılış mesajını kullan
