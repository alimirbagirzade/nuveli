# Google Play Store Submission Checklist — Nuveli

Play Console'a başvuru için gerekli tüm materyaller.

---

## Google Play Developer Account Gereksinimleri

- [ ] Google Play Developer Program aktif ($25 one-time)
- [ ] Package name kayıtlı: `com.nuveli.app`
- [ ] Play Console'da app oluşturulmuş
- [ ] Signing key oluşturulmuş (`android/key.properties` + `.jks` keystore)

---

## Store Listing — Metin Alanları (TR)

### App name (50 karakter)
`Nuveli — AI Kalori Koçu`

### Short description (80 karakter)
`Fotoğraftan kalori analizi + kişisel AI koç. Yargısız, sürdürülebilir.`

### Full description (4000 karakter)

```
Nuveli, fotoğraftan yemek analizi yapan yapay zeka destekli wellness
uygulamasıdır. Katı rakamlar yerine sürdürülebilir alışkanlıklar hedefler.

🍽️ FOTOĞRAF İLE KALORİ TAKİBİ
Öğününün fotoğrafını çek, AI saniyeler içinde kalori + makro değerlerini
tahmin etsin. Yanlışsa düzenle, onayla, günlüğüne ekle.

🤖 KİŞİSEL AI KOÇ
3 farklı koç tarzından seç: destekleyici, motive edici veya gerçekçi.
Sesli yanıtlarla da konuşabilirsin (premium).

🎯 SÜRDÜRÜLEBİLİR HEDEFLER
Mifflin-St Jeor bilimsel hesabıyla kişisel kalori hedefi. Kötü bir gün
normal — önemli olan yön.

🛡️ GÜVENLİK ÖNCELİĞİ
Yeme ile ilgili zorlanıyorsan koç seni profesyonel kaynaklara
yönlendirir. ALO 182 + TTB her zaman erişilebilir.

🔒 GİZLİLİK
Verileriniz Supabase EU region'da. İstediğin an tüm verilerini tek tıkla
silebilirsin (GDPR/KVKK uyumlu).

💎 PREMIUM
• Sınırsız fotoğraf analizi (ücretsiz: 3/gün)
• Sınırsız koç mesajı (ücretsiz: 10/gün)
• Sesli koç yanıtları
• Haftalık + aylık ilerleme raporu
• 7 GÜN ÜCRETSİZ DENEME — kredi kartı gerekmez

═══════════════════════════════════
⚠️ Nuveli bir wellness aracıdır. Tıbbi teşhis veya tedavi sağlamaz.
Sağlık sorunlarında sağlık profesyoneliyle görüşün.
═══════════════════════════════════

Support: support@nuveli.com.tr
Gizlilik: https://nuveli.com.tr/privacy
```

---

## Graphic Assets

### App Icon
**Boyut:** 512 × 512 px (PNG, 32-bit)
**Kurallar:** Background opak, transparan olmamalı

### Feature Graphic
**Boyut:** 1024 × 500 px (PNG/JPG)
**Kullanım:** Play Store'da üst banner
**İçerik:** App name + tagline + ürün vizual

### Phone Screenshots
**Boyut:** minimum 320px, maksimum 3840px (uzun kenar)
**Oran:** 16:9 veya 9:16
**Sayı:** minimum 2, ideal 6-8
**Öneri:** App Store ile aynı 6 screenshot'ı kullan

### 7" Tablet Screenshots (opsiyonel)
**Boyut:** 1024 × 600 px veya 600 × 1024 px

### 10" Tablet Screenshots (opsiyonel)
**Boyut:** 1920 × 1080 px veya 1080 × 1920 px

---

## Content Rating (IARC Questionnaire)

Google Play için IARC questionnaire:

| Soru | Cevap |
|---|---|
| Violence | None |
| Sexuality | None |
| Language | None |
| Controlled substance | None |
| Scary content | None |
| Simulated gambling | None |
| User interaction | **Yes** — chat with AI (safety-controlled) |
| Unrestricted internet | No |
| Location sharing | No |
| Digital purchase | **Yes** — IAP (subscriptions) |

**Final Rating:** PEGI 3 / Everyone

---

## Data Safety (Privacy Form)

