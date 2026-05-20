# ✅ Final Pre-Submit Checklist

**Hedef:** Submit butonuna basmadan önce **HER ŞEYİN** kontrolü.

Bu listenin tüm kutucukları işaretlenmediyse → **submit etme.**

---

## 🎨 1. App Assets

### Icons
- [ ] iOS icon 1024×1024 PNG (no alpha)
- [ ] Android adaptive icon (foreground + background)
- [ ] Notification icon (white + alpha)
- [ ] flutter_launcher_icons çalıştırıldı
- [ ] iOS Settings → app icon görünüyor
- [ ] Android home screen → adaptive icon görünüyor
- [ ] Android settings → app icon görünüyor

### Splash Screen
- [ ] Splash logo asset hazır
- [ ] flutter_native_splash:create çalıştırıldı
- [ ] iOS splash → 3 cihaz boyutunda test
- [ ] Android 12+ splash test edildi
- [ ] Splash → onboarding/login transition smooth

### Screenshots
- [ ] iPhone 6.5" (1284×2778) — 6 screenshot EN
- [ ] iPhone 6.5" — 6 screenshot TR
- [ ] iPhone 5.5" (1242×2208) — 6 screenshot EN
- [ ] iPhone 5.5" — 6 screenshot TR
- [ ] Android phone (1080×1920) — 6 screenshot EN
- [ ] Android phone — 6 screenshot TR
- [ ] Tüm screenshot'larda app içeriği gerçekçi
- [ ] Yazılar typo'suz (özellikle TR'de Türkçe karakterler)
- [ ] Hassas/kişisel bilgi yok (demo data)

### Other
- [ ] Feature graphic Android (1024×500)
- [ ] Promo video (opsiyonel, 30s)
- [ ] Tüm asset'ler PNG (JPG değil, kalite kaybı için)

---

## 📝 2. Store Metadata

### App Store Connect
- [ ] App name: `Nuveli — AI Calorie Coach` (25 char ✅)
- [ ] Subtitle EN: `Track meals with AI vision` (24 char)
- [ ] Subtitle TR: `AI ile akıllı kalori takibi` (27 char)
- [ ] Description EN dolu (~2150 char)
- [ ] Description TR dolu (~2180 char)
- [ ] Keywords EN (94 char ≤ 100)
- [ ] Keywords TR (97 char ≤ 100)
- [ ] Promotional text EN dolu
- [ ] Promotional text TR dolu
- [ ] What's New EN dolu
- [ ] What's New TR dolu
- [ ] Primary Category: Health & Fitness
- [ ] Secondary Category: Lifestyle
- [ ] Copyright: `2026 Nuveli (Ali Mirbağırzade)`
- [ ] Marketing URL: https://nuveli.app
- [ ] Support URL: https://nuveli.app/support
- [ ] Privacy Policy URL: https://nuveli.app/privacy

### Google Play Console
- [ ] App title (30 char ≤ 30)
- [ ] Short description EN (73 char ≤ 80)
- [ ] Short description TR (72 char ≤ 80)
- [ ] Full description EN
- [ ] Full description TR
- [ ] Category: Health & Fitness
- [ ] Tags: Calorie Tracker, Nutrition, Diet, Lifestyle, Fitness
- [ ] Contact: support@nuveli.app
- [ ] Website: https://nuveli.app
- [ ] Privacy Policy: https://nuveli.app/privacy

---

## 🔒 3. Privacy & Legal

### Privacy Policy
- [ ] `https://nuveli.app/privacy` canlı ve erişilebilir
- [ ] EN versiyon yayında
- [ ] TR versiyon yayında (`/privacy/tr`)
- [ ] GDPR uyumlu
- [ ] CCPA uyumlu
- [ ] KVKK uyumlu
- [ ] OpenAI data flow disclosed
- [ ] Third-party tablosu doğru
- [ ] Contact: privacy@nuveli.app aktif

### Terms of Service
- [ ] `https://nuveli.app/terms` canlı
- [ ] EN ve TR versiyonlar
- [ ] Subscription terms açık
- [ ] AI medical disclaimer var
- [ ] Refund policy belirtilmiş
- [ ] Turkey jurisdiction belirtilmiş

### Apple Privacy Label
- [ ] App Privacy form complete
- [ ] 11 data type doğru işaretlendi
- [ ] **"Used to Track You" = NO** (kritik!)
- [ ] Privacy Policy URL girildi

### Google Data Safety
- [ ] Data Safety form complete
- [ ] Tüm data types declare edildi
- [ ] Encryption in transit: Yes
- [ ] Data deletion mechanism: Yes
- [ ] URL: https://nuveli.app/delete-account

