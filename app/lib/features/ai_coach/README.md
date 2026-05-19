# Chat 11a — AI Coach Insights (Flutter UI) — v2

**Hedef:** Görsel 8'in birebir UI'ı, mock data ile çalışır halde.
**Backend (Chat 11b):** Henüz yok. Provider `kCoachMockMode = true` ile mock data kullanıyor.

---

## 🔄 v1 → v2 Değişiklikleri

İlk versiyonda olmayan `AppColors.primaryCyan`, `AppTypography.cardTitle`, `AppSpacing.md`, `AppRadius.card`, `NuveliCard`, `NuveliBackground`, `NuveliButton`, `NuveliBottomNav` gibi sembollere bağlanılmıştı — bunlar projende **yoktu**. v2 bu sembolleri tamamen kaldırıp, projenin **gerçek pattern'ine** (habits/streak_banner.dart, habits_screen.dart) sadık kalıyor:

| Sorun (v1) | Çözüm (v2) |
|---|---|
| `AppColors.primaryCyan` (yok) | Local `const _cyan = Color(0xFF00D4FF)` her widget'ta |
| `AppColors.cyanGlow` (yok) | Local `const _cyanGlow = Color(0xFF4DDBFF)` |
| `AppColors.protein/cardBackground` (yok) | Local `Color(0xFF3DDC97)` / inline glass effect |
| `AppTypography.X` (yok) | Inline `TextStyle()` veya istersen `AppTextStyles.headingMedium` |
| `AppSpacing.X` (yok) | Inline literal: `16`, `20`, `12` |
| `AppRadius.X` (yok) | Inline literal: `20`, `12` |
| `NuveliCard` (yok) | Inline `Container` + `BoxDecoration(white.withOpacity(0.04), border 0.08)` |
| `NuveliBackground` (yok) | Inline `DecoratedBox` + `[0xFF050A1F, 0xFF0B1A3D]` gradient |
| `NuveliButton.primary/secondary` (yok) | **`PrimaryButton` + `SecondaryButton`** (zaten var: `shared/widgets/primary_button.dart`) |
| `NuveliBottomNav` (yok) | Inline `_CoachBottomNav` (habits pattern) |

---

## 📁 Üretilen Dosyalar (13 adet .dart + README)

```
lib/features/ai_coach/
├── ai_coach_screen.dart                      (ana screen)
├── models/
│   ├── ai_insight.dart
│   ├── nutrition_score.dart
│   └── coach_recommendation.dart
├── data/
│   └── mock_coach_data.dart                  (Görsel 8 ile 1:1 mock)
├── providers/
│   └── ai_coach_provider.dart                (AsyncNotifier + applyTip + refresh)
└── widgets/
    ├── coach_header.dart                     (HabitsHeader birebir pattern)
    ├── nutrition_score_ring.dart             (animasyonlu halka, CustomPaint)
    ├── todays_insight_card.dart              (sol cyan accent + lightbulb)
    ├── insights_grid.dart                    (2x2 küçük kartlar)
    ├── todays_summary_mini.dart              (4 makro mini)
    ├── recommended_for_you_card.dart         (PrimaryButton + SecondaryButton)
    └── daily_recap_card.dart                 (kompakt durum)
```

---

## 🔗 Dış Bağımlılık (sadece 1 tane!)

```dart
// recommended_for_you_card.dart içinde:
import '../../../shared/widgets/primary_button.dart';
// → PrimaryButton (zaten var)
// → SecondaryButton (zaten var — aynı dosyada)
```

Diğer her şey self-contained: tüm renkler local const, tüm typography inline TextStyle, tüm spacing/radius literal sayı.

---

## 🚀 Test Adımları

### 1. Üstüne yaz (mevcut Chat 11a v1 dosyaları)

```bash
cd ~/Development/nuveli/app
unzip -o ~/Downloads/nuveli_chat11a_ai_coach_v2.zip
```

### 2. Analyze çalıştır

```bash
flutter analyze lib/features/ai_coach
```

**Beklenen:** `No issues found!` (veya en fazla birkaç `info` seviyesinde deprecated `withOpacity` uyarısı — bunlar habits ile aynı seviye, derlemeyi engellemiyor.)

### 3. Görsel test

`main.dart`'a geçici route:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuveli/features/ai_coach/ai_coach_screen.dart';
// veya 'package:<senin_package_adın>/features/ai_coach/ai_coach_screen.dart'

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

Sonra `flutter run -d "iPhone"`.

---

## 🎨 Görsel 8 Uyum Kontrol Listesi

| Bölüm | Mock değer | Görsel 8 uyumu |
|---|---|---|
| Nutrition Score | 86 "Great" | ✅ |
| Score animation | 0 → 86, 1.2s easeOutCubic, cyan glow | ✅ |
| Today's Insight | "On track for weight loss goal…" | ✅ |
| Sol accent stripe | 3px cyan + glow | ✅ |
| 4 küçük öneri | Protein power / Hydration / Smart snack / Mindful eating | ✅ |
| Today's Summary | 1480 kcal / 95p / 160c / 48f | ✅ |
| Recommendation | "Try adding avocado…" + image fallback | ✅ |
| Apply Tip → Applied ✓ | 250ms AnimatedSwitcher fade | ✅ |
| Daily Recap | "You're on track. Keep going!" | ✅ |
| Bottom nav | Profile sekmesi seçili (AI Coach → Profile'dan ulaşılır) | ✅ |

---

## 🔌 Chat 11b Geçişi (ileride)

`providers/ai_coach_provider.dart`:

```dart
const bool kCoachMockMode = false;     // ← false yap

// build() içindeki TODO bloğunu aç:
final response = await ref.read(coachRepositoryProvider).getToday();
return response;
```

`applyTip()` da o zaman `POST /coach/apply-tip` çağıracak.

---

## ✅ Manuel Test Senaryoları

1. **Skor animasyonu:** İlk açılışta halka cyan dolgusu 0→86 pürüzsüz büyür, içerideki sayı senkron sayılır.
2. **Apply Tip idempotent:** Birden fazla tıklamak hata vermez (provider check'liyor).
3. **Refresh:** Pull-to-refresh → 350ms skeleton → tekrar mock data. Apply'lanmış state sıfırlanır.
4. **Skor → label mapping:** `mock_coach_data.dart`'ta `value: 60` yap → "Good"; `45` → "Fair"; `30` → "Needs work".
5. **InsightTone değişimi:** `mainInsight.tone`'u `warning` yap → sol accent stripe sarı/turuncu olur.

---

## 📝 Sonraki Adım

- [x] Üstüne yaz: `unzip -o ~/Downloads/nuveli_chat11a_ai_coach_v2.zip`
- [x] `flutter analyze lib/features/ai_coach` → temiz olmalı
- [ ] `flutter run` ile simulator'de görsel kontrol
- [ ] Yeni commit: `git add app/lib/features/ai_coach/ && git commit -m "fix(chat-11a): align AI Coach UI with project DNA (PrimaryButton, glass cards, local color consts)"`
- [ ] Push: `git push origin feature/chat-11a-ai-coach-ui`
- [ ] **Sonraki chat: Chat 11b** (Backend GPT-4o + cron + Supabase)