Play Console "Data safety" bölümünde beyan edilecek.

### Data collection

**Toplanan veri kategorileri:**

| Category | Data | Collected? | Shared? | Purpose |
|---|---|---|---|---|
| Personal info | Email | ✓ | ✗ | Account management |
| Personal info | User IDs | ✓ | ✗ | Account management |
| Health & fitness | Health info | ✓ | ✗ | App functionality |
| Photos/videos | Photos | ✓ | ✗ | App functionality (meal analysis) |
| App activity | App interactions | ✓ | ✗ | Analytics |
| App info and performance | Crash logs | ✓ | ✗ | Diagnostics |
| App info and performance | Diagnostics | ✓ | ✗ | Analytics |

### Data protection
- ✓ Data is encrypted in transit (HTTPS)
- ✓ User can request data deletion (Settings → Hesabı Sil)

### No third-party ad SDKs
Nuveli ad SDK kullanmaz.

---

## Permissions

Manifest'te sadece şunlar:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Permission Declaration (Play Console)

| Permission | Reason (TR) |
|---|---|
| CAMERA | Öğün fotoğrafı çekmek için, AI analizi yapılır |
| READ_EXTERNAL_STORAGE | Galeriden öğün fotoğrafı seçmek için |
| POST_NOTIFICATIONS | Öğün hatırlatıcıları ve koç mesajları için (kullanıcı opt-in) |

---

## In-App Products

RevenueCat üzerinden yönetilen paketler (Play Console'da da tanımlanmalı):

| Product ID | Base Plan | Price | Period |
|---|---|---|---|
| `nuveli_premium_monthly` | Monthly | ₺149.99 | Auto-renewing monthly |
| `nuveli_premium_yearly` | Yearly | ₺999.99 | Auto-renewing yearly |

**Subscription group:** `Nuveli Premium`

### Free trial offer
- 7 gün ücretsiz deneme (trial claim akışı üzerinden)

---

## App Category

- **Category:** Health & Fitness
- **Tags:** Calorie counter, diet tracker, AI assistant, nutrition

---

## Target audience

- **Target age range:** 18+ (18+ age gate var app içinde)
- **Primarily designed for children:** No

---

## Testing Tracks

```
Internal testing  → Ekip (1-100 tester), saatlik review
Closed testing    → Beta testerlar (up to 10,000), hızlı
Open testing      → Herkes join edebilir, moderate review
Production        → Public, full review
```

**Önerilen akış:**
1. Internal → 3-5 kişi, 1 hafta
2. Closed (beta) → 20-50 kişi, 2 hafta
3. Production

---

## Rejection Risk'leri ve Önlemler

| Risk | Önlem |
|---|---|
| Misleading functionality | Açıklamada "wellness aracıdır, tıbbi değil" net |
| Medical claim | Description ve about sayfasında disclaimer |
| Eating disorder policy | Safety service aktif, crisis yönlendirme |
| Subscription hardship | Easy cancellation (Play Store üzerinden) |
| Data safety inaccurate | Bu dokümandaki kategorilerle eşleş |
| Intellectual property | Kendi içeriğimiz, 3. parti asset yok |

---

## Submission Akışı

```
1. ./scripts/build-android.sh                # .aab oluştur
2. Play Console → Production → Create new release
3. Upload app-release.aab
4. Release notes (TR + EN)
5. Review release → Start rollout
6. Review süreci: 1-7 gün arası
```

---

## Release Strategy: Staged Rollout

İlk production release için:

| Hafta | Rollout % |
|---|---|
| 1 | 10% |
| 2 | 25% |
| 3 | 50% |
| 4+ | 100% |

Her artırımdan önce Crashlytics'te fatal crash rate < 0.5% olmalı.

---

## Deployment Day Checklist

- [ ] `pubspec.yaml` `version:` ve `build number` bump
- [ ] Play Console'da release notes TR + EN
- [ ] Signed App Bundle hazır
- [ ] Data Safety form dolduruldu ve güncel
- [ ] Store listing screenshot'ları yüklü
- [ ] Content rating tamamlanmış
- [ ] Test: Fresh install → onboarding → satın alma akışı (sandbox) çalışıyor
- [ ] Backend production'da
- [ ] RevenueCat Play Store integration aktif
