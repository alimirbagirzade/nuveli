# 📷 Nuveli — Chat 5a: AI Meal Scan UI (v2 SELF-CONTAINED)

Görsel 2'nin birebir Flutter UI'ı. **Mock mode** ile çalışır.
Bu versiyon **kendi içinde yeterli** — sadece `AppColors` ve `camera` paketine bağımlı.

---

## 📂 Dosyalar

```
lib/features/meal_scan/
├── meal_scan_screen.dart                 # Ana ekran + state machine
├── models/
│   ├── detected_food.dart
│   ├── portion_insight.dart
│   └── scan_result.dart
├── data/
│   └── mock_scan_result.dart             # Görsel 2 mock (520 kcal, %85)
├── providers/
│   └── meal_scan_provider.dart           # AsyncNotifier + mock/real toggle
└── widgets/
    ├── _glass_card_local.dart            # Lokal glass card (NuveliCard yerine)
    ├── analyze_another_button.dart       # CTA — kendi gradient'li
    ├── camera_preview_with_frame.dart    # Square camera + scan frame
    ├── detected_food_list.dart           # 3 yemek satırı
    ├── portion_insights_card.dart        # 85% donut + insights
    ├── scan_complete_banner.dart         # ✓ + foods + total kcal
    ├── scan_frame_painter.dart           # CustomPainter (4 L + 3x3 grid)
    └── scan_header.dart                  # ✕ + title + ⚡
```

---

## 🔌 Bağımlılıklar

`lib/features/meal_scan/` dışında **sadece şunlara muhtaç:**
- `package:flutter/material.dart` (standart)
- `package:flutter_riverpod/flutter_riverpod.dart` (zaten projede var, Chat 4 kullanıyor)
- `package:camera/camera.dart` (**yeni ekleme**)
- `package:nuveli_test/core/theme/app_colors.dart` (mevcut)

Hiçbir `NuveliCard`, `NuveliButton`, `NuveliBackground`, `NuveliBottomNav`, `AppTypography`, `AppSpacing`, `AppRadius` import etmez.

### Kurulum

```bash
flutter pub add camera
flutter pub get
```

---

## 🔐 İzinler

### iOS — `ios/Runner/Info.plist`

`<dict>` içine ekle:
```xml
<key>NSCameraUsageDescription</key>
<string>Nuveli uses the camera to scan your meals and analyze nutrition.</string>
```

Deployment target en az 12.0 (`ios/Podfile`):
```ruby
platform :ios, '12.0'
```

### Android — `android/app/src/main/AndroidManifest.xml`

`<manifest>` içine:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

`minSdkVersion 21` veya üstü.

---

## 🚀 Test (Geçici)

`lib/main.dart` veya `lib/app.dart` içinde `home`'u geçici değiştir:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/meal_scan/meal_scan_screen.dart';

// MaterialApp içinde:
home: const MealScanScreen(),

// Ve root'ta ProviderScope olduğundan emin ol:
// runApp(const ProviderScope(child: MyApp()));
```

Sonra:
```bash
flutter run
```

### Mock vs Real mode

```bash
# Mock mode (default — şu an aktif):
flutter run

# Real backend (Chat 5b sonrası):
flutter run --dart-define=MOCK=false
```

---

## 🧠 State Machine

```
initial ──tap capture──► capturing ──photo──► analyzing ──result
  ▲                                                         │
  │                                                         │
  └── tap "Analyze Another" ────────────── result ──────────┘
                                                error → retry → initial
```

---

## ✅ Test Checklist

- [ ] `flutter analyze` temiz (sadece `meal_scan/` ile ilgili hata yok)
- [ ] Ekran açılıyor, kamera viewfinder + scan frame görünüyor
- [ ] Capture butonuna basınca 2 sn "Analyzing meal..." overlay
- [ ] Sonuç: çekilen foto + Scan Complete (3 foods | 520 kcal)
- [ ] Detected Foods: Grilled Chicken (250) + Quinoa (120) + Steamed Vegetables (150)
- [ ] Portion Insights: 85% donut + "Great portion!" + "High in protein • Balanced meal"
- [ ] "Analyze Another Meal" → ekran kameraya döner
- [ ] Simulator'de kamera yoksa "Tap to analyze (using demo)" hint + yine çalışır

---

## ⏭️ Sonraki: Chat 5b (Backend)

Backend gelince yapılacaklar:
1. `backend/routers/meals_scan.py` — POST /meals/scan
2. `backend/services/openai_vision_service.py` — GPT-4o Vision
3. `meal_scan_provider.dart` içindeki real-mode bloğunu Dio + Supabase JWT ile değiştir
4. `flutter run --dart-define=MOCK=false`

---

## 🎨 Tema Notu

Bu paket Nisan'daki Chat 4 dashboard'unun `_shared/glass_card.dart`, `bottom_nav.dart` gibi yardımcılarına bağlı **değil**. İlerde proje genelinde `NuveliCard` standardı oluşursa `_glass_card_local.dart` o referansla replace edilir, geri kalan kod aynen kalır.
