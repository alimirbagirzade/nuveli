# 🧪 TestFlight Workflow

**TestFlight:** Apple'ın resmi beta test platformu. iOS app'lerini App Store review öncesi gerçek cihazlarda test etmek için.

**URL:** App Store Connect → TestFlight sekmesi
**App (iOS):** https://testflight.apple.com (testerların indirme app'i)

---

## 📋 İki Aşamalı Test Stratejisi

### Aşama 1: Internal Testing (1-100 kişi)
- **Apple review yok**
- **Anında erişim** (build upload + 5-10 dk processing)
- App Store Connect kullanıcıları + 100 internal tester
- En hızlı feedback

### Aşama 2: External Testing (1-10,000 kişi)
- **Apple Beta App Review** gerekli (24-48 saat)
- Email davet veya **public link**
- Public link: limitsiz kişiye gönderebilirsin
- Sandbox IAP test edilebilir

---

## 🛠️ Adım 1: İlk Build Upload

### Yöntem A: Xcode (Önerilen)

```bash
# 1. Build for archive
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release \
  --build-name=1.0.0 \
  --build-number=1

# 2. Xcode'da aç
open ios/Runner.xcworkspace

# 3. Xcode menüsünde:
# Product → Archive
# Bekle (5-10 dk, ilk archive uzun)

# 4. Archive bitince Organizer açılır:
# Window → Organizer (CMD+SHIFT+9)
# → Distribute App
# → App Store Connect
# → Upload
# → Automatically manage signing
# → Upload

# 5. 5-15 dakika processing
```

### Yöntem B: Transporter App (Daha hızlı)

1. Mac App Store'dan **Transporter** indir
2. Apple ID ile giriş yap
3. IPA dosyasını sürükle bırak: `build/ios/ipa/Nuveli.ipa`
4. **Deliver** butonu
5. Background'da upload eder (Xcode'a göre daha hızlı)

### Yöntem C: Fastlane (CI/CD için)

```ruby
# fastlane/Fastfile
lane :beta do
  build_app(
    workspace: "ios/Runner.xcworkspace",
    scheme: "Runner",
    export_method: "app-store"
  )
  upload_to_testflight(
    skip_waiting_for_build_processing: true
  )
end
```

```bash
fastlane beta
```

---

## ⏳ Adım 2: Build Processing

Upload bittikten sonra App Store Connect:

1. **My Apps → Nuveli → TestFlight** sekmesi
2. Build önce "**Processing**" durumunda (~5-15 dk)
3. İşlem bittiğinde "**Ready to Submit**" oluyor

### Export Compliance Bilgisi

İlk build upload'unda Apple sorabilir:

**Q: Does your app use encryption?**
A: ✅ Yes (HTTPS kullanıyoruz)

**Q: Does it qualify for any exemptions provided in Category 5, Part 2 of the U.S. Export Administration Regulations?**
A: ✅ Yes
- ✅ Exemption: "(a) standard cryptographic algorithms"

Bu Info.plist'te zaten set:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Bu sayede her build'de bu soru tekrar sorulmaz.

---

## 🧪 Adım 3: Internal Testing Setup

### Tester Ekle

1. App Store Connect → TestFlight → **Internal Testing** sol menüden
2. **Create Internal Group** (örn: "Nuveli Internal")
3. **Add Testers:**
   - App Store Connect kullanıcılarından seç
   - Email ile davet et (App Store Connect user olmalı)
4. **Add Builds:**
   - Latest build'i grup'a ata
   - ✅ Auto-notify testers
5. **Save**

### Test Süreci

Testers'a email gelir:
```
You've been invited to test Nuveli — AI Calorie Coach.
Download TestFlight: https://apps.apple.com/us/app/testflight
Then tap the link to add the app.
```

İlk indirme:
1. TestFlight app'i App Store'dan indir
2. Davet email'indeki **"Start Testing"** linkine tıkla
3. Tap "Accept" → Nuveli TestFlight'a eklenir
4. Tap "Install" → indirme başlar

### Feedback Toplama

TestFlight içinde feedback için:
- **TestFlight app → Nuveli → Send Beta Feedback**
- App içinde screenshot al → otomatik TestFlight feedback'e eklenir
- Crash logs otomatik upload edilir

Sen App Store Connect'te görürsün:
- TestFlight → **Feedback** sekmesi
- Screenshots, comments, crashes

---

## 🌐 Adım 4: External Testing Setup

### Beta App Review (İlk build için)

External testers eklemeden önce **Apple Beta App Review** gerekiyor:

1. TestFlight → **External Testing** → **Create External Group**
2. Group name: "Nuveli Public Beta"
3. **Add Builds** → latest build seç
4. **Test Information** doldur:

#### Test Info

| Alan | Değer |
|---|---|
| **What to Test** | Test the AI meal scanning, meal logging, daily insights, and premium subscription flow. |
| **App Description** | Aynı App Store description (kısaltılmış versiyon) |
| **Email** | support@nuveli.app |
| **Privacy Policy URL** | https://nuveli.app/privacy |

#### Test Account (Reviewer için)
```
Username: reviewer@nuveli.app
Password: ReviewPass2026!
```

