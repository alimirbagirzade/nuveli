# Launch Sonrası İlk 90 Gün

Bu belge, Nuveli'nin yayına çıkışından sonraki ilk 90 günü tanımlar. Yayına çıkış bir bitiş değil, başlangıç — bu 90 gün ürünün kaderini belirler.

---

## Temel İlke

**Launch'tan sonraki 90 gün, önceki 6 aydan daha önemli.** Çünkü artık gerçek kullanıcılar var, gerçek veri var, gerçek para hareket ediyor. Varsayımlar sınanıyor.

Bu 90 günü **öğrenme dönemi** olarak düşünüyoruz — yeni özellik değil, ürünü anlamak.

---

## Gün 0 — Launch Günü

### Hazırlıklar (Launch'tan 7 gün önce)

- [ ] Release checklist baştan sona tamamlanmış
- [ ] Crashlytics + Analytics aktif ve test edilmiş
- [ ] Backend production'da, load test yapılmış
- [ ] App Store + Play Store onaylı, "ready for sale"
- [ ] Landing page canlı, SSL aktif
- [ ] Destek e-postası kurulu, yönlendirme çalışıyor
- [ ] Launch day communication planı hazır

### Launch Day Timeline

**06:00** — App Store'da "Release this version" (TR timezone'de canlı zaten)
**08:00** — Play Store scheduled release
**10:00** — Landing page "Beta" badge kaldırılır, "Şimdi indir" aktif
**11:00** — Social media posts (Twitter/X, Instagram, LinkedIn)
**12:00** — Kuruculukla tanınan 10-20 kişiye kişisel e-posta
**14:00** — Product Hunt launch (TR daytime, US morning için bonus)
**15:00** — İlk indirmeleri izle, crashlytics kontrol et
**18:00** — Günlük özet: kaç indirme, kaç hata, kaç feedback
**22:00** — Son kontrol, ertesi gün için hazırlık

### Launch Day Panik Kuralları

- Ciddi bug çıkarsa → App Store'u "Remove from sale" yap, düzelt, tekrar submit
- Backend overload → Render'ı scale up et (manuel)
- Kötü review gelirse → sakin yanıt ver, sorunu çöz

---

## Hafta 1 — "Canlı Tutma Haftası"

### Odaklar

1. **Kritik bug fix**
2. **Kullanıcı geri bildirimi toplama**
3. **Temel metrik baseline oluşturma**

### Günlük ritüel

Her sabah 09:00:
- Crashlytics dashboard kontrolü (crash var mı)
- Firebase Analytics: DAU, retention D1
- Backend error log'ları
- Destek e-postaları
- App Store review'lar

Her akşam 18:00:
- Günün özeti doküman
- Ertesi gün için öncelik listesi

### İlk hafta KPI'ları

- **D1 retention:** %50+
- **Onboarding completion:** %70+
- **Crash-free session:** %99+
- **Ortalama meal analiz süresi:** < 5s
- **Destek yanıt süresi:** < 24h

### Yapılacak

- **Emergency fix PRs** — kritik bug'lar hemen
- **Minor UI fix'ler** — 2-3 günde bir release
- **İlk user research** — 5 kullanıcıyla 15-dk video call
- **App Store kopya optimize** — keyword kontrol

### Yapılmayacak

- **Yeni feature** — hiç yok, kod buffer'da değilse
- **Marketing kampanyası** — organic ilk, paid sonra
- **Fiyat değişikliği** — baseline toplamadan kararsız

---

## Hafta 2-4 — "Anlama Ayı"

### Odaklar

1. **Gerçek kullanım pattern'lerini görme**
2. **Ölümcül olmayan bug'lar**
3. **İlk feature iterasyonları (varsa gerekli)**

### Veri topluyoruz

**Haftalık rapor üret:**

