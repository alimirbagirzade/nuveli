# A/B Test Stratejisi

Bu belge, Nuveli'nin launch sonrası hangi varsayımları nasıl test edeceğini tanımlar.

---

## Temel İlke

**Kararların çoğu test edilerek verilir, varsayımlarla değil.** Ama her şey test edilmez — test maliyetlidir, kullanıcı havuzunu paylaşır, zaman alır. Sadece **büyük etkili** şeyleri test ederiz.

**İyi bir A/B testi:**
- Spesifik bir hipotezi sorar
- Tek bir değişken değiştirir
- Net bir başarı kriteri var
- Yeterli örneklem büyüklüğü var
- Bitme zamanı var (belirsiz "bekle bak" yok)

---

## Test Yapmak İçin Gerekli Altyapı

### Firebase Remote Config
- Feature flag'lar
- A/B grupları (%50/%50 veya custom split)
- Minimum %10 grup koruma

### Firebase Analytics
- `ab_test_group` custom dimension her event'te
- Conversion funnel tracking

### Minimum örneklem

Her varyant için:
- **Conversion testi:** 500+ kullanıcı
- **Engagement testi:** 300+ kullanıcı
- **UI preference:** 200+ kullanıcı
- **Retention testi:** 1000+ kullanıcı (uzun kuyruk etkisi için)

### Minimum süre
- 2 hafta (haftasonu/hafta içi farklarını yakala)
- Bayram/tatil dönemleri hariç tut
- Yeterli örneklem yoksa uzat (3-4 hafta)

---

## Test Önceliklendirme

### Nasıl seçeriz

RICE skoru kullanıyoruz:

- **Reach:** Kaç kullanıcı etkilenir
- **Impact:** Etki büyüklüğü (1-3)
- **Confidence:** Hipoteze ne kadar güveniyoruz (0.3-1.0)
- **Effort:** Test için gerekli iş (1-5)

**Skor = (Reach × Impact × Confidence) / Effort**

En yüksek skorlu 3-5 test kuyruğa alınır. Aynı anda max 2 test çalışır.

---

## Öncelikli Test Listesi (Launch sonrası 6 ay)

### Test 1 — Paywall tetik zamanlaması

**Hipotez:** Paywall'ı onboarding'in 3. gününde göstermek yerine 7. günde göstermek, trial conversion'ı artırır.

- **Varyant A (kontrol):** İlk paywall limit aşımında gösterilir (gün 1-3 arası)
- **Varyant B:** İlk 7 gün paywall hiç gösterilmez, sadece milestone'da (streak kutlaması)

**Metrik:** Trial başlatma oranı (14 gün sonrası)

**Beklenti:** Varyant B %20+ daha yüksek trial conversion

**Süre:** 4 hafta

**Risk:** Gelir kaybı — eğer varyant B çok daha iyi, geçiş pozitif. Aksi durumda revert.

---

### Test 2 — Onboarding uzunluğu

**Hipotez:** 11 adımlı onboarding çok uzun. 7 adıma indirince terk azalır.

- **Varyant A (kontrol):** 11 adım (mevcut)
- **Varyant B:** 7 adım — Özel durumlar, bildirim tercihi ve Koç persona seçimi skip edilebilir

**Metrik:**
- Onboarding completion rate
- 7 gün retention (kısa onboarding ile daha az kayıp mı)

**Beklenti:** Varyant B %10 daha fazla tamamlama, retention değişmez veya hafif artar

**Süre:** 3 hafta

**Not:** Skip edilen adımları kullanıcı sonradan Ayarlar'dan doldurabilir

---

### Test 3 — Koç persona default

**Hipotez:** Kullanıcıların çoğu "Destekleyici" seçiyor — bu pre-select ile daha da artar, diğer persona'lar unutulur.

- **Varyant A (kontrol):** Seçim yapmadan devam yok (mevcut)
- **Varyant B:** "Destekleyici" pre-selected, değiştirmezse bu aktif

**Metrik:**
- Persona dağılımı (%)
- Koç memnuniyet — 7 gün sonra bir mini feedback sorusu

**Beklenti:** Varyant B'de Destekleyici %85+ olur, ama memnuniyet değişmez

