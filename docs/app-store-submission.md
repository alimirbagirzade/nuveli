# App Store Submission Checklist — Nuveli

Apple App Store'a başvuru için gerekli tüm materyaller ve akış.

---

## Apple Developer Account Gereksinimleri

- [ ] Apple Developer Program aktif ($99/yıl)
- [ ] Bundle ID kayıtlı: `com.nuveli.app`
- [ ] App Store Connect'te app oluşturulmuş
- [ ] iOS Distribution Certificate + Provisioning Profile

---

## App Store Connect — Metin Alanları (TR)

### App Name
`Nuveli`

### Subtitle (30 karakter)
`AI kalori koçu`

### Promotional Text (170 karakter)
Fotoğraf çek, kaloriyi gör. Kişisel koçunla sürdürülebilir beslenme alışkanlıkları kur. Yargısız, destekleyici, bilimsel temelli.

### Description (4000 karakter — TR)

```
Nuveli, fotoğraftan yemek analizi yapan ve kişisel bir koç gibi yanında olan
yapay zeka destekli wellness uygulamasıdır.

◆ FOTOĞRAF İLE KALORİ TAKİBİ
Öğününün fotoğrafını çek, AI saniyeler içinde kalori ve makro değerlerini
tahmin etsin. Düzenle, onayla, günlüğüne ekle.

◆ KİŞİSEL AI KOÇ
Kendi tercih ettiğin koç tarzında (destekleyici, motive edici veya gerçekçi)
yargısız destek al. Sesli yanıtlar da mevcut.

◆ SÜRDÜRÜLEBİLİR HEDEFLER
Katı rakamlar yerine gerçekçi, sürdürülebilir alışkanlıklar. Kötü bir gün
normal — önemli olan yön.

◆ GÜVENLİK ÖNCELİĞİ
Yeme ile ilgili zorlanıyorsan koç uzmana yönlendirir. ALO 182 ve Türk
Tabipleri Birliği kaynakları her zaman ulaşılabilir.

◆ GİZLİLİK
Verileriniz Türkiye'de (Supabase EU region) tutulur. İstediğin an tüm
verilerini kalıcı olarak silebilirsin.

◆ PREMIUM ÖZELLİKLER
• Sınırsız fotoğraf analizi (ücretsiz: günde 3)
• Sınırsız koç mesajı (ücretsiz: günde 10)
• Gelişmiş koç + sesli yanıt
• Haftalık ve aylık ilerleme raporu

Yeni kullanıcılar için 7 gün ücretsiz deneme — kredi kartı gerekmez.

━━━━━━━━━━━━━━━━━━━━━━━━
Nuveli bir wellness aracıdır. Tıbbi teşhis veya tedavi sağlamaz. Sağlık
sorunlarında mutlaka bir sağlık profesyoneliyle görüşün.
━━━━━━━━━━━━━━━━━━━━━━━━

Support: support@nuveli.com.tr
Gizlilik: https://nuveli.com.tr/privacy
Şartlar: https://nuveli.com.tr/terms
```

### Keywords (100 karakter)
```
kalori,yemek,diyet,sağlık,fitness,koç,AI,fotoğraf,makro,wellness
```

### What's New in This Version
```
🎉 Nuveli'nin ilk sürümü!
• Fotoğraftan AI ile kalori tahmini
• Kişisel AI koç (sesli yanıt)
• Sürdürülebilir hedef belirleme
• 7 gün ücretsiz premium denemesi
```

### Support URL
`https://nuveli.com.tr/support`

### Marketing URL (opsiyonel)
`https://nuveli.com.tr`

### Privacy Policy URL
`https://nuveli.com.tr/privacy`

---

## Kategori + Alt Kategori

- **Primary Category:** Health & Fitness
- **Secondary Category:** Food & Drink

---

## Age Rating (Ratings Questionnaire)

| Soru | Cevap |
|---|---|
| Cartoon/fantasy violence | None |
| Realistic violence | None |
| Sexual content/nudity | None |
| Profanity/crude humor | None |
| Alcohol/tobacco/drug use | None |
| Mature/suggestive themes | None |
| Simulated gambling | None |
| Horror/fear themes | None |
| Prolonged graphic/sadistic realistic violence | None |
| Medical/treatment information | **Infrequent/Mild** ← yeme bozukluğu destekleyici metinler |
| Unrestricted web access | No |
| Gambling contests | No |

**Final Rating:** 4+ (medical/treatment info mild → rating değişmez)

---

## App Review Information

### Demo Account (mutlaka çalışır olmalı!)
```
Email: reviewer@nuveli.com.tr
Password: (App Store Connect'te set et)
```

Bu hesap:
- Onboarding tamamlanmış olmalı
- Örnek öğün kayıtları olmalı
- Premium tier `trial` olmalı (tüm özellikleri gösterir)

