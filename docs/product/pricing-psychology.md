# Fiyatlandırma Psikolojisi ve Elastikliği

Bu belge, Nuveli'nin fiyatlandırma kararlarının ardındaki düşünceyi tanımlar. Fiyat sadece bir sayı değil, bir mesajdır.

---

## Temel İlke

**Fiyat, ürünün ne kadar değer verdiği algısını belirler.** Çok düşük fiyat "bu ucuz bir şey olmalı" hissi yaratır. Çok yüksek fiyat erişimi keser. İkisi arasındaki **algı-değer dengesi** bizim aradığımız nokta.

**Anahtar soru:** Kullanıcı fiyatı gördüğünde "değer ediyor" mu, "bunu kim verir" mi diyor?

---

## Türkiye Pazarı Bağlamı

### Abonelik alışkanlığı

Türk kullanıcısı dijital abonelikte Batı'dan daha temkinli:
- **Spotify:** ₺39.99/ay
- **Netflix:** ₺149.99/ay (2024 fiyatı, sürekli değişir)
- **BluTV/Gain:** ₺54-89/ay
- **MyFitnessPal Premium:** $9.99/ay (~₺340) → bu yüzden TR'de pek yok
- **Yazio:** €9.99/ay (~₺400) → aynı sorun

### Türk kullanıcısının mental model'i

- ₺50/ay → "ucuz, bir kahve"
- ₺100/ay → "kahvaltı dışarı"
- ₺200/ay → "ciddi bir değerlendirme gerekir"
- ₺500/ay → "bir üyelik kararı"

### Çıkarım

Kalori takibi uygulamasının **Netflix'ten pahalı olmaması** gerekiyor kullanıcı algısında. Entertainment her gün kullanılır, wellness ara sıra kullanılır diye algılanır (haksız ama gerçek).

**Hedef:** ₺99/ay sınırında kal. Yıllık ₺599 bunun altında mükemmel durur.

---

## Fiyat Stratejisi — Seçtiğimiz Noktalar

### Aylık: ₺99

**Neden bu rakam:**
- Ruh hali "kahvaltı fiyatı" kategorisinde
- Netflix'ten ucuz, Spotify'den biraz pahalı
- Yuvarlak değil (99 daha iyi algılanıyor, düşük tutma hissi)

### Yıllık: ₺599 (aylık ₺50 gibi)

**Neden bu rakam:**
- Ayda efektif ₺50 → "yarı fiyat" hissi
- %50 iskonto = güçlü teşvik
- 12 × 99 = 1188 → 589 tasarruf görünür

### Ömür boyu: ₺1,499

**Neden bu rakam:**
- Yaklaşık 2.5 yıllık değer (yıllık × 2.5)
- Büyük ödeme ama "bir daha ödeme yok"
- Erken benimseyen kitle (early adopter) için uygun
- Yıllık'tan yalnızca %150 pahalı → mantıklı upgrade

---

## Fiyat Elastikliği — Testler

### Test öncesi varsayımlar

- **Aylık ₺79 vs ₺99:** Büyük ihtimalle %20 fiyat farkı %10-15 daha çok dönüşüm getirir ama MRR düşebilir. Net kazanç görmek için test gerekir.
- **Aylık ₺129 vs ₺99:** Fiyat hassasiyeti yüksek → dönüşüm düşer, MRR muhtemelen düşer.
- **Yıllık ₺499 vs ₺599:** Aylık olmayan kullanıcıyı yıllığa çekmek için test edilebilir.

### A/B test planı (launch sonrası 3-6 ay)

1. **Ay 3:** Fiyat testleri başlamaz — baseline topluyoruz
2. **Ay 4:** Test 1 — Aylık ₺89 vs ₺99 (yeni kayıtlar için)
3. **Ay 5:** Test 2 — Yıllık ₺549 vs ₺599
4. **Ay 6:** Sonuçlar analiz edilir, en iyi kombinasyon canlıya alınır

**Grandfather policy:** Eski fiyattan abone olanlar eski fiyatta kalır. Yükseltirken şikayeti önlemek için.

---

## Fiyat Psikolojisi Teknikleri

### 1. Anchor etkisi

Paywall'da 3 fiyat gösterilir, en pahalı önce:
- ~~Ömür Boyu: ₺1,499~~ (üstü çizili, iskonto ima edilir ya da yok)
- **Yıllık: ₺599** ← seçili olarak vurgu (badge: "En popüler")
- Aylık: ₺99

Beyin ₺1,499'u görür, sonra ₺599'a "ucuz" diye tepki verir.

### 2. Aylık eşdeğer gösterimi

