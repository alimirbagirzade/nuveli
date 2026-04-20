# Öğün Giriş Akışı

Bu belge, kullanıcının bir öğünü uygulamaya kaydetme sürecini tanımlar.

---

## Genel İlke

**Sürtünme düşmanımızdır.** Kullanıcı öğünü yedikten sonra 30 saniye içinde kaydedemiyorsa, bir daha kaydetmez. Her ekstra tap, her karar noktası, her form alanı kaybettiğimiz kullanıcıdır.

**Kritik metrik:** İlk öğünün fotoğrafından onaylanan kayda kadar süre < 20 saniye.

---

## Akış Şeması

```
Home → "Öğün Ekle" butonu
   ↓
Meal Capture
   ├─→ Kamera çek
   ├─→ Galeri seç
   └─→ "Manuel giriş" linki
   ↓
Analyze (2-4 saniye)
   ↓
Analiz Sonucu
   ├─→ High/Medium confidence → Onayla veya Düzenle
   └─→ Low confidence → "Emin değilim" banner + Düzenle CTA
   ↓
Home (günlük özet güncellendi)
```

---

## 1. Meal Capture Ekranı

### Giriş noktaları
Kullanıcı buraya üç yerden gelebilir:
1. Home → "Öğün Ekle" hızlı aksiyon butonu
2. Tab bar → Öğün ekle (+) butonu
3. Bildirim → "Öğle yemeğini ekleyelim mi?" → direkt