### Account Deletion
- [ ] In-app delete flow implement edildi
- [ ] Settings → Account → Delete butonu çalışıyor
- [ ] "DELETE" type confirmation var
- [ ] Active subscription warning gösteriliyor
- [ ] Backend `/account/me` DELETE endpoint çalışıyor
- [ ] 30-day cleanup cron job kurulu

---

## 🏗️ 4. Build Configuration

### iOS Build
- [ ] Bundle ID: `com.nuveli.app`
- [ ] Version: 1.0.0
- [ ] Build number: 1 (unique)
- [ ] Info.plist tüm permission strings dolu
- [ ] ITSAppUsesNonExemptEncryption: false
- [ ] NSAppTransportSecurity: strict HTTPS
- [ ] PrivacyInfo.xcprivacy dosyası eklendi (iOS 17+ zorunlu)
- [ ] Xcode capabilities:
  - [ ] Sign in with Apple
  - [ ] HealthKit
  - [ ] Push Notifications
  - [ ] Background Modes
  - [ ] Associated Domains (applinks:nuveli.app)
  - [ ] In-App Purchase
- [ ] Production provisioning profile geçerli
- [ ] Code signing automatic
- [ ] IPA build başarılı (`build/ios/ipa/Nuveli.ipa`)
- [ ] IPA boyutu < 200 MB

### Android Build
- [ ] Application ID: `com.nuveli.app`
- [ ] Version code: 1
- [ ] Version name: 1.0.0
- [ ] targetSdk: 34
- [ ] minSdk: 23
- [ ] AndroidManifest tüm permissions doğru
- [ ] network_security_config.xml HTTPS-only
- [ ] Keystore oluşturuldu ve yedeklendi (3 yere)
- [ ] keystore.properties .gitignore'da
- [ ] SHA-1 + SHA-256 Play Console'a girildi
- [ ] SHA-1 Firebase'e girildi
- [ ] Multidex enabled
- [ ] Proguard rules (release shrinking)
- [ ] AAB build başarılı (`build/app/outputs/bundle/release/app-release.aab`)
- [ ] AAB boyutu < 200 MB
- [ ] Play App Signing aktif edilecek

### Common
- [ ] pubspec.yaml `version: 1.0.0+1`
- [ ] flutter analyze → 0 issue
- [ ] flutter test → all passed
- [ ] Production .env file mevcut
- [ ] Tüm API key'ler production değerleri
- [ ] Debug/staging endpoints çıkarıldı

---

## 🧪 5. Functional Testing

### Auth Flow
- [ ] Sign up email/password çalışıyor
- [ ] Sign in with Apple çalışıyor (iOS)
- [ ] Sign in with Google çalışıyor
- [ ] Password reset email gönderiliyor
- [ ] Logout çalışıyor
- [ ] Session persistence çalışıyor (app kapanıp açılınca login)

### Onboarding
- [ ] Onboarding screens akıcı
- [ ] Skip butonu çalışıyor (eğer varsa)
- [ ] Profile setup save ediyor
- [ ] Calorie target hesaplanıyor (BMR/TDEE)

### AI Meal Scan
- [ ] Camera permission rationale gösteriliyor
- [ ] Camera açılıyor
- [ ] Foto çekme çalışıyor
- [ ] Gallery'den seçme çalışıyor
- [ ] EXIF strip çalışıyor (önemli — privacy)
- [ ] OpenAI API çağrısı gidiyor
- [ ] Response 5-10 saniyede dönüyor
- [ ] Detected foods edit edilebiliyor
- [ ] Save → DB'ye yazılıyor

### Dashboard
- [ ] Today's calories doğru
- [ ] Macro breakdown doğru
- [ ] AI Insight gösteriliyor
- [ ] Recent meals listesi doğru
- [ ] Water tracker tap → +250ml
- [ ] Weight quick add çalışıyor

### Analytics
- [ ] Weekly chart doğru
- [ ] Macro distribution doğru
- [ ] Weight trend grafiği doğru
- [ ] Date picker çalışıyor

### AI Coach
- [ ] Daily insight üretiliyor
- [ ] OpenAI API'ye gidip dönüyor
- [ ] Geçmiş insight'lar listede

### Water Tracker
- [ ] Glass grid UI çalışıyor
- [ ] Tap → +250ml
- [ ] Daily target progress doğru
- [ ] Reminder notifications kurulu

### Habits
- [ ] Habit oluşturma çalışıyor
- [ ] Habit complete tap → streak artıyor
- [ ] Streak counter doğru
- [ ] Habit list reorder çalışıyor