**Süre:** 3 hafta

**Karar:** Memnuniyet aynıysa B (daha hızlı onboarding), düşerse A (seçim hissi önemli)

---

### Test 4 — Meal analiz başarı mesajı

**Hipotez:** Şu an sessiz kayıt (snackbar). Küçük bir "Eklendi ✓" kutlaması kullanıcıyı daha çok eylem yapmaya iter.

- **Varyant A (kontrol):** Sessiz snackbar "Öğün eklendi"
- **Varyant B:** Kısa animasyon + "Kaydedildi. Gün özeti güncellendi."

**Metrik:** Günlük ortalama öğün kayıt sayısı

**Beklenti:** Varyant B'de %5-10 daha fazla ikinci/üçüncü öğün kaydı

**Risk:** Gereksiz ödüllendirme hissi, uzun vadede sıkıcılaşabilir

---

### Test 5 — Trial uzunluğu

**Hipotez:** 7 gün trial yerine 14 gün daha çok conversion getirir — kullanıcı gerçek değeri görür.

- **Varyant A (kontrol):** 7 gün
- **Varyant B:** 14 gün

**Metrik:** Trial → ücretli conversion oranı

**Beklenti:** Varyant B'de conversion +%15-20

**Risk:** 14 gün bedava kullanım → bazıları iptal eder daha çok. Net gelir etkisi ölç.

**Süre:** 6 hafta (daha uzun trial, daha uzun test gerekir)

---

### Test 6 — Fiyatlandırma noktası

**Hipotez:** ₺99/ay yerine ₺79/ay daha çok conversion getirir — toplam gelir artar mı?

- **Varyant A:** ₺99/ay
- **Varyant B:** ₺79/ay

**Metrik:** MRR (Monthly Recurring Revenue) per 1000 kullanıcı

**Beklenti:** Belirsiz — fiyat elastikliği sektöre göre değişir

**Süre:** 6 hafta

**Not:** Bu testi dikkatli yap — fiyatı düşürüp geri yükseltmek risk. Grandfather varyant B'dekileri (onlar ₺79'da kalır).

---

### Test 7 — Haftalık özet zamanlaması

**Hipotez:** Pazartesi sabah haftalık özet bildirimini göndermek yerine Pazar akşam göndermek açma oranını artırır.

- **Varyant A (kontrol):** Pazartesi 10:00
- **Varyant B:** Pazar 20:00

**Metrik:** Bildirim açma oranı + özete yapılan eylem

**Beklenti:** Varyant B +%30 açma (hafta sonu refleksiyon zamanı)

---

### Test 8 — Empty day kartı içeriği

**Hipotez:** Soru yerine doğrudan eylem daveti daha çok conversion getirir.

- **Varyant A (kontrol):** "Bugün henüz kayıt yok. Başlamak için küçük bir adımla başlayalım."
- **Varyant B:** "İlk öğünü ekle, sonrası gelir." (daha direkt)
- **Varyant C:** "Fotoğraf çek, saniyeler içinde hazır." (özellik vurgusu)

**Metrik:** Kart → meal capture ekranına geçiş oranı

**3-way test!** 400+ kullanıcı/varyant gerekir. Daha uzun süre.

---

## Test Çalıştırma Protokolü

### Öncesi
1. Hipotez yaz (bir cümle)
2. Varyantları tanımla (kontrol + 1-2 alternatif)
3. Metrik seç (tek bir primary, 2-3 secondary)
4. Başarı kriteri yaz ("varyant B, kontrolden %15 daha yüksekse kazanır")
5. Örneklem büyüklüğü hesapla (G*Power veya basit calculator)
6. Süreyi belirle
7. Feature flag kur, sessizce dağıt

### Sırasında
- İlk 3 gün sadece gözlem (bug tespiti)
- Her hafta quick check (beklenmeyen büyük sapma var mı)
- Erken sonlandırma eşiği: p < 0.01 (çok güçlü sinyal) + örneklem minimumu karşılandı

### Sonrası
1. Veriyi çek
2. Güven aralığı hesapla (%95 güven)
3. Başarı kriteri karşılandı mı
4. Kazananı tam uygula
5. Belge yaz: hangi test, ne sonuç, ne öğrenildi
6. Team'e duyur (bir Slack post olur)

