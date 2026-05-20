# pubspec.yaml — Final Production Configuration

**Hedef:** Launch için final `pubspec.yaml` içeriği.

**Kullanım:** App'in root'undaki `pubspec.yaml`'ı bu içerikle değiştir.

---

## 📄 Final pubspec.yaml

```yaml
name: nuveli
description: AI-powered nutrition coach. Snap meals, track calories, reach your goals.
publish_to: 'none'

# ÖNEMLİ: Her release'de versionCode (build number) artırılmalı
# Format: SEMVER+BUILD
# v1.0.0 launch:      1.0.0+1
# v1.0.1 hotfix:      1.0.1+2
# v1.1.0 minor:       1.1.0+3
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # ═══════════════════════════════════════════════
  # STATE MANAGEMENT
  # ═══════════════════════════════════════════════
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # ═══════════════════════════════════════════════
  # ROUTING
  # ═══════════════════════════════════════════════
  go_router: ^14.2.0

  # ═══════════════════════════════════════════════
  # BACKEND & DATABASE
  # ═══════════════════════════════════════════════
  supabase_flutter: ^2.5.6
  dio: ^5.4.3
  
  # ═══════════════════════════════════════════════
  # AUTH
  # ═══════════════════════════════════════════════
  sign_in_with_apple: ^6.1.1
  google_sign_in: ^6.2.1  # Apple zorunluluğu: Google varsa Apple da olmalı
  
  # ═══════════════════════════════════════════════
  # IN-APP PURCHASE
  # ═══════════════════════════════════════════════
  purchases_flutter: ^7.2.0  # RevenueCat
  
  # ═══════════════════════════════════════════════
  # CHARTS & VISUALIZATION
  # ═══════════════════════════════════════════════
  fl_chart: ^0.68.0
  
  # ═══════════════════════════════════════════════
  # CAMERA & IMAGE
  # ═══════════════════════════════════════════════
  camera: ^0.10.6
  image_picker: ^1.1.2
  image: ^4.2.0  # Image processing (EXIF strip)
  
  # ═══════════════════════════════════════════════
  # NOTIFICATIONS
  # ═══════════════════════════════════════════════
  flutter_local_notifications: ^17.2.1
  firebase_messaging: ^15.0.4
  timezone: ^0.9.4
  
  # ═══════════════════════════════════════════════
  # FIREBASE
  # ═══════════════════════════════════════════════
  firebase_core: ^3.3.0
  firebase_analytics: ^11.2.1
  firebase_crashlytics: ^4.0.4
  
  # ═══════════════════════════════════════════════
  # HEALTH DATA
  # ═══════════════════════════════════════════════
  health: ^10.2.0
  permission_handler: ^11.3.1
  
  # ═══════════════════════════════════════════════
  # STORAGE
  # ═══════════════════════════════════════════════
  shared_preferences: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.3
  
  # ═══════════════════════════════════════════════
  # UI & UX
  # ═══════════════════════════════════════════════
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^3.1.2
  flutter_svg: ^2.0.10+1
  
  # ═══════════════════════════════════════════════
  # UTILS
  # ═══════════════════════════════════════════════
  intl: ^0.19.0
  uuid: ^4.4.0
  url_launcher: ^6.3.0
  package_info_plus: ^8.0.0
  device_info_plus: ^10.1.0
  
  # ═══════════════════════════════════════════════
  # ENV & CONFIG
  # ═══════════════════════════════════════════════
  flutter_dotenv: ^5.1.0
  
  # ═══════════════════════════════════════════════
  # ERROR MONITORING
  # ═══════════════════════════════════════════════
  sentry_flutter: ^8.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  
  # Code generation
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
  hive_generator: ^2.0.1
  
  # Launcher icons & splash
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.4.1

# ═══════════════════════════════════════════════
# FLUTTER LAUNCHER ICONS
# ═══════════════════════════════════════════════
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "launch_assets/icons/app_icon_1024.png"
  remove_alpha_ios: true
  background_color_ios: "#050A1F"
  # Adaptive icon (Android)
  adaptive_icon_background: "launch_assets/icons/app_icon_adaptive_background.png"
  adaptive_icon_foreground: "launch_assets/icons/app_icon_adaptive_foreground.png"
  min_sdk_android: 23

# ═══════════════════════════════════════════════
# FLUTTER NATIVE SPLASH
# ═══════════════════════════════════════════════
flutter_native_splash:
  color: "#050A1F"
  image: launch_assets/splash/splash_logo.png
  android_12:
    image: launch_assets/splash/splash_logo.png
    icon_background_color: "#050A1F"
    image_dark: launch_assets/splash/splash_logo.png
    icon_background_color_dark: "#050A1F"
  color_dark: "#050A1F"
  image_dark: launch_assets/splash/splash_logo.png
  ios: true
  fullscreen: true
  android: true
  android_gravity: center
  web: false

# ═══════════════════════════════════════════════
# FLUTTER
# ═══════════════════════════════════════════════
flutter:
  uses-material-design: true
  
  assets:
    - .env.production
    - assets/images/
    - assets/icons/
    - assets/animations/
  
  fonts:
    - family: SFProDisplay
      fonts:
        - asset: assets/fonts/SFProDisplay-Regular.ttf
          weight: 400
        - asset: assets/fonts/SFProDisplay-Medium.ttf
          weight: 500
        - asset: assets/fonts/SFProDisplay-Semibold.ttf
          weight: 600
        - asset: assets/fonts/SFProDisplay-Bold.ttf
          weight: 700
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

---

## 📝 Önemli Notlar

### Version Numbering
- `version: 1.0.0+1` formatı
- `1.0.0` = semantic version (kullanıcıya gösterilir)
- `+1` = build number (App Store / Play Store iç kullanım)
- **Build number her upload'da artmalı** (1, 2, 3, ...). Aynı build number ile upload yapamazsın.

### Production-Only Asset
`.env.production` dosyası asset listesine eklendi. Bu dosya:
- Backend URL
- Supabase URL & anon key
- RevenueCat public key
- Sentry DSN

İçeriği `.gitignore`'da olmalı, build sırasında manuel yerleştirilir veya CI/CD'den enjekte edilir.

### Font Lisansı
- **SF Pro Display:** Sadece iOS/macOS apps'te kullanım için Apple'ın lisansı altında. Diğer platformlar için **Inter** fallback ediliyor.
- **Inter:** Open source, SIL Open Font License — her platform için ücretsiz.

Apple lisansı: https://developer.apple.com/fonts/

### Çıkartılan Paketler (önceki taslakta vardı, gerekmediği için silindi)
- ❌ `bloc` / `flutter_bloc` — Riverpod kullanıyoruz
- ❌ `provider` — Riverpod yeterli
- ❌ `dio_intercept_to_curl` — debug only

---

## 🛠️ Komutlar

### İlk kurulum
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Production build (iOS)
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release \
  --build-name=1.0.0 \
  --build-number=1
# Output: build/ios/ipa/Nuveli.ipa
```