### Premium
- [ ] Paywall gösteriliyor
- [ ] Pricing doğru (Apple/Google fiyatları)
- [ ] Subscription disclosure tam
- [ ] Free trial bilgisi var
- [ ] Purchase flow çalışıyor (Sandbox)
- [ ] Restore purchases çalışıyor
- [ ] Premium feature gating doğru

### Account Management
- [ ] Profile edit çalışıyor
- [ ] Export data çalışıyor
- [ ] Delete account flow çalışıyor
- [ ] Settings tüm options çalışıyor

### Notifications
- [ ] Permission rationale gösteriliyor
- [ ] Permission grant sonrası izin alınıyor
- [ ] Scheduled notifications gönderiliyor
- [ ] Push notifications (FCM) gelmeli
- [ ] Notification tap → deep link çalışıyor

### Deep Linking
- [ ] `nuveli://` scheme çalışıyor
- [ ] `https://nuveli.app/...` universal link çalışıyor
- [ ] Apple Sign-In callback çalışıyor

---

## 🎯 6. Real Device Testing

### iOS Devices (minimum)
- [ ] iPhone 15 Pro (latest)
- [ ] iPhone 12/13 (mid-range)
- [ ] iPhone SE (small screen, oldest supported)
- [ ] iOS 17.x test
- [ ] iOS 16.x test (min support)
- [ ] iPad (eğer destekleniyorsa)

### Android Devices (minimum)
- [ ] Pixel 7+ (Google reference)
- [ ] Samsung Galaxy (high market share)
- [ ] Xiaomi/Oppo (popular in TR market)
- [ ] Android 14 test
- [ ] Android 11 test (minimum supported)
- [ ] Tablet test (eğer destekleniyorsa)

### Performance
- [ ] Cold start < 2 saniye
- [ ] Dashboard render < 1 saniye
- [ ] Meal scan < 10 saniye end-to-end
- [ ] Frame rate 60fps (homescreen scroll)
- [ ] Memory leak yok (uzun kullanım sonrası)
- [ ] Battery drain normal

---

## 🌐 7. Backend & Infrastructure

### Production Backend
- [ ] Render.com production deployment canlı
- [ ] Domain bağlı (api.nuveli.app)
- [ ] HTTPS aktif
- [ ] Environment variables set:
  - [ ] SUPABASE_URL
  - [ ] SUPABASE_SERVICE_ROLE_KEY
  - [ ] OPENAI_API_KEY (production tier)
  - [ ] REVENUECAT_WEBHOOK_SECRET
  - [ ] SENTRY_DSN
- [ ] Health endpoint: `https://api.nuveli.app/health` → 200 OK
- [ ] Rate limiting aktif
- [ ] Logging configured (Sentry)
- [ ] Monitoring set (Render dashboard)

### Database (Supabase)
- [ ] Production project ayrı (staging ile karışmıyor)
- [ ] Tüm tablolar oluşturuldu
- [ ] RLS policies aktif
- [ ] Indexes oluşturuldu
- [ ] Backups otomatik (daily)
- [ ] Connection pooling aktif

### Storage
- [ ] Supabase Storage bucket: `meals`
- [ ] RLS policies aktif (kullanıcı sadece kendi fotosunu görsün)
- [ ] Auto-delete 90 days cron çalışıyor

### Third-party Services
- [ ] OpenAI production tier (not free trial)
- [ ] OpenAI rate limit yeterli
- [ ] RevenueCat production keys
- [ ] RevenueCat webhook → backend bağlı
- [ ] Firebase production project (debug != prod)
- [ ] Firebase Crashlytics aktif
- [ ] Sentry production DSN set

### IAP Configuration
- [ ] App Store Connect IAP products onaylandı:
  - [ ] com.nuveli.app.premium.monthly
  - [ ] com.nuveli.app.premium.annual
  - [ ] com.nuveli.app.premium.lifetime
- [ ] Play Console IAP products aktif:
  - [ ] premium_monthly
  - [ ] premium_annual
  - [ ] premium_lifetime
- [ ] RevenueCat'te products configure edildi
- [ ] Sandbox/Test purchases çalışıyor
- [ ] Webhook events backend'e geliyor

---

## 👤 8. Reviewer Account

- [ ] Email/password oluşturuldu: `reviewer@nuveli.app` / `ReviewPass2026!`
- [ ] Premium aktif (manual grant)
- [ ] 7 günlük sample data seed edildi:
  - [ ] Meals (25+ entry)
  - [ ] Water logs
  - [ ] Weight logs (5 entry)
  - [ ] Habits (5 habit + completions)
  - [ ] AI insight (bugün)
  - [ ] Meal plan (bu hafta)