---

## Test Etmediğimiz Şeyler

### Etik alanlar

- **Dark pattern'ler** — "Abone ol butonunu büyütsek..." Hayır, etik değil.
- **Guilt-trip dili** — "Seni özledik, geri dön" Kullanıcı manipülasyonu.
- **Urgency false** — "Son 2 saat!" Test bile etmeyiz.

### Güvenlik alanları

- Kriz mesajı (sabit, test edilemez)
- ALO 182 gönderimi (sabit)
- Yaş kapısı (sabit)

### Çekirdek ürün tonu

- "Nuveli yargısız" — bu test edilecek bir varsayım değil, ürün değeri
- "Wellness, tıbbi değil" — yasal + etik sınır

---

## Küçük Testler (Micro A/B)

Bazı şeyler 2 hafta testi bile değmez ama test etmek istersin. Bunlar için:

### 1-günlük micro test

- Button color (primary'nin değil, secondary'nin)
- Icon seçimi
- Loading mesajı varyantı

Bunlar hızlı uygulanır, bir hafta içinde karara bağlanır.

### Polling style quick feedback

Bazı değişiklikleri A/B yerine anket ile test edebiliriz:

"Yeni koç kartı tasarımını nasıl buldun?"
- 👍 Daha iyi
- 👎 Eskisi daha iyi
- 🤷 Fark etmedim

100+ yanıt geldiğinde karar.

---

## Test Sonuçlarını Kullanma

### Kazanan varyant tam uygulanır
- Feature flag tamamen açılır
- Kod temizlenir (if/else kalmaz)
- Documentation güncellenir

### Kazanan yoksa
- Kontrol kalır
- Hipotez yanlış çıkmış olabilir
- Veya örneklem yetersiz — daha uzun sürdür

### Kazanan var ama çok küçük fark
- %5'ten küçük farklar anlamlı değil genelde
- İki varyant da ürünle uyumluysa random seç
- Daha büyük bir hipoteze zaman ayır

---

## Öğrenme Belgesi

Her test sonrası kısa bir belge:

```
# Test: [başlık]
Tarih: [2026-XX-XX]
Süre: [X hafta]

Hipotez:
Varyantlar:
Örneklem:
Sonuç: [A/B kazandı, fark %X]
Karar:
Öğrendiklerimiz:
```

Bu belgeler `docs/experiments/` altında saklanır. 6 ay sonra pattern'ler çıkar — kullanıcı hakkında genel öğrenmeler.

---

## Yapılmayanlar

- **Sürekli A/B test** — test yorgunluğu oluşur, ürün koherans kaybeder
- **Yüksek riskli finansal test tek seferde** — her zaman küçük örneklemle başla
- **Açık kullanıcı manipülasyonu testi** — dark pattern, guilt trip asla
- **PR amaçlı sahte test** — "milyonlarca kullanıcı testi" marketing yalanı

---

## Launch İlk 30 Günü

### İlk 7 gün
- Hiçbir A/B test çalışmaz
- Sadece baseline metrikleri topla
- Bug hunting

### Gün 8-30
- Test 1 (paywall timing) başlar
- Diğer testler kuyruğa alınır
- İlk sonuçlar gün 30 civarında

### 30-60 gün
- Test 1 sonuçlanır, uygulanır
- Test 2 başlar

### 60-90 gün
- Hızlı iterasyon dönemi
- 2-3 test paralel çalışabilir
- Retention cohort analizi

### 90+ gün
- Testler daha nuansed olur
- Segment-bazlı testler (örn. sadece free user, sadece 30+ yaş)

---

## Özet

**Varsayımsal değil, veri destekli ürün.** Ama overkill değil — önemli olan büyük etkili şeyleri test etmek. Her karar testten geçmez, ama stratejik kararlar geçer.

Başardığımızda:
- Kararlar "herhalde iyi olur" değil "test ettik, iyi oluyor" oluyor
- Team kültürü "sanıyorum" yerine "ölçelim" oluyor
- Ürün 3 ayda 1 önemli dönüş yapıyor, çünkü öğreniyoruz
