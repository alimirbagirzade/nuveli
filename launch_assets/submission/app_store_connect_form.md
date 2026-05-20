# 📋 App Store Connect — Form Doldurma Rehberi

**Hedef:** App Store Connect'te yapacağın her form alanı için **alan alan** ne yazacağın belli olsun.

**URL:** https://appstoreconnect.apple.com

---

## 📋 1. App Oluşturma

### My Apps → "+" → New App

| Alan | Değer |
|---|---|
| **Platforms** | iOS |
| **App Name** | `Nuveli — AI Calorie Coach` |
| **Primary Language** | English (U.S.) |
| **Bundle ID** | `com.nuveli.app` (Identifier'da kayıtlı olmalı, dropdown'dan seç) |
| **SKU** | `nuveli-ios-001` |
| **User Access** | Full Access |

**Create** → boş app şablonu oluşur.

---

## 📋 2. App Information

### General Information

| Alan | Değer |
|---|---|
| **Bundle ID** | `com.nuveli.app` |
| **Apple ID** | (otomatik atanır, not al) |
| **SKU** | `nuveli-ios-001` |
| **Primary Language** | English (U.S.) |
| **Privacy Policy URL** | `https://nuveli.app/privacy` |
| **Subscription Privacy Policy URL** | `https://nuveli.app/privacy` (subscription için ayrıca isterse) |
| **Content Rights Information** | "Does NOT contain third-party content" |
| **Age Rating** | (questionnaire ile belirlenecek, aşağıda) |

### Localizable Information (English)

| Alan | Değer |
|---|---|
| **Subtitle** | `Track meals with AI vision` |
| **Privacy Policy URL** | `https://nuveli.app/privacy` |
| **Marketing URL** | `https://nuveli.app` (opsiyonel ama önerilen) |
| **Support URL** | `https://nuveli.app/support` |

### Localizable Information (Turkish)

| Alan | Değer |
|---|---|
| **Subtitle** | `AI ile akıllı kalori takibi` |
| **Privacy Policy URL** | `https://nuveli.app/privacy/tr` |
| **Marketing URL** | `https://nuveli.app/tr` |
| **Support URL** | `https://nuveli.app/destek` |

---

## 📋 3. Pricing and Availability

### Price Schedule
| Alan | Değer |
|---|---|
| **Price** | Free (with In-App Purchases) |
| **Tier** | Free |

### Availability
| Alan | Değer |
|---|---|
| **Available in** | All countries and regions ✅ |

⚠️ **İhtiyatlı launch istiyorsan:** Sadece TR + US + EU ülkeleri seç (legal/support yükü daha az). v1.1'de global aç.

### Pre-Orders
| Alan | Değer |
|---|---|
| **Pre-Orders** | Off (önerilen — küçük app için pre-order pek değer üretmez) |

---

## 📋 4. App Privacy (CRITICAL)

App Privacy sekmesinde **Data Collection** form'unu doldur.

**Detaylı rehber:** `launch_assets/legal/apple_privacy_label.md`

Özetle:
- **Data Collection:** Yes
- 11 data type seç (Contact Info, Health, Identifiers, Usage, Diagnostics, Purchases, User Content)
- **Used for Tracking:** No (kritik!)

---

## 📋 5. Age Rating

**Apple Questionnaire** doldur:

| Soru | Cevap |
|---|---|
| Cartoon/Fantasy Violence | None |
| Realistic Violence | None |
| Sexual Content | None |
| Profanity | None |
| Alcohol/Tobacco/Drug | None |
| Mature/Suggestive | None |
| Simulated Gambling | None |
| Horror | None |
| Prolonged Graphic Violence | None |
| **Medical/Treatment Information** | **Infrequent/Mild** ⚠️ |
| Unrestricted Web Access | None |
| Gambling/Contests | None |

**Sonuç:** Age Rating **4+**

---

## 📋 6. Version Information (Version 1.0)

### Version Number
```
1.0.0
```

