# 📤 Upload Workflow — IPA & AAB

**Hedef:** Build'lerin store'lara nasıl yüklendiği adım adım.

---

## 🍎 iOS Upload — Transporter

### Yöntem 1: Transporter App (Önerilen, Mac App Store ücretsiz)

#### Kurulum
1. Mac App Store → **Transporter** ara
2. Install (ücretsiz)
3. Aç → Apple ID ile giriş

#### Upload
1. Transporter'ı aç
2. IPA dosyasını **sürükle bırak**: `build/ios/ipa/Nuveli.ipa`
3. Transporter otomatik validate eder:
   - Bundle ID kontrolü
   - Build number unique kontrolü
   - Provisioning profile kontrolü
   - Asset format kontrolü
4. **Deliver** butonu
5. Upload progress bar (~3-5 dk)
6. Tamamlanınca App Store Connect'te görünür

#### Upload Sonrası
- App Store Connect → TestFlight → Builds
- Status: **Processing** (5-15 dk)
- Sonra: **Ready to Test** (TestFlight'a hazır)

### Yöntem 2: Xcode Organizer

1. Xcode → Window → Organizer (`CMD+SHIFT+9`)
2. Archives sekmesi → son archive'ı seç
3. **Distribute App** butonu
4. **App Store Connect** seç
5. **Upload** seç
6. Signing options:
   - ✅ Automatically manage signing
7. Review screen → **Upload**
8. Upload + processing

**Avantajı:** Xcode build artifact'ından direkt upload, ayrı IPA dosyasına gerek yok.

### Yöntem 3: Fastlane (CI/CD)

```ruby
# fastlane/Fastfile
lane :release_ios do
  build_app(
    workspace: "ios/Runner.xcworkspace",
    scheme: "Runner",
    export_method: "app-store",
    output_directory: "build/ios/ipa"
  )
  upload_to_app_store(
    submit_for_review: false,  # Önce TestFlight'a, sonra manuel submit
    automatic_release: false,
    skip_metadata: true,       # Metadata'yı manuel yöneteceğiz
    skip_screenshots: true
  )
end
```

```bash
fastlane release_ios
```

---

## ⏳ iOS Processing Süreci

Upload sonrası Apple'ın işlem adımları:

1. **Validation** (1-2 dk)
   - IPA structure check
   - Code signing check
   - Asset compliance
2. **Symbol upload** (3-5 dk)
   - dSYM dosyaları işlenir
   - Crashlytics için
3. **Privacy check** (1-3 dk)
   - Privacy manifest validation
4. **App processing** (3-10 dk)
   - Available for TestFlight + App Store

**Toplam:** ~15-30 dakika (genelde 10 dakika)

### Email Bildirimleri
- ✅ "App is ready for distribution" — Build hazır
- ⚠️ "Issues with build" — Hata var (aşağıya bak)

---

## 🚨 iOS Upload Hataları

### "ITMS-90683: Missing Purpose String"
- Info.plist'te eksik permission string
- Hangi key olduğunu hata mesajı söylüyor
- Ekle, rebuild, re-upload

### "ITMS-90478: Invalid Version"
- Build number önceki upload'dan büyük olmalı
- pubspec.yaml'da `+2`, `+3`, ... artır

### "ITMS-91056: Invalid privacy manifest"
- iOS 17+ için PrivacyInfo.xcprivacy gerekiyor
- Bizim için: kullandığımız API'leri declare et

#### PrivacyInfo.xcprivacy oluştur (iOS 17+ zorunlu)
`ios/Runner/PrivacyInfo.xcprivacy`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyTracking</key>
  <false/>
  <key>NSPrivacyTrackingDomains</key>
  <array/>
  <key>NSPrivacyCollectedDataTypes</key>
  <array>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeEmailAddress</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <true/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeHealthAndFitness</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <true/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
        <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypePhotosorVideos</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <true/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeUserID</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <true/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeCrashData</string>
      <key>NSPrivacyCollectedDataTypeLinked</key>
      <false/>
      <key>NSPrivacyCollectedDataTypeTracking</key>
      <false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array>
        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
      </array>
    </dict>
  </array>
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>CA92.1</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>C617.1</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategorySystemBootTime</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>35F9.1</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryDiskSpace</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>E174.1</string>
      </array>
    </dict>
  </array>
</dict>
</plist>
```

Bu dosyayı Xcode'da Runner target'a ekle: Project navigator → drag&drop.

### "ITMS-90809: Deprecated API Usage - UIWebView"
- Eski paket UIWebView kullanıyor
- Çoğunlukla 3rd party SDK (Firebase eski)
- `flutter pub upgrade` ile son sürümleri al

### "Invalid Signature"
- Provisioning profile bozuk
- Xcode → Settings → Accounts → "Manage Certificates" → Yeniden indir
- Veya `automaticallyManaged: true`

---

## 🤖 Android Upload — Play Console

### Adım 1: Play Console'a Git
https://play.google.com/console → Nuveli app'i seç

### Adım 2: Release Track Seç

Sıralama (önerilen):
1. **Internal testing** → ilk önce buraya
2. **Closed testing** (Alpha)
3. **Open testing** (Beta)
4. **Production**

#### Internal Testing'e Upload

1. **Testing → Internal testing** sol menüden
2. **Create new release** butonu
3. **App bundles** → **Upload**
4. AAB sürükle bırak: `build/app/outputs/bundle/release/app-release.aab`
5. Bekle (1-2 dk upload)

### Adım 3: Release Detayları

#### App bundles section
- Yüklediğin AAB görünür
- Version code + name otomatik okunur
- ⚠️ "Errors" varsa düzelt (aşağıda)

#### Release name
```
1.0.0 (1)
```

#### Release notes
```html
<en-US>
<![CDATA[
Welcome to Nuveli — your AI calorie coach!

📸 AI Meal Scanner
🧠 Personal AI Coach
📊 Beautiful Analytics
💧 Water Tracker
🍴 Meal Planner
✅ Habits + Achievements

Premium: unlimited AI, full history, AI meal plans, Health Connect sync.

Feedback: hello@nuveli.app
]]>
</en-US>

<tr-TR>
<![CDATA[
Nuveli'ye hoş geldiniz — AI kalori koçunuz!

📸 AI Yemek Tarayıcı
🧠 Kişisel AI Koç
📊 Şık Analitik
💧 Su Takibi
🍴 Yemek Planlayıcı
✅ Alışkanlıklar + Başarılar

Premium: sınırsız AI, tüm geçmiş, AI yemek planı, Health Connect.

Geri bildirim: hello@nuveli.app
]]>
</tr-TR>
```

### Adım 4: Review & Rollout

1. **Next** butonu
2. Review screen — tüm bilgileri kontrol
3. **Start rollout to internal testing**
4. Bekleme: birkaç dakika → testers email alır

### Adım 5: Test sonrası Production'a Promote

Internal test başarılı geçince:
1. **Production** track'e git
2. **Create new release** veya **Promote release** (mevcut AAB'yi taşır)
3. Production-specific release notes ekle (yukarıdaki gibi)
4. **Save → Review release → Start rollout to Production**

### Staged Rollout
Production rollout'ta:
- **Initial rollout: 20%** (önerilen)
- 48 saat sonra: **50%**
- 1 hafta sonra: **100%**

Bu sayede crash spike olursa hızlıca durdurabilirsin.

---

## ⏳ Android Processing Süreci

Upload sonrası Google'ın işlem adımları:

1. **AAB processing** (~30 sn)
   - Bundle parse
   - Manifest validation
2. **Pre-launch report** (~30 dk)
   - Sanal cihazlarda test
   - Crash detection
   - Accessibility check
3. **Review** (3-7 gün ilk submission, 1-3 saat update'ler)

### Email Bildirimleri
- ✅ "Your app has been published"
- ⚠️ "Issues with your app submission" (reject)

---

## 🚨 Android Upload Hataları

### "Version code X has already been used"
- Build number tekrar kullanılamaz
- pubspec.yaml'da `+2`, `+3` artır
- Rebuild + re-upload

### "Your app bundle is signed with the wrong key"
- Yanlış keystore ile imzalanmış
- `keystore.properties`'i kontrol et
- Doğru keystore'la rebuild

### "Targets API level X but Google Play requires Y"
- targetSdk eski (2024+ minimum 34)
- `android/app/build.gradle.kts` güncelle
- Rebuild

### "Missing privacy policy"
- Play Console → App content → Privacy Policy URL eksik
- Doldur: https://nuveli.app/privacy

### "Data safety form incomplete"
- Play Console → App content → Data safety doldurulmamış
- Tüm soruları cevapla, save et

### "Permission policy violation"
- Sensitive permission kullanıyorsun ama kullanım gerekçesi yok
- Permission justification ekle (Play Console form'unda)

### "Health Connect permissions misused"
- Health Connect READ_STEPS gibi izinler kullanıyorsun
- "App content → Health connect permissions declaration" form'unu doldur

---

## 📊 Upload Timeline Karşılaştırması

### iOS
| Aşama | Süre |
|---|---|
| Transporter upload | 3-5 dk |
| Processing | 10-30 dk |
| TestFlight'a düşme | ~30 dk total |
| Beta App Review (external) | 24-48 saat |
| Final App Store Review | 24-72 saat |

### Android
| Aşama | Süre |
|---|---|
| Play Console upload | 1-2 dk |
| Pre-launch report | 30 dk |
| Internal testing live | ~10 dk |
| Closed testing review | 1-24 saat |
| Production review (ilk) | 3-7 gün |
| Production review (update) | 1-3 saat |

---

## 🎯 Upload Sırası Önerisi

### Day 1 (Pazartesi)
1. iOS IPA + Android AAB build (aynı build number, aynı versiyon)
2. iOS → Transporter ile App Store Connect'e upload
3. Android → Play Console Internal Testing'e upload
4. Beklerken: store listing form'ları doldur

### Day 2 (Salı)
1. iOS TestFlight Internal Testing'e ata
2. Internal testers (sen + 2-3 kişi) cihazlarda test et
3. Android Internal test feedback topla
4. Hata varsa: hotfix → build number +1 → tekrar upload

### Day 3-4 (Çarşamba-Perşembe)
1. iOS External TestFlight için Beta Review submit (24-48 saat)
2. Android Closed Testing'e promote
3. Recruit 20-50 beta tester

### Day 5-12 (Cuma - sonraki Çarşamba)
1. Beta test (1 hafta)
2. Critical bug fix'ler için patch upload
3. Feedback'i değerlendir, son düzeltmeler

### Day 13 (Pazartesi)
1. App Store + Play Production submit
2. iOS review 1-3 gün
3. Play production review 3-7 gün (ilk için)

### Day 16-20 (yaklaşık)
**🎉 LAUNCH**

---

## ✅ Final Upload Checklist

### iOS
- [ ] IPA build edildi
- [ ] Transporter veya Xcode Organizer ile upload
- [ ] Processing tamamlandı (TestFlight'ta görünüyor)
- [ ] Export compliance cevaplandı
- [ ] Internal Testing group'a build atandı
- [ ] Cihazda test edildi (en az 2 iOS device)
- [ ] External Testing için Beta Review submit
- [ ] App Store Connect → Build seçildi (review submission için)

### Android
- [ ] AAB build edildi
- [ ] Play Console → Internal Testing'e upload
- [ ] Pre-launch report yeşil
- [ ] Internal testing tamamlandı
- [ ] Closed/Open testing'e promote
- [ ] Production release oluşturuldu
- [ ] Staged rollout %20 set
- [ ] Submit for review ✅

---

**Tip:** Her platform için **build number'ları senkron tut**. iOS build 5 = Android build 5. Bu confusion'ı azaltır.
