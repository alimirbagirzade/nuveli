# 📋 Google Play Console — Form Doldurma Rehberi

**Hedef:** Google Play Console'da yapacağın her form alanı için adım adım rehber.

**URL:** https://play.google.com/console

---

## 📋 1. App Oluşturma

### Create App

| Alan | Değer |
|---|---|
| **App name** | Nuveli — AI Calorie Coach |
| **Default language** | English (United States) – en-US |
| **App or game?** | App |
| **Free or paid?** | Free |
| **Declaration** | ✅ Acceptance of all developer agreements |

**Create app** →

---

## 📋 2. Set up your app (Dashboard)

Bu sayfada görev listesi var. Sırayla yapacağız:

### Görev 1: App access
- "All functionality is available without special access" ❌ (giriş gerektiriyor)
- ✅ **"All or some functionality is restricted"**
- Açıklama ekle:
```
Username: reviewer@nuveli.app
Password: ReviewPass2026!

Premium test account. Onboarding complete with 7 days sample data.
```

### Görev 2: Ads
**Does your app contain ads?** ❌ **No**

### Görev 3: Content rating
**Detay:** Aşağıda Section 7'de.

### Görev 4: Target audience
- Age groups: **18-24, 25-34, 35-54, 55+** (yetişkin)
- "Are children in your target audience?" → **No**

### Görev 5: News app
"Is this a news app?" → **No**

### Görev 6: COVID-19 tracking
"Does your app implement contact tracing or status sharing?" → **No**

### Görev 7: Data safety
**Detay:** Aşağıda Section 5'te (en uzun bölüm).

### Görev 8: Government apps
"Is this a government app?" → **No**

### Görev 9: Financial features
"Does your app contain financial features?" → **No**

### Görev 10: Health features
**✅ Yes** — Health & Fitness app
- Sub-question: "Does your app collect personal or sensitive health data?" → **Yes**
- "Do you measure/collect physiological data?" → No (we collect logged data, not sensor-derived)

---

## 📋 3. Store Listing

### Path: Grow → Store presence → Main store listing

#### App details

| Alan | Değer |
|---|---|
| **App name** (30 char) | `Nuveli — AI Calorie Coach` |
| **Short description** (80 char) | `AI-powered nutrition coach. Snap meals, track calories, reach your goals.` |
| **Full description** (4000 char) | Kopyala: `launch_assets/metadata/app_description_en.md` |

#### Graphics

| Alan | Boyut | Notlar |
|---|---|---|
| **App icon** | 512 × 512 | `launch_assets/icons/app_icon_512.png` |
| **Feature graphic** | 1024 × 500 | `launch_assets/feature_graphic/feature_graphic.png` |
| **Phone screenshots** | min 2, max 8 | `launch_assets/screenshots/android/phone/` |
| **7" Tablet screenshots** | opsiyonel | atla |
| **10" Tablet screenshots** | opsiyonel | atla |
| **Promo video** | YouTube URL | opsiyonel |

#### Categorization

| Alan | Değer |
|---|---|
| **App category** | Health & Fitness |
| **Tags** | Calorie Tracker, Nutrition, Diet, Lifestyle, Fitness |

#### Contact details

| Alan | Değer |
|---|---|
| **Email** | support@nuveli.app |
| **Phone** (opsiyonel) | +90 XXX XXX XX XX |
| **Website** | https://nuveli.app |

#### External marketing
**Allow Google to show your app to users in promotions outside Google Play?** → ✅ Yes (önerilen, free marketing)

---

## 📋 4. Custom store listing (Turkish)

Path: **Main store listing** → **Manage listings (+)** → **Turkish (tr-TR)**

| Alan | Değer |
|---|---|
| **App name** | Nuveli — AI Calorie Coach |
| **Short description** | `AI destekli beslenme koçu. Yemekleri tara, kalori takip et, hedefe ulaş.` |
| **Full description** | Kopyala: `launch_assets/metadata/app_description_tr.md` |

Diğer alanları İngilizce ile aynı bırak (görseller localize değil).

---

## 📋 5. Data Safety (CRITICAL — Google'ın Privacy Label'ı)

Path: **Policy → Data safety**

Bu Apple Privacy Label'ın eşdeğeri ama daha detaylı. ✅ Dikkat et.

