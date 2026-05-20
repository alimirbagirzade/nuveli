# 📸 Screenshot Story — Nuveli App Store Listing

**Hedef:** App Store + Google Play için 6 screenshot — value prop'larını anlatan ve indirme oranını artıran tasarım.

**Önemli:** Apple ve Google'ın algoritmaları **ilk 2-3 screenshot'a** ağırlık verir. En güçlü mesajları en başa koy.

---

## 🎬 6 Screenshot Hikayesi (Sıralama Kritik!)

Her screenshot bir **value proposition** ileri sürer. Önce **WHY** (faydaya çağır), sonra **HOW** (özelliği göster).

### 1️⃣ Dashboard — "Track every meal effortlessly"
- **Başlık (büyük üst):** "Track every meal effortlessly"
- **Alt başlık:** "AI hesaplar, sen sadece yersin"
- **Görsel:** Dashboard ekranı (Görsel 1)
  - Calorie ring 1,480 / 2,200 görünür
  - 3 makro bar dolu
  - Bugünün 2-3 öğünü listede
  - "Add Food" CTA dikkat çekici
- **TR versiyonu:** "Her öğünü zahmetsizce takip et"

### 2️⃣ AI Meal Scan — "AI sees what you eat" 🪄
- **Başlık:** "AI sees what you eat"
- **Alt başlık:** "Photo in, calories out — in seconds"
- **Görsel:** Meal Scan ekranı (Görsel 2)
  - Yemek fotoğrafı (ızgara tavuk + salata)
  - "Detected: Grilled chicken (180g) • 320 kcal"
  - Portion Insight: 85/100 yeşil
- **TR:** "Fotoğraf çek, kaloriyi öğren"
- **Bu en güçlü screenshot** — kullanıcının "Wow" dediği an

### 3️⃣ Analytics — "See your progress"
- **Başlık:** "See your progress"
- **Alt başlık:** "Weight, calories, macros — at a glance"
- **Görsel:** Analytics ekranı (Görsel 4)
  - Weight trend line (8 hafta düşüş trendi)
  - Macro donut chart
  - Weekly calorie bars
  - 1-2 achievement badge
- **TR:** "Gelişimini gör"

### 4️⃣ AI Coach Insights — "Your personal nutrition coach"
- **Başlık:** "Your personal nutrition coach"
- **Alt başlık:** "Daily tips powered by AI"
- **Görsel:** AI Coach ekranı (Görsel 8)
  - Nutrition Score 82/100 (cyan ring)
  - "Today's insight" kartı
  - 3-4 tip kartı (Protein, Hydration, Sleep)
- **TR:** "Kişisel beslenme koçun"

### 5️⃣ Water Tracker — "Stay hydrated"
- **Başlık:** "Stay hydrated, every day"
- **Alt başlık:** "Smart reminders + visual progress"
- **Görsel:** Water Tracker ekranı (Görsel 5)
  - Water ring 1.8 / 2.5L
  - Bardak ızgarası (7/10 dolu)
  - Timeline: 9:00 AM 250ml, 11:30 AM 250ml, ...
- **TR:** "Her gün yeterince su iç"

