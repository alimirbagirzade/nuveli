# Kullanıcı Segmentleri ve Yaşam Döngüsü

Bu belge, Nuveli'nin kullanıcılarını nasıl segmentlere ayırdığını ve her segmenti nasıl farklı yönettiğini tanımlar.

---

## Temel İlke

**Tek bir kullanıcı yok.** Farklı kullanıcıların farklı ihtiyaçları, farklı motivasyonları, farklı risk profilleri var. Ürünü hepsine aynı sunarsak hiçbirine tam hizmet etmiş olmayız.

Segmentasyon bir etiketleme değil, bir **hizmet stratejisi**dir.

---

## Ana Segmentler

### Segment 1 — "İlk Denemeci" (First-timer)

**Profil:**
- Hiç kalori takibi yapmamış
- Onboarding sonrası 1-7 gün
- Motivasyon yüksek ama şüpheli

**İhtiyaçları:**
- Düşük sürtünme
- Hızlı ilk başarı hissi
- Yargısız karşılama

**Nuveli stratejisi:**
- İlk öğünü hemen ekletsin, AI tahminini zorlamadan önce göstersin
- İlk hafta paywall gösterilmez
- Koç karşılama mesajı sıcak ve kısa
- Empty day kartı hemen çalışır

**Risk:**
- %60'ı ilk hafta kaybedilir (sektör ortalaması)
- Hedef: %40 retention (7 gün)

---

### Segment 2 — "Geri dönen" (Returning)

**Profil:**
- Daha önce başka bir kalori uygulaması denemiş, bırakmış
- Nuveli'ye şüpheli geldi
- "Hadi bunu da deneyelim" tavrında

**İhtiyaçları:**
- Farklı bir şey olduğunu görmek
- Hızlı fark — ilk 3 günde anlıyorlar
- "Yine aynı uygulama" olmadığına ikna

**Nuveli stratejisi:**
- Onboarding'de ton hemen farklı olsun ("yargısız destek" vurgusu)
- Koç ilk mesajda "bu farklı" hissini versin
- Recovery gününün varlığı gösterilmeli

**Tespit:**
- Onboarding'de "daha önce kalori takibi yapmış mıydın?" sorulabilir (v2)
- Veya davranıştan tespit: hızlı tempo + derin feature kullanımı

---

### Segment 3 — "Derin kullanıcı" (Power user)

**Profil:**
- 30+ gün aktif
- Her gün kayıt
- Makro takip ediyor
- Koç ile sohbet eder

**İhtiyaçları:**
- Daha derin veri
- Customization (koç persona değişimi, vb.)
- Advanced insights

**Nuveli stratejisi:**
- Bu kullanıcı premium olmalı zaten
- Aylık insight raporlarında daha derin kırılımlar
- Beta özelliklere erken erişim teklifi
- "Ambassador" program davetiyesi

**Value:**
- En değerli kullanıcı segmenti
- Referral'ı bu kitle yapar
- App Store review'larını bunlar bırakır

---

### Segment 4 — "Ara sıra kullanan" (Casual)

**Profil:**
- Haftada 2-3 gün kayıt
- Streak yapmaz
- Koç ile az konuşur

**İhtiyaçları:**
- Baskısız kullanım
- "Her gün kayıt tutmalıyım" hissi olmadan değer

**Nuveli stratejisi:**
- Streak'in önemini abartma
- Haftalık özeti bile eksik veriyle yapabilsin
- Bildirimler daha az sık

**Risk:**
- Kolay kaybediliyor
- Ama bu kitle pazarın büyük kısmı (%40-50)

---

### Segment 5 — "Zorlanan" (Struggling)

**Profil:**
- Sürekli "bad" veya "rough" check-in
- Düşük kalori takibi (kısıtlama davranışı?)
- Risk kelimeleri geçmişi

**İhtiyaçları:**
- Yargısız alan
- Profesyonel destek bilgisi
- Baskı değil, destek

**Nuveli stratejisi:**
- Koç otomatik "gentle" moduna geçer
- Paywall azaltılır (baskı olmamalı)
- Kalori hedefi görünürlüğü azaltılabilir
- Safety resources kolayca erişilebilir

**Hassas:**
- Bu segmenti yanlış yönetmek ciddi etik sorun
- `docs/protocols/safety-wellness-boundary.md` kurallarına sıkı uyum

---

### Segment 6 — "Özel durum" (Special)

**Profil:**
- Onboarding'de hamilelik / ED geçmişi / kronik hastalık işaretledi

**İhtiyaçları:**
- Kalori hedefi dayatılmamalı
- Wellness boundary sıkı
- Profesyonel yönlendirme hazır

**Nuveli stratejisi:**
- Kalori önerisi yok
- Makro/kalori grafikleri azaltılmış
- Koç sayısal öneri üretmez
- Her ekranda hatırlatıcı banner opsiyonel

