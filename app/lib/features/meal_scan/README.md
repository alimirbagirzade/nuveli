# 📷 Nuveli — Chat 5a: AI Meal Scan UI

Görsel 2'nin birebir Flutter UI'ı. **Mock mode** ile çalışır (`kMockMode = true`).
Backend gerçek bağlantı Chat 5b'de açılır.

---

## 📂 Dosya Yapısı

```
lib/features/meal_scan/
├── meal_scan_screen.dart                    # Ana ekran (state machine)
├── models/
│   ├── detected_food.dart                   # Tek yemek modeli
│   ├── portion_insight.dart                 # Porsiyon analizi
│   └── scan_result.dart                     # Tüm sonuç
├── data/
│   └── mock_scan_result.dart                # Görsel 2 ile birebir mock
├── providers/
│   └── meal_scan_provider.dart              # Riverpod AsyncNotifier
└── widgets/
    ├── scan_header.dart                     # ✕ + "AI Meal Scan" + ⚡
    ├── camera_preview_with_frame.dart       # Kamera + frame overlay
    ├── scan_frame_painter.dart              # CustomPainter (4 köşeli L + grid)
    ├── scan_complete_banner.dart            # ✓ + "3 foods | 520 kcal"
    ├── detected_food_list.dart              # 3 yemek satırı
    ├── portion_insights_card.dart           # 85% donut + insights
    └── analyze_another_button.dart          # CTA button
```

---

## 🔌 Bağımlılıklar

`pubspec.yaml`'a eklenmesi gerekenler:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  camera: ^0.10.5
```

Sonra:
```bash
flutter pub get
```

---

## 🔐 Kamera İzinleri (Manuel)

### iOS — `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Nuveli uses the camera to scan your meals and analyze nutrition.</string>
```

iOS deployment target en az **12.0** olmalı (`ios/Podfile`):
```ruby
platform :ios, '12.0'
```

### Android — `android/app/src/main/AndroidManifest.xml`

`<manifest>` içine:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

`android/app/build.gradle` içinde `minSdkVersion 21` olduğundan emin ol.

---

## 🚀 Kullanım

### Routing'e ekle (Chat 12'de tam bağlanacak)

```dart
import 'features/meal_scan/meal_scan_screen.dart';

// Geçici test için ana app içinde:
MaterialApp(
  home: ProviderScope(child: MealScanScreen()),
);
```

### Mock mode toggle

Default `true`. Backend'i Chat 5b'de bağlayınca real moda geç:

```bash
# Mock mode (default — şu an):
flutter run

# Real mode (Chat 5b sonrası):
flutter run --dart-define=MOCK=false
```

---

## 🧠 State Machine

```
        initial ──tap capture──► capturing ──photo taken──► analyzing
           ▲                                                    │
           │                                                    │ (mock 2s / real call)
           │                                                    ▼
           └─── tap "Analyze Another" ──────────────────────  result
                                                                │
                                                              error (retry → initial)
```

| State | Görsel |
|---|---|
| `initial` | Canlı kamera + scan frame + büyük cyan capture butonu |
| `capturing` | Capture butonu fade out, "Capturing..." hint |
| `analyzing` | Karanlık overlay + cyan spinner + "Analyzing meal..." |
| `result` | Çekilen foto + Scan Complete banner + Detected Foods + Portion Insights + "Analyze Another" |
| `error` | Karanlık overlay + ⚠️ + retry butonu |

---

## ✅ Test Checklist (Chat 5a Sonrası)

- [ ] Ekran açılınca kamera viewfinder görünüyor (4 köşeli L + 3x3 grid overlay)
- [ ] Flash butonu çalışıyor (ışık değişiyor)
- [ ] Capture butonuna basınca 2 saniye analyzing animasyonu
- [ ] Sonuç ekranında: çekilen foto + "Scan Complete | 3 foods detected | 520 kcal"
- [ ] Detected Foods listesi: Grilled Chicken (250) + Quinoa (120) + Steamed Vegetables (150)
- [ ] Portion Insights kartında 85% donut + "Great portion!" + highlights
- [ ] "Analyze Another Meal" butonu kamerayı tekrar açıyor
- [ ] Simulator/emülatörde kamera yoksa hint mesajı + yine de mock çalışıyor

---

## ⏭️ Sonraki: Chat 5b

Chat 5b'de yapılacaklar (`nuveli_chat5_hazirlik.md`'de detay):
1. `backend/routers/meals_scan.py` — POST /meals/scan
2. `backend/services/openai_vision_service.py` — GPT-4o Vision
3. `backend/services/meal_service.py` — Supabase kayıt
4. Frontend: `meal_scan_provider.dart`'taki real-mode bloğunu Dio + Supabase auth ile değiştir
5. `--dart-define=MOCK=false` ile gerçek API testi

---

**Kaynak:** `nuveli_chat5_hazirlik.md` (master plan'a bağlı)