### 6️⃣ Premium Paywall — "Unlock the full experience"
- **Başlık:** "Unlock the full experience"
- **Alt başlık:** "7 days free, then ₺349.99/month"
- **Görsel:** Premium Paywall ekranı (Chat 18'de yapıldı)
  - Hero illüstrasyon (cyan glow)
  - 3 plan kartı: Monthly / Annual / Lifetime
  - Annual highlighted "Save 50%"
  - Bullet list (6 premium feature)
  - "Start Free Trial" CTA
- **TR:** "Tüm özellikleri aç"
- **Apple kuralı:** Auto-renewal info bu ekranda görünmeli ("Cancel anytime")

---

## 📐 Boyutlar (Zorunlu)

### iOS

| Cihaz Sınıfı | Çözünürlük | Apple Zorunlu mu? | Notlar |
|---|---|---|---|
| **6.5" / 6.7"** (iPhone 14 Plus, 14 Pro Max) | **1284 × 2778** | ✅ Evet | Modern iPhone |
| **5.5"** (iPhone 8 Plus) | **1242 × 2208** | ✅ Evet | Apple hala istiyor (legacy) |
| **12.9" iPad Pro** | 2048 × 2732 | ⚠️ Sadece iPad destekleniyorsa | Şimdilik atla |

⚠️ **6.5" upload edersen Apple onu 6.7" cihazlar için de otomatik kullanır.** İki ayrı set'e gerek yok.

### Android (Google Play)

| Cihaz | Çözünürlük | Min - Max |
|---|---|---|
| **Phone** | **1080 × 1920** veya **1080 × 2400** (16:9 veya 18:9) | Min 2, max 8 |
| **7" Tablet** | 1200 × 1920 | Opsiyonel |
| **10" Tablet** | 1920 × 1200 | Opsiyonel |

### Toplam screenshot sayısı
- iOS: 6 × 2 dil (TR + EN) × 2 cihaz (6.5" + 5.5") = **24 screenshot**
- Android: 6 × 2 dil = **12 screenshot**
- **Grand total: 36 screenshot**

---

## 🎨 Tasarım Rehberi

### Layout (3 element)

```
┌──────────────────────────────┐
│                              │
│  📍 BÜYÜK BAŞLIK (üst)      │ ← 48-56px Bold
│  küçük açıklama              │ ← 20-24px Regular
│                              │
│  ┌────────────────────┐      │
│  │                    │      │
│  │   📱 PHONE MOCKUP  │      │
│  │   (uygulama görsel) │     │ ← orta, %60 alan
│  │                    │      │
│  └────────────────────┘      │
│                              │
│  (boşluk veya ikincil CTA)   │
│                              │
└──────────────────────────────┘
```

### Renkler (master_plan'dan)

```css
/* Arkaplan */
background: linear-gradient(180deg, #050A1F 0%, #0B1A3D 100%);

/* Üst başlık */
color: #FFFFFF;
font-family: SF Pro Display / Inter;
font-weight: 700;

/* Alt açıklama */
color: #B8C5D6;
font-weight: 400;

/* Vurgu (CTA, highlight) */
color: #00D4FF; /* primary cyan */
glow: 0 0 30px rgba(0, 212, 255, 0.4);

/* Phone mockup gölgesi */
box-shadow: 0 30px 80px rgba(0, 0, 0, 0.5);
```

### Phone Mockup Frame

**Önerilen kaynaklar:**
- **Figma Apple Devices Library:** Free, resmi Apple mockup'ları
  - [Apple Design Resources](https://developer.apple.com/design/resources/)
- **Mockuuups Studio:** Hızlı drag-drop ($14/ay)
- **Previewed.app:** Web tabanlı, ücretsiz tier
- **Rotato:** 3D animasyonlu mockup (promo video için ideal)

### Tipografi

```
Üst başlık: 56px SF Pro Display Bold, white
Alt açıklama: 22px SF Pro Display Regular, #B8C5D6
Mockup içindeki app: uygulamanın kendi tipografisi (zaten doğru)
```

### Spacing

- Üst kenar boşluk: 120px
- Başlık → açıklama: 16px
- Açıklama → mockup: 80px
- Alt kenar boşluk: 120px

---

## 🎭 İçindeki Veri (Önemli!)

**Apple kuralı 2.3:** Screenshot'lar app'in **gerçek özelliklerini** ve **gerçekçi veriyi** göstermeli.

❌ **Yapma:**
- Lorem ipsum
- "Sample User" placeholder
- 999,999 kalori gibi gerçek dışı sayılar
- Henüz yapılmamış özellikleri göster

✅ **Yap:**
- Gerçekçi kullanıcı verisi (Demo user: "Sarah", "Ali" gibi)
- Tutarlı tarihler (bugün veya yakın gelecek)
- Mantıklı sayılar (1,480 kcal — günde tipik öğle)
- 8 hafta gerçekçi weight trend (yavaş düşüş)

### Demo Kullanıcı Profili

İçeride göstermek için tutarlı bir demo persona kullan:

```
İsim: Ayşe (TR) / Sarah (EN)
Yaş: 28
Hedef: Lose weight
Mevcut kilo: 68 kg
Hedef kilo: 62 kg (3 ay)
Günlük hedef: 1,800 kcal
Bugün yenilen: 1,480 kcal
Streak: 14 gün
```

---

## 🛠️ Üretim Workflow

### Adım 1: Figma'da Master File

`nuveli-screenshots-master.fig` oluştur:

```
Pages:
├─ EN — iOS 6.5"  (1284 x 2778, 6 frame)
├─ EN — iOS 5.5"  (1242 x 2208, 6 frame)
├─ EN — Android   (1080 x 1920, 6 frame)
├─ TR — iOS 6.5"  (1284 x 2778, 6 frame)
├─ TR — iOS 5.5"  (1242 x 2208, 6 frame)
└─ TR — Android   (1080 x 1920, 6 frame)
```

### Adım 2: App'ten Screenshot Al

```bash
# iOS Simulator (6.5" için iPhone 14 Pro Max kullan)
# Open Simulator → Device → iPhone 14 Pro Max
# App'i çalıştır
# CMD+S → Desktop'a screenshot kaydedilir

# Android Emulator (Pixel 6 Pro veya benzeri 1080x2400)
# Toolbar → Camera icon
```

**İpucu:** Status bar'ı temizle:
- iOS: `xcrun simctl status_bar "iPhone 14 Pro Max" override --time "9:41" --batteryState charged --batteryLevel 100`
- Android: `adb shell settings put global sysui_demo_allowed 1`

### Adım 3: Mockup + Başlık Yerleştir

1. Figma frame'inde gradient background hazır
2. Phone mockup'ı yerleştir
3. Screenshot'u mockup'ın ekran alanına `Place Image` ile koy
4. Üst başlık + açıklama metni ekle
5. Glow/shadow uygula

### Adım 4: Export

Figma → Export → PNG, 1× scale
- Naming: `01_dashboard_en.png`, `02_scan_en.png`, ...
- Klasör: `launch_assets/screenshots/ios/6.5_inch/`

---

## 📋 Naming Convention

```
launch_assets/screenshots/ios/6.5_inch/
├── 01_dashboard_en.png
├── 02_scan_en.png
├── 03_analytics_en.png
├── 04_coach_en.png
├── 05_water_en.png
├── 06_premium_en.png
├── 01_dashboard_tr.png
├── 02_scan_tr.png
└── ... (TR versiyonu)
```

---

## ✅ Kontrol Listesi

Üretim sonrası her screenshot için:

- [ ] Doğru çözünürlük (1284×2778 / 1242×2208 / 1080×1920)
- [ ] PNG, sRGB color space
- [ ] Boyut < 8 MB (App Store limit)
- [ ] Lorem ipsum YOK
- [ ] Demo veri gerçekçi
- [ ] Status bar temiz (9:41 / 12:00 saat, %100 batarya)
- [ ] Üst başlık yazım hatasız (TR + EN)
- [ ] Premium ekranında "Cancel anytime" yazısı var
- [ ] Health permission ifadeleri henüz görünmüyor (onboarding'de gösterilir)
- [ ] Renkler brand guideline ile uyumlu
- [ ] Telefon mockup şeffaflık doğru (köşelerden background görünüyor)

---

## 🚨 Reject Riski

| Hata | Apple Reject Reason |
|---|---|
| Lorem ipsum veya placeholder | 2.3 (Inaccurate metadata) |
| App'te olmayan özellik gösterimi | 2.3.10 (False claims) |
| Üst başlıkta legal claim ("Best calorie app") | 5.4 (Misleading) |
| Telif hakkı ihlali (Disney karakteri vb) | 5.2 (IP) |
| Çok küçük metin (10px altı) | 4.0 (UX) |

---

## 🎬 Bonus: Promo Video (Opsiyonel)

App Preview video (15-30s) Apple'da %25 conversion artırır. Detay: `promo_video/PROMO_VIDEO_SPEC.md`

---

**Not:** Bu screenshot'lar app'in vitrin yüzü. **2-3 günü** Figma'da geçirmeye değer. Acele yapma.
