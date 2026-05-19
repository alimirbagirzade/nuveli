# Chat 4 — Dashboard Screen

**Tamamlandı:** 19 Mayıs 2026
**Hedef:** AuthGate placeholder'ını backend-bağlı gerçek Dashboard ile değiştirmek.

---

## 📂 Üretilen Dosyalar

### Yeni: Shared network layer
```
lib/core/network/
├── authed_dio_provider.dart   # JWT'li Dio singleton, tüm feature'lar paylaşır
└── api_exception.dart         # Dio hatalarını user-facing mesaja çevirir
```

### Yeni: Dashboard feature
```
lib/features/dashboard/
├── dashboard_screen.dart                    # Ana ekran (AsyncValue.when + RefreshIndicator)
├── models/
│   ├── today_summary.dart                   # /meals/today/summary response
│   └── meal.dart                            # /meals[] tek öğün
├── providers/
│   └── dashboard_provider.dart              # 3 provider: summary, meals, logWater
└── widgets/
    ├── dashboard_header.dart                # Tarih + greeting + avatar
    ├── todays_summary_section.dart          # Büyük kalori halkası (inline CustomPainter)
    ├── macros_row.dart                      # Protein/Carbs/Fat 3'lü
    ├── water_quick_card.dart                # +250ml hızlı log
    ├── meals_section.dart                   # Bugünün öğünleri + empty state
    └── add_food_button.dart                 # CTA (Chat 5 placeholder)
```

### Güncellenen
- `lib/features/auth/screens/auth_gate.dart` — `_DashboardPlaceholder` → `DashboardScreen` (bkz. `AUTH_GATE_PATCH.md`)

---

## 🔌 Backend Bağlantısı

| Endpoint | Provider | Açıklama |
|---|---|---|
| `GET /meals/today/summary` | `dashboardSummaryProvider` | Kalori + makro + su + meal count |
| `GET /meals?date=YYYY-MM-DD` | `todayMealsProvider` | Bugünün öğün listesi |
| `POST /water/logs` | `logWaterProvider` | +250ml log (sonra summary invalidate) |

**Auth:** `authedDioProvider` her isteğe otomatik `Authorization: Bearer <JWT>` ekler. JWT'yi `Supabase.instance.client.auth.currentSession.accessToken`'dan alır — Chat 15'in oluşturduğu session zaten geçerli.

---

## 🎨 Tasarım Kararları

1. **Inline CustomPainter halkası** — `CalorieRingChart` (Chat 2) API'sini bilmediğim için Dashboard kendi halkasını çiziyor. Chat 2'nin chart'ı gerçek API'siyle çalışıyorsa, `todays_summary_section.dart`'ta `_CalorieRing` → `CalorieRingChart` swap'ı kolay.
2. **Inline color/text values** — Chat 1'in `AppColors`/`AppTypography` alias'larına bağımlılığı en aza indirdik. Tüm renkler hex literal, tüm text style'lar inline. Tema migration'ı sonra (Chat 16/17 cleanup'ta) tek bir bulup-değiştir hareketiyle yapılır.
3. **Bottom nav placeholder** — `NuveliBottomNav` (Chat 3) yerine inline placeholder kullandık. Tap'lar SnackBar gösterir, Chat 17'de `go_router` ile gerçek navigation gelecek.
4. **Single summary call** — Eskiden 2 ayrı endpoint (summary + water) varsayıyordum. Backend `/meals/today/summary` zaten water dahil her şeyi dönüyor, tek call yetti. Su +250ml sonrası tüm dashboard tek invalidate ile güncellenir.

---

## 🧪 Test Akışı

```bash
cd ~/Development/nuveli/app
flutter pub get
flutter run
```

1. **Login** (mevcut hesap) veya yeni signup → onboarding → AuthGate
2. AuthGate → **Dashboard otomatik açılır**
3. İlk render: Skeleton loading (Render cold start ~30s ise dayan, timeout 60s)
4. Veri gelir: Halka + makrolar + su kartı + (varsa) öğün listesi
5. **Pull-to-refresh** dene → spinner → veri tazelenir
6. **+250 ml** butonuna bas → buton spinner → su sayısı anında artar
7. **Add Food** butonu → "AI Meal Scan ships in Chat 5" SnackBar
8. **Bottom nav** tap'ları → "Chat 17" SnackBar

### Yeni kullanıcı senaryosu (empty state)
- Hiç meal log'lanmamışsa: "No meals logged yet" empty state görünür
- Kalori sayısı 0, halka boş
- Pull-to-refresh çalışır

### Network hata senaryosu
- Wi-Fi'ı kapat → pull-to-refresh
- Error block: "No internet connection..." + Retry buton
- Wi-Fi'ı aç + Retry → veri gelir

---

## ⚠️ Bilinen Sınırlamalar

1. **Greeting saati hard-coded English.** Lokalizasyon ayrı bir chat'in işi.
2. **Avatar boş** — Profile photo henüz onboarding'de toplanmıyor. Initial harf gösteriyor.
3. **"See all" butonu** — Tıklama "Chat 17" SnackBar. Chat 17'de meal history ekranına bağlanacak.
4. **Real-time refresh yok** — Yeni meal eklenince (Chat 5'te) `ref.invalidate(dashboardSummaryProvider)` + `ref.invalidate(todayMealsProvider)` çağrılmalı. Chat 5 entegrasyonunda eklenecek.

---

## 🔄 Sonraki Chat (5) İçin Notlar

Chat 5 (AI Meal Scan), meal log'ladıktan sonra dashboard'ı güncellemek için:

```dart
// Chat 5'in meal_scan_provider'ında, /meals POST başarılı olunca:
ref.invalidate(dashboardSummaryProvider);
ref.invalidate(todayMealsProvider);
```

Dashboard scope'undan değil ama path'i tutarlı:
```dart
import 'package:nuveli_app/features/dashboard/providers/dashboard_provider.dart';
```

Add Food butonu Chat 5'te şuna bağlanacak:
```dart
AddFoodButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const MealScanScreen()),
  ),
),
```