### Step 1: Data collection and security

#### Does your app collect or share user data?
**✅ Yes**

#### Is all of the user data collected by your app encrypted in transit?
**✅ Yes** — HTTPS/TLS 1.3 kullanıyoruz

#### Do you provide a way for users to request that their data be deleted?
**✅ Yes** — In-app + email request

URL for data deletion: `https://nuveli.app/delete-account`

### Step 2: Data types (long form)

#### ✅ Personal info
**Email address**
- Collected? ✅ Yes
- Shared with third parties? ❌ No
- Required or optional? Required
- Purpose: Account management, App functionality
- User can request data deletion? Yes
- Is encrypted in transit? Yes

**Name**
- Collected? ✅ Yes
- Optional
- Purpose: Account management, Personalization

**User IDs**
- Collected? ✅ Yes
- Purpose: Account management, App functionality
- Encrypted: Yes

#### ✅ Health and fitness
**Health info**
- Collected? ✅ Yes
- Shared with third parties? ❌ No (3rd party API processing OpenAI ≠ "sharing" per Google definition)
- Required (for personalized coaching)
- Purpose: App functionality, Personalization, **Analytics**
- Encrypted: Yes
- User control: ✅ Delete in-app

**Fitness info**
- Collected? ✅ Yes (Premium: Apple Health/Health Connect sync)
- Optional
- Purpose: App functionality, Personalization

#### ✅ Financial info
**Purchase history**
- Collected? ✅ Yes
- Shared? ❌ No
- Required
- Purpose: App functionality (subscription management)

#### ✅ Photos and videos
**Photos**
- Collected? ✅ Yes (meal scan photos)
- Optional
- Purpose: App functionality, AI analysis

#### ✅ App activity
**App interactions**
- Collected? ✅ Yes (analytics)
- Optional
- Purpose: Analytics, App functionality
- Encrypted: Yes

#### ✅ App info and performance
**Crash logs**
- Collected? ✅ Yes (Firebase Crashlytics)
- Purpose: App functionality (bug fixing)

**Diagnostics**
- Collected? ✅ Yes
- Purpose: App functionality

#### ✅ Device or other IDs
**Device IDs**
- Collected? ✅ Yes (Firebase device ID)
- Purpose: Analytics
- Encrypted: Yes

