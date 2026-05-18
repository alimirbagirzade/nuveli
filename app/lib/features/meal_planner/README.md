# Chat 9 — Meal Planner Screen (Görsel 6)

Üretim tarihi: 17 Mayıs 2026
Hedef ekran: **Plan Meals Ahead**

## 📁 Dosya Yapısı

```
lib/features/meal_planner/
├── meal_planner_screen.dart           Ana ekran
├── README.md                          (bu dosya)
├── models/
│   ├── meal_plan.dart                 MealType, MealPlan, MealPlannerData
│   ├── recipe.dart                    Recipe
│   └── grocery_item.dart              GroceryItem
├── data/
│   └── mock_meal_planner_data.dart    Görsel 6 ile %100 uyumlu mock
├── providers/
│   └── meal_planner_provider.dart     FutureProvider.autoDispose.family
└── widgets/
    ├── meal_planner_header.dart       Logo + "Meal Planner" + ⚙️
    ├── today_week_toggle.dart         Pill segmented (PlannerView enum dahil)
    ├── weekly_calendar.dart           7-gün strip, cyan circle seçim
    ├── meal_plan_card.dart            Tek öğün satırı
    ├── daily_total_card.dart          1,680 kcal + 80% mini donut
    ├── grocery_summary_card.dart      12 items + 4 thumbnail
    └── create_plan_button.dart        Cyan CTA
```

## ✅ Mockup Uyum Kontrolü

| Alan | Beklenen | Gerçek |
|---|---|---|
| Seçili gün | Mon 20 cyan | ✅ |
| Hafta kalorileri | 1680/1850/1720/1640/1780/1690/1610 | ✅ |
| Breakfast | 420 kcal — Greek Yogurt Bowl | ✅ |
| Lunch | 520 kcal — Chicken Wrap | ✅ |
| Dinner | 610 kcal — Salmon & Rice | ✅ |
| Snack | 130 kcal — Fruit Snack | ✅ |
| Toplam | 420+520+610+130 = 1,680 | ✅ |
| Hedef | 2,100 kcal | ✅ |
| Yüzde | 80% (1680/2100) | ✅ |
| Grocery | Oats / Chicken / Spinach / Yogurt, 12 items | ✅ |

## 🔌 Bağımlılıklar

`pubspec.yaml`'da olması gerekenler:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  intl: ^0.19.0
```

Diğer her şey Flutter SDK (Material) — ekstra paket gerekmez. `fl_chart`
**kullanmadık** çünkü mini donut için `CustomPainter` daha hafif geldi.

## ⚙️ Test/Çalıştırma

`app/main.dart` veya routing dosyasında geçici test için:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/meal_planner/meal_planner_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MealPlannerScreen(),
    );
  }
}
```

## 🔧 Chat 1-3 Widget'larıyla Refactor Notu

Bu kod, Chat 1-3 widget'ları (`NuveliCard`, `NuveliButton`, `NuveliBackground`,
`NuveliBottomNav`) tam API'si bilinmediği için **inline stillerle** yazıldı.
Tüm renkler / spacing / radius değerleri master plan'daki design system'le birebir.

Entegrasyon sırasında basit aramaları:

| Inline pattern | Önerilen Chat 1-3 widget |
|---|---|
| `Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(20), border: ...))` | `NuveliCard(...)` |
| `DecoratedBox(decoration: BoxDecoration(gradient: ...))` (CreatePlanButton) | `NuveliButton.primary(...)` |
| Ekranın en dış `DecoratedBox(gradient: ...)` | `NuveliBackground(...)` |
| `_MealsBottomNav` (screen dosyasında) | `NuveliBottomNav(currentIndex: 1, onTap: ...)` |

`MealPlanCard` özelliği prep doc'a göre `MealListTile`'a uymadığı için
**yeni widget** olarak yazıldı (doğru karar — pattern farklı: thumbnail + recipe name + chevron).

## 🚦 State Behavior

- `_view` (PlannerView.today / .week) — toggle ile değişir, animated (220ms).
- `_selectedDate` — calendar'da gün tıklanınca `setState` ile günceller.
- `mealPlannerProvider(_selectedDate)` — `family` parametresi sayesinde
  her gün değişiminde yeniden fetch (şu an mock hep aynı dönüyor).
- `autoDispose` — kullanıcı ekrandan çıkınca state cleanup.

## 🚀 Sonraki Adımlar

1. **Test:** `flutter run` ile mockup'la karşılaştır
2. **Refactor (opsiyonel, şimdi gerekmez):** Yukarıdaki tabloyu uygulayarak Chat 1-3 widget'larına geç
3. **Git:**
   ```bash
   cd ~/Development/nuveli
   git checkout -b feature/chat-9-meal-planner
   # dosyaları yerleştir
   git add lib/features/meal_planner/
   git commit -m "feat(chat-9): meal planner screen with mock data"
   git push -u origin feature/chat-9-meal-planner
   ```
4. **Master plan güncelleme:** Chat 9'un yanına ✅ koy, üretilen dosya listesini ekle
5. **Sonraki chat:** Chat 10 (Healthy Habits — Görsel 7)

## ⚠️ Bilinen Sınırlamalar

- Recipe thumbnail'leri şu an placeholder (`Icons.restaurant`) — gerçek görseller
  Chat 13/14'te Supabase Storage'dan gelecek.
- "Today" segmenti seçilse de görünüm aynı (mock hep tüm günü gösteriyor) —
  Chat 14 backend'inde "today" filtresi eklenince fark olacak.
- Settings cog henüz hiçbir şey yapmıyor — Chat 12 (routing) bekliyor.
