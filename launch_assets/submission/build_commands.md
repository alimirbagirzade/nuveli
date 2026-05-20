# 🛠️ Build Commands — Production

**Hedef:** iOS IPA ve Android AAB production build'leri için copy-paste komutlar.

---

## 📋 Pre-Build Checklist

Her production build'den ÖNCE:

- [ ] `pubspec.yaml` → version artırıldı (örn. `1.0.0+1` → `1.0.0+2`)
- [ ] `flutter pub get` çalıştı
- [ ] `flutter analyze` → 0 issue
- [ ] `flutter test` → all passed
- [ ] `.env.production` dosyası mevcut (gerçek API key'ler)
- [ ] Keystore (Android) hazır
- [ ] Provisioning profile (iOS) hazır
- [ ] Build number unique (önceki + 1)

---

## 🍎 iOS — IPA Build

### Adım 1: Pre-build temizlik
```bash
cd ~/Development/nuveli/app
flutter clean
flutter pub get
cd ios && pod install --repo-update && cd ..
```

### Adım 2: Code generation (Riverpod + Hive)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Adım 3: Launcher icons + splash
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Adım 4: Production IPA build
```bash
flutter build ipa --release \
  --build-name=1.0.0 \
  --build-number=1 \
  --dart-define=ENV=production
```

**Çıktı:** `build/ios/ipa/Nuveli.ipa`
**Süre:** İlk build 5-10 dk, sonraki build'ler 2-3 dk

### Alternatif: Build & Archive in Xcode

```bash
# Build için Xcode'a hazırla
flutter build ios --release \
  --build-name=1.0.0 \
  --build-number=1

# Xcode aç
open ios/Runner.xcworkspace

# Xcode'da:
# 1. Top bar: device "Any iOS Device (arm64)" seç
# 2. Product → Archive
# 3. Bekle (5-10 dk)
# 4. Organizer açılır → Distribute App
```

### Adım 5: IPA boyutunu kontrol et
```bash
ls -lh build/ios/ipa/
# Beklenen: 30-60 MB
```

⚠️ **>200 MB ise:** OTA download blocked. Assets temizle, image compress et.

### Adım 6: IPA validate (optional, upload öncesi)
```bash
# Xcode Organizer'da:
# Distribute App → App Store Connect → Validate
# Apple sunucusunda pre-flight check yapar
# Sorun varsa upload etmeden bildirir
```

---

## 🤖 Android — AAB Build

### Adım 1: Pre-build temizlik
```bash
cd ~/Development/nuveli/app
flutter clean
flutter pub get
```

### Adım 2: Code generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Adım 3: Launcher icons + splash
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Adım 4: Production AAB build
```bash
flutter build appbundle --release \
  --build-name=1.0.0 \
  --build-number=1 \
  --dart-define=ENV=production
```

**Çıktı:** `build/app/outputs/bundle/release/app-release.aab`
**Süre:** İlk build 5-8 dk, sonraki 2-3 dk

### Adım 5: AAB boyutunu kontrol et
```bash
ls -lh build/app/outputs/bundle/release/
# Beklenen: 30-50 MB
```

### Adım 6: AAB içeriğini inceleme (optional)
```bash
# bundletool ile içeriği görmek
brew install bundletool

bundletool dump manifest \
  --bundle=build/app/outputs/bundle/release/app-release.aab

# Permissions'ı listele
bundletool dump manifest \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --xpath="/manifest/uses-permission/@android:name"
```

### Adım 7: Test AAB'yi indirilebilir APK'ya çevir (test için)
```bash
# Universal APK üret (her cihaz için)
bundletool build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=nuveli.apks \
  --mode=universal \
  --ks=~/keys/nuveli-release.jks \
  --ks-key-alias=nuveli-release

# APK'ı extract et
unzip nuveli.apks -d nuveli_extracted/
# nuveli_extracted/universal.apk → fiziksel cihaza yüklenebilir

# Cihaza install (USB bağlı olmalı)
adb install nuveli_extracted/universal.apk
```

---

## 🔍 Build Doğrulama

### iOS IPA Validation
```bash
# IPA içeriğini incele
unzip -l build/ios/ipa/Nuveli.ipa | head -20

# Info.plist'i extract et
unzip -p build/ios/ipa/Nuveli.ipa Payload/Runner.app/Info.plist | plutil -p -

# Bundle version doğrula
unzip -p build/ios/ipa/Nuveli.ipa Payload/Runner.app/Info.plist | \
  plutil -p - | grep -E "(CFBundleShortVersionString|CFBundleVersion)"
```

### Android AAB Validation
```bash
# AAB içindeki AndroidManifest.xml
bundletool dump manifest \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  > manifest.xml

# Permissions doğrula
grep "uses-permission" manifest.xml

# Version doğrula
grep -E "(versionCode|versionName)" manifest.xml
```

---

## 🚨 Yaygın Build Hataları

### iOS

#### "No provisioning profile found"
```bash
# Xcode → Settings → Accounts
# Apple ID seç → "Download Manual Profiles"

# Veya Xcode otomatik yönetimi aç:
# Runner project → Signing & Capabilities → "Automatically manage signing" ✅
```

#### "CocoaPods could not find compatible versions"
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

#### "Provisioning profile doesn't include the entitlement"
- Apple Developer portal → Identifiers → com.nuveli.app
- Capabilities ekle (Sign in with Apple, HealthKit, Push Notifications)
- Provisioning profile yeniden generate et
- Xcode → Profiles indir

#### "ITMS-90683: Missing Purpose String in Info.plist"
- `Info.plist`'te eksik `NSXxxUsageDescription` var
- Hangi permission olduğunu hata mesajı söylüyor, ekle

### Android

#### "Keystore was tampered with, or password was incorrect"
- `keystore.properties` şifresi yanlış
- Veya `storeFile` path'i yanlış
- Doğrula:
```bash
keytool -list -keystore ~/keys/nuveli-release.jks
# Şifre giriş yapıldığında doğru çıkıyor mu?
```

#### "Execution failed for task ':app:lintVitalRelease'"
```bash
# Lint hatalarını ignore et (geçici, ideal değil)
# android/app/build.gradle.kts
android {
  lint {
    checkReleaseBuilds = false
    abortOnError = false
  }
}
```

Veya hataları gerçekten düzelt (önerilen).

#### "AndroidManifest.xml: duplicate attribute"
- Manifest merge çakışması (3rd party library + bizim manifest)
- Çözüm: `tools:replace` kullan:
```xml
<application
    android:label="Nuveli"
    tools:replace="android:label">
```

#### "More than one file was found with OS independent path 'META-INF/DEPENDENCIES'"
- `build.gradle.kts`'de packaging excludes ekle (zaten yukarıda set ettik)

---

## 🚀 Build Optimization (Boyut Küçültme)

### iOS

#### Bitcode Disable (Apple 2023'ten beri opsiyonel)
Xcode → Build Settings → Bitcode: NO (zaten Flutter default'u)

#### App Thinning
Apple otomatik yapıyor (App Store Connect'te).

### Android

#### ProGuard / R8 (zaten enabled)
`android/app/build.gradle.kts`:
```kotlin
buildTypes {
    getByName("release") {
        isMinifyEnabled = true
        isShrinkResources = true
    }
}
```

#### Bundle Splits (zaten enabled)
```kotlin
bundle {
    language { enableSplit = true }
    density { enableSplit = true }
    abi { enableSplit = true }
}
```

Sonuç: Kullanıcılar ortalama 20-30 MB indirir (universal 50 MB değil).

---

## 📊 Build Time Karşılaştırması

| Build | İlk Çalıştırma | Sonraki (cache'li) |
|---|---|---|
| `flutter clean` | 10s | 10s |
| `flutter pub get` | 30s | 5s |
| `pod install` | 60-180s | 30s |
| `build_runner build` | 60s | 20s |
| `flutter build ipa` | 5-10 dk | 2-3 dk |
| `flutter build appbundle` | 5-8 dk | 2-3 dk |
| **Toplam (her platform)** | **~15 dk** | **~5 dk** |

---

## 🎯 Otomatik Build Script

`scripts/build_all.sh` oluştur:

```bash
#!/bin/bash
set -e  # Hata olunca dur

VERSION_NAME="1.0.0"
BUILD_NUMBER=$1

if [ -z "$BUILD_NUMBER" ]; then
  echo "Usage: ./build_all.sh <build_number>"
  echo "Example: ./build_all.sh 1"
  exit 1
fi

echo "🚀 Building Nuveli v${VERSION_NAME}+${BUILD_NUMBER}"
echo ""

# Step 1: Clean
echo "🧹 Cleaning..."
flutter clean

# Step 2: Pub get
echo "📦 Getting packages..."
flutter pub get

# Step 3: iOS pods
echo "🍎 Installing iOS pods..."
cd ios && pod install --repo-update && cd ..

# Step 4: Code generation
echo "⚙️  Generating code..."
dart run build_runner build --delete-conflicting-outputs

# Step 5: Icons + splash
echo "🎨 Generating icons + splash..."
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# Step 6: Test
echo "🧪 Running tests..."
flutter test

# Step 7: Analyze
echo "🔍 Analyzing code..."
flutter analyze

# Step 8: Build iOS IPA
echo "🍎 Building iOS IPA..."
flutter build ipa --release \
  --build-name=$VERSION_NAME \
  --build-number=$BUILD_NUMBER \
  --dart-define=ENV=production

# Step 9: Build Android AAB
echo "🤖 Building Android AAB..."
flutter build appbundle --release \
  --build-name=$VERSION_NAME \
  --build-number=$BUILD_NUMBER \
  --dart-define=ENV=production

# Step 10: Summary
echo ""
echo "✅ Build complete!"
echo ""
echo "📦 Artifacts:"
echo "  iOS:     build/ios/ipa/Nuveli.ipa"
echo "  Android: build/app/outputs/bundle/release/app-release.aab"
echo ""
ls -lh build/ios/ipa/Nuveli.ipa
ls -lh build/app/outputs/bundle/release/app-release.aab
```

Kullanım:
```bash
chmod +x scripts/build_all.sh
./scripts/build_all.sh 1
# Build number 1 ile production build üretir
```

---

## ✅ Final Build Checklist

- [ ] Version + build number doğru
- [ ] `.env.production` mevcut ve doğru API key'ler içeriyor
- [ ] iOS IPA üretildi (`build/ios/ipa/Nuveli.ipa`)
- [ ] Android AAB üretildi (`build/app/outputs/bundle/release/app-release.aab`)
- [ ] Her iki dosya boyutu < 200 MB
- [ ] iOS IPA validate edildi (Xcode Organizer)
- [ ] Android AAB Play Console internal test'e yüklendi (önce)
- [ ] Fiziksel cihazlarda test edildi (en az 2 iOS + 2 Android)
- [ ] Crash yok, performans iyi
- [ ] Production tarafına geçmeye hazır