### ❌ Toplamadığımız (Google'a "No" diyeceğimiz)
- Location (Precise / Approximate)
- Personal info: Address, Phone number, Race, Political, Sexual orientation, Religious belief
- Financial info: Credit card, Payment info, Other financial
- Messages (in-app messages, emails, SMS)
- Audio (voice, sound recordings)
- Files and docs
- Calendar
- Contacts
- App activity: In-app search history, Other actions
- Web browsing
- Other info: Other (we don't collect anything else)

### Step 3: Privacy policy

| Alan | Değer |
|---|---|
| **Privacy policy URL** | `https://nuveli.app/privacy` |

⚠️ Bu URL **canlı olmalı** ve **Privacy Policy içermeli**. Google bot doğrular.

---

## 📋 6. App content (Detailed)

Path: **Policy → App content**

### Privacy policy
URL: `https://nuveli.app/privacy`

### App access
"All or some functionality requires login" → reviewer credentials yukarıda

### Ads
No ads ✅

### Content rating
**IARC Questionnaire** doldur:

| Soru | Cevap |
|---|---|
| Violence | No |
| Sexuality | No |
| Language | No |
| Controlled substances (alcohol, drugs, tobacco) | No |
| User-generated content | No (community feature yok) |
| **Health data collection** | **Yes** ⚠️ |
| Location sharing | No |
| Digital purchases | Yes (IAP) |
| Gambling | No |
| Crude humor | No |
| Horror/Fear | No |

**Sonuç:** **Everyone (3+)** veya **Everyone (7+)**

### Target audience and content
- Age groups: 18+ (Health & Fitness için tipik)
- "Are children part of your target audience?" → **No**
- Designed for Families program → No

### News
No ✅

### COVID-19 contact tracing
No ✅

### Data safety
✅ (yukarıda dolduruldu)

### Government apps
No ✅

### Financial features
"Does your app provide financial services?" → No (sadece subscription billing, finansal hizmet değil)

### Health features
**✅ Yes** — Health-related claims

| Soru | Cevap |
|---|---|
| Does your app provide health information (e.g., calorie counting)? | **Yes** |
| Are these claims supported by clinical research? | No (we use USDA + OpenAI data; not clinical) |
| Does your app provide medical advice? | **No** ⚠️ — Önemli! |
| Does your app target people with specific health conditions? | No |

⚠️ **"Medical advice" → No** kritik. Eğer "Yes" dersek FDA-style regulation gerekir, app store dışı süreçler başlar.

### Sensitive permissions
**Permission justification** (kullandığımız her sensitive permission için):

#### CAMERA
**Use case:** AI meal photo scanning
**Justification:**
```
Nuveli uses the camera to capture meal photos. These photos are sent to our AI service (OpenAI GPT-4 Vision) for nutritional analysis. Without camera access, the core meal-scanning feature cannot function. Users can also manually input meals if they prefer not to use the camera.
```

#### POST_NOTIFICATIONS
**Use case:** Meal logging, hydration reminders
**Justification:**
```
Nuveli sends scheduled notifications to remind users about meal logging, water intake, and habit completion. All notifications are user-configurable via Settings.
```

#### READ_MEDIA_IMAGES
**Use case:** Select meal photo from gallery
**Justification:**
```
Users can optionally select a previously taken photo from their device gallery to log a meal. Access is limited to user-selected images via the system picker.
```

#### Health Connect permissions
**Use case:** Premium feature — sync weight/steps
**Justification:**
```
Premium subscribers can optionally connect with Health Connect to automatically sync weight, steps, and workout data for better personalized coaching. All health data sync is opt-in and can be revoked anytime.
```

---

## 📋 7. Pricing & distribution

### Countries / regions
✅ **All countries available** (önerilen)

⚠️ **Restrictive launch isteniyorsa:** TR + US + EU select et.

### Pricing
**Free** ✅

### Devices
- **Phone**: ✅ Yes
- **7" Tablet**: ✅ Yes (Flutter responsive)
- **10" Tablet**: ✅ Yes
- **Wear OS**: ❌ No
- **Android TV**: ❌ No
- **Chrome OS**: ✅ Yes (Flutter destekler)

### Distribution
**Programs:**
- Designed for Families: ❌ No
- Google Play Pass: ❌ No (subscription model'le çakışır)
- Wear OS app: ❌ No

---

## 📋 8. App releases

### Release tracks (önerilen sıralama)
1. **Internal testing** (ilk önce — kendi cihazlarda)
2. **Closed testing** (Alpha — 100 tester)
3. **Open testing** (Beta — public, opt-in)
4. **Production** (Live)

### Adım 1: Internal Testing

Path: **Release → Testing → Internal testing**

**Create new release:**
- Upload AAB: `build/app/outputs/bundle/release/app-release.aab`
- Release name: `1.0.0 (1)`
- Release notes (EN):
```
Welcome to Nuveli — internal test build!

📸 AI Meal Scanner
🧠 Personal AI Coach
📊 Analytics
💧 Water Tracker
🍴 Meal Planner
✅ Habits
🏆 Achievements

Premium: AI insights, full history, Health Connect sync.
```

**Add testers:**
- Email list: ali@nuveli.app, etc.
- Or: Google Group

**Save → Review release → Start rollout to internal testing**

Bekleme: ~1-2 saat sonra testers'a email gelir.

### Adım 2: Closed Testing (Alpha)

Internal'da hata çıkmadıysa → Alpha track.
- 50-100 tester
- Daha geniş kapsam testi
- 24-48 saat review (Google daha hızlı oluyor)

### Adım 3: Open Testing (Beta)

Public opt-in, internet üzerinden link paylaşılabilir.

### Adım 4: Production

**Create production release:**
- Aynı AAB veya yeni build (production-only)
- Release notes (final, kopyala: `release_notes_v1.0.md`)
- **Staged rollout:** %20'den başla → 48 saat sonra %50 → 1 hafta sonra %100

**Save → Review → Start rollout to production**

Bekleme:
- İlk submission: 3-7 gün (manuel review)
- Sonraki updates: 1-3 saat (otomatik)

---

## 📋 9. App Bundle Settings

Path: **Release → Setup → App integrity**

### Play App Signing
**Use Google Play App Signing** ✅ (önerilen)

İlk upload'da Google soracak:
- "Let Google manage your app signing key" → **Yes**
- Upload key (your keystore) Google'a gönderilir
- Google ayrı bir app signing key üretir

SHA-1 fingerprint'leri burada görünür → Firebase'e gir.

### Internal app sharing
**Enable** — TestFlight'ın eşdeğeri, hızlı dağıtım

---

## 📋 10. In-App Products (IAP)

Path: **Monetize → Products → Subscriptions**

### Create Subscription Plan

#### Subscription 1: Monthly
| Alan | Değer |
|---|---|
| **Subscription ID** | `premium_monthly` |
| **Name** | Nuveli Premium Monthly |
| **Description (EN)** | Unlock all premium features. Cancel anytime. |
| **Description (TR)** | Tüm premium özelliklerin kilidini aç. İstediğin zaman iptal et. |
| **Base plan** | Auto-renewing, 1 month |
| **Price (USD)** | $9.99 |
| **Free trial offer** | 7 days |

#### Subscription 2: Annual
| Alan | Değer |
|---|---|
| **Subscription ID** | `premium_annual` |
| **Name** | Nuveli Premium Annual |
| **Base plan** | Auto-renewing, 1 year |
| **Price** | $59.99 |
| **Free trial** | 7 days |

### Create One-Time Product (Lifetime)
Path: **Monetize → Products → In-app products**

| Alan | Değer |
|---|---|
| **Product ID** | `premium_lifetime` |
| **Name** | Nuveli Lifetime Access |
| **Description** | One-time purchase. Premium forever. |
| **Price** | $149.99 |
| **Product type** | Managed product (one-time purchase) |

### Activate Subscriptions
Her subscription için **Activate** butonu → app'te kullanıma açılır.

---

## 📋 11. Pre-launch Report

Google Play Pre-launch Report (otomatik):
- AAB upload sonrası Google sanal cihazlarda test eder
- Crash report, accessibility, performance
- ~30 dakika sonra rapor hazır

Path: **Release → Testing → Pre-launch report**

⚠️ **Errors düzelt:**
- Common: ANR (Application Not Responding) → background work optimize et
- Crash on startup → release config kontrolü
- Accessibility issues → screen reader test

---

## 📋 12. Submission Checklist

### Pre-submission
- [ ] All sections "Completed" (yeşil tik)
- [ ] Data safety form approved
- [ ] Content rating finalized
- [ ] App content questions answered
- [ ] Store listing complete (EN + TR)
- [ ] Privacy Policy URL live
- [ ] AAB uploaded (production track)
- [ ] Internal test passed (no crash)
- [ ] Pre-launch report green
- [ ] IAP products active
- [ ] Reviewer credentials documented
- [ ] Sensitive permission justifications written

### Submit
- Production release → **Review release** → **Start rollout to production**
- Staged rollout: Start with 20%

### Wait
- First submission: 3-7 days
- Updates: 1-3 hours

---

## 🚨 Yaygın Google Play Reject Sebepleri

`launch_assets/submission/reject_reasons.md`'de detaylı liste. Hızlı özet:

| Reason | Çözüm |
|---|---|
| Permission policy violation | Permission justification ekle |
| Data safety form incomplete | Tüm data types doldur |
| Target SDK too old | targetSdk = 34 |
| Account deletion missing | In-app delete flow var ✅ |
| Misleading content | Screenshot/description gerçekçi ✅ |
| In-app billing policy | Cancel anytime, price disclosure ✅ |
| Health claims unsubstantiated | "Not medical advice" disclaimer ✅ |

---

## ✅ Final Checklist (Google Play)

- [ ] App created in Play Console
- [ ] Store listing complete (icon, feature graphic, screenshots)
- [ ] Short + Full description (EN + TR)
- [ ] Privacy Policy URL accessible
- [ ] Data Safety form complete
- [ ] Content rating: Everyone
- [ ] Sensitive permissions justified
- [ ] Health features declared (not medical advice)
- [ ] Target audience: 18+
- [ ] AAB uploaded (signed with release keystore)
- [ ] Play App Signing enabled
- [ ] Internal testing passed
- [ ] Pre-launch report: no critical issues
- [ ] IAP subscriptions + lifetime product active
- [ ] Production release reviewed
- [ ] Start rollout ✅