**Etik önemli:**
- Bu kullanıcıya yanlış mesaj = potansiyel zarar
- Product team'de "yeni özellik eklenince bu kullanıcıya ne olur?" check-listesi

---

## Lifecycle Aşamaları

### 1. Keşif (Discovery) — Gün -∞ ile 0

Kullanıcı Nuveli'yi duyar:
- Arkadaşından (WoM)
- App Store araması
- Sosyal medyadan
- Landing sayfasından

**Önemli:**
- İlk izlenim = indirme kararı
- App Store kopyası kritik
- Landing page hikayeyi anlatır

---

### 2. Onboarding — Gün 0

Kullanıcı uygulamayı açtı.

**Bu anda kaybedilmemeli:**
- Kabul ekranları engel değil
- Onboarding maksimum 2-3 dakika
- İlk koç mesajı sıcak

**Terk oranı:** %30'a kadar kabul edilebilir (sektör ~%40-60)

---

### 3. İlk Başarı — Gün 1-3

Kullanıcı ilk değeri hisseder.

**İdeal senaryolar:**
- İlk öğün analizi başarılı → "AI gerçekten çalışıyor"
- Koçtan anlamlı bir yanıt → "bu farklı"
- Home ekranında güzel grafik → "ilerleme hissedilir"

**Terk sinyalleri:**
- AI yanlış tahmin ediyor → düzeltme sürtünmeli
- Koç cliché cevaplar veriyor → AI kalitesi sorunu
- Uygulama açılış yavaş → teknik sorun

**Retention hedef:** %50 (3 gün sonra hâlâ açanlar)

---

### 4. Alışkanlık Oluşumu — Gün 4-14

Kayıt tutma rutine dönüşüyor.

**Olumlu sinyaller:**
- Push bildirimlere açma oranı yüksek
- Birden fazla meal/gün kaydediyor
- Check-in yapıyor

