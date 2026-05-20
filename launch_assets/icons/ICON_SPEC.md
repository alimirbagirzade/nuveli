# 🎨 App Icon Spec — Nuveli

**Hedef:** App Store + Google Play için production-ready icon set.

---

## 📐 Boyutlar ve Format

### iOS (App Store)
| Asset | Boyut | Format | Notlar |
|---|---|---|---|
| `app_icon_1024.png` | **1024 × 1024** | PNG, **alpha YOK** | App Store Connect upload için |
| In-app icons | 180/120/87/80/60/58/40 px | PNG | Xcode otomatik üretir (Asset Catalog) |

⚠️ **Apple kuralları:**
- `1024 × 1024` icon **alpha channel İÇERMEMELİ** (transparency yok)
- **Köşeleri yuvarlama** (Apple kendisi yuvarlar). Tam kare ver.
- sRGB color space
- **Texture/gradient olabilir** ama metin yok (App Store reddeder)

### Android (Google Play + adaptive)
| Asset | Boyut | Format | Notlar |
|---|---|---|---|
| `app_icon_512.png` | **512 × 512** | PNG, 32-bit (alpha olabilir) | Play Store listing |
| `app_icon_adaptive_foreground.png` | **432 × 432** | PNG (alpha YES) | Adaptive icon foreground layer |
| `app_icon_adaptive_background.png` | **432 × 432** | PNG (alpha YES) veya solid color | Adaptive icon background |
| `notification_icon.png` | **96 × 96** | PNG, **monochrome (beyaz + alpha)** | Status bar icon (Android) |

⚠️ **Android Adaptive Icon kuralları:**
- Toplam alan **108 × 108 dp** ama görünür alan sadece **72 × 72 dp** (merkez)
- Foreground'da logo **66 × 66 dp safe zone** içinde olmalı (köşeler kırpılır)
- Background **düz renk veya basit pattern** olmalı

### Notification Icon (kritik!)
- **Sadece beyaz + transparent** olmalı (Android Lollipop+ sistem rengi uygular)
- Renkli notification icon → Google Play reject riski
- Basit silüet: damla/dalga formu yeterli

---

## 🎨 Tasarım Briefi

### Konsept: **Underwater Drop**
Master plan'daki "underwater / liquid glass" temasından türetildi.

**Önerilen tasarım:**
- Su damlası veya dalga formu (Nuveli'nin "N"i içinde)
- Cyan → Deep blue gradient
- İnce ışık huzmesi (parlaklık)
- Premium hissiyat: glossy ama abartısız

### Renkler (master_plan'dan)
```
Background gradient: #050A1F → #0B1A3D (koyu lacivert)
Logo accent: #00D4FF (primary cyan)
Glow highlight: #4DDBFF (parlak vurgu)
Optional inner shine: rgba(255,255,255,0.15)
```

### Tipografi (icon içinde yok!)
- App icon'da **metin/harf olmayacak** (Apple "N" harfli icon'ları küçük boyutta tanınmaz buluyor)
- Sadece sembol (damla/dalga)

---

## 🛠️ Figma Template

### Önerilen Setup
1. **Yeni Figma file:** `nuveli-app-icon-master`
2. **Master frame:** 1024 × 1024 px
3. **Layer'lar:**
   ```
   ┌─ 1024 Master
   │  ├─ Background (gradient #050A1F → #0B1A3D)
   │  ├─ Glow ring (radial gradient cyan, %30 opacity, blur 40)
   │  ├─ Drop shape (Nuveli logo formu, cyan gradient)
   │  ├─ Inner highlight (top-left, rgba white %15)
   │  └─ Border subtle (1px rgba white %5, opsiyonel)
   ```
4. **Export presets** (Figma → Export):
   - `app_icon_1024.png` — 1× (1024 × 1024), **PNG (no alpha)**
   - `app_icon_512.png` — 0.5× (512 × 512), PNG
   - `app_icon_adaptive_foreground.png` — sadece drop shape, 432 × 432, alpha
   - `app_icon_adaptive_background.png` — sadece gradient, 432 × 432
   - `notification_icon.png` — drop silüeti white, 96 × 96

### Alpha Kaldırma (1024 için)
Figma → Export → PNG seçtiğinde **"Background"** seçeneğini işaretle (solid background ekler, alpha silinir). Veya export sonrası terminalden:
```bash
# macOS — sips ile alpha kaldır
sips -s format png --deleteColorManagementProperties app_icon_1024.png
# veya ImageMagick
magick app_icon_1024.png -background black -alpha remove -alpha off app_icon_1024_final.png
```

---

## 📦 Flutter'a Entegrasyon

### Paket: `flutter_launcher_icons`

`pubspec.yaml`'a ekle:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "launch_assets/icons/app_icon_1024.png"
  remove_alpha_ios: true   # iOS için kritik
  background_color_ios: "#050A1F"
  # Adaptive icon (Android)
  adaptive_icon_background: "launch_assets/icons/app_icon_adaptive_background.png"
  adaptive_icon_foreground: "launch_assets/icons/app_icon_adaptive_foreground.png"
  # Min SDK için fallback
  min_sdk_android: 23
```

Çalıştır:
```bash
dart run flutter_launcher_icons
```

Bu komut iOS Asset Catalog'u ve Android `mipmap-*` klasörlerini otomatik doldurur.

---

## ✅ Kontrol Listesi

Üretim bitince:
- [ ] `app_icon_1024.png` — 1024×1024, alpha YOK, < 1 MB
- [ ] App Store Connect'te preview'da düzgün görünüyor (yuvarlatma sonrası)
- [ ] Küçük boyutta (60×60) hala tanınır
- [ ] Koyu mod ve açık mod ekranlarda kontrast yeterli
- [ ] `app_icon_512.png` — Google Play için
- [ ] Adaptive icon foreground safe zone'da
- [ ] Notification icon **sadece beyaz + alpha**
- [ ] `flutter_launcher_icons` çalıştı, build hatasız
- [ ] iPhone simulator + Android emulator'de doğrulandı

---

## 🚨 Yaygın Hatalar

| Hata | Sonuç |
|---|---|
| 1024 PNG'de alpha var | App Store Connect upload reject |
| Icon'da metin/logo harfi | Apple Review reject (okunmaz buluyor) |
| Adaptive background transparent | Android'de bozuk görünür |
| Notification icon renkli | Google Play reject (sensitive permission policy) |
| Köşeleri elle yuvarlamak | Apple zaten yuvarlıyor → çift yuvarlatma |

---

**Asset üretim önerisi:**
İstersen ben sana Figma'da kullanabileceğin **SVG taslak** üreteyim (drop + gradient + glow). Söyle, hazırlayayım.