```
Hafta 2 - Nuveli Metrikleri
───────────────────────────

Kayıt: X yeni kullanıcı
DAU: X
D7 retention: %X
Onboarding completion: %X

Top events:
- meal_analysis_completed: X
- coach_message_sent: X
- paywall_viewed: X

Top crashes:
1. X — Y crash
2. X — Y crash

Destek geri bildirimleri:
- Y benzersiz konu
- En sık: X

Paywall:
- Views: X
- Trial starts: X
- Paid conversions: X
```

Bu rapor her Pazartesi paylaşılır.

### İlk user research turu (Hafta 3)

- 10 aktif kullanıcıyla 20 dakikalık görüşme
- 5 terk etmiş kullanıcıyla (varsa ulaşılabilirse)
- Sorular:
  - İlk kullandığında ne bekliyordun?
  - En çok beğendiğin şey?
  - En sinir bozucu şey?
  - Eksik gördüğün?
  - Arkadaşına tavsiye eder misin, neden?

### İlk iterasyon öncelikleri

Hafta 2-4'te yapılacak küçük değişiklikler:
- Onboarding'den terk olan ekran varsa o yeniden tasarlanır
- Crashlytics'te top crash'ler düzeltilir
- "Hiç kullanılmayan" özellik tespit edilirse gizlenebilir

---

## Ay 2 — "İvme Oluşturma"

### Odaklar

1. **Organic büyüme hızlandırma**
2. **Paywall optimizasyonu**
3. **İlk A/B testler**

### Organic büyüme

**ASO (App Store Optimization):**
- Keyword araştırma: "kalori takibi", "diyet", "sağlıklı yaşam", "beslenme" gibi
- App Store açıklaması optimize
- Screenshot'lar test (A/B)
- Video preview hazırla

**Sosyal medya:**
- Haftada 2-3 post (Instagram ağırlıklı)
- Kullanıcı hikâyeleri (izinli)
- Feature announcement'lar

**Community:**
- Kullanıcı WhatsApp/Discord grubu (opt-in)
- Beta tester grubu oluştur
- Erken feedback kanalı

### İlk A/B testler (Ay 2 ortasından itibaren)

Sırayla:
1. **Paywall timing** — ne zaman göstermek en iyi
2. **Onboarding uzunluğu** — 11 adım mı, 7 adım mı
3. **Koç persona default** — pre-select mı

Her test 2-3 hafta sürer. Sonuçlar belgelenir.

### İlk feature iterasyonları

Eğer veri gösteriyorsa bu ayda eklenebilir:
- **Barkod tarama** (eğer yemek veritabanı sorgusu çok istenirse)
- **Meal favorite'leri** (aynı yemeği tekrar tekrar ekleyenler için)
- **Recipe görünümü** (basit: isim + makrolar)

**Ama ana odak hâlâ temel retention.**

---

## Ay 3 — "Sürdürülebilirlik"

### Odaklar

1. **Retention odaklı iyileştirme**
2. **Monetizasyon optimizasyonu**
3. **İlk ölçeklenebilirlik hazırlığı**

### D30 Retention

Bu ayın başında D30 retention ölçülebilir hale gelir.
- **Hedef:** %15-20 (sektör ortalaması)
- Altındaysa → ürün değeri sorunu, root cause arama
- Üstündeyse → doğru yoldayız

### Monetizasyon ince ayar

- Fiyat testleri (₺89 vs ₺99)
- Yıllık paket vurgu testleri
- Trial uzunluğu (7 vs 14 gün) testi

### Teknik borç

Launch sonrası her zaman teknik borç birikir:
- Kod refactor
- Database index'leri
- Cache layer
- Error monitoring detaylandırma

**Kural:** Ay 3'te yeni feature eklerken teknik borç da azaltılır.

### Ölçek hazırlığı

Kullanıcı 10K+ olduğunda ne lazım:
- Supabase plan upgrade (bedava tier'dan pro'ya)
- Render scale-up
- Rate limiting daha sıkı
- CDN (landing için Cloudflare)