### What's New in This Version (English)
```
👋 Welcome to Nuveli — your AI calorie coach!

This is our launch version with everything you need to start tracking smarter:

📸 AI Meal Scanner — snap a photo, get calories instantly
🧠 Personal AI Coach — daily nutrition insights tailored to you
📊 Beautiful Analytics — track weight, calories, macros
💧 Water Tracker — smart hydration reminders
🍴 Meal Planner — weekly plans + grocery lists
✅ Habits — build streaks for breakfast, water, protein, sleep
🏆 Achievements — earn badges as you progress

Premium unlocks unlimited AI coaching, full history, AI meal plans, and Apple Health sync.

We're a small team. Your feedback shapes Nuveli — write us at hello@nuveli.app.

Start your healthier journey today! 🌱
```

### What's New (Turkish)
```
👋 Nuveli'ye hoş geldiniz — AI kalori koçunuz!

Bu launch sürümümüzde, daha akıllı takibe başlamanız için ihtiyacınız olan her şey var:

📸 AI Yemek Tarayıcı — fotoğraf çek, kaloriyi anında öğren
🧠 Kişisel AI Koç — sana özel günlük beslenme önerileri
📊 Şık Analitik — kilo, kalori, makro takibi
💧 Su Takibi — akıllı hidrasyon hatırlatıcıları
🍴 Yemek Planlayıcı — haftalık plan + alışveriş listesi
✅ Alışkanlıklar — kahvaltı, su, protein, uyku streak'leri
🏆 Başarılar — ilerledikçe rozet kazan

Premium üyelik sınırsız AI koçluk, tüm zamanlı geçmiş, AI yemek planı ve Apple Health senkronu sağlar.

Biz küçük bir ekibiz. Geri bildirimleriniz Nuveli'yi şekillendiriyor — hello@nuveli.app adresinden yazın.

Sağlıklı yolculuğunuza bugün başlayın! 🌱
```

### Description (English)
**Konum:** Version → English (U.S.) → Description
**Kopyala:** `launch_assets/metadata/app_description_en.md` dosyasındaki tam metin

### Description (Turkish)
**Konum:** Version → Turkish (Türkiye) → Description  
**Kopyala:** `launch_assets/metadata/app_description_tr.md` dosyasındaki tam metin

### Keywords

**English:**
```
calorie,counter,nutrition,diet,weight,loss,tracker,food,ai,scanner,meal,health,fitness,water
```

**Turkish:**
```
kalori,sayaci,beslenme,diyet,kilo,verme,takip,yemek,ai,tarayici,ogun,saglik,fitness,su,koc
```

### Promotional Text

**English:**
```
New: AI Coach v2 provides personalized weekly meal plans! Snap meals, track macros, reach your goals. Try 7 days free.
```

**Turkish:**
```
Yeni: AI Koç v2 kişisel haftalık öğün planları sunar! Yemekleri tara, makroları takip et, hedeflerine ulaş. 7 gün ücretsiz dene.
```

### App Category

| Alan | Değer |
|---|---|
| **Primary** | Health & Fitness |
| **Secondary** | Lifestyle |

### Copyright
```
2026 Nuveli (Ali Mirbağırzade)
```

### Routing App Coverage File
**Not applicable** (transportation app değiliz)

### Trade Representative Contact Information (Korea için)
Sadece Korea'da yayınlanacaksa zorunlu. Eğer launch'ta Korea seçmediysek → boş bırak.

---

## 📋 7. Build Selection (TestFlight'tan)

App'i upload ettikten sonra (Xcode veya Transporter ile):

1. **TestFlight** sekmesi → upload edilen build görünür
2. Build'i seç → **Submit for Beta App Review** (eğer external testing için)
3. **App Store** sekmesine dön → **Build** alanına git → **Select Build**
4. TestFlight'taki son build'i seç

**Encryption export compliance (eğer ilk uploadlamadıysan):**
- "Does your app use encryption?" → Yes (HTTPS kullanıyoruz)
- "Does it qualify for any exemptions?" → Yes
- Exemption: "Your app uses, accesses, contains, implements, or incorporates encryption that is exempted from..."
- Info.plist'te `ITSAppUsesNonExemptEncryption: false` zaten set ✅

---

## 📋 8. Screenshots Upload

### Path: Version → [Localization] → App Preview and Screenshots

