# Google Play — Store listing (Nuveli)

> Copy + asset checklist + step-by-step Play Console guide for the production
> store listing. Primary market: **Türkiye (tr-TR)**. Add **en-US** as a second
> language. Wellness app — **no medical claims** (see
> `docs/protocols/safety-wellness-boundary.md`).

---

## 0. Asset checklist

| Asset | Spec (Play) | Status | File |
|-------|-------------|--------|------|
| **App icon** | 512×512 PNG, 32-bit, ≤1 MB | ✅ ready | `logo/store-icon-512.png` |
| **Feature graphic** | 1024×500 PNG/JPG, ≤1 MB | ✅ ready | `logo/1024 x 500.png` |
| **Phone screenshots** | 2–8, PNG/JPG, 16:9 or 9:16, min side ≥320px, ≤8 MB | ❌ TODO — capture on device | — |
| **Tablet screenshots** | optional | skip (phone-first) | — |
| **Promo video** | optional (YouTube URL) | skip for v1 | — |

**Screenshots — capture these 5 flows on a real phone** (after the vCode 34 AAB
is installed), portrait 1080×1920 or 1080×2400:
1. **Dashboard** — daily calorie ring + macros + greeting.
2. **AI Meal Scan result** — a scanned plate with foods/calories.
3. **Coach insight** — a daily coaching card.
4. **Exercise / activity** — the weekly bar chart + activity log.
5. **Progress / weight** — weight trend or meal planner.

> Tip: use a clean test account with a few days of realistic data. Avoid any
> medical-sounding overlays. You can add a short caption strip per screenshot
> later, but raw device screenshots are accepted.

---

## 1. App name (≤30 chars)

- **tr-TR:** `Nuveli: AI Kalori Koçu`  (22)
- **en-US:** `Nuveli: AI Calorie Coach`  (24)

## 2. Short description (≤80 chars)

- **tr-TR:** `Fotoğrafla kalori say, yapay zekâ koçunla sağlıklı alışkanlıklar kur.`  (~68)
- **en-US:** `Snap a photo to count calories and build healthy habits with your AI coach.`  (~75)

## 3. Full description (≤4000 chars)

### tr-TR

```
Nuveli, fotoğrafla kalori takibini ve nazik bir yapay zekâ koçluğunu tek
uygulamada birleştirir. Suçlayan diyet kültürü yok — sürdürülebilir, sakin
alışkanlıklar var.

📸 FOTOĞRAFLA ÖĞÜN ANALİZİ
Tabağının fotoğrafını çek; Nuveli yiyecekleri tanır, kalori ve makro
(protein/karbonhidrat/yağ) tahmini yapar. Dilersen elle de ekleyebilirsin.

🤖 YAPAY ZEKÂ KOÇU
Günlük kişisel içgörüler. Koç seni motive eder, dengeli beslenmeye yönlendirir
ve kötü bir gün için seni asla suçlamaz.

🔥 KALORİ VE MAKRO TAKİBİ
Profilin ve hedefinden günlük kalori ve makro hedeflerini hesaplar. İlerlemeni
sade, anlaşılır bir panoda gör.

💧 SU, KİLO VE ALIŞKANLIKLAR
Su tüketimini, kilo değişimini ve günlük alışkanlıklarını tek yerde izle.

🏃 EGZERSİZ KAYDI
Aktivitelerini ekle, yaklaşık yakılan kaloriyi gör. (Egzersiz kalorisi
yalnızca bilgilendirme amaçlıdır, günlük bütçene eklenmez.) İstersen telefon
sağlık verini (Health Connect) bağlayıp antrenmanlarını içe aktarabilirsin —
tamamen isteğe bağlı, varsayılan kapalı.

🍽️ ÖĞÜN PLANLAYICI VE TARİFLER
Öğünlerini planla, tarifleri keşfet, alışveriş listeni oluştur.

🌍 7 DİL DESTEĞİ
Türkçe, İngilizce ve daha fazlası.

— Premium —
Sınırsız öğün analizi, gelişmiş koç ve haftalık/aylık özetler.

Nuveli bir WELLNESS uygulamasıdır. Tıbbi teşhis, tedavi veya klinik diyet
planı sunmaz. Sağlığınla ilgili kararlar için bir uzmana danış.

Sorular ve destek: support@nuveli.com.tr
```

### en-US