- [ ] Manuel test edildi (cihazda login + dashboard kontrol)
- [ ] is_test_account flag set (analytics'i bozmasın)

---

## 📋 9. Submission Forms

### App Store Connect
- [ ] App Information complete
- [ ] Pricing and Availability set
- [ ] App Privacy form complete
- [ ] Age Rating set (4+)
- [ ] Version 1.0 info complete
- [ ] Screenshots uploaded (6.5" + 5.5")
- [ ] Build selected from TestFlight
- [ ] App Review Information complete:
  - [ ] Sign-in required: Yes
  - [ ] Test credentials provided
  - [ ] Contact info
  - [ ] Detailed reviewer notes
- [ ] IAP'lar attached
- [ ] Manual release seçildi (önerilen)

### Google Play Console
- [ ] Store listing complete (EN + TR)
- [ ] Data safety complete
- [ ] Content rating done
- [ ] Target audience set
- [ ] App content questions answered
- [ ] Sensitive permission justifications written
- [ ] Health features declared (not medical advice)
- [ ] AAB uploaded
- [ ] Play App Signing enabled
- [ ] Internal testing passed
- [ ] Pre-launch report green (no critical issues)
- [ ] Production release created
- [ ] Staged rollout 20% set

---

## 🚀 10. Marketing & Launch Prep

### Pre-Launch
- [ ] Landing page canlı (nuveli.app)
- [ ] Twitter handle aktif (@nuveli_app)
- [ ] Instagram handle (opsiyonel)
- [ ] Email waitlist hazır (Mailchimp/ConvertKit)
- [ ] Product Hunt draft (Pazartesi launch için)
- [ ] Press kit hazır:
  - [ ] High-res icons
  - [ ] Screenshots
  - [ ] Logo (SVG + PNG)
  - [ ] About paragraf
  - [ ] Contact info

### Launch Day Plan
- [ ] App approval geldiğinde sosyal medya posts hazır
- [ ] Email blast hazır (waitlist'e)
- [ ] Product Hunt submission tarihi (Salı-Çarşamba ideal)
- [ ] Friend network (early upvoters) hazır
- [ ] Customer support inbox aktif (support@nuveli.app)
- [ ] Quick response template'leri hazır

### Post-Launch
- [ ] Crash monitoring (Sentry alarmları)
- [ ] App Store reviews monitoring (App Reviews tool)
- [ ] User feedback channel (form, email, Twitter)
- [ ] Bug fix hotfix flow hazır (build number +1 → fast resubmit)

---

## ⚠️ KRİTİK SON KONTROLLER

Bu kontroller olmadan **submit yapma:**

- [ ] **Reviewer test account ÇALIŞIYOR** (cihazda kendin login ol, kontrol et)
- [ ] **Privacy Policy URL erişilebilir** (browser'da kontrol et: https://nuveli.app/privacy)
- [ ] **AI meal scan production API'sine bağlı** (sandbox/test backend değil)
- [ ] **Account deletion gerçekten siliyor** (test hesabıyla dene)
- [ ] **Premium purchase flow** test edildi
- [ ] **Push notifications** geliyor
- [ ] **App crash etmiyor** (cold start, normal kullanım)
- [ ] **Backend down değil** (https://api.nuveli.app/health → 200)
- [ ] **Build number unique** (önceki upload'lardan büyük)
- [ ] **Keystore yedekli** (Android için, 3 farklı yerde)

---

## 🎯 Submission Day Plan

### Sabah
1. ☕ Final coffee
2. ✅ Bu checklist'i tekrar bir kere oku
3. ✅ Tüm "[]" kutucuklar işaretli mi?

### Öğleden Önce
4. iOS submission → App Store Connect → "Submit for Review"
5. Android submission → Play Console → "Start rollout to Production"

### Öğleden Sonra
6. Submission confirmation email'lerini kontrol et
7. Backend monitoring aç (Sentry, Render dashboard)
8. İlk 24 saat hazır ol (acil hotfix gerekebilir)

### Akşam
9. 🍷 Bir şeyler iç, kendini kutla
10. Bekleme süresi başladı — Apple 24-72 saat, Google 3-7 gün

---

## 📞 Acil Durum

Submission sonrası bir şey patlamış mi:

- **Backend down** → Render dashboard, restart
- **DB issue** → Supabase logs
- **OpenAI rate limit** → upgrade tier
- **Crash spike** → Sentry alarm, prepare hotfix
- **Reject** → Resolution Center, respond within 24h

İletişim:
- Apple Developer Support: developer.apple.com/support
- Google Play Developer Support: support.google.com/googleplay/android-developer

---

**Eğer her şey hazırsa: 🚀 BAŞARILAR!**
