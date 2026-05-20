# 🔑 Keywords (ASO Optimization)

**Apple kuralı:** 100 karakter max, virgülle ayır, **boşluk koyma** (her boşluk 1 karakter)
**Apple algoritma:** App Name + Subtitle + Keywords = ASO sıralama
**Google Play:** Keyword alanı yok → uzun description'daki repetition önemli

---

## 🇺🇸 EN Keywords (App Store, max 100 char)

### Final (94 karakter ✅)
```
calorie,counter,nutrition,diet,weight,loss,tracker,food,ai,scanner,meal,health,fitness,water
```

### Karakter sayısı kontrolü
```
calorie       7
counter       7  → 14
nutrition     9  → 24
diet          4  → 29
weight        6  → 36
loss          4  → 41
tracker       7  → 49
food          4  → 54
ai            2  → 57
scanner       7  → 65
meal          4  → 70
health        6  → 77
fitness       7  → 85
water         5  → 91
+ 13 virgül    13 → ~94 ✅
```

### ASO Stratejisi (EN)
- **App Name'de zaten var:** "calorie", "coach", "AI" → keyword field'da tekrar etmiyoruz
- **Subtitle'da zaten var:** "track", "meals", "AI", "vision" → keyword field'da tekrar etmiyoruz
- **Apple algoritması:** name + subtitle + keywords kelimelerini birleştirip arama yapar
- **Sonuç:** "AI calorie counter", "nutrition tracker", "meal scanner", "weight loss diet" gibi 2-3 kelimelik aramalarda görünür

### Alternatif keyword setleri (test için)

**V2 (lifestyle odaklı):**
```
healthy,eating,macros,protein,carbs,fat,fasting,intermittent,vegan,keto,paleo,recipes,workout
```

**V3 (rakip-odaklı, riskli):**
```
myfitnesspal,lifesum,yazio,noom,loseit,fooducate,carbmanager,foodvisor,calai,bitesnap
```
⚠️ **DİKKAT:** Rakip marka adlarını keyword'e koymak Apple Guideline **2.3.7** ihlali. Reject riski yüksek. **Önerilmez.**

---

## 🇹🇷 TR Keywords (App Store, max 100 char)

### Final (97 karakter ✅)
```
kalori,sayaci,beslenme,diyet,kilo,verme,takip,yemek,ai,tarayici,ogun,saglik,fitness,su,koc
```

### Karakter sayısı
```
kalori         6
sayaci         6  → 12
beslenme       8  → 20
diyet          5  → 25
kilo           4  → 29
verme          5  → 34
takip          5  → 39
yemek          5  → 44
ai             2  → 46
tarayici       8  → 54
ogun           4  → 58
saglik         6  → 64
fitness        7  → 71
su             2  → 73
koc            3  → 76
+ 14 virgül    14 → ~97 ✅
```

### Türkçe karakter notu
Apple keyword field'da **özel karakter desteklenir** ama önerilmez:
- `sayacı` (ı ile) → 6 karakter ama bazı keyboard'larda sorunlu
- `sayaci` (i ile) → daha güvenli, hala arama eşleşmesi yapıyor

Apple, Türkçe büyük/küçük + diakritik aramalarda fuzzy matching yapıyor. Yani `sayaci` yazılsa bile "sayacı" araması bulur.

### Alternatif TR setleri

**V2 (yöntem odaklı):**
```
makro,protein,karbonhidrat,yag,oruc,aralikli,vegan,ketojenik,paleo,tarif,antrenman,spor
```

---

## 📊 Optimization Strategy

### Apple algoritma yapısı (2024 sonrası)
1. **Title** (30 char) — en güçlü ranking
2. **Subtitle** (30 char) — 2. en güçlü
3. **Keywords** (100 char) — 3. en güçlü
4. **In-app purchase names** — opsiyonel ranking
5. **Description** — ranking için zayıf, conversion için güçlü

### Bizim "Nuveli — AI Calorie Coach" stratejimiz

| Kelime | Konum | Sebep |
|---|---|---|
| `Nuveli` | Title | Brand |
| `AI` | Title + Description | Differentiator |
| `Calorie` | Title + Keywords | Core function |
| `Coach` | Title | Differentiator |
| `Track meals with AI vision` | Subtitle | "track", "meals", "AI", "vision" eklendi |
| `nutrition, diet, weight, scanner, meal, health, fitness, water` | Keywords | Long-tail searches |

### Tahmini ranking pozisyonu (US App Store, ilk hafta)

| Anahtar Kelime | Tahmini Pozisyon |
|---|---|
| "AI calorie counter" | Top 50 |
| "meal scanner" | Top 30 |
| "calorie tracker AI" | Top 20 |
| "nutrition coach app" | Top 100 |
| "myfitnesspal alternative" | Bulunmaz (rakip ad) |

ASO bir maraton. İlk 4-6 hafta ranking düşük olur, sonra organic'ler düzene oturur.

---

## 🔄 İterasyon Stratejisi

Launch sonrası 30 günde bir keyword'leri test et:
- App Store Connect → Analytics → Search → Keywords
- Hangi kelimelerden geliyor traffic? → keyword field'da yoksa ekle
- Hangileri 0 conversion? → çıkar, yerine yeni dene

Tool önerileri:
- **AppTweak** — $69/ay, comprehensive
- **Sensor Tower** — Pro tier, expensive
- **AppFollow** — daha ucuz, yeterli
- **Apple Analytics** — ücretsiz ama sınırlı

---

## ✅ Submission Listesi

App Store Connect:
- [ ] `Keywords (English)`: `calorie,counter,nutrition,diet,weight,loss,tracker,food,ai,scanner,meal,health,fitness,water`
- [ ] `Keywords (Turkish)`: `kalori,sayaci,beslenme,diyet,kilo,verme,takip,yemek,ai,tarayici,ogun,saglik,fitness,su,koc`

Google Play:
- Keywords alanı yok. Description'da repetition zaten yapıldı.

---

**Not:** Keyword'ler her sürüm güncellemesinde (App Store Connect → Edit Version) değiştirilebilir. Launch sonrası A/B test et.
