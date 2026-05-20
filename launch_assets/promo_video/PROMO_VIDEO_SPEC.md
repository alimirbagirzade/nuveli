# 🎬 Promo Video Spec — Nuveli App Preview

**Hedef:** App Store "App Preview" video — listing'in en üstünde otomatik oynayan 15-30 saniyelik tanıtım.

**Apple:** %25'e kadar conversion artışı sağlıyor (Apple'ın kendi data'sı).
**Google Play:** YouTube link kabul ediyor.

**Bu opsiyonel ama önerilen.** Launch'a yetişmezse v1.1'de eklenebilir.

---

## 📐 Teknik Spec

### Apple App Preview
| Özellik | Değer |
|---|---|
| Süre | **15-30 saniye** |
| Çözünürlük | 1080 × 1920 (Portrait) veya 1920 × 1080 (Landscape) |
| Frame rate | 30 fps |
| Codec | H.264 |
| Container | MP4 veya MOV |
| Audio | AAC (opsiyonel ama önerilen) |
| Dosya boyutu | Max 500 MB |
| Number of previews | Cihaz başına 3 tane (6.5", 5.5", iPad) |

### Google Play
- YouTube link (Unlisted veya Public)
- Süre: önerilen 30s-2dk
- Apple'dan farklı: değil app preview, **YouTube hosted** video

---

## 🎞️ Storyboard (30 saniye)

### Sahne 1 (0:00-0:03) — Hook
**Görsel:** Yemek fotoğrafı çekiliyor (eli kamera kullanırken)
**Metin overlay:** "What's in your meal?"
**Müzik:** Cinematic build-up (Epidemic Sound)

### Sahne 2 (0:03-0:07) — AI Magic
**Görsel:** Meal Scan screen — fotoğraf → AI loading → sonuç
**Animasyon:** Detected foods listeye düşüyor, kalorler hesaplanıyor
**Metin overlay:** "AI calculates it. In seconds."

### Sahne 3 (0:07-0:12) — Dashboard
**Görsel:** Dashboard kalori ringi dolarken, makro barları animasyonla doluyor
**Metin overlay:** "Track every meal effortlessly"

### Sahne 4 (0:12-0:17) — AI Coach
**Görsel:** AI Coach screen — daily tip kartı kayıyor
**Metin overlay:** "Your personal AI coach"

### Sahne 5 (0:17-0:22) — Analytics
**Görsel:** Weight trend line çiziliyor (8 hafta düşüş)
**Metin overlay:** "See your progress"

### Sahne 6 (0:22-0:27) — Premium / Multiple Features
**Görsel:** Hızlı sequence: Water Tracker → Habits → Meal Planner (her biri 1.5s)
**Metin overlay:** "And so much more"

### Sahne 7 (0:27-0:30) — CTA
**Görsel:** App icon zoom in + "Nuveli" logo
**Metin overlay:** "Download Nuveli. Start free."
**Müzik:** Climax + soft outro

---

## 🛠️ Üretim Workflow

### Seçenek 1: Rotato (Önerilen, kolay)
- **Maliyet:** $19/ay (free trial var)
- **URL:** https://rotato.app
- **Özellikler:**
  - Drag-drop screenshot → 3D animated mockup
  - Camera path control
  - Hazır şablonlar
- **İdeal:** Hızlı, professional sonuç

### Seçenek 2: Apple iMovie (Ücretsiz, manuel)
1. iOS Simulator'de ekran kaydı (CMD+R)
2. iMovie'de timeline'a koy
3. Title kartları ekle (between scenes)
4. Müzik ekle (Free: Pixabay Music, YouTube Audio Library)
5. Export: 1080p, 30fps, MP4

### Seçenek 3: After Effects (Pro, full control)
- Daha fazla zaman ama yüksek kalite
- Phone mockup template'ler (Envato Elements $16.50/ay)

### Seçenek 4: Veed.io / Submagic (Web-based, AI)
- Subtitle otomatik
- Template'li hızlı edit
- $20-30/ay

---

## 🎵 Müzik

**Telif sorununu önlemek için:**

| Kaynak | Maliyet | Notlar |
|---|---|---|
| [Epidemic Sound](https://www.epidemicsound.com/) | $9-15/ay | Kalite yüksek, App Store onaylı |
| [Artlist](https://artlist.io/) | $200/yıl | Geniş katalog |
| [YouTube Audio Library](https://studio.youtube.com/) | Ücretsiz | Sınırlı seçenek |
| [Pixabay Music](https://pixabay.com/music/) | Ücretsiz | Kalite değişken |

**Önerilen tarz:**
- Cinematic uplifting electronic
- 120-130 BPM
- Build-up + climax structure
- Vokal yok (overlay metinle çakışmasın)

---

## 🍎 Apple Kuralları

### ✅ İzin Verilen
- App'in kendi screen recording'i
- Animated text/title cards
- Müzik (telifsiz)
- Voice-over (opsiyonel)
- Marketing tagline ekranlar

### ❌ Yasak
- App dışı içerik (TV, müzik klip)
- Telif sorunlu görüntü
- Misleading özellikler (app'te olmayan)
- Anti-competitive ifade
- Çocuk hedefli içerik (4+ rating için)
- Heavy splash text (her sahnede 1 cümle yeter)

---

## 📋 Google Play / YouTube

Apple App Preview ≠ Google Play promo video.

**Google Play workflow:**
1. Yukarıdaki videoyu YouTube'a yükle (Unlisted)
2. Play Console → Store listing → "Promo video" alanına URL yapıştır
3. URL formatı: `https://www.youtube.com/watch?v=XXXXXX`

**YouTube ayarları:**
- Visibility: Unlisted (Play Store'da görünür ama YouTube search'te değil)
- Audience: Not made for kids
- Category: Education veya Technology
- Title: "Nuveli — AI Calorie Coach (Promo Video)"

---

## ✅ Kontrol Listesi

- [ ] 30 saniye veya altı (Apple)
- [ ] 1080 × 1920 portrait (önerilen)
- [ ] 30 fps, H.264, MP4
- [ ] Dosya < 500 MB
- [ ] Telifsiz müzik
- [ ] App-only screen recording (PIP, TV içeriği yok)
- [ ] Marketing claims doğrulanabilir
- [ ] Her sahne 3-5 saniye (overload yok)
- [ ] Voice-over varsa: sessize alındığında metin overlay'lar yeterli
- [ ] YouTube'a Unlisted yüklendi (Google Play için)
- [ ] Apple Transporter ile App Store Connect'e upload edildi

---

## 🚨 Reject Riskleri

| Sebep | Apple |
|---|---|
| Telifli müzik | Reject + DMCA risk |
| App-dışı içerik | 2.3.10 |
| Misleading marketing | 5.4 |
| Sound issues (mono, çok yüksek) | 4.0 |

---

## 💡 İpucu: A/B Testing

Apple App Preview'ı sonradan değiştirebilirsin. Launch sonrası 2 versiyon dene:
- **V1:** "Hook → AI Magic → CTA" (action-focused)
- **V2:** "Lifestyle → Progress → Community" (aspirational)

App Store Connect'te conversion rate'i karşılaştır.

---

**Önemli:** Promo video kaliteli olmazsa, **hiç olmaması daha iyi**. Düşük kalite video conversion'ı düşürür.

Eğer launch'a yetişmezse, v1.1'de eklersin. 30 günde sonra ekleyebilirsin.
