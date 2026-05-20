# iOS Info.plist — Final Production Config

**Konum:** `ios/Runner/Info.plist`

**Hedef:** Tüm Apple permissions, capabilities ve build flag'leri tam tanımlanmış.

⚠️ **Kritik:** Eksik permission string'i = anında reject (Apple Guideline 5.1.1).

---

## 📄 Tam Info.plist İçeriği

`ios/Runner/Info.plist` dosyasına ekle:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- APP IDENTITY                                              -->
  <!-- ════════════════════════════════════════════════════════ -->
  <key>CFBundleDevelopmentRegion</key>
  <string>$(DEVELOPMENT_LANGUAGE)</string>
  
  <key>CFBundleDisplayName</key>
  <string>Nuveli</string>
  
  <key>CFBundleExecutable</key>
  <string>$(EXECUTABLE_NAME)</string>
  
  <key>CFBundleIdentifier</key>
  <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
  
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  
  <key>CFBundleName</key>
  <string>nuveli</string>
  
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  
  <key>CFBundleShortVersionString</key>
  <string>$(FLUTTER_BUILD_NAME)</string>
  
  <key>CFBundleSignature</key>
  <string>????</string>
  
  <key>CFBundleVersion</key>
  <string>$(FLUTTER_BUILD_NUMBER)</string>
  
  <key>LSRequiresIPhoneOS</key>
  <true/>
  
  <key>UILaunchStoryboardName</key>
  <string>LaunchScreen</string>
  
  <key>UIMainStoryboardFile</key>
  <string>Main</string>
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- LOCALIZATION                                              -->
  <!-- ════════════════════════════════════════════════════════ -->
  <key>CFBundleLocalizations</key>
  <array>
    <string>en</string>
    <string>tr</string>
  </array>
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- PERMISSIONS (NSUsageDescription)                          -->
  <!-- ════════════════════════════════════════════════════════ -->
  
  <!-- Camera (meal scan) -->
  <key>NSCameraUsageDescription</key>
  <string>Nuveli uses the camera to scan your meals with AI for instant calorie tracking.</string>
  
  <!-- Photo Library (alternatif olarak galeriden seçim) -->
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Choose a photo of your meal from your library for AI nutrition analysis.</string>
  
  <key>NSPhotoLibraryAddUsageDescription</key>
  <string>Save meal photos to your library (optional).</string>
  
  <!-- Apple Health (Premium feature) -->
  <key>NSHealthShareUsageDescription</key>
  <string>Sync weight, steps, and workouts with Apple Health for personalized coaching (Premium feature).</string>
  
  <key>NSHealthUpdateUsageDescription</key>
  <string>Update your weight in Apple Health when you log it in Nuveli (Premium feature).</string>
  
  <!-- Notifications -->
  <key>NSUserNotificationsUsageDescription</key>
  <string>Nuveli sends meal logging, hydration, and habit reminders to keep you on track.</string>
  
  <!-- Face ID / Touch ID (gelecekteki secure access için) -->
  <key>NSFaceIDUsageDescription</key>
  <string>Use Face ID to securely access your health data in Nuveli.</string>
  
  <!-- App Tracking Transparency: 
       Bu app TRACKING YAPMIYOR, IDFA toplamıyor.
       Bu nedenle NSUserTrackingUsageDescription EKLENMEDİ.
       Apple bu prompt'u istemeyen app'ler için sormaz. -->
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- BACKGROUND MODES                                          -->
  <!-- ════════════════════════════════════════════════════════ -->
  <key>UIBackgroundModes</key>
  <array>
    <string>fetch</string>
    <string>remote-notification</string>
  </array>
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- DEVICE & ORIENTATION                                      -->
  <!-- ════════════════════════════════════════════════════════ -->
  <key>UIDeviceFamily</key>
  <array>
    <integer>1</integer>  <!-- iPhone -->
  </array>
  
  <key>UISupportedInterfaceOrientations</key>
  <array>
    <string>UIInterfaceOrientationPortrait</string>
  </array>
  
  <key>UISupportedInterfaceOrientations~ipad</key>
  <array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
  </array>
  
  <key>UIRequiresFullScreen</key>
  <true/>
  
  <key>UIStatusBarStyle</key>
  <string>UIStatusBarStyleLightContent</string>
  
  <key>UIViewControllerBasedStatusBarAppearance</key>
  <false/>
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- CAPABILITIES                                              -->
  <!-- ════════════════════════════════════════════════════════ -->
  
  <!-- Healthkit capability (Premium) -->
  <key>UIRequiredDeviceCapabilities</key>
  <array>
    <string>arm64</string>
  </array>
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- ENCRYPTION                                                -->
  <!-- ════════════════════════════════════════════════════════ -->
  
  <!-- App standart HTTPS kullanıyor, custom encryption yok -->
  <!-- "NO" desek bile export compliance gerekirdi (ITSAppUsesNonExemptEncryption: false) -->
  <key>ITSAppUsesNonExemptEncryption</key>
  <false/>
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- NETWORK SECURITY                                          -->
  <!-- ════════════════════════════════════════════════════════ -->
  
  <!-- Sadece HTTPS, ATS aktif. Backend zaten HTTPS. -->
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <!-- İstisna yok — production'da HTTPS-only -->
  </dict>
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- DEEPLINKING (CustomURLScheme)                             -->
  <!-- ════════════════════════════════════════════════════════ -->
  
  <!-- Supabase Auth deeplink + RevenueCat deeplink -->
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLName</key>
      <string>com.nuveli.app</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>nuveli</string>
      </array>
    </dict>
    
    <!-- Sign in with Apple callback -->
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLName</key>
      <string>com.nuveli.app.signin</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>com.nuveli.app.signin</string>
      </array>
    </dict>
  </array>
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- UNIVERSAL LINKS (Associated Domains)                      -->
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- Bu Xcode'da "Signing & Capabilities → Associated Domains"
       ile ayarlanır, Info.plist'te değil.                       -->
  <!-- applinks:nuveli.app                                       -->
  
  <!-- ════════════════════════════════════════════════════════ -->
  <!-- FLUTTER -->
  <!-- ════════════════════════════════════════════════════════ -->
  <key>CADisableMinimumFrameDurationOnPhone</key>
  <true/>
  
  <key>UIApplicationSupportsIndirectInputEvents</key>
  <true/>
