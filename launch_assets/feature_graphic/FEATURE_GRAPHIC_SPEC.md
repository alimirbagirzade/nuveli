# 🖼️ Feature Graphic Spec — Google Play

**Hedef:** Google Play Store listing'in üst başlığı (header banner). 
**Sadece Android için.** App Store'da karşılığı yok.

---

## 📐 Boyut

| Asset | Boyut | Format | Notlar |
|---|---|---|---|
| `feature_graphic.png` | **1024 × 500** | PNG (alpha YOK) | Google Play zorunlu, max 1 MB |

⚠️ **Önemli:** 
- Transparency yok (Google reject eder)
- Tek bir görsel, animasyon yok
- 24-bit PNG veya JPEG

---

## 🎨 Tasarım Briefi

### Layout

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  🌊 Sol taraf: Brand + Tagline                                │
│  ┌──────────┐                                                 │
│  │ NUVELI   │   📱 Sağ taraf: 1-2 phone mockup               │
│  │ logo     │      (dashboard + scan, açılı)                  │
│  └──────────┘                                                 │
│  AI Calorie Coach                                              │
│  Snap. Scan. Track.                                            │
│                                                                │
└────────────────────────────────────────────────────────────────┘
1024 × 500 px
```

### Renkler

```
Background: Linear gradient #050A1F → #0B1A3D (45° açı)
İkincil glow: Radial #00D4FF @ %20 opacity (sol arka)
Logo: White (Nuveli)
Tagline: White / #B8C5D6
Accent: #00D4FF (CTA renk)
Phone mockup gölge: drop shadow blur 40, %50 opacity
```

### Tipografi

```
Logo (büyük): "Nuveli" — 72px SF Pro Display Bold, white
Tagline (alt): "AI Calorie Coach" — 32px Medium, #B8C5D6
Sub-tagline: "Snap. Scan. Track." — 24px Regular, #00D4FF
```

### Phone Mockup

- 1 veya 2 phone (açılı yerleştirilmiş, sağda)
- İçerikleri: en güçlü 2 ekran (Dashboard + Meal Scan)
- Boyut: 280 × 580 px (her phone)
- Açı: -15° rotate (dynamism)

---

## 🚨 Google Play Kuralları

| Kural | Detay |
|---|---|
| **Tek dil zorunlu** | Görseldeki metin, app'in primary language'ında (EN) olmalı |
| **Kullanıcı verisi gösterme** | Screenshot içinde gerçek email/isim olmasın |
| **App icon yerleştirme** | Sol üstte küçük icon eklersen kabul; ortada büyük icon → spam görünür |
| **Cap (büyük harf) kötüye kullanma** | "BEST APP EVER" → reject |
| **Logo + appName birlikte** | Genelde reject sebebi değil ama gereksiz |
| **Animated GIF** | Kabul edilmez (statik PNG) |
| **Resolution** | Tam 1024 × 500 (1 px sapma bile reject) |

---

## 🛠️ Üretim Workflow

### Figma'da

1. **Yeni frame:** 1024 × 500
2. **Layer:**
   ```
   ┌─ feature_graphic_master
   │  ├─ Background gradient
   │  ├─ Glow blob (cyan radial)
   │  ├─ Left text group (Nuveli + tagline)
   │  ├─ Right mockup group (2 phone, açılı)
   │  └─ Border subtle (1px rgba white %5, opsiyonel)
   ```
3. **Export:** PNG, 1×, **alpha off**

### Komut Satırı (alpha kaldırma)

```bash
# ImageMagick ile
magick feature_graphic.png -background "#050A1F" -alpha remove -alpha off feature_graphic_final.png

# Veya macOS sips
sips -s format png --deleteColorManagementProperties feature_graphic.png
```

---

## ✅ Kontrol Listesi

- [ ] **Tam 1024 × 500 px** (yarım piksel bile yok)
- [ ] PNG, alpha kapalı
- [ ] Dosya boyutu < 1 MB
- [ ] Görseldeki metin **app'in primary dili** (EN)
- [ ] Lorem ipsum / placeholder yok
- [ ] App icon sol üstte küçük (opsiyonel)
- [ ] Phone mockup'ta gerçek app içeriği var
- [ ] Renkler brand ile tutarlı
- [ ] Mobile preview'da okunur (Google Play app içinde küçük gözükür)

---

## 🎬 Bonus: Promo Banner (Sosyal Medya için)

Aynı tasarımı farklı boyutlarda çıkar:

| Platform | Boyut |
|---|---|
| Twitter/X header | 1500 × 500 |
| Instagram post | 1080 × 1080 |
| LinkedIn post | 1200 × 627 |
| Product Hunt thumbnail | 240 × 240 |
| Website hero | 1920 × 1080 |

Master file 1024×500 değil, **1920×1080** olarak hazırla, küçültme her boyut için yapılır.

---

**Not:** Feature graphic genelde **3 saniyede karar verdirir**. Çok yoğun bilgi koyma. Bir tagline + güzel mockup yeter.
