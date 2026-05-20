# 📂 Category, Age Rating & Languages

**Hedef:** App Store Connect ve Play Console'da seçilecek meta değerler.

---

## 🏷️ Kategori

### iOS (App Store Connect)
**Primary Category:** `Health & Fitness`
**Secondary Category:** `Lifestyle`

**Sebep:**
- Health & Fitness → en alakalı, rakipler burada (MyFitnessPal, Lifesum, Yazio)
- Lifestyle → ikinci kategori; daha geniş erişim

⚠️ **Apple kuralı:** Kategori sonradan değiştirilirse mevcut ranking sıfırlanır → ilk seçim önemli.

### Android (Google Play Console)
**Application Category:** `Health & Fitness`
**Tags (max 5):**
- `Health & Fitness`
- `Calorie Tracker`
- `Nutrition`
- `Diet`
- `Lifestyle`

---

## 🔞 Age Rating

### iOS
**Apple Age Rating:** `4+` (no objectionable content)

**Apple questionnaire'de işaretlenecekler:**
| Soru | Cevap |
|---|---|
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Sexual Content or Nudity | None |
| Profanity or Crude Humor | None |
| Alcohol, Tobacco, or Drug Use | None |
| Mature/Suggestive Themes | None |
| Simulated Gambling | None |
| Horror/Fear Themes | None |
| Prolonged Graphic Violence | None |
| Medical/Treatment Info | **Infrequent/Mild** ⚠️ |
| Unrestricted Web Access | None |
| Gambling/Contests | None |
| Age Verification | None |

⚠️ **"Medical/Treatment Info"** için **"Infrequent/Mild"** seç → app nutrition/health info veriyor ama medical advice değil. **"None"** seçersen Apple reject edebilir.

### Android (Google Play)
**IARC Rating:** `Everyone` (3+ veya 7+)

**Google questionnaire'de cevaplar:**
- Violence: None
- Sexuality: None
- Language: None
- Controlled substance: None
- User-generated content: None (Nuveli'de kullanıcılar başkalarıyla içerik paylaşmıyor)
- Privacy & data collection: **Yes, health data** (bunu Data Safety form'unda detaylandıracağız)
- Diğer hassas içerik: None

**Sonuç IARC rating:** `Everyone`

---

## 🌍 Languages (Localizations)

### Launch için (v1.0)

**Primary Language (App Store base):** `English (US)`
**Localizations:** `Turkish (Türkiye)`

### Localized içerikler
| Alan | EN | TR |
|---|---|---|
| App Name | ✅ Aynı | ✅ Aynı |
| Subtitle | ✅ | ✅ |
| Description | ✅ | ✅ |
| Keywords | ✅ | ✅ |
| Promotional Text | ✅ | ✅ |
| Release Notes | ✅ | ✅ |
| Screenshots | 6 adet | 6 adet (aynı tasarım, TR metin) |
| Privacy Policy URL | https://nuveli.app/privacy | https://nuveli.app/privacy/tr |
| Support URL | https://nuveli.app/support | https://nuveli.app/destek |

### Gelecek (v1.2+)
Sonraki localization'lar (impact'e göre sıralı):
1. Spanish (ES) — 500M+ konuşan
2. German (DE) — yüksek paying power
3. French (FR)
4. Portuguese (PT) — Brezilya pazarı
5. Russian (RU)
6. Arabic (AR)
7. Indonesian (ID)

Localize edilecek katmanlar:
- App store listing (description, keywords)
- In-app strings (Flutter `intl` paketi)
- AI Coach response language (OpenAI prompt'a "respond in {locale}" eklemek)

---

## 📋 App Store Connect Form Değerleri (Özet)

**Information sekmesi:**
```
Primary Category: Health & Fitness
Secondary Category: Lifestyle
Content Rights: Does NOT use third-party content
Age Rating: 4+
```

**Pricing and Availability:**
```
Price: Free
Availability: All countries (önerilen — global launch)
  Alternatif: Sadece TR + US + EU (cautious launch)
In-App Purchases: Yes (Premium subscriptions)
```

**App Information:**
```
Bundle ID: com.nuveli.app
SKU: nuveli-ios-001
Primary Language: English (U.S.)
```

---

## 📋 Google Play Console Form Değerleri (Özet)

**App details:**
```
Application Type: App
Category: Health & Fitness
Tags: Calorie Tracker, Nutrition, Diet, Lifestyle, Fitness
Email: support@nuveli.app
Website: https://nuveli.app
Privacy Policy: https://nuveli.app/privacy
```

**Content rating:**
```
IARC: Everyone
Target audience: 18-65+ (genel sağlık kategorisinde)
```

**Pricing:**
```
Pricing: Free
Contains ads: No
In-app purchases: Yes ($1-$200 range)
```

---

## ✅ Karar Listesi

- [x] iOS Primary: Health & Fitness
- [x] iOS Secondary: Lifestyle
- [x] iOS Age Rating: 4+
- [x] Apple "Medical/Treatment Info": Infrequent/Mild
- [x] Android Category: Health & Fitness
- [x] Android IARC: Everyone
- [x] Primary Language: English (US)
- [x] Localizations (launch): Turkish
- [x] Pricing: Free with IAP
- [x] Availability: All countries

---

**Not:** Bu değerler submission sırasında App Store Connect ve Play Console formlarına aynen kopyalanacak.