### Production build (Android)
```bash
flutter clean
flutter pub get
flutter build appbundle --release \
  --build-name=1.0.0 \
  --build-number=1
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## ⚠️ Lock File

Build edildikten sonra `pubspec.lock` üretilir. Bu dosya:
- ✅ **Commit ET** (production uniformity için)
- ✅ Team üyeleri aynı paket versiyonlarını kullanır
- ❌ Manuel düzenleme YAPMA (`flutter pub upgrade` ile güncellenir)

---

## 📊 Build Size Tahmini

Tüm paketlerle:
- **iOS IPA:** ~45-55 MB
- **Android AAB:** ~35-45 MB (Play Store optimize edip platform başına ~25-30 MB indirilebilir APK üretir)

App Store limit: 200 MB OTA download, 4 GB IPA
Google Play limit: 200 MB AAB

→ Bizim için sorun yok ✅

---

## 🚨 Pubspec Validation

Upload öncesi son kontrol:

- [ ] `version` 1.0.0+1 (launch için)
- [ ] `description` 80 karakter altında
- [ ] Tüm asset path'ları doğru
- [ ] Font dosyaları `assets/fonts/` içinde
- [ ] `.env.production` mevcut ama `.gitignore`'da
- [ ] `flutter pub get` hatasız çalışıyor
- [ ] `flutter analyze` 0 issue
- [ ] `flutter test` geçiyor
- [ ] `dart run build_runner build` hatasız
