# Nuveli — Privacy Policy

**Effective Date:** May 18, 2026
**Last Updated:** May 18, 2026

**Live URL:** `https://nuveli.app/privacy`

---

## NOTLAR (Üst meta — yayın öncesi sil)

- Bu metin **Apple ve Google'ın zorunlu** Privacy Policy gereksinimlerini karşılar.
- TR versiyonu için: `https://nuveli.app/privacy/tr` (aynı metnin Türkçesi)
- **Yayın öncesi gözden geçir:**
  - [ ] `support@nuveli.app` aktif mi?
  - [ ] `privacy@nuveli.app` aktif mi? (DSAR talepleri için)
  - [ ] Şirket adı/adresi doğru mu?
  - [ ] EU server lokasyonu Supabase Frankfurt → ✅
- **Hukuki not:** Bu metin Anthropic'in AI sistemi tarafından üretilmiştir. Production'a çıkmadan önce **bir avukat tarafından gözden geçirilmesi önerilir** (özellikle Türkiye'de KVKK uyumu için).

---

## English Version

### 1. Introduction

Welcome to Nuveli ("we", "our", or "us"). We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use the Nuveli mobile application (the "App").

By using Nuveli, you agree to the practices described in this Privacy Policy.

**Contact:**
- Email: privacy@nuveli.app
- Developer: Ali Mirbagirzade (operating as Nuveli)
- Country: Turkey

---

### 2. Information We Collect

We collect the following categories of information:

#### 2.1 Account Information
When you create an account, we collect:
- Email address
- Name (optional)
- Authentication credentials (managed by Supabase Auth or Apple Sign-In)

#### 2.2 Health and Fitness Data
To provide personalized coaching, we collect:
- Body metrics: weight, height, age, sex, activity level
- Meal logs: food name, portion, calories, macros, photos (optional)
- Water intake records
- Habit completion data
- Steps and workouts (if synced from Apple Health/Google Fit, with your permission)

#### 2.3 Usage Data
We collect anonymized analytics about how you use the App:
- Screen views, button taps, feature usage
- App version, OS version, device model
- Crash reports (via Firebase Crashlytics)
- Approximate region (country-level, derived from IP — not stored as IP)

#### 2.4 Subscription Data
- Purchase history (managed by Apple/Google)
- Subscription status (active, trial, cancelled)
- Webhook events from RevenueCat

#### 2.5 What We DO NOT Collect
- Precise location (GPS)
- Browsing history outside the App
- Contacts, photos library (beyond meal scan uploads)
- Microphone audio
- Health data not related to nutrition (sleep stages, ECG, etc.)
- Advertising identifiers (IDFA, AAID)

---

### 3. How We Use Your Information

We use your data only for the following purposes:

| Purpose | Data Used |
|---|---|
| Provide core functionality (meal tracking, analytics) | Account, Health, Usage |
| AI-powered features (meal scanning, coaching) | Meal photos, health data (sent to OpenAI, see Section 5) |
| Personalize daily insights | Health data, usage patterns |
| Send notifications (reminders, achievements) | Account, preferences |
| Improve the App (analytics, crash reports) | Usage data (anonymized) |
| Manage subscriptions | Subscription data |
| Customer support | Email, account info |

**We do NOT:**
- Sell your data to third parties
- Use your data for advertising
- Share identifiable health data with anyone outside of the strictly necessary service providers listed in Section 5

---

### 4. Legal Basis (GDPR — EU Users)

If you are in the European Economic Area (EEA), our legal basis for processing your data is:

| Processing | Legal Basis |
|---|---|
| Account creation, app functionality | Contract (Art. 6(1)(b) GDPR) |
| AI features, personalization | Consent (Art. 6(1)(a) + Art. 9(2)(a) for health data) |
| Analytics (anonymized) | Legitimate interest (Art. 6(1)(f)) |
| Subscription billing | Contract |
| Legal compliance | Legal obligation (Art. 6(1)(c)) |

You can withdraw consent at any time. See Section 8 for your rights.

---

### 5. Third-Party Service Providers

We use the following providers to operate Nuveli. Each is bound by data processing agreements and limited to the data necessary for their function.

| Provider | Purpose | Data Shared | Location |
|---|---|---|---|
| **Supabase** | Database, authentication | Account, health, usage data | EU (Frankfurt) |
| **OpenAI** | AI meal analysis, coaching | Meal photos, anonymized nutrition data | USA |
| **Render.com** | Backend hosting (FastAPI) | All API request data | USA (Oregon) |
| **RevenueCat** | Subscription management | Apple/Google purchase tokens | USA |
| **Firebase (Google)** | Analytics, crash reporting, push | Anonymized usage, device ID | Global |
| **Apple / Google** | Payment, OS-level services | Subscription, device | Per Apple/Google policy |

**OpenAI Specific:**
- Meal photos are sent to OpenAI's GPT-4 Vision API for analysis
- OpenAI **does not retain** API request data for training purposes (per their [API Terms](https://openai.com/policies/api-data-usage-policies))
- Photos are **deleted from OpenAI's systems within 30 days** as per their data retention policy
- We strip all personally identifying metadata (EXIF) before sending

---

### 6. Data Storage and Security

#### 6.1 Where Your Data Lives
- **Primary database:** Supabase Postgres, hosted in **Frankfurt, EU**
- **Backend servers:** Render.com, hosted in **Oregon, USA**
- **Backups:** Encrypted daily backups, retained for 30 days

#### 6.2 Security Measures
- All data in transit: **TLS 1.3 encryption**
- All data at rest: **AES-256 encryption**
- Authentication: JWT tokens, 1-hour expiry
- Row-Level Security (RLS) policies in Supabase — users can only access their own data
- Service role keys stored in environment variables (never exposed to clients)
- Regular security audits

#### 6.3 Data Breach Notification
In the event of a data breach affecting your personal data, we will notify you via email and in-app notification within **72 hours** of detection, in compliance with GDPR Art. 33.

---

### 7. Data Retention

| Data Type | Retention Period |
|---|---|
| Account info | Until account deletion |
| Health logs | Until account deletion |
| Meal photos | 90 days, then auto-deleted |
| Usage analytics (anonymized) | 24 months |
| Subscription records | 7 years (legal/tax requirement) |
| Crash reports | 90 days |
| Customer support emails | 2 years |

**Account deletion:** Upon request, we delete all your personal data within **30 days**. Anonymized analytics may be retained longer.

---

### 8. Your Rights

Depending on your jurisdiction, you have the following rights:

| Right | How to Exercise |
|---|---|
| **Access** — see what we have on you | In-app: Settings → Privacy → Download My Data (CSV) |
| **Rectification** — correct inaccurate data | In-app: Settings → Profile → Edit |
| **Erasure** — delete your account and data | In-app: Settings → Account → Delete Account |
| **Restriction** — limit processing | Email privacy@nuveli.app |
| **Portability** — export your data | In-app: Settings → Privacy → Export (CSV/JSON) |
| **Object** — opt out of certain processing | Email privacy@nuveli.app |
| **Withdraw consent** | Settings → Privacy → Revoke (per service) |
| **Lodge a complaint** | Your local data protection authority |

**Response time:** We respond to all rights requests within **30 days** (GDPR requirement).

**Specific rights:**
- **California (CCPA):** You have the right to know, delete, and opt-out of "sale" of personal information. We do not sell your data — there is nothing to opt out of, but you can confirm this in writing.
- **Turkey (KVKK):** You have rights under Law No. 6698 (Personal Data Protection Law). Contact us at privacy@nuveli.app for KVKK-specific requests.

---

### 9. Children's Privacy

Nuveli is **not intended for users under 13 years of age** (COPPA) or **under 16 in the EU** (GDPR Article 8).

We do not knowingly collect data from children. If you believe a child has provided us with data, please contact privacy@nuveli.app immediately and we will delete it.

---

### 10. International Data Transfers

If you are located outside Turkey or the EU, your data may be transferred to and processed in countries with different privacy laws. We rely on:
- **Standard Contractual Clauses (SCCs)** for EU → USA transfers
- **Supplementary measures** (encryption, pseudonymization) as required by Schrems II
- **Adequacy decisions** where available

By using Nuveli, you consent to such transfers.

---

### 11. Marketing Communications

We may send you:
- **Transactional emails** (order confirmation, password reset) — you cannot opt out (required for service)
- **Product updates** (new features, improvements) — opt-in only
- **Promotional emails** (discounts, offers) — opt-in only

You can unsubscribe from marketing emails any time via the link at the bottom of each email or in Settings → Notifications.

---

### 12. Cookies and Tracking

Our mobile app does not use cookies. Our website (nuveli.app) uses minimal analytics cookies. See our [Cookie Policy](https://nuveli.app/cookies) for details.

We do **not** use:
- Advertising identifiers (IDFA, AAID)
- Third-party advertising trackers
- Cross-app tracking (App Tracking Transparency: we do not request permission because we don't track)

---

### 13. Changes to This Policy

We may update this Privacy Policy from time to time. When we do:
- We update the "Last Updated" date at the top
- For material changes, we notify you in-app and via email at least 30 days before they take effect
- Continued use of Nuveli after changes constitutes acceptance

---

### 14. Contact Us

**Privacy questions:** privacy@nuveli.app
**General support:** support@nuveli.app
**Data Protection Officer:** privacy@nuveli.app (acting DPO)
**Mailing address:** [To be provided based on legal entity setup]

**Response time:** 5 business days for general inquiries, 30 days for rights requests.

---

### 15. Jurisdiction

This Privacy Policy is governed by the laws of **Turkey**. Disputes will be resolved in the courts of Istanbul, Turkey, unless your local law gives you additional rights that cannot be waived.

---

**End of Privacy Policy (English)**

---

# Türkçe Versiyon

**Yürürlük Tarihi:** 18 Mayıs 2026
**Son Güncelleme:** 18 Mayıs 2026

## 1. Giriş

Nuveli'ye ("biz", "bizim") hoş geldiniz. Gizliliğinizi korumaya kararlıyız. Bu Gizlilik Politikası, Nuveli mobil uygulamasını ("Uygulama") kullanırken bilgilerinizi nasıl topladığımızı, kullandığımızı ve koruduğumuzu açıklar.

Nuveli'yi kullanarak bu Gizlilik Politikası'nda açıklanan uygulamaları kabul etmiş olursunuz.

**İletişim:**
- E-posta: privacy@nuveli.app
- Geliştirici: Ali Mirbağırzade (Nuveli olarak faaliyet gösteriyor)
- Ülke: Türkiye

## 2. Topladığımız Bilgiler

### 2.1 Hesap Bilgileri
- E-posta adresi
- İsim (opsiyonel)
- Kimlik doğrulama bilgileri (Supabase Auth veya Apple Sign-In tarafından yönetilir)

### 2.2 Sağlık ve Fitness Verileri
- Vücut metrikleri: kilo, boy, yaş, cinsiyet, aktivite seviyesi
- Öğün kayıtları: yemek adı, porsiyon, kalori, makrolar, fotoğraflar
- Su tüketim kayıtları
- Alışkanlık takibi
- Adım ve antrenmanlar (izninizle Apple Health/Google Fit'ten senkron)

### 2.3 Kullanım Verileri
- Ekran görüntüleme, buton tıklama, özellik kullanımı
- App sürümü, OS sürümü, cihaz modeli
- Çökme raporları (Firebase Crashlytics)
- Yaklaşık bölge (ülke seviyesi, IP'den türetilmiş — IP saklanmaz)

### 2.4 Abonelik Verileri
- Satın alma geçmişi (Apple/Google tarafından yönetilir)
- Abonelik durumu

### 2.5 Toplamadığımız Veriler
- Kesin konum (GPS)
- Uygulama dışı tarama geçmişi
- Rehber, fotoğraf galerisi (öğün fotoğrafları hariç)
- Mikrofon sesi
- Beslenme ile ilgisiz sağlık verileri (uyku evreleri, EKG, vb.)
- Reklam tanımlayıcıları (IDFA, AAID)

## 3. Verilerinizi Nasıl Kullanırız

Verilerinizi yalnızca aşağıdaki amaçlar için kullanırız:

- Temel işlevsellik (öğün takibi, analitik)
- AI özellikleri (yemek tarama, koçluk — fotoğraflar OpenAI'ya gönderilir)
- Kişiselleştirilmiş günlük öneriler
- Bildirimler (hatırlatıcılar, başarılar)
- Uygulama iyileştirme (anonim analitik)
- Abonelik yönetimi
- Müşteri desteği

**Yapmadıklarımız:**
- Verilerinizi üçüncü taraflara satmak
- Reklam için kullanmak
- Bu politikada belirtilenler dışında kimliği belirlenebilir sağlık verilerini paylaşmak

## 4. KVKK (Türkiye) Hakları

6698 sayılı Kişisel Verilerin Korunması Kanunu gereği:

- **Veri sahibinin hakları:**
  - Kişisel verilerin işlenip işlenmediğini öğrenme
  - İşlenmişse bilgi talep etme
  - İşleme amacını ve buna uygun kullanılıp kullanılmadığını öğrenme
  - Yurt içi/yurt dışı aktarılan üçüncü kişileri öğrenme
  - Eksik veya yanlış işlenmişse düzeltilmesini isteme
  - Silinmesini veya yok edilmesini isteme
  - Düzeltme/silme işlemlerinin aktarıldığı üçüncü kişilere bildirilmesini isteme
  - Otomatik sistemlerle analiz edilerek aleyhine sonuç çıkmasına itiraz etme
  - Kanuna aykırı işleme nedeniyle zarara uğradıysa tazminat talep etme

**KVKK talepleri için:** privacy@nuveli.app

## 5. Üçüncü Taraf Servis Sağlayıcılar

(English versiyonundaki tabloyla aynı — Supabase, OpenAI, Render, RevenueCat, Firebase, Apple, Google)

## 6. Veri Saklama ve Güvenlik

- Birincil veritabanı: **Supabase Postgres, Frankfurt (AB)**
- Aktarımda şifreleme: TLS 1.3
- Depolamada şifreleme: AES-256
- Kimlik doğrulama: JWT (1 saat ömür)
- Row-Level Security politikaları aktif

## 7. Veri Saklama Süresi

| Veri | Süre |
|---|---|
| Hesap bilgileri | Hesap silinene kadar |
| Sağlık kayıtları | Hesap silinene kadar |
| Öğün fotoğrafları | 90 gün, sonra otomatik silinir |
| Anonim analitik | 24 ay |
| Abonelik kayıtları | 7 yıl (vergi yükümlülüğü) |

**Hesap silme:** Talebiniz üzerine **30 gün** içinde tüm kişisel verileriniz silinir.

## 8. Haklarınızı Kullanma

- **Görme:** Settings → Privacy → Verilerimi İndir (CSV)
- **Düzeltme:** Settings → Profil → Düzenle
- **Silme:** Settings → Hesap → Hesabı Sil
- **Diğer:** privacy@nuveli.app

## 9. Çocukların Gizliliği

Nuveli, **13 yaş altı kullanıcılar için tasarlanmamıştır** (KVKK ve COPPA gereği).

## 10. Politika Değişiklikleri

Maddi değişikliklerden en az 30 gün önce e-posta ve uygulama içi bildirimle haberdar edilirsiniz.

## 11. İletişim

- **Gizlilik soruları:** privacy@nuveli.app
- **Genel destek:** support@nuveli.app

## 12. Yargı Yetkisi

Bu politika **Türkiye Cumhuriyeti** yasalarına tabidir. Uyuşmazlıklar İstanbul mahkemelerinde çözülür.

---

**Privacy Policy sonu (Türkçe)**

---

## 📋 Yayınlama Talimatları

### Adım 1: Web sitesinde host et
1. Bu metni `nuveli.app/privacy` (EN) ve `nuveli.app/privacy/tr` (TR) URL'lerinde yayınla
2. Statik HTML veya Markdown renderer (Vercel, Netlify, GitHub Pages)
3. Her iki dile de SSL zorunlu (https://)

### Adım 2: App Store / Play Store'da link ver
- App Store Connect → App Information → Privacy Policy URL: `https://nuveli.app/privacy`
- Play Console → App content → Privacy Policy: `https://nuveli.app/privacy`

### Adım 3: App içinde göster
- Onboarding'de checkbox: "I agree to [Privacy Policy] and [Terms]"
- Settings → Legal → Privacy Policy (WebView veya external link)

### Adım 4: Yıllık gözden geçirme
- Her 12 ayda bir avukatla gözden geçir
- Yasal değişiklikler için trigger setup et (KVKK, GDPR güncellemeleri)