```
Nuveli combines photo-based calorie tracking with gentle AI coaching in one
app. No blame, no diet-culture guilt — just calm, sustainable habits.

📸 SNAP YOUR MEAL
Take a photo of your plate and Nuveli recognizes the foods and estimates
calories and macros (protein/carbs/fat). Prefer typing? Add meals manually.

🤖 AI COACH
Daily personalized insights. Your coach keeps you motivated, nudges you toward
balanced eating, and never blames you for an off day.

🔥 CALORIE & MACRO TRACKING
Daily calorie and macro targets calculated from your profile and goal. See your
progress on a clean, easy dashboard.

💧 WATER, WEIGHT & HABITS
Track water intake, weight changes and daily habits in one place.

🏃 EXERCISE LOGGING
Log your activities and see approximate calories burned. (Exercise calories are
for information only and are never added to your daily budget.) Optionally
connect your phone health data (Health Connect) to import workouts — fully
optional, off by default.

🍽️ MEAL PLANNER & RECIPES
Plan your meals, browse recipes, build your shopping list.

🌍 7 LANGUAGES
English, Turkish and more.

— Premium —
Unlimited meal analysis, advanced coaching and weekly/monthly summaries.

Nuveli is a WELLNESS app. It does not provide medical diagnosis, treatment or
clinical dietary plans. Consult a professional for health decisions.

Questions & support: support@nuveli.com.tr
```

---

## 4. Categorization & contact

- **App category:** Health & Fitness
- **Tags:** calorie counter, nutrition, wellness (pick from Play's tag list)
- **Contact email:** support@nuveli.com.tr
- **Website:** https://nuveli.com.tr (live)
- **Privacy policy URL:** **https://nuveli.com.tr/privacy** (live, 7-lang,
  KVKK/GDPR). ⚠️ Add the Health Connect section first —
  `docs/legal/health-connect-privacy-insert.md`.

---

## 5. Step-by-step — Play Console

Do these in order. Items marked 🔒 block the production release.

### A. Store listing (Main store listing)
1. Play Console → your app → **Grow → Store presence → Main store listing**.
2. Set default language to **Turkish (tr-TR)**; add **English (en-US)** via
   "Manage translations → Add your own translations".
3. Paste **App name / Short description / Full description** per language (§1–3).
4. Upload **App icon** (`logo/store-icon-512.png`).
5. Upload **Feature graphic** (`logo/1024 x 500.png`).
6. Upload **2–8 phone screenshots** (capture per §0). 🔒 (min 2 required)
7. Save.

### B. Store settings
1. **Grow → Store presence → Store settings**.
2. **App category:** Health & Fitness. Add tags.
3. **Contact details:** email `support@nuveli.com.tr` (+ website if live).
4. Save.

### C. App content (Policy) 🔒
1. **Policy → App content**.
2. **Privacy policy:** paste `https://nuveli.com.tr/privacy`. 🔒
3. **Data safety:** fill from `docs/ops/play-data-safety.md`. 🔒
4. **Health apps declaration:** declare Health Connect read perms
   (Exercise + Active calories only), read-only, opt-in, display-only —
   see the Health Connect section in `docs/ops/play-data-safety.md`. May
   require a short demo video of the consent flow. 🔒
5. **Ads:** declare **No ads**.
6. **Content rating:** complete the IARC questionnaire (see §6). 🔒
7. **Target audience:** adults (18+); not designed for children.
8. **Government apps / News / COVID:** No.

### D. Release
1. **Release → Production** (or promote the closed-testing build).
2. Confirm the AAB is **versionCode 34** (the vCode-34 build with exercise +
   health import). Build per SESSION_HANDOFF: `cd app && flutter build
   appbundle --release --dart-define-from-file=.env.production`.
3. Add release notes (TR + EN). Submit for review.

---

## 6. Content rating — questionnaire answers

IARC questionnaire (Health & Fitness app, no objectionable content). Expected
answers → likely **PEGI 3 / Everyone**:
- Violence / fear / sexual content / gambling / drugs / language: **No** to all.
- **Does the app share the user's current physical location?** No.
- **Does the app let users interact / share content?** No (no social/UGC; coach
  is one-way insight, no chat between users).
- **Does the app collect personal info?** Yes (email, health & fitness) — this
  is the Data-safety disclosure, doesn't raise the age rating.
- Digital purchases: **Yes** (subscriptions) — disclose.

> Answer honestly from the actual app behavior; the above is the expected shape,
> not a script. A wrong answer here can get the listing pulled.

---

## 7. Release notes (template)

**tr-TR:**
```
İlk sürüm: fotoğrafla kalori takibi, yapay zekâ koçu, su/kilo/alışkanlık
takibi, egzersiz kaydı ve öğün planlayıcı.
```
**en-US:**
```
First release: photo calorie tracking, AI coach, water/weight/habit tracking,
exercise logging and a meal planner.
```

---

_Prepared 2026-05-26. Copy is wellness-safe (no medical claims). Re-check char
counts in Play Console — it enforces 30 / 80 / 4000 limits live._
