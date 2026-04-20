# Monetizasyon Alternatifleri

Bu belge, Nuveli'nin ana monetizasyon modelini (freemium + trial + abonelik) ve reddedilen alternatifleri tanımlar. **Neden bu modeli seçtik, neden diğerlerini seçmedik** — bu soruların net cevapları burada.

---

## Seçilen Model — Freemium + Trial + Abonelik

**Özet:**
- Ücretsiz tier (sınırlı ama kullanışlı)
- 7 gün ücretsiz trial (kredi kartı yok)
- Aylık / Yıllık / Ömür boyu abonelik
- App Store ve Google Play IAP (+ Web Stripe)

**Neden:**
- Kullanıcı değer görene kadar ödeme istemez
- Trial ürünü tanıma fırsatı verir
- Recurring revenue tahmin edilebilir (business için)
- Türkiye pazarında tanıdık model (Spotify, Netflix)

---

## Reddedilen Alternatifler

Her biri ciddiyetle değerlendirildi. Biri geçerli olsaydı Nuveli çok farklı bir ürün olurdu.

### 1. Tamamen Ücretsiz (Reklam Destekli)

**Model:** Uygulama bedava, reklam gelirle finanse edilir.

**Neden reddedildi:**
- Wellness uygulamasında reklam etik değil — "kilo ver hapı" reklamı gösteremeyiz
- Reklam gelirinin CPM'i düşük (TR için ~$1-3 per 1000 impression)
- 100K aktif kullanıcı → aylık $200-500 gelir → yetersiz
- Reklam kullanıcı deneyimini bozar — hassas konuda ikinci bozma
- Data harvesting'e kayar — "kullanıcı ürün" olur

**Kabul şartları yoktu** — bu modeli düşünmedik bile uzun süre.

---

### 2. Tek Seferlik Ücret (One-time purchase)

**Model:** ₺149 öde, sonsuza kadar kullan.

**Neden reddedildi:**
- AI maliyetleri sürekli (her meal analizi = OpenAI $0.01-0.05)
- 100 aktif kullanıcı = aylık $30-50 OpenAI maliyeti
- Bir kere öde → kullanıcı her ay fatura yaratır → 5 ay sonra zarar
- Recurring değil → business büyümüyor (valuation düşük)
- Yeni özellik eklendikçe "tekrar ödemeli miyim" sorunu

**İstisna:** Ömür boyu paket bunu ima eder. Ama fiyatı yüksek (₺1,499), sadece küçük bir kitleye hitap eder, maliyet amortize olur.

---

### 3. Kullanım Bazlı (Usage-based)

**Model:** Her AI analizi ₺0.50, her koç mesajı ₺0.25 gibi.

**Neden reddedildi:**
- Kullanıcı her etkileşimde "para sayacı" görür → anxiety
- Wellness ürünü — kullanıcı serbestçe denemek ister
- Küçük ödemeler yönetmesi zor (payment processor minimum var)
- Türk kullanıcısı "mikrotransaksiyon" kültürüne alışık değil

**İstisna:** B2B API modeli (v∞) olsaydı böyle olurdu. Ama consumer app için değil.

---

### 4. Donanım Satışı (Hardware + App)

**Model:** Bir akıllı tartı veya sensör sat, uygulama gratis.

**Neden reddedildi:**
- Donanım üretimi ayrı bir business
- Ekip donanım deneyimsiz
- Marj düşük, yüksek stok riski
- Yazılım tek başına daha ölçeklenebilir

**Potansiyel v3+:** Eğer ürün başarılı olursa, "Nuveli smart scale" gibi bir ürün düşünülebilir. Ama şimdilik yok.

---

### 5. B2B (Enterprise/Sigorta Satışı)

**Model:** Sigorta şirketlerine, kurumsal wellness programlarına sat.

**Neden reddedildi:**
- Sales cycle uzun (6-12 ay)
- İlk yıl için yanlış odak
- Özellik seti farklı (HIPAA/GDPR enterprise compliance)
- Kurucu ekip B2C'de deneyimli, B2B pivot büyük risk

**Potansiyel v∞:** Consumer başarılı olursa, "Nuveli for Teams" gibi bir iş ürünü düşünülebilir. Ama şimdilik consumer odaklı.