### Notes for Reviewer
```
Nuveli bir wellness/yemek takip uygulamasıdır (kalori counter).

Test adımları:
1. Demo hesapla login olun
2. Home'da günlük özeti görün
3. "Öğün Ekle" → Manuel Giriş ile bir yemek ekleyin
   (gerçek fotoğraf test için: assets/sample_meal.jpg mevcut)
4. Coach sekmesinde bir mesaj gönderin

AI özellikleri backend üzerinden çalışır (OpenAI Vision + TTS).

Yeme bozukluğu güvenliği: "kusuyorum" gibi ifadeler kullanıcıyı ALO 182
gibi profesyonel kaynaklara yönlendirir. Bu davranış kasıtlıdır ve
docs/protocols/safety-wellness-boundary.md'de tanımlıdır.

Privacy: Kullanıcılar Settings → Hesabı Sil ile tüm verilerini kalıcı
olarak silebilirler (GDPR/KVKK uyumlu).
```

### Contact Info
- First Name: [Your First Name]
- Last Name: [Your Last Name]
- Phone: [+90 5XX XXX XX XX]
- Email: review@nuveli.com.tr

---

## Screenshots (GEREKSİNİMLER)

Apple şu boyutlarda screenshot ister. **5 ekran** minimum, ideal 6-8.

### iPhone 6.7" (iPhone 15 Pro Max, 14 Pro Max, 13 Pro Max)
**Boyut:** 1290 × 2796 px
**Gerekli:** Evet
**Önerilen ekranlar:**
1. Home ekranı — daily summary + meal list
2. Meal capture → AI result (high confidence)
3. Coach chat — bir konuşma örneği
4. Paywall — trial teklifi
5. Onboarding result — kişiselleştirilmiş hedef

### iPhone 6.5" (iPhone 11 Pro Max, XS Max)
**Boyut:** 1242 × 2688 px
**Gerekli:** Evet (6.7 submit edilse bile)

### iPhone 5.5" (iPhone 8 Plus) — OPSIYONEL
**Boyut:** 1242 × 2208 px

### iPad Pro 12.9" (2. veya 3. gen) — SADECE iPad support eklerseniz

---

## App Privacy (Data Types)

App Store Connect'te "App Privacy" bölümünde beyan edilecek:

### Data Used to Track You
**None** — Nuveli 3rd party ad/tracking SDK kullanmaz.

### Data Linked to You
- **Contact Info:** Email Address (authentication)
- **Health & Fitness:** Fitness (kilo, boy, aktivite seviyesi)
- **User Content:** Photos (meal photos, AI analysis için)
- **Identifiers:** User ID (Supabase UUID)
- **Usage Data:** Product Interaction (Firebase Analytics)
- **Diagnostics:** Crash Data, Performance Data (Crashlytics)

### Data Not Linked to You
**None**

---

## In-App Purchases

RevenueCat üzerinden yönetilen paketler:

| Product ID | Display Name | Price | Type |
|---|---|---|---|
| `nuveli.premium.monthly` | Premium Aylık | ₺149.99 | Auto-Renewable Subscription |
| `nuveli.premium.yearly` | Premium Yıllık | ₺999.99 | Auto-Renewable Subscription |

**Subscription Group:** `Nuveli Premium`

### Subscription Benefits (her subscription için set et)
- ✓ Sınırsız fotoğraf analizi
- ✓ Sınırsız AI koç
- ✓ Sesli koç yanıtları
- ✓ Haftalık + aylık ilerleme
- ✓ Öncelikli destek

---

## Rejection Risk'leri ve Önlemler

| Risk | Önlem |
|---|---|
| Medical advice iddia etmek | `medical-disclaimer` her AI yanıtında. README'de net "wellness aracıdır". |
| Eating disorder kötüye kullanımı | Safety service aktif + kriz metinleri ALO 182 yönlendirmesi |
| Minor kullanımı | Onboarding'de 18+ age gate var |
| Privacy policy eksik | `nuveli.com.tr/privacy` yayınlanmış olmalı |
| Demo account çalışmıyor | Submission öncesi manuel test şart |
| 3.1.1 — IAP için alternate payment | Sadece IAP kullanılıyor, Stripe vs. yok |
| 4.0 — Spam / duplicate functionality | Unique AI-powered + Türk pazar odaklı |

---

## Submission Akışı

```
1. ./scripts/build-ios.sh                    # Build oluştur
2. Xcode → Product → Archive                 # Archive
3. Window → Organizer → Distribute App       # Upload to App Store Connect
4. App Store Connect → TestFlight            # 30+ dakika işleme
5. Internal testing (ekip) — minimum 1 hafta
6. External testing (beta — opsiyonel)
7. Submit for Review                         # App Store Review
8. Review → Approved → Release               # Genelde 24-48 saat
```

---

## Deployment Day Checklist

- [ ] `pubspec.yaml` version bump yapıldı (`1.0.0+1` → `1.0.1+2`)
- [ ] Release notes yazıldı (TR)
- [ ] Demo account credentials App Store Connect'te güncel
- [ ] Test: Fresh install → onboarding → meal → coach → logout → login → geri dönebiliyor
- [ ] Crashlytics dashboard temiz (0 fatal crashes son 24 saat)
- [ ] Backend production'da (`/health` endpoint green)
- [ ] RevenueCat test satın almalar çalışıyor (sandbox)
- [ ] Privacy policy URL erişilebilir
- [ ] Support URL erişilebilir