**iPhone (6.5"):**
- 6 screenshot upload (sıra önemli!)
- 1284 × 2778 px

**iPhone (5.5"):**
- 6 screenshot upload
- 1242 × 2208 px

⚠️ **5.5" yoksa 6.5"'lar otomatik scale edilmez.** Apple ayrıca ister.

**Apple Order:**
1. `01_dashboard_en.png`
2. `02_scan_en.png`
3. `03_analytics_en.png`
4. `04_coach_en.png`
5. `05_water_en.png`
6. `06_premium_en.png`

**App Preview Video (opsiyonel):**
- 30 saniye max
- En üstte (#1 pozisyonda) gösterilir
- Detay: `launch_assets/promo_video/PROMO_VIDEO_SPEC.md`

---

## 📋 9. App Review Information

### Sign-In Required
**Yes** — Sign-in zorunlu

### Test Account
```
Username: reviewer@nuveli.app
Password: ReviewPass2026!
```

⚠️ **ÖNEMLİ:** Bu hesap **gerçekten oluşturulmalı** ve **Premium olarak işaretlenmeli**. Aşağıda detay.

### Contact Information
| Alan | Değer |
|---|---|
| **First Name** | Ali |
| **Last Name** | Mirbağırzade |
| **Phone Number** | +90 XXX XXX XX XX (gerçek bir telefon) |
| **Email** | support@nuveli.app |

### Notes (Reviewer için açıklamalar)
```
Hello Apple Review Team,

Thank you for reviewing Nuveli! Here are some notes to help with testing:

OVERVIEW:
Nuveli is an AI-powered nutrition tracking app that uses computer vision (OpenAI GPT-4 Vision) to analyze meal photos and calculate calories/macros automatically.

TEST ACCOUNT:
Email: reviewer@nuveli.app
Password: ReviewPass2026!

This account has:
- Premium subscription enabled (sandbox)
- Onboarding completed
- 7 days of sample meal/water/weight data
- Apple Health integration disabled (can be enabled to test)

TESTING THE AI MEAL SCAN:
1. Open the app and sign in with the credentials above
2. Tap the camera icon in the bottom navigation
3. You can either:
   a) Take a photo of any meal (real or printed image)
   b) Select from photo library (we've pre-loaded a sample image)
4. Wait 3-5 seconds for AI analysis
5. Confirm or edit detected foods, then "Save"

TESTING PREMIUM:
- The test account already has Premium activated
- To test the purchase flow without committing:
  1. Sign out of the test account
  2. Create a new account with any email
  3. Settings → Premium → Try Free → use Sandbox tester
- Subscription details are disclosed on the paywall ("Cancel anytime", price, auto-renewal)

ACCOUNT DELETION:
- Tap Settings → Account → Delete Account
- Verification flow is required (type "DELETE")
- Data is permanently removed within 30 days

HEALTH DATA:
- Apple Health integration is optional and Premium-gated
- We collect: weight, body metrics, meals, water, habits
- We do NOT collect: location, contacts, browsing history
- All data is encrypted in transit (TLS 1.3) and at rest (AES-256)
- Stored on Supabase Postgres in Frankfurt, EU
- Meal photos are sent to OpenAI for analysis (per their API policy, not used for training)

PRIVACY:
Full privacy policy: https://nuveli.app/privacy

SUBSCRIPTIONS:
- Monthly: $9.99
- Annual: $59.99 (save 50%)
- Lifetime: $149.99
- 7-day free trial for Monthly and Annual

Auto-renewal disclosed in paywall and Settings → Premium.
Cancellation possible via App Store Settings (we link to it).

If you encounter any issues, please contact me at:
- Email: support@nuveli.app
- Phone: +90 XXX XXX XX XX

Thank you,
Ali Mirbağırzade
Founder, Nuveli
```

### Attachment (optional)
- Demo meal images (PDF veya zip)
- App walkthrough video (eğer karmaşık özellik varsa)

---

## 📋 10. In-App Purchases

### Adım 1: Create Subscription Group
- App Store Connect → App → In-App Purchases → Subscriptions → **+**
- Group Name: `nuveli_premium_group`
- Reference Name: `Nuveli Premium Subscriptions`

### Adım 2: Subscriptions Oluştur

#### Subscription 1: Monthly
| Alan | Değer |
|---|---|
| **Reference Name** | Nuveli Premium Monthly |
| **Product ID** | `com.nuveli.app.premium.monthly` |
| **Subscription Duration** | 1 month |
| **Price (US)** | $9.99 |
| **Free Trial** | 7 days |
| **Display Name (EN)** | Premium Monthly |
| **Display Name (TR)** | Premium Aylık |
| **Description (EN)** | Unlock all premium features |
| **Description (TR)** | Tüm premium özelliklerin kilidini aç |
| **Review Screenshot** | Premium paywall screenshot upload |

#### Subscription 2: Annual
| Alan | Değer |
|---|---|
| **Reference Name** | Nuveli Premium Annual |
| **Product ID** | `com.nuveli.app.premium.annual` |
| **Subscription Duration** | 1 year |
| **Price (US)** | $59.99 |
| **Free Trial** | 7 days |
| **Display Name (EN)** | Premium Annual |
| **Display Name (TR)** | Premium Yıllık |

#### One-Time (Lifetime)
Apple **lifetime subscription'ı IAP olarak** (subscription değil, non-consumable) işler.

| Alan | Değer |
|---|---|
| **In-App Purchase Type** | Non-Consumable |
| **Reference Name** | Nuveli Lifetime |
| **Product ID** | `com.nuveli.app.premium.lifetime` |
| **Price (US)** | $149.99 |
| **Display Name (EN)** | Lifetime Access |
| **Display Name (TR)** | Ömür Boyu Erişim |
| **Description** | One-time purchase for permanent Premium access |

---

## 📋 11. Submit for Review

### Pre-Submit Checklist
- [ ] App Information eksiksiz
- [ ] App Privacy dolu (Data Collection + Tracking: No)
- [ ] Age Rating set (4+)
- [ ] Version info (description, keywords, what's new) dolu
- [ ] 6 screenshot upload (iPhone 6.5" + 5.5")
- [ ] Build seçildi (TestFlight'tan)
- [ ] App Review Information dolu (test account, notes)
- [ ] IAP'lar oluşturuldu + onaylandı
- [ ] Reviewer notes detaylı
- [ ] Demo veri test hesabında dolu

### Submit Adımı
1. Sağ üstte **Add for Review** butonu
2. Apple final inceleme yapar
3. **Submit for Review** ✅

### Submission Sonrası Statüler
```
Waiting for Review     (1-3 saat)
↓
In Review              (1-2 gün, bazen daha hızlı)
↓
[Approved | Rejected]
  ↓                ↓
Approved          Rejected → fix → Resubmit
  ↓
[Pending Developer Release | Auto-Release]
  ↓
Ready for Sale → 🎉 LIVE
```

---

## 📋 12. Manuel Release Stratejisi

**Auto-Release** vs **Manual Release**:
- ✅ **Manual** öneriyorum: Approve olduktan sonra `Release this Version` butonu ile yayınla
- Avantaj: PR/marketing'i hazır tut, sosyal medya post zamanlanmış olsun

**Manual Release Akışı:**
1. Apple "Approved" maili gönderir
2. App Store Connect → Version → Status: "Pending Developer Release"
3. Marketing hazırla:
   - Social media post (Twitter, IG)
   - Product Hunt launch (Pazartesi sabahı önerilir)
   - Email blast (waitlist varsa)
4. `Release this Version` butonu → 1-2 saat içinde Live

---

## 🚨 Yaygın Reject Sebepleri (Ek Detay)

`launch_assets/submission/reject_reasons.md`'de detaylı liste var. Hızlı özet:

| Reject Kodu | Önleme |
|---|---|
| 2.1 Bug | Pre-submission test |
| 3.1.1 IAP missing | Yukarıdaki IAP setup eksiksiz |
| 5.1.1(v) Account delete eksik | `account_delete_flow.md` implement edildi |
| 5.1.1(i) Permission strings boş | `Info.plist.md` dolu |
| 4.0 UI/UX | Onboarding test edildi, UX akıcı |
| 4.8 Sign in with Apple eksik | Apple Sign-In implement edildi |

---

## ✅ Final Checklist (Apple)

- [ ] App created in App Store Connect
- [ ] All metadata fields filled (EN + TR)
- [ ] Privacy Policy URL live and accessible
- [ ] Screenshots uploaded (6.5" + 5.5", both languages)
- [ ] Age Rating: 4+
- [ ] App Privacy form complete
- [ ] In-App Purchases created (Monthly, Annual, Lifetime)
- [ ] Build uploaded via Transporter
- [ ] Build selected in App Store version
- [ ] Test account works (premium active)
- [ ] Reviewer notes comprehensive
- [ ] Submit for Review ✅