---

### 6. Affiliate / Referral

**Model:** Süpermarket/restoran zinciriyle anlaş, kullanıcıyı yönlendir, komisyon al.

**Neden reddedildi:**
- Wellness uygulamasında "bu yemekçiden sipariş ver" önerisi = çıkar çatışması
- Kullanıcı güveni çöker ("bu bana X öneriyor çünkü para alıyor")
- Etik sınır hassas

**Kabul edilebilir version:** Affiliate değil ama "Türk mutfağı yemek rehberi" gibi organik içerik v2'de olabilir.

---

### 7. Veri Satışı (Data monetization)

**Model:** Anonim kullanıcı verilerini sağlık araştırmalarına sat.

**Neden reddedildi:**
- KVKK/GDPR altında "anonim" çok zor (özellikle sağlık verisi)
- Kullanıcı güveninin taban taşı — ihlal edilirse marka biter
- Etik olarak sakıncalı

**Olası yer:** Academic research için anonimleştirilmiş dataset (opt-in + IRB approval). Ama gelir kaynağı değil.

---

### 8. NFT / Crypto (hype bazlı)

**Model:** "Nuveli Coin" ile gamification, kazan-öde.

**Neden reddedildi:**
- Wellness ile çelişen felsefe
- Regülasyon belirsiz (özellikle TR)
- Kullanıcı güveni kazanılacak bir alan değil şu an

---

## Gelir Karışımı (Mevcut Modelde)

### İdeal karışım (12 ay sonra)

- **Aylık abonelik:** %30 gelir
- **Yıllık abonelik:** %60 gelir (en sağlam)
- **Ömür boyu:** %10 gelir (küçük ama yüksek)

### Kaçınılacak durum

- Aylık %80+ → trial conversion iyi değil demek (yıllığa geçiş yapamıyor)
- Ömür boyu %30+ → kullanıcı uzun vadeli güvenmiyor demek

---

## Gelir Projeksiyonu (tahmini)

### Ay 1-3 (launch)

- 5,000 kayıt / ay
- %3 trial start → 150/ay
- %35 trial → paid → 50/ay
- ARPU ~₺50/ay (karışım)
- Aylık yeni MRR: ~₺2,500

### Ay 4-12

- İvme artışı
- Ay 12: ~50K kayıt, ~5K abone
- MRR: ~₺250K
- Yıllık runrate: ~₺3M

### Ay 12+

- Enterprise girişimleri
- Uluslararası yayın
- Yeni feature'lar

**Uyarı:** Bu projeksiyon tahmin. Launch sonrası gerçek veri çok farklı olabilir. Belge arşiv için, plan için değil.

---

## Birim Ekonomisi

### Kullanıcı başına aylık maliyet (tahmini)

| Kalem | Maliyet |
|-------|---------|
| OpenAI (analiz + koç + TTS) | ₺8-15 |
| Supabase (DB + Auth + Storage) | ₺3 |
| Render (backend hosting) | ₺2 |
| Firebase (Analytics + Crashlytics + FCM) | ₺1 |
| App Store / Google / Stripe fees (%15-30) | Değişken |
| **Toplam infra:** | **₺14-21** |

### Abonelik bazlı net gelir

- **Aylık ₺99:** Apple %30 → ₺69 net → ₺49 kâr/ay
- **Yıllık ₺599:** Apple %15 (1. yıl sonrası) → ₺509 → ₺299 kâr/yıl
- **Ömür boyu ₺1,499:** ₺1,050 → ₺400 kâr (3 yıl sonra başa baş)

### LTV > CAC hedefi

- **CAC (Customer Acquisition Cost):** Organic ilk zamanlar ~₺5, paid ad ile ~₺50
- **LTV:** 6 ay ortalama kullanım × aylık ₺50 kar = ₺300
- **LTV / CAC:** 6x → sağlıklı

---

## Riskler ve Hedging

### Risk 1: OpenAI maliyet artışı

**Senaryo:** OpenAI fiyatlandırma %50 artar.