Yıllık paket için:
- **"₺599/yıl"** değil, **"₺50/ay gibi"** yaz
- Çünkü kullanıcı aylık düşünür
- Tam fiyat da altta görünür ("yıllık toplam ₺599")

### 3. Tasarruf vurgusu

Yıllık paket için:
- "₺589 tasarruf ediyorsun" → somut rakam
- "%50 indirim" → yüzde beyni karıştırır bazen
- İkisini yan yana kullan, maksimum etki

### 4. Trial hatırlatıcısı

Fiyat göstermeden önce trial vurgusu:
- "7 gün ücretsiz" → büyük font
- Sonra fiyat kartı → "sonrasında ₺99/ay"
- Kullanıcı önce "bedava" görür, sonra fiyata hazırlanır

### 5. İptal kolaylığı beyanı

Paywall'da sabit metin:
- "İstediğin zaman iptal et"
- Bu güven verir, churn artırmaz
- Çünkü kolay iptal zaten zorunlu (policy)

---

## Fiyat Yükseltme Stratejisi (ileride)

### Ne zaman yükseltmek

Yükseltme tetikleyicileri:
- 12 ay geçti, enflasyon farkı büyüdü
- Yeni major özellik eklendi (belirgin değer artışı)
- Rakip fiyatları da arttı (pazarda normal)

### Nasıl yükseltmek

1. **Grandfather eski üyeler** — onlar eski fiyatta kalır (sadakat)
2. **Yeni fiyat yeni kayıtlar için** — test et, kademeli
3. **Yıllık paket için 30 gün öncesi bildirim** — yenileme farklı fiyattan
4. **Açık iletişim** — "neden yükseltiyoruz" mesajı

### Kaçınılacak taktikler

- Sessiz yükseltme — kullanıcı yıl sonunda şok olur, churn patlar
- Sadece aylık yükseltme, yıllık aynı → bu ters sinyal verir
- Yüksek fiyat + indirim kampanyası sürekli → değer algısı çöker

---

## Bölgesel Farklılaştırma (v2+)

### Türkiye dışı fiyatlar

- **AB ülkeleri:** €5.99/ay, €39/yıl
- **UK:** £5.99/ay, £39/yıl
- **US:** $6.99/ay, $49/yıl

### Satın alma gücü paritesi (PPP)

- **Doğu Avrupa:** 50% indirim
- **Güney Asya:** 60% indirim
- **Latin Amerika:** 40% indirim

Apple/Google store'ları bunu otomatik yapar ama biz fiyatı `default` olarak belirleriz, local fiyatlandırma RC üzerinden overridable.

---

## Trial Ekonomisi

### Trial matematiği

Trial başlatan kullanıcının ekonomik değeri:
- **OpenAI maliyeti (7 gün):** ~₺15-25 (sınırsız kullanım varsayımı)
- **Altyapı maliyeti:** negligible
- **Conversion oranı:** %30-40 (ideal hedef)

### Hesap

100 trial başlatıcı için:
- Maliyet: ~₺2.000
- Conversion %35: 35 kullanıcı aylık ₺99 → yıllık net değer ~₺1.000/kullanıcı (churn dahil)
- Total revenue: ~₺35.000
- **ROI: 17x**

Trial kârlıdır, müsaade edelim kullanılsın.

### Trial suistimali

"Trial-hopping" — kullanıcı farklı e-postalarla trial başlatıyorsa:
- Device ID tracking (RC otomatik)
- Anonymous user'a trial verme
- Same device tekrar trial → aynı kullanıcı sayılır

---

## Fiyat Görselleştirme — Best Practices

### Paywall düzeni

```
┌─────────────────────────────────┐
│  NUVELI PREMIUM                 │
│                                 │
│  Tüm özellikler, sınır yok.     │
│                                 │
│  ✓ Sınırsız AI meal analizi     │
│  ✓ Sesli koç yanıtı             │
│  ✓ Haftalık ve aylık özet       │
│  ✓ Tüm grafikler                │
│                                 │
│  ┌─────────────────────────┐   │
│  │  YILLIK                  │   │
│  │  ₺50/ay                  │   │
│  │  ₺599/yıl                │   │
│  │  ₺589 tasarruf           │   │
│  │  [En popüler]            │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │  AYLIK                   │   │
│  │  ₺99/ay                  │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │  ÖMÜR BOYU               │   │
│  │  ₺1,499                  │   │
│  │  Tek ödeme               │   │
│  └─────────────────────────┘   │
│                                 │
│  [  7 Gün Ücretsiz Başla  ]     │
│                                 │
│  İstediğin zaman iptal et       │
│  Satın almayı geri yükle        │
│                                 │
└─────────────────────────────────┘
```