### Ekran yapısı
- **Başlık:** "Öğün Ekle" (üstte)
- **Kamera önizleme alanı** (büyük, ekranın %60'ı)
  - Eğer kamera izni yoksa: gri kare + "Kameraya erişim izni ver" butonu
  - İzin varsa: canlı kamera feed
- **3 buton alt sırada:**
  - Galeri (ikon)
  - Çek (büyük, merkezi, beyaz yuvarlak)
  - Flash aç/kapa (ikon)
- **Alt metin alanı (opsiyonel, collapsible):**
  - "Yemeği yaz (opsiyonel)" → açılır text input
- **Alt link:** "Fotoğraf çekmeden, manuel giriş"

### Karar — neden kamera direkt açık, başka menü yok

Alternatif: "Kamera / Galeri / Manuel" seçim ekranı gösterilebilirdi. Ama çoğu kullanıcı kamera kullanacak, bu bir ekran kazandırır. Galeriye geçmek isteyen ikon'a basar, manuel isteyen alt link'e.

### Karar — neden metin alanı collapsible

Fotoğraf + metin birleşimi en iyi sonucu verir ("tavuk döner, normal porsiyon" yazmak AI'yi doğruluğunu artırır). Ama ilk kullanıcının metin yazması beklenmez. Açılır yapı ikisine de yer açar.

### Edge cases

- **Kamera izni reddedilmiş:** "Fotoğraf çekmek için kamera erişimi gerekli. Ayarlar'dan açabilirsin." + "Galeriden seç" alternatifi
- **Fotoğraf blurry:** Yükleme sırasında sunucu değil, client-side basit kontrol (laplacian variance < threshold) ile uyar: "Biraz bulanık görünüyor, tekrar çeker misin?"
- **İnternet yok:** "Bağlantı kurulamadı. Manuel giriş yapmak ister misin?" → manuel ekrana yönlendir

---

## 2. Analyze Ekranı (geçiş)

AI analizi tipik olarak 2-4 saniye sürer. Bu süre kullanıcıya kötü hissettirmemeli.

### Ekran
- Fotoğraf (kullanıcının çektiği, tam ekran)
- Üstte loading indicator
- Alt metin: kısa, değişen mesajlar:
  - 0-2sn: "Yemeğine bakıyorum..."
  - 2-4sn: "Besin değerlerini hesaplıyorum..."
  - 4+sn: "Biraz vakit alıyor, sabret..."

### Karar — neden yemek kalır ekranda

Fotoğrafı kaybedip sadece loading spinner göstermek yanlış — kullanıcı "yemeğim nerede" hissine kapılır. Fotoğraf kalınca ne olduğu belli, sistem sadece düşünüyor.

### Karar — neden mesajlar değişiyor

Sabit "Analiz ediliyor..." mesajı 3 saniye sonra sıkılır. Değişen mesaj sistemin çalıştığını hissettirir. Yaratıcı mesajlar değil, gerçek iş açıklayan mesajlar.

---

## 3. Analiz Sonucu Ekranı

Analiz bitti. Şimdi kullanıcı onaylayacak, değiştirecek veya iptal edecek.

### High confidence (AI emin)

**Ekran:**
- Üstte küçük fotoğraf (thumbnail)
- Yemek adı: büyük (örn. "Tavuk göğsü + pilav + salata")
- 4 kart alt alta veya grid:
  - Kalori: "520 kcal"
  - Protein: "42 g"
  - Karbonhidrat: "55 g"
  - Yağ: "12 g"
- Öğün tipi seçici: breakfast/lunch/dinner/snack (zaman baz alarak akıllı varsayılan)
- 2 buton altta:
  - Solda: "Düzenle" (outlined)
  - Sağda: "Onayla" (dolu, primary)

### Medium confidence

High ile aynı ama üstte küçük banner:
> "Yaklaşık tahminim bu. Doğruysa onayla, değilse düzenle."

### Low confidence

Daha ciddi bir banner (turuncu):
> "Tam emin olamadım. Lütfen kontrol et ve düzeltebileceklerini düzelt."

Değerler yine gösterilir ama "Düzenle" butonu daha belirgin, "Onayla" gri.

### Failed (AI yapamadı)

Analiz hiç sonuç çıkaramazsa:
- Ekran: "Bu fotoğraftan anlayamadım 🤔"
- "Manuel giriş yap" primary buton
- "Başka fotoğraf dene" secondary buton

### Karar — neden düzenle ve onayla iki farklı buton

Alternatif: tek "Devam" butonu, sonra düzenleme formu. Ama high-confidence'da çoğu kullanıcı düzeltme istemez, "Onayla" direkt kayıt açar. İki buton karışık gelebilir, ama kullanıcı istatistiği: %70 onay, %25 düzenle, %5 iptal.

### Öğün tipi akıllı varsayılan

Saat baz alarak:
- 05:00 - 10:30 → breakfast
- 11:00 - 14:30 → lunch
- 18:00 - 22:00 → dinner
- Diğer saatler → snack

Kullanıcı yanlışsa değiştirir. %85 doğru tahmin ediyoruz.

---

## 4. Düzenleme Ekranı

"Düzenle" butonuna basınca değerler editable hale gelir.

**Ekran:**
- Fotoğraf thumbnail (değişmez)
- Yemek adı: **editable text field** (eski değer ön-doldurulmuş)
- Kalori, Protein, Karb, Yağ: hepsi **editable number field**
- Alt: "Değişikliği kaydet" butonu

### Karar — neden yemek adı editable

Kullanıcı "Tavuk göğsü" değil "Tavuk göğsü tandır" yazmak isteyebilir. Adı düzenleyebilmesi kayıt kalitesini artırır. Listelerde daha kullanışlı.

### Karar — neden kalori + makro ayrı ayrı düzenleme

Alternatif: sadece kalori düzenle, makroları kendi hesaplasın. Ama macro tracking ciddi kullanıcı için önemli. Hepsi editable, sen ne dersen o.

---

## 5. Manuel Giriş Ekranı

Kullanıcı fotoğraf hiç çekmek istemiyor veya tahmin tutmadı, direkt manuel giriyor.

**Ekran:**
- Başlık: "Manuel Giriş"
- Form:
  - Yemek adı (required)
  - Kalori (required)
  - Protein, Karb, Yağ (opsiyonel)
  - Öğün tipi (akıllı varsayılan)
- Alt: "Kaydet" butonu

### Karar — neden makrolar opsiyonel

Kullanıcı sadece kalori biliyor olabilir. Makroları zorunlu yaparsak %40'ı bırakır. Opsiyonel, boşsa `null` olarak kaydedilir.

### Karar — neden autocomplete yok (şimdilik)

"Tavuk göğsü" yazınca USDA veritabanından öneriler gelebilirdi. V2'de yapılır. MVP'de kompleks olması gerekmeyen bir şey.

---

## 6. Başarı Ekranı (yok)

Kayıt sonrası ayrı "Başarıyla eklendi" ekranı yok. Direkt home'a dön. Küçük bir snackbar:
> "Öğün eklendi."

### Karar — neden kutlama yok

"Tebrikler! İlk öğününü kaydettin! 🎉" tarzı bildirimler ilk kullanımda hoş, sonraki her eklemede sinir bozucu olur. Sessiz başarı daha sürdürülebilir.

**İstisna:** Gamification isteniyorsa, sadece milestone'larda bildirim:
- 7. gün streak
- 30. gün streak
- 100. öğün

V2.

---

## 7. Öğün Silme

Kullanıcı home'daki listeden bir öğüne swipe-left yapar veya long-press:
- "Sil" butonu çıkar
- Onay modal: "Bu öğünü silmek istediğine emin misin?"
- Onaylarsa → silinir, günlük toplam yeniden hesaplanır

### Karar — neden onay modal

Öğün silme geri alınamıyor (MVP'de). Yanlış tap'e karşı koruma.

---

## 8. Günlük Öğün Listesi (home bileşeni)

Home ekranında o günün öğünleri listelenir. Bu akış kısa ama önemli:

**Liste:**
- Her satır: thumbnail + yemek adı + kalori + zaman
- Saate göre sıralı (yeni en üstte)
- Tap → öğün detayı (düzenleme + silme)

**Empty state:**
"Henüz öğün kaydın yok. İlk yemeği ekleyelim!"
+ "Öğün Ekle" butonu

---

## 9. Limit Aşımı (Free Tier)

Free kullanıcı günde 3 AI analizi yapabilir. 4. analizde:

**Ekran:**
- Friendly mesaj: "Bugünkü AI analizini kullandın. Devam etmek ister misin?"
- Seçenekler:
  - "7 gün ücretsiz dene" (primary) → Paywall
  - "Manuel giriş yap" (secondary) → Manuel ekrana git

### Karar — neden hard block yok

Kullanıcı limit aşınca "bitti, yarın gel" dersek öfkeli gider. Manuel giriş her zaman alternatif, bu ücretsiz ama limitsiz. Paywall nazik bir öneri.

---

## 10. Metrikler

- `meal_analysis_started` (source: photo|text|both)
- `meal_analysis_completed` (confidence, duration_ms)
- `meal_confirmed` (source: ai_confirmed|ai_edited|manual, confidence)
- `meal_deleted`
- `meal_limit_reached` (tier)
- `meal_analysis_failed` (error_type)

**Hedef oranlar:**
- Confirmation rate (high confidence): %80+
- Edit rate (high confidence): %15 ideal, %30+ ise AI kalitesi düşük demek
- Manual entry oranı: %20'den az olmalı (fotoğraf alışkanlığı kuruluyorsa sağlıklı)

---

## 11. Yapılmayanlar

- **Barkod tarama** — V2.
- **Restoran menüleri** — V2.
- **Yemek tarifi görünümü** — V2, belki hiç.
- **Porsiyon tahmini interaktif** ("büyük mü küçük mü?" sorusu) — V2'de deneyebiliriz.
- **Ses ile giriş** — şu an öncelik değil.