**Hedging:**
- Claude veya Google Gemini alternatif olarak değerlendirilir
- Local model (Llama) test edilir — özellikle meal analizi için
- Daha küçük model (gpt-4o-mini) default yapılır, ihtiyaç varsa gpt-4o

### Risk 2: Apple/Google %30 komisyonu

**Senaryo:** Zaten alıyorlar. Avrupa'da azaldı (EU Digital Markets Act).

**Hedging:**
- Web subscription portalı (nuveli.com.tr/app) = Stripe %3 ← kazanç
- Kullanıcıyı web'e yönlendirmek (policy izin verdiğince)

### Risk 3: Trial abuse

**Senaryo:** Kullanıcı çoklu e-posta ile trial-hopping.

**Hedging:**
- Device ID bazlı track
- Abuse detection (3+ trial = flag)

### Risk 4: Churn artışı

**Senaryo:** Aylık churn %15'e çıkar.

**Hedging:**
- Exit survey ("neden gidiyorsun?")
- Win-back kampanyası
- Ürün kalite iyileştirmeleri

---

## Etik Sınırlar

Monetizasyon hedefi olsa da şunları **asla** yapmayız:

### Fiyatlama

- ❌ Sürpriz fiyat artışları
- ❌ "Sessiz" ücret (kullanıcı fark etmediği)
- ❌ Confusing tiering ("aylık %80 iskonto ama sonra %200 artış")
- ❌ Trial'dan çıkışı zorlaştırma

### Kullanıcı deneyimi

- ❌ Dark pattern paywall (X butonu küçük, abone ol büyük)
- ❌ Fake urgency
- ❌ Guilt trips
- ❌ Agresif cross-sell

### Veri

- ❌ Veri satışı (3. partiye)
- ❌ Reklam profili oluşturma
- ❌ Sessiz data harvesting

### İçerik

- ❌ "Önerilen" kisvesi altında sponsor içerik
- ❌ Paid influencer koçu olarak sunmak

---

## İleride Değerlendirilebilecekler (v2+)

### "Aile" planı

**Model:** 4 kişiye kadar aile üyesine aynı abonelik.

**Pro:** Yüksek retention, viral büyüme.
**Con:** Karmaşa, fiyat belirsizliği.
**Karar:** v2'de düşünülür.

### "Gift" modu

**Model:** Arkadaşına 3 ay Pro hediye edebilirsin.

**Pro:** WoM büyüme.
**Con:** Karmaşa, abuse riski.
**Karar:** v2'de, referral kampanyasıyla birlikte.

### "Öğrenci indirimi"

**Model:** .edu.tr e-postası ile %50 indirim.

**Pro:** Genç kullanıcı kitlesi.
**Con:** Verification karmaşık.
**Karar:** v2'de düşünülür (SheerID gibi servisler var).

### Physical product

**Model:** Nuveli branded akıllı tartı, su şişesi.

**Karar:** v3+, ürün olgunlaştıktan sonra.

### Content monetization

**Model:** Premium içerik (beslenme uzmanı videoları, tarif kitapları).

**Con:** Uzmanla çalışmak gerekir (tıbbi sınır hassas).
**Karar:** v∞, partnership şeklinde.

---

## Başarı Kriterleri

### 12 ay sonra

- MRR > ₺200K
- Aktif ücretli abone > 3,000
- LTV / CAC > 4x
- Aylık churn < %7
- NPS > 40

### Kötü sinyaller (pivot düşün)

- 12 ay sonra MRR < ₺50K → model veya ürün ayarı
- Churn > %15 → ürün değeri sorunu
- CAC > LTV → unsustainable, tekrar değerlendir

---

## Özet

Nuveli **freemium + trial + abonelik** modeli kullanır çünkü:
- Wellness ürününe uygun (kullanıcı önce tanımalı)
- Türkiye pazarında tanıdık
- Recurring revenue sürdürülebilir
- Etik sınırları koruyor

Diğer modeller (reklam, tek seferlik, kullanım bazlı, B2B) bilinçli reddedildi. Her biri farklı bir ürün gerektirirdi.

Bu karar gözden geçirilebilir — ama "denemek için" değil, "veri gösteriyor ki bu model tıkanıyor, pivot gerekli" noktasında.