5. **Save** → Apple Beta App Review başlar
6. Bekleme: **24-48 saat** (genelde 12-24 saat)

### External Tester Ekleme

Review onaylandıktan sonra:

#### Yöntem 1: Email ile davet
- Tek tek email ekle (max 10,000)

#### Yöntem 2: Public Link (önerilen)
- Group sayfasında: **Enable Public Link**
- Link örneği: `https://testflight.apple.com/join/AbCdEfGh`
- Bu linki sosyal medya, blog, email'lerde paylaş
- **10,000 tester limit** (Apple max)
- Tester sayısı limit'i kendi belirleyebilirsin

#### Beta Recruitment Strategy
Pre-launch tester toplama:
- Twitter announce: "Looking for 100 beta testers for Nuveli — AI calorie coach"
- Reddit r/AppHookup, r/iOSBeta
- Indie Hackers, Product Hunt
- Email waitlist (varsa)

---

## 📊 Adım 5: Beta Test İşletim

### Sürüm Güncellemesi
Beta sırasında yeni build upload'larında:
1. Build number artır (`flutter build ipa --build-number=2`)
2. Upload (Transporter)
3. Processing (~10 dk)
4. App Store Connect'te yeni build görünür
5. Internal group otomatik son build'i alır
6. External group: yeni build için **Submit for Beta Review** (genelde minor changes hızlı geçer)

### Test Süresi
Apple TestFlight build'lerinin **90 gün geçerlilik** süresi var. 90 gün sonra **expired** olur, kullanıcılar download edemez. Yeni build upload ile sıfırlanır.

---

## 🐛 Adım 6: Yaygın Sorunlar

### "Could not install Nuveli"
- TestFlight app outdated → güncelle
- iOS version uyumsuz (min iOS 14)
- Storage yetersiz

### "This beta has expired"
- 90 gün geçti → yeni build upload et

### "Provisioning profile error" (upload sırasında)
- Xcode → Settings → Accounts → "Download Manual Profiles"
- Xcode → Signing & Capabilities → "Automatically manage signing" ✅

### "Missing compliance" (TestFlight'ta build yok)
- Export compliance soru cevaplanmadı
- Info.plist'te `ITSAppUsesNonExemptEncryption: false` set et

### "App rejected from Beta Review"
- Test Info eksik
- Test account çalışmıyor
- Privacy Policy URL erişilemez
- Test edilebilir özellik yok → spesifik test instruction yaz

---

## ✅ Adım 7: Production'a Geçiş

External beta 1-2 hafta çalıştıktan sonra:

### Checklist
- [ ] Beta'da en az 50 tester aktif
- [ ] Crash rate < %1
- [ ] Kritik bug yok
- [ ] AI meal scan başarı oranı > %85
- [ ] Premium purchase test edildi (Sandbox)
- [ ] Account deletion test edildi
- [ ] Push notifications çalışıyor
- [ ] Feedback'in çoğu olumlu

### Submit for App Review

1. **App Store** sekmesine git (TestFlight değil)
2. **Add for Review** → submit
3. Apple final review (1-3 gün)
4. Approve → Manual Release for launch day

---

## 🎯 Beta Test Goalleri

### Quantitative
- 100+ active beta testers
- 90%+ crash-free sessions
- 80%+ session completion rate
- Premium conversion 5%+ (sandbox)

### Qualitative
- AI meal scan accuracy feedback
- Onboarding flow clarity
- Premium value perception
- Notification timing
- UI/UX glitches

---

## 📋 Beta Tester Onboarding Email Template

```
Subject: Welcome to Nuveli Beta! 🌊

Hi [Name],

Thanks for joining the Nuveli beta!

📥 INSTALL
1. Download TestFlight: https://apps.apple.com/us/app/testflight
2. Tap this link from your iPhone: [TestFlight Public Link]
3. Tap "Accept" then "Install"

🧪 WHAT TO TEST
- AI meal scanning (try real meals + library photos)
- Daily AI Coach insights (check every morning)
- Premium subscription (sandbox - won't charge you)
- Water tracker reminders
- Account deletion flow

💬 SHARE FEEDBACK
- In TestFlight app: "Send Beta Feedback"
- Or email: beta@nuveli.app
- Twitter: @nuveli_app

🎁 PERK
All beta testers get 3 months free Premium when we launch publicly!

Build expires every 90 days. We'll send a fresh build before then.

Thanks for helping shape Nuveli! 🚀

— Ali, Founder
```

---

## ✅ Final Checklist

- [ ] First build uploaded successfully
- [ ] Build processing complete (no errors)
- [ ] Export compliance answered
- [ ] Internal testing group created
- [ ] First internal testers added (you + close friends)
- [ ] Build distributed to internal group
- [ ] Test on real device confirmed (no crash)
- [ ] External testing group created
- [ ] Test Info filled (test account, what to test)
- [ ] Beta App Review submitted
- [ ] Public link generated
- [ ] Recruitment plan ready (Twitter, Reddit, etc.)
- [ ] Feedback collection workflow ready (Notion, Linear, etc.)

---

**Tip:** İlk build'de tüm setup'ı bitir. Sonraki build'ler 5 dakikalık iş (upload → auto-distribute).