---

## İlk 90 Gün Sonu — Değerlendirme

### Başarılı launch metrikleri

- **10K+ organic indirme**
- **%20+ D30 retention**
- **%3+ paywall conversion**
- **500+ ücretli abone**
- **MRR ₺25K+**
- **App Store rating 4.3+**
- **NPS 30+**

### Problemli launch sinyalleri

- D1 retention < %40 → onboarding/ilk izlenim sorunu
- D7 retention < %15 → ürün değeri sorunu
- Paywall conversion < %1 → fiyat veya timing sorunu
- Crash rate > %1 → stabilite sorunu
- NPS < 20 → kullanıcı memnun değil

---

## 90 Gün Sonrası — 3 Olası Yol

Launch sonrası veriye göre 3 senaryo:

### Senaryo A — Başarılı Launch

**Metrikler iyi, ivme var.**

**Sonraki 90 gün:**
- Uluslararasılaşma (EN dili, Avrupa)
- Yeni özellikler (barkod, öneriler)
- Seed funding için hazırlanma (varsa ihtiyaç)
- Takım büyütme

### Senaryo B — Karma Sinyal

**Bazı metrikler iyi, bazıları kötü.**

**Sonraki 90 gün:**
- Root cause analizi — neden böyle
- Kullanıcı araştırmasına geri dön
- Bir-iki büyük özellik iyileştirmesi
- Fiyat veya monetizasyon modelini tekrar gözden geçir

### Senaryo C — Başarısız Launch

**Metrikler kötü, kaybı var.**

**Sonraki 90 gün:**
- Dürüst değerlendirme — pivot mı, kapat mı
- Temel varsayımları yeniden sor
- Kullanıcılarla derin görüşmeler
- Eğer pivot: başka bir ürün fikrine
- Eğer kapat: teşekkür e-postası, veri silme, graceful shutdown

---

## Kurucu Odak Alanları

### İlk ay — Ürün

- Kod
- Bug fix
- User research
- Metrik izleme

### İkinci ay — Büyüme

- ASO
- Social media
- Community
- Early adopter ilişkileri

### Üçüncü ay — Sürdürülebilirlik

- Yol haritası
- Takım planı (eğer büyüyecekse)
- Fonlama (eğer gerekli)
- Uzun vadeli vizyon

**Bu sıra değişebilir** — gerçek veriye göre ayarlanır.

---

## Psikolojik Hazırlık

### Launch heyecanı sonrası

Launch'tan 2-3 hafta sonra bir "low" gelecek. Bu normal.
- Sayılar beklendiğinden düşük olacak
- Kimse yazmamış gibi gelecek
- "Yanlış şey mi yapıyorum" hissi

### Bununla başa çıkma

- İlk 48 saatteki sayıları ölçüt yapma
- Haftalık trend'lere bak
- 5 gerçek kullanıcının hayatında fark yaratmak büyük şey
- Uzun oyun — 3 ay minimum sonra değerlendir

### Destek sistemi

- Bir mentor veya danışman (haftalık 30 dk)
- Başka kurucularla peer group
- Sağlıklı rutin — uyku, egzersiz, sosyal hayat

---

## Özet

İlk 90 gün için özet:

- **Hafta 1:** Canlı tut, bug fix
- **Hafta 2-4:** Anla, veri topla
- **Ay 2:** İvme yakala, büyü, test et
- **Ay 3:** Sürdür, optimize et, hazırlan

Her hafta sonu: "bu hafta ne öğrendim, sonraki hafta ne yapacağım?"
Her ay sonu: "hedefler karşılandı mı, öncelikler değişti mi?"

90 günün sonunda 3 şey biliyor olmalıyız:
1. Ürün gerçekten değer yaratıyor mu
2. Fiyatlandırma doğru mu
3. Büyüme nasıl olacak

Bu üçüne cevap alırsak — şirketi inşa edebiliriz.