**Negatif sinyaller:**
- 2-3 gün hiç açılmıyor
- Sadece manuel giriş (AI'yi kullanmıyor)
- Koç ile hiç etkileşim yok

**Retention hedef:** %30 (2 hafta sonra aktif)

---

### 5. Paywall Karşılaşması — Gün 7-14

Kullanıcı değere inanır, premium teklifi gelir.

**İdeal:**
- Kullanıcı **hazır** anında görür ("ah keşke sınırsız olsa")
- Trial başlatır
- 7 gün premium'u tadar

**Kötü senaryo:**
- Kullanıcı hazır değilken paywall ile karşılaşır
- "Sürekli para istiyorlar" his
- Uninstall

**Trial start rate:** %15-20 (bu aşamadaki aktif kullanıcılar)

---

### 6. Derinleşme — Gün 15-30

Kullanıcı uygulama ile ilişki kurar.

**Derinleşme sinyalleri:**
- Koç persona değiştirdi (engage)
- Weekly summary açıyor
- Profile tamamlıyor (boy, kilo güncelliyor)

**Premium dönüşüm:**
- Trial → paid geçiş burada olur
- %35-40 conversion hedefi

---

### 7. Sürdürme (Maintenance) — Gün 30+

Uzun vadeli kullanım.

**Profil:**
- Alışkanlık yerleşti
- Streak tutuyor olabilir
- Premium aylık/yıllık

**Risk:**
- Sıkıcılaşma
- Life change (hamilelik, taşınma, iş değişimi)
- Rakip ürüne geçme

**Stratejiler:**
- Aylık insight raporu (yeni şey göster)
- Yeni koç persona testleri
- Seasonal content

---

### 8. Kaybetme Riski — Değişken

Kullanıcı kaybolur veya iptal eder.

**Erken sinyaller:**
- 7+ gün uygulamayı açmadı
- Premium iptal etti
- Uninstalled (tespit: event'ler gelmiyor)

**Win-back:**
- E-posta kampanyası ("seni özledik" değil, "yeni özellik bu")
- Push notification (cep tercih varsa)
- 3 ay sonra tekrar

---

## Segment × Lifecycle Matrix

Farklı lifecycle aşamalarında segmentler farklı davranır. Örnek:

| Segment | Onboarding | İlk Başarı | Alışkanlık | Paywall | Sürdürme |
|---------|-----------|-----------|-----------|---------|----------|
| First-timer | %70 tamamlar | %40 kalır | %25 aktif | %15 trial | %10 uzun vadeli |
| Returning | %85 tamamlar | %60 kalır | %40 aktif | %25 trial | %20 uzun vadeli |
| Power user (olacak) | %95 tamamlar | %90 kalır | %85 aktif | %60 trial | %70 uzun vadeli |
| Casual | %60 tamamlar | %30 kalır | %15 aktif | %5 trial | %10 low-engage |
| Struggling | %70 tamamlar | Değişken | Değişken | Az gösterilir | Hassas |
| Special | %90 tamamlar | %80 kalır | %70 aktif | Sınırlı | Stabil |

(Rakamlar tahmin — launch sonrası gerçek veriyle güncellenir.)

---

## Segment Belirleme — Nasıl Tespit Ederiz?

### Onboarding'de tespit

- "Daha önce kalori takibi yaptın mı?" → first-timer vs returning
- Özel durum işaretlemeleri → special segment
- Hedef + aktivite → light signal

### Davranıştan tespit (ilk 7 gün sonrası)

- Kayıt sıklığı → casual vs power
- Koç engage oranı → casual vs power
- Check-in mood ortalaması → struggling tespiti

### Risk tabanlı tespit

- Tetikleyici kelimeler → struggling
- Düşük kalori + kısıtlama dili → low-intake risk
- Kriz kelimeleri → derhal safety protokolü

### Segment değişimi

Segmentler sabit değil. Kullanıcı zamanla segment değiştirir:
- First-timer → Power user (başarılı)
- First-timer → Lost (terk)
- Casual → Struggling (hayat zorlaşır)
- Struggling → Stable (destek çalışır)

Sistem haftalık bu geçişleri yeniden değerlendirmeli.

---

## Kişiselleştirme Stratejisi

### Ton

- **First-timer** için koç daha tanışmacı
- **Power user** için koç daha challenging
- **Struggling** için koç daha nazik (her persona otomatik gentle)

### İçerik

- **First-timer** için basit metrikler
- **Power user** için detaylı kırılımlar
- **Casual** için haftalık özet key insights

### Bildirim sıklığı

- **First-timer** — daha sık (alışkanlık kurma)
- **Power user** — gerçekten değerli olanlar
- **Casual** — minimum (rahatsız etmemek)
- **Struggling** — hassas (sadece destek)

---

## Edge Case Segmentleri

### "Abonelik hopper"

Trial alır, iptal eder, e-postasını değiştirip tekrar trial alır.
- Tespit: device ID + IP + davranış pattern
- Çözüm: device-level tracking, abuse limit

### "Sadece manuel"

Fotoğraf hiç çekmez, sadece manuel giriş yapar.
- Neden: AI'ye güvenmiyor? Gizlilik endişesi? Foton kullanmıyor?
- Strateji: "AI denemek ister misin?" light prompt, bir kere

### "Ultra minimal"

Sadece meal ekler, başka hiçbir şey (koç, check-in, su) yok.
- Neden: sadece bu özelliği istiyor
- Strateji: Bu kullanıcıya uygulama dar ama değerli. Rahatsız etme.

### "Coach-only"

Sadece koçla konuşur, meal kaydı yapmaz.
- Bu ilginç bir pattern — wellness chatbot olarak kullanıyor
- Strateji: Belki v2'de bir "Coach-only" mode düşünülebilir

---

## Data Privacy ve Segmentasyon

### KVKK uyumu

Segmentasyon kullanıcı verisini **analytics amaçlı** işler.
- Anonymous/aggregated bazda
- Kişisel tanımlayıcı olmadan (user_id hash'lenmiş)
- Reklam amaçlı asla kullanılmaz

### Kullanıcı hakları

- Kullanıcı "segmentimi nasıl görürüm" diye sorabilir
- Datayı export ederken segment bilgisi dahil
- Kullanıcı istediğinde manual segment override olabilir

---

## Yapılmayanlar

- **Dark pattern segmentasyon** — "bu kullanıcı ödeyebilir, ona yüksek fiyat göster"
- **Ayrımcılık** — yaş/cinsiyet/bölge bazlı agresif teklifler
- **"Vip" sınıfı** — elit kullanıcıya farklı ton, etik değil

---

## Ölçümler

### Segment başına metrikler

- **Retention by segment** (Day 1/7/30)
- **Conversion rate by segment**
- **LTV by segment** (en değerli segment hangisi)
- **Churn by segment** (nerede kaybediyoruz)

### Segment hareketleri

- First-timer → Power user conversion ne kadar
- Struggling → Stable geçişi ne kadar
- Power user → Churn oranı ne kadar

---

## Özet

Nuveli 6 segment için 6 farklı hizmet sunar:
- **First-timer** karşılanır
- **Returning** ikna edilir
- **Power user** derinleştirilir
- **Casual** baskısız tutulur
- **Struggling** korunur
- **Special** saygıyla tutulur

Her karar, "bu hangi segmenti etkiliyor" süzgecinden geçer. Ürün tek bir şey olmaya çalışmaz — bir platform olur, farklı insanlar için farklı değer yaratır.
