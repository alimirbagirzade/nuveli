# 🌊 Splash Screen Setup — Nuveli

**Hedef:** App açılışında native splash screen (boş beyaz ekran yerine markalı açılış).

**Önerilen paket:** [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) — iOS LaunchScreen ve Android `splashscreen` API'ını otomatik konfigüre eder.

---

## 📐 Asset Gereksinimleri

### Splash Logo
| Asset | Boyut | Format | Notlar |
|---|---|---|---|
| `splash_logo.png` | **512 × 512** (en az) | PNG, alpha YES | Sadece logo, arkaplan transparent |
| `splash_logo@2x.png` | 1024 × 1024 | PNG | iOS retina |
| `splash_logo@3x.png` | 1536 × 1536 | PNG | iOS xxhdpi |

### Background
- **Tek renk önerilir** (gradient native splash'te problemli)
- Renk: `#050A1F` (master_plan primary background)
- İstersen `splash_background.png` (gradient) kullanabilirsin ama paket native render'da edge-case'ler yaşatabilir → düz renk daha güvenli

### Tasarım Briefi
- **Sadece Nuveli logosu ortada**, hiçbir metin yok
- Logo boyutu: 240 × 240 dp (orta nokta) — küçük ekranda taşma yok
- Arkaplan: `#050A1F` solid
- Animasyon: yok (native splash statik). Animasyonlu açılış istiyorsan splash → Flutter `SplashScreen` widget'ına Lottie ekle (Chat 12'de navigation'da yapılır)

---

## 🛠️ Kurulum Adımları

### 1. Paketi yükle

`pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.0
```

```bash
flutter pub get
```

### 2. Splash config dosyası

Proje root'una `flutter_native_splash.yaml` oluştur:

```yaml
flutter_native_splash:
  color: "#050A1F"
  image: launch_assets/splash/splash_logo.png

  # Android 12+ (yeni splash API)
  android_12:
    image: launch_assets/splash/splash_logo.png
    icon_background_color: "#050A1F"
    image_dark: launch_assets/splash/splash_logo.png
    icon_background_color_dark: "#050A1F"

  # Dark mode (her ikisi için)
  color_dark: "#050A1F"
  image_dark: launch_assets/splash/splash_logo.png

  # iOS — fullscreen
  ios: true
  fullscreen: true

  # Android
  android: true
  android_gravity: center

  # Web (opsiyonel)
  web: false
```

### 3. Generate

```bash
dart run flutter_native_splash:create
```

Bu komut:
- **iOS:** `ios/Runner/Base.lproj/LaunchScreen.storyboard` günceller
- **Android:** `android/app/src/main/res/drawable*/launch_background.xml` günceller
- **Android 12+:** `values-night-v31/styles.xml` günceller

### 4. Test

```bash
# iOS
flutter run -d "iPhone 15 Pro"

# Android
flutter run -d emulator-5554
```

Açılışta `#050A1F` arkaplanda merkez logo görmen lazım — sonra Flutter app yükleniyor.

---

## 🎬 Animasyonlu Splash (İsteğe Bağlı)

Native splash sadece statik. Animasyonlu açılış için:

1. Native splash → instant `#050A1F` + statik logo (1 saniyeden az)
2. Flutter app başladığında **SplashScreen widget** göster:
   - Lottie animasyon (`lottie` paketi)
   - Logo'dan gradient'e geçiş
   - "Nuveli" yazısı fade-in
3. 2-3 saniye sonra `go_router` ile Dashboard'a yönlendir

Bu Chat 12 (Navigation & Routing) içinde detaylandırılır. Şimdilik native splash'i kuralım yeter.

---

## 🚨 Yaygın Hatalar

| Sorun | Çözüm |
|---|---|
| iOS'ta splash görünmüyor | `flutter clean` + `cd ios && pod install` |
| Android'de logo dev (taşıyor) | Splash logo'yu küçült (512px logo + 240dp render) |
| Dark mode'da farklı arkaplan | `color_dark` ve `image_dark` ayarla |
| Logo flicker | `fullscreen: true` ekle (status bar gizle) |
| Android 12+ icon görünmüyor | `android_12` bloğunu ekle (yeni API) |

---

## ✅ Kontrol Listesi

- [ ] `splash_logo.png` üretildi (512 × 512, alpha)
- [ ] `flutter_native_splash.yaml` oluşturuldu
- [ ] `dart run flutter_native_splash:create` çalıştı
- [ ] iOS simulator'de doğrulandı (light + dark mode)
- [ ] Android emulator'de doğrulandı
- [ ] Android 12+ cihazda doğrulandı (yeni splash API farklı render)
- [ ] App açılış süresi < 2 saniye (boş ekran görünmüyor)

---

**Not:** Splash screen, sezonsal kampanyalarda değiştirilebilir. Şimdilik temel underwater branding yeterli.