### Kullanılan teknikler

- **Yıllık baskın** → ortaya konulmuş, badge'li
- **Hiyerarşi** → önce değer, sonra fiyat, sonra CTA
- **Küçük yazı güven** → "istediğin zaman iptal"
- **Restore link her zaman** → cihaz değişenler için

---

## Ödeme Noktası Psikolojisi

### Abonelik onay ekranı (Apple/Google native)

Bu ekran Apple/Google tarafından yönetiliyor — biz değiştiremeyiz. Ama trial başlatma ekranımız:

**Önce bu ekranı görür:**

```
7 gün ücretsiz dene

Sonra ₺599/yıl (ayda ₺50 gibi)

[ Trial Başlat ]

Kredi kartı gerekmez
```

**Sonra Apple/Google native ekranı:**
Bu bizim kontrolümüzde değil ama iyi hazırlık önceki ekranla yapılmış olur.

---

## İptal Psikolojisi

### İptal deneyimi

Kullanıcı Settings → Premium → "Aboneliği yönet" der:
- Direkt Apple/Google store'una gider
- Biz araya kırıcı sorular sokmayız ("gitme, özel indirim") — dark pattern
- Temiz bir deneyim

### İptal sonrası

Kullanıcı iptal etti, ama hâlâ abonelik süresinin sonuna kadar premium:
- Bir push: "Aboneliğini iptal ettin. [X tarihe] kadar Pro özellikler açık."
- Baskı yok

### Win-back stratejisi

İptal ettikten 2 hafta sonra (premium süresi bitmeden):
- E-posta: "Geri dönmek ister misin? Her şey aynı."
- Uygulama içi: yumuşak davet, tek kere
- Bu da geçerse, 3 ay sonra tekrar (rare)

---

## Ücretsiz Kullanıcı Değeri

**Ücretsiz kullanıcı aslında ücretli:**
- Uygulama mağaza ranking'ine yardım eder
- Word of mouth
- Bir gün abone olabilir
- Bazı kişiler asla abone olmaz ama topluluk yaratırlar

### Bu yüzden
- Free tier'ı çok katı tutmayız
- "3 meal analiz yetiyor" orta sertlik
- Manuel giriş her zaman sınırsız
- Koç 5 mesaj — yeterince değerli, baskı yaratmaz

---

## Metrikler — Fiyatlandırma Sağlığı

### Ana metrikler

- **Conversion rate:** Paywall view → purchase (%3-5 hedef)
- **Trial → paid:** Trial başlatan → ücretli (%35-40 hedef)
- **Aylık churn:** (abone kaybı / toplam abone) × 100 (%5'ten az)
- **LTV:** Ortalama kullanıcı ömür boyu geliri (6+ ay)
- **ARPU:** Ortalama kullanıcı başına gelir (aylık)

### Uyarı sinyalleri

- **Churn > %10** → bir şey yanlış, ürün değeri sorunu
- **Conversion < %2** → paywall çok yanlış zamanda
- **Refund rate > %5** → beklenti yönetimi yanlış
- **Trial → paid < %25** → trial deneyimi değer göstermiyor

---

## Dünya Örnekleri (öğrenmek için)

### MyFitnessPal
- Aylık $9.99, yıllık $49.99
- %50 iskonto yıllık (endüstri standart)
- Türkiye'de çok pahalı algılanıyor

### Yazio
- Aylık €9.99, yıllık €59.99
- PPP yok, Türkiye'de kötü dönüşüm

### Lifesum
- Aylık €7.99, yıllık €39.99
- Daha agresif fiyatlandırma, daha yüksek conversion

### Nuveli'nin pozisyonu
- Aylık ₺99 (MFP'den ucuz, Lifesum'a yakın)
- Yıllık ₺599 (rakiplerden ~30% ucuz)
- **TR pazarı için "mantıklı ucuz"**

---

## Özet

Nuveli fiyatı:
- **Türkiye pazarı için doğru** (erişilebilir ama değersiz değil)
- **Mental model'e uyumlu** (kahvaltı fiyatı)
- **Psikolojik ipuçlarını kullanır** (anchor, tasarruf, trial)
- **Dark pattern'lerden uzak** (fake urgency, guilt trip yok)
- **Test edilebilir** (6 ayda fiyat testleri)

Başardığımızda:
- Kullanıcı fiyatı görünce "değer ediyor" der
- İptal eden de pişman değil, "güzeldi" der
- Pazar refleksi "pahalı" değil, "adil" olur