</dict>
</plist>
```

---

## 🔍 Permission Strings Açıklamaları

Apple **Guideline 5.1.1(i)**: Permission istek nedeni **açık ve net** olmalı.

### ❌ KÖTÜ (reject olur)
```
"App needs camera access"
"For features"
"To enable photo upload"
```

### ✅ İYİ (bizim version)
```
"Nuveli uses the camera to scan your meals with AI for instant calorie tracking."
```

**Formül:**
> `[App adı] uses [permission] to [spesifik fayda]`

---

## 🔐 Xcode Capabilities

Info.plist dışında Xcode'da elle ayarlanacak capabilities:

### Signing & Capabilities sekmesinde ekle:

1. **Sign in with Apple** ✅
   - Apple zorunlu: Google/Facebook login varsa Apple da olmalı

2. **HealthKit** ✅
   - Premium feature için
   - "Clinical Health Records: NO" (sadece nutrition + activity)

3. **Push Notifications** ✅
   - APNs için gerekli (Firebase Messaging)

4. **Background Modes** ✅
   - Background fetch (insight güncelleme)
   - Remote notifications (push receive)

5. **Associated Domains** ✅ (universal links için)
   - `applinks:nuveli.app`

6. **In-App Purchase** ✅
   - RevenueCat için zorunlu

---

## 🌐 NSAppTransportSecurity (ATS) Detayı

Yukarıdaki config'de **`NSAllowsArbitraryLoads: false`** → ATS tam aktif.

**Anlamı:**
- Backend (Render) HTTPS olmalı ✅
- Supabase HTTPS ✅
- OpenAI HTTPS ✅
- Tüm 3rd party servisler HTTPS

Eğer bir backend HTTP olsaydı (legacy API), exception ekleyebilirdik:
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>legacy.example.com</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <true/>
    </dict>
  </dict>
</dict>
```

⚠️ **Bu istisna ATS reject riski yaratır.** Sadece zorunluysa kullan + Apple'a justify et.

---

## 📋 LSApplicationQueriesSchemes

Eğer app içinden başka app'lere geçiş varsa (örn. "Spotify'da aç"), `LSApplicationQueriesSchemes` ekle:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>itms-apps</string>  <!-- App Store linkleri -->
</array>
```

Bizim için: Subscription management için App Store'a yönlendirme:
```dart
launchUrl(Uri.parse('itms-apps://apps.apple.com/account/subscriptions'));
```
→ Yukarıdaki array'e `itms-apps` eklenmeli.

---

## ✅ Submission Checklist

App Store Connect'e upload öncesi:

- [ ] Tüm `NSXxxUsageDescription` doldurulmuş
- [ ] Bundle ID: `com.nuveli.app`
- [ ] Display Name: "Nuveli"
- [ ] CFBundleVersion artırıldı (her upload'da +1)
- [ ] ITSAppUsesNonExemptEncryption: false
- [ ] NSAppTransportSecurity strict (HTTPS-only)
- [ ] CFBundleLocalizations: en, tr
- [ ] Background modes set
- [ ] Sign in with Apple capability eklendi (Xcode)
- [ ] HealthKit capability (Xcode)
- [ ] Push Notifications (Xcode)
- [ ] Associated Domains: nuveli.app
- [ ] In-App Purchase (Xcode)

---

## 🚨 Apple Reject Sebepleri (Info.plist Spesifik)

| Hata | Reject Code |
|---|---|
| Permission string boş | 5.1.1(i) |
| Permission string belirsiz ("For features") | 5.1.1(i) |
| NSAppTransportSecurity disabled | 1.1 (Security) |
| Capability claim eksik (App entitlement-istiyor ama Info'da yok) | 4.0 |
| Bundle ID format yanlış | 4.0 |
| Build number geriledi (önceki build > yeni) | 4.0 (Build version) |
| Sign in with Apple yok ama Google login var | 4.8 (Sign in with Apple zorunlu) |
| Push notifications config yok ama FCM kullanılıyor | 2.1 |

---

**Önemli:** Bu Info.plist test build'lerde de kullanılır. Production-only ayrımı yapmaya gerek yok.
