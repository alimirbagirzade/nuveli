# 🌊 Nuveli — Master Development Plan

**Proje:** Nuveli AI Calorie Coach (Flutter + FastAPI + Supabase + OpenAI)
**Repo:** github.com/alimirbagirzade/nuveli_test
**Backend URL:** https://nuveli-api.onrender.com
**Son Güncelleme:** 21 Mayıs 2026 (Chat 24 round 2 — A11y semantics + haptic + empty state coverage)
**Hazırlayan:** Claude (Anthropic) + Ali

---

## 📌 BU DOSYANIN AMACI

Bu doküman, Nuveli projesinin **tüm geliştirme yol haritasıdır.** Proje çok büyük olduğu için her bölüm **ayrı bir Claude chat'inde** geliştirilecek. Bu sayede:

- ✅ Her chat odaklı ve temiz kalır
- ✅ Context window aşılmaz
- ✅ Bir bölümü değiştirince diğeri bozulmaz
- ✅ Geri dönüp aramak kolaylaşır

**Her yeni chat açtığında bu dosyayı project files'a yükle.** Claude direkt nerede olduğumuzu bilecek.

---

## 🎨 PROJE GENEL BİLGİLERİ

### Marka Kimliği
- **İsim:** Nuveli
- **Slogan:** AI Calorie Coach
- **Tema:** Underwater / Liquid Glass (deniz altı, ışık huzmeleri, akışkan formlar)
- **Stil:** Apple Liquid Glass diline yakın, premium hissiyat

### Renk Paleti (App Store mockup'larından çıkarıldı)
```
ARKA PLAN:
- Primary Background: #050A1F → #0B1A3D (gradient, koyu lacivert → koyu mavi)
- Card Background: rgba(20, 35, 70, 0.6) (yarı saydam, glass effect için)

VURGU RENKLERİ:
- Primary Cyan: #00D4FF (ana CTA, halkalar, highlight)
- Cyan Glow: #4DDBFF (parlak vurgu, glow efektleri)
- Cyan Dark: #0099CC (hover/pressed state)

MAKRO RENKLERİ:
- Protein (Yeşil/Mavi karışım): #3DDC97 veya #4ECDC4
- Carbs (Yeşil): #6BCB77
- Fat (Turuncu): #FF9F45

DURUM RENKLERİ:
- Success: #3DDC97 (yeşil)
- Warning: #FFC857 (sarı)
- Danger: #FF5C5C (kırmızı)
- Streak Fire: #FF6B35 → #FF9F45 (turuncu gradient)

METİN:
- Primary Text: #FFFFFF
- Secondary Text: #B8C5D6 (açık gri-mavi)
- Tertiary Text: #6E7B91
- Disabled: #4A5670
```

### Tipografi
- **Font Family:** SF Pro Display (iOS) / Inter (cross-platform fallback)
- **Başlık (Hero):** 48-56px, Bold, white
- **Section Title:** 24-28px, SemiBold
- **Card Title:** 18-20px, SemiBold
- **Body:** 14-16px, Regular
- **Caption:** 12px, Regular, secondary color
- **Numbers (Hero):** 36-48px, Bold (örn: "1,480")

### Component Stili
- **Border Radius:** 16-20px (kartlar), 28px (butonlar), 999px (pill/chip)
- **Card Padding:** 16-20px
- **Glass Effect:** `BackdropFilter` blur 10-15 + border 1px rgba(255,255,255,0.1)
- **Glow Effect:** `BoxShadow` blur 20-30, cyan @ 0.3-0.5 opacity
- **Spacing:** 4 / 8 / 12 / 16 / 24 / 32 / 48 (8'in katları)

---

## 🗂️ TÜM EKRANLAR (8 ana özellik)

| # | Ekran | Görsel | Özellikler |
|---|---|---|---|
| 1 | Dashboard | Görsel 1 | Today's Summary halkası, makro barlar, meal list, Add Food CTA |
| 2 | AI Meal Scan | Görsel 2 | Kamera + OpenAI Vision, detected foods, portion insights |
| 3 | Goals & Profile | Görsel 3 | Daily target, weight goal, streak, weekly bars, recommendations |
| 4 | Analytics | Görsel 4 | Weight trend line, macro donut, weekly bars, achievements |
| 5 | Water Tracker | Görsel 5 | Halka + bardak ızgarası, timeline, reminders, insights |
| 6 | Meal Planner | Görsel 6 | Haftalık plan, daily total, grocery summary, create plan |
| 7 | Healthy Habits | Görsel 7 | Streak, today's habits, weekly consistency, reminders |
| 8 | AI Coach Insights | Görsel 8 | Nutrition score, AI öneriler, recommended actions |

---

## 📊 EKRAN İŞLEYIŞ MANTIĞI

### 1️⃣ Dashboard
**Veri kaynakları:**
- `meals` tablosu → bugünün toplamları (kalori, makrolar)
- `user_profiles.daily_calorie_target` → hedef değer

**Hesaplamalar:**
- Yüzde: `consumed / target * 100`
- Kalan: `target - consumed`
- Makro hedefleri: kalorinin %25 protein, %45 carbs, %30 fat (default)

**State:** Real-time update (yeni meal eklenince)

---

### 2️⃣ AI Meal Scan
**Flow:**
1. Kamera açılır (`camera` paketi)
2. Fotoğraf çekilir → base64 encode
3. Backend `/meals/scan` endpoint'ine POST
4. Backend → OpenAI GPT-4o Vision API
5. Response: `[{name, grams, calories, protein, carbs, fat}, ...]`
6. Frontend listeyi gösterir + "Portion Insights" skoru
7. Onay → Supabase `meals` tablosuna kayıt

**Backend prompt:**
```
You are a nutrition expert. Analyze this meal photo and return JSON only:
{
  "foods": [{"name", "grams", "calories", "protein_g", "carbs_g", "fat_g"}],
  "total_calories": number,
  "portion_score": 0-100,
  "insights": ["High in protein", "Balanced meal", ...]
}
```

---

### 3️⃣ Goals & Profile
**Veri:**
- Daily calorie target: kullanıcının BMR + TDEE hesabıyla (onboarding)
- Weight goal: `weight_goals(user_id, target_kg, target_date)` tablosu
- Streak: ardışık gün sayısı (en az 1 meal loglandığı günler)

**Recommendations:**
- AI tarafından üretilir (Chat 11'de detay) — günde 1 kez cache'lenir

---

### 4️⃣ Analytics
**Grafikler:**
- **Weight Trend:** `weight_logs` tablosundan son 8 hafta, smoothed line
- **Macro Breakdown:** Son 7 günün ortalaması (protein/carbs/fat kalori bazında %)
- **Weekly Calorie:** Son 7 günün günlük toplamları (bar chart)
- **Achievements:** Cron job ile günlük güncellenir

**Makro yüzde hesaplama:**
```
protein_kcal = protein_g * 4
carbs_kcal   = carbs_g * 4
fat_kcal     = fat_g * 9
total = protein_kcal + carbs_kcal + fat_kcal
% = (her_makro / total) * 100
```

---

### 5️⃣ Water Tracker
**Veri:** `water_logs(user_id, amount_ml, logged_at)` tablosu

**Hesaplamalar:**
- Günlük hedef: `user_profiles.weight_kg * 35` ml (veya manuel)
- Bardak sayısı: `total_ml / 250`
- Yüzde: `total / goal * 100`

**Quick add butonları:** +250ml, +500ml, +1000ml (1 tap ile log)

**Reminders:** Local notifications (`flutter_local_notifications`)
- Morning (9:00 AM)
- Afternoon (1:00 PM)
- Evening (6:30 PM)

**Insights:** Kural tabanlı pattern detection
- "You hydrate better before lunch" → son 7 günde 12:00'dan önce ortalama %X içildi vs sonra

---

### 6️⃣ Meal Planner
**Veri:**
- `meal_plans(user_id, plan_date, meal_type, recipe_id)` tablosu
- `recipes(id, name, calories, ingredients_json, image_url)` tablosu

**Özellikler:**
- Haftalık görünüm (7 gün)
- Her gün için 4 öğün: Breakfast, Lunch, Dinner, Snack
- Daily Total: planlanan öğünlerin kalori toplamı vs hedef
- **Grocery Summary:** Tüm planlanan recipe'lerin ingredients'larının `SUM`'u

**AI Önerisi (opsiyonel):**
- "Create Plan" butonu → GPT-4o ile haftalık plan üret (kullanıcı hedeflerine göre)

---

### 7️⃣ Healthy Habits
**Veri:**
- `habits(id, user_id, name, icon, target_type, target_value, schedule)` tablosu
- `habit_completions(habit_id, completed_at)` tablosu

**Default habits (önceden yüklü):**
1. Log breakfast
2. Drink 8 glasses (water tracker'dan otomatik kontrol)
3. Walk 6,000 steps (Apple Health / Google Fit)
4. Protein goal (meal logs'tan otomatik)
5. Sleep before 11 PM (manuel check veya HealthKit)

**Streak hesaplama:**
```sql
WITH daily_completion AS (
  SELECT DATE(completed_at) as day, COUNT(*) as completed
  FROM habit_completions
  WHERE user_id = $1
  GROUP BY DATE(completed_at)
  HAVING COUNT(*) >= (SELECT COUNT(*) FROM habits WHERE user_id = $1) * 0.8
)
SELECT COUNT(*) FROM (
  -- ardışık günler
);
```

**Weekly Consistency:** Her gün için "kaç habit tamamlandı / toplam" oranı

---

### 8️⃣ AI Coach Insights
**Bu ekran AI'ın kalbi.** Her sabah:

**Cron flow:**
1. Cron job (Render scheduled task) → her sabah 6:00
2. Her aktif kullanıcı için son 7 günlük veri toplanır
3. GPT-4o'ya prompt gönderilir:
   ```
   User data: {meals, water, habits, weight_change, calorie_avg}
   Return JSON:
   {
     "nutrition_score": 0-100,
     "today_insight": "kısa motivasyon",
     "tips": [
       {"icon": "muscle", "title": "...", "description": "..."},
       ...4 tane
     ],
     "recommended_action": {"text": "...", "apply_tip_data": {...}}
   }
   ```
4. Sonuç `ai_insights(user_id, date, payload_json)` tablosuna kaydedilir
5. Frontend ekranı açtığında bu kayıttan okur (re-fetch yok, cost optimization)

**Nutrition Score algoritması:**
```python
score = 0
# Kalori uyumu (40 puan)
score += 40 if abs(daily_kcal - target) / target < 0.1 else proportional
# Makro dengesi (30 puan)
score += 30 if all macros within target ±20%
# Su (15 puan)
score += 15 if water >= 2.5L
# Habits (15 puan)
score += 15 * (habits_completed / habits_total)
return min(score, 100)
```

**"Apply Tip":** Önerilen aksiyonu otomatik uygular
- "Add 30g protein at lunch" → meal planner'a chicken breast ekler
- "Hydrate earlier" → water reminder saatini öne alır

---

## 🛠️ TEKNİK STACK ÖZET

| Katman | Teknoloji |
|---|---|
| Frontend | Flutter 3.x (iOS + Android) |
| State Management | Riverpod 2.x |
| Charts | `fl_chart` |
| Camera | `camera` |
| Local Storage | `shared_preferences` + Hive (cache) |
| Notifications | `flutter_local_notifications` + FCM |
| Health Data | `health` paketi |
| Backend | FastAPI (Python 3.11+) |
| Database | Supabase Postgres |
| Auth | Supabase Auth (email + Apple Sign-In) |
| AI | OpenAI GPT-4o + GPT-4o Vision |
| Hosting | Render.com (FastAPI) |
| In-App Purchase | RevenueCat |
| Analytics | Firebase Analytics + Crashlytics |

---

## 🗺️ CHAT YOL HARİTASI

### Faz 1: TEMEL (Foundation) — SİZ BURADASINIZ

#### 🎨 Chat 1: Theme & Design System ⭐ İLK BU
**Hedef:** Tüm uygulamanın temel görsel sistemi
**Çıktılar:**
- `lib/core/theme/app_colors.dart` — tüm renk sabitleri
- `lib/core/theme/app_typography.dart` — text style'lar
- `lib/core/theme/app_spacing.dart` — spacing sabitleri
- `lib/core/theme/app_radius.dart` — border radius sabitleri
- `lib/core/theme/app_theme.dart` — Flutter `ThemeData`
- `lib/shared/widgets/nuveli_card.dart` — glass card widget
- `lib/shared/widgets/nuveli_button.dart` — primary CTA button
- `lib/shared/widgets/nuveli_background.dart` — underwater gradient
- `lib/shared/screens/style_guide_screen.dart` — tüm component'leri gösteren test ekranı

**Bağımlılık:** Yok
**Sonraki:** Chat 2 + Chat 3 paralel yapılabilir

---

#### 📊 Chat 2: Chart Components
**Hedef:** Tüm grafik widget'ları (reusable)
**Çıktılar:**
- `lib/shared/widgets/charts/calorie_ring_chart.dart` (Görsel 1, 3 - halka)
- `lib/shared/widgets/charts/macro_progress_bar.dart` (Görsel 1, 8)
- `lib/shared/widgets/charts/weekly_bar_chart.dart` (Görsel 3, 4)
- `lib/shared/widgets/charts/weight_line_chart.dart` (Görsel 4)
- `lib/shared/widgets/charts/macro_donut_chart.dart` (Görsel 4)
- `lib/shared/widgets/charts/water_ring_chart.dart` (Görsel 5)
- `lib/shared/widgets/charts/glasses_grid.dart` (Görsel 5 - bardak ızgarası)
- `lib/shared/widgets/charts/consistency_bar_chart.dart` (Görsel 7)
- `lib/shared/widgets/charts/nutrition_score_ring.dart` (Görsel 8)
- Demo sayfası: tüm chart'ları tek ekranda

**Bağımlılık:** Chat 1
**Paket:** `fl_chart: ^0.66.0`

---

#### 🧩 Chat 3: Common Widgets
**Hedef:** Ortak kullanılan diğer widget'lar
**Çıktılar:**
- `lib/shared/widgets/meal_list_tile.dart` (Görsel 1, 6)
- `lib/shared/widgets/streak_card.dart` (Görsel 3, 7)
- `lib/shared/widgets/reminder_toggle_tile.dart` (Görsel 5, 7)
- `lib/shared/widgets/insight_card.dart` (Görsel 8)
- `lib/shared/widgets/quick_add_button.dart` (Görsel 5 - +250ml gibi)
- `lib/shared/widgets/habit_check_tile.dart` (Görsel 7)
- `lib/shared/widgets/timeline_event.dart` (Görsel 5 - 9:00 AM 250ml)
- `lib/shared/widgets/achievement_badge.dart` (Görsel 4)
- `lib/shared/widgets/nuveli_bottom_nav.dart` (Tüm ekranlar)
- `lib/shared/widgets/recommendation_card.dart` (Görsel 3, 8)

**Bağımlılık:** Chat 1

---

### Faz 2: EKRANLAR (Screens) — Mock data ile statik

#### 📱 Chat 4: Dashboard Screen (Görsel 1)
**Çıktılar:** `lib/features/dashboard/`
**Bağımlılık:** Chat 1, 2, 3

#### 📷 Chat 5: AI Meal Scan Screen (Görsel 2)
**Çıktılar:** `lib/features/meal_scan/` + backend `/meals/scan` endpoint
**Bağımlılık:** Chat 1, 3
**Not:** En kompleks ekran — OpenAI Vision burada

#### 🎯 Chat 6: Goals & Profile Screen (Görsel 3)
**Çıktılar:** `lib/features/profile/`
**Bağımlılık:** Chat 1, 2, 3

#### 📈 Chat 7: Analytics Screen (Görsel 4)
**Çıktılar:** `lib/features/analytics/`
**Bağımlılık:** Chat 1, 2, 3

#### 💧 Chat 8: Water Tracker Screen (Görsel 5)
**Çıktılar:** `lib/features/water_tracker/`
**Bağımlılık:** Chat 1, 2, 3

#### 🍽️ Chat 9: Meal Planner Screen (Görsel 6)
**Çıktılar:** `lib/features/meal_planner/`
**Bağımlılık:** Chat 1, 3

#### ✅ Chat 10: Healthy Habits Screen (Görsel 7)
**Çıktılar:** `lib/features/habits/`
**Bağımlılık:** Chat 1, 2, 3

#### 🤖 Chat 11: AI Coach Insights Screen (Görsel 8)
**Çıktılar:** `lib/features/ai_coach/` + backend cron job
**Bağımlılık:** Chat 1, 3
**Not:** GPT-4o entegrasyonu burada

---

### Faz 3: ENTEGRASYON (Integration)

#### 🧹 Chat 12: Supabase Audit & Cleanup ✅
**Çıktılar:** Eski şemanın güvenli temizliği, temiz public schema
**Üretilen dosyalar:**
- `supabase/audit/01_full_audit.sql`
- `supabase/audit/02_data_count_check.sql`
- `supabase/audit/03_pre_check_extensions.sql`
- `supabase/audit/audit_report_FINAL.md`
- `supabase/backup/backup_instructions.md`
- `supabase/migrations/000_cleanup_old_schema.sql`
**Sonuç:** 22 tablo + 6 function + 11 trigger + 27 policy + 24 index + 2 bucket silindi. `auth.users` korundu. Public schema sıfırdan.

#### 🗄️ Chat 13: Supabase Schema & Migrations ✅
**Çıktılar:** 14 migration dosyası, 13 tablo + 2 view + 45 RLS policy + 49 index + 12 trigger + 5 helper function + 5 public seed recipe
**Tarih:** 2026-05-19
**Branch:** `feature/chat-13-supabase-schema` (commit `3a90ec8`, merged to main)
**Üretilen dosyalar:**
- `supabase/migrations/001_extensions.sql` — uuid-ossp, pgcrypto, pg_trgm
- `supabase/migrations/002_profiles_table.sql` — user_profiles (chk_macro_pct_sum constraint)
- `supabase/migrations/003_meals_table.sql` — meals + meal_foods
- `supabase/migrations/004_water_logs_table.sql` — water_logs + water_reminders
- `supabase/migrations/005_habits_tables.sql` — habits + habit_completions
- `supabase/migrations/006_meal_plans_tables.sql` — recipes + meal_plans (GIN index)
- `supabase/migrations/007_weight_logs_table.sql` — weight_logs + weight_goals (partial unique 1 active)
- `supabase/migrations/008_ai_insights_table.sql` — ai_insights (JSONB-heavy)
- `supabase/migrations/009_achievements_table.sql` — user_achievements
- `supabase/migrations/010_rls_policies.sql` — 45 RLS policy (auth.uid() = user_id pattern)
- `supabase/migrations/011_views.sql` — dashboard_today + user_7day_summary (security_invoker=true)
- `supabase/migrations/012_triggers.sql` — 12 trigger + 5 function (updated_at, meal totals, streak, new user, achievement unlock)
- `supabase/migrations/013_seed_data.sql` — 5 public recipe + backfill loop
- `supabase/migrations/README.md` — ER diagram + doğrulama sorguları

**Tablolar:**
- `user_profiles` — onboarding, hedefler, streak, premium
- `meals` + `meal_foods` — öğün + içindeki yiyecekler (total_* trigger ile)
- `water_logs` + `water_reminders` — su tüketim + hatırlatıcılar
- `habits` + `habit_completions` — alışkanlık + günlük tamamlama (UNIQUE habit+date)
- `recipes` + `meal_plans` — tarif kütüphanesi + haftalık plan
- `weight_logs` + `weight_goals` — kilo takibi + aktif hedef
- `ai_insights` — günlük AI cache (UNIQUE user+date)
- `user_achievements` — başarımlar

**Production sırasında çözülen bug'lar:**
- `42P17`: DATE() functional indexler IMMUTABLE değil → B-tree composite (user_id, timestamp DESC) ile değişti
- `42803`: user_7day_summary scalar subquery GROUP BY ile çakıştı → CTE + LEFT JOIN pattern'ine çevrildi

**Test:** Yeni user signup zinciri doğrulandı (1 profile + 5 habit + 4 achievement otomatik oluşuyor) ✅

#### ⚙️ Chat 14: Backend API (FastAPI)
**Çıktılar:** Tüm endpoint'ler, OpenAI entegrasyonu, cron jobs
**Endpoints:**
- `POST /meals/scan` — AI vision
- `POST /meals` — meal log
- `GET /dashboard/summary`
- `GET /analytics/weekly`
- `POST /ai/generate-insight` (cron)
- `POST /meal-planner/generate` (AI plan)
- `POST /premium/webhook` (RevenueCat)

#### 🔐 Chat 15: Authentication Flow
**Çıktılar:** Login/Signup/Onboarding ekranları + Supabase Auth
**Bağımlılık:** Chat 13, 14

#### 🔌 Chat 16: State Management & Repository Integration
**Çıktılar:** Riverpod providers, repository classes, gerçek backend bağlantısı
**Bağımlılık:** Chat 13, 14, 15

#### 🧭 Chat 17: Navigation & Routing
**Çıktılar:** `go_router` ile tüm ekranları birleştir, bottom nav çalışsın
**Bağımlılık:** Chat 4-11, 15, 16

#### 🔔 Chat 18: Push Notifications & Reminders
**Çıktılar:** Local notifications + FCM, water/sleep/habit reminders
**Bağımlılık:** Chat 16

---

### Faz 4: PARA & YAYIN (Monetization & Release)

#### 💰 Chat 19: RevenueCat & Premium Features
**Çıktılar:** Paywall ekranı, premium feature gating, subscription management
**Bağımlılık:** Chat 15

#### 🚀 Chat 20: App Store & Play Store Preparation
**Çıktılar:** Screenshots, descriptions, build configs, TestFlight setup
**Bağımlılık:** Hepsi

---

## 📝 HER YENİ CHAT İÇİN AÇILIŞ MESAJI ŞABLONU

Yeni chat açtığında bu mesajı yapıştır:

```
Nuveli AI Calorie Coach projesinde çalışıyoruz.

📎 Project files'da:
- nuveli_master_plan.md (TÜM yol haritası)
- nuveli_credentials_guide.md (key'ler ve servisler)

📍 Şu an: Chat [X] — [Chat Adı]
🎯 Hedef: [chat'in hedefi master plan'dan kopyala]

📦 Önceki chat'lerde tamamlandı:
- Chat 1: Theme System ✅ (eğer yapıldıysa)
- Chat 2: Charts ✅
- ...

📐 Referans görsel: [varsa ekran mockup'ını yükle]

Başlayalım. Önce yapılacakları özetle, sonra kodlamaya geç.
```

---

## ✅ HER CHAT BİTİMİNDE YAPILACAKLAR

1. **Chat sonu özeti iste:**
   "Bu chat'te ne yaptık? Hangi dosyalar oluşturuldu? Master plan'ın hangi bölümü tamamlandı?"

2. **Master plan'ı güncelle:**
   - İlgili chat'in yanına ✅ işareti koy
   - Üretilen dosyaların listesini ekle
   - Varsa notlar/değişiklikler ekle

3. **Kodları GitHub'a push'la:**
   - Branch ismi: `feature/chat-X-[konu]` (örn: `feature/chat-1-theme-system`)
   - Commit mesajları açık olsun

4. **Sonraki chat için hazırlan:**
   - Yeni mockup varsa kaydet
   - Master plan'da bir sonraki chat'i seç

---

## 🚨 ÖNEMLİ KURALLAR

### Kod Kuralları
- ✅ Her chat **kendi feature klasörüne** kod yazsın (`lib/features/X/`)
- ✅ Ortak widget'lar `lib/shared/widgets/`'a
- ✅ Tema `lib/core/theme/`'de — başka yere yazma
- ✅ Mock data ile başla, backend'i sona bırak
- ✅ Her widget'ı **tek başına test edilebilir** yap (preview screen)

### Chat Kuralları
- ❌ Tek chat'te 2 farklı feature yapma
- ❌ Master plan'ı atlama — sıra önemli
- ❌ Theme dosyalarını her chat'te yeniden yazma (Chat 1'dekini kullan)
- ✅ Mockup'a sadık kal — yaratıcılık değil, replikasyon
- ✅ Türkçe konuş, kodlar İngilizce (variable, class isimleri)

### Güvenlik
- ❌ API key'leri kodda **asla** hardcode etme
- ✅ `.env` + `dotenv` paketi kullan
- ✅ `nuveli_credentials_guide.md`'deki kurallara uy

---

## 📊 PROJE İLERLEME DURUMU

### Faz 1: Foundation
- [ ] Chat 1: Theme & Design System
- [ ] Chat 2: Chart Components
- [ ] Chat 3: Common Widgets

### Faz 2: Screens
- [ ] Chat 4: Dashboard
- [ ] Chat 5: AI Meal Scan
- [ ] Chat 6: Goals & Profile
- [ ] Chat 7: Analytics
- [ ] Chat 8: Water Tracker
- [ ] Chat 9: Meal Planner
- [ ] Chat 10: Healthy Habits
- [ ] Chat 11: AI Coach Insights

### Faz 3: Integration
- [x] **Chat 12: Supabase Audit & Cleanup ✅** (2026-05-19)
- [x] **Chat 13: Supabase Schema ✅** (2026-05-19)
- [ ] Chat 14: Backend API
- [ ] Chat 15: Authentication
- [ ] Chat 16: State Management & Repository Integration
- [ ] Chat 17: Navigation & Routing
- [ ] Chat 18: Notifications

### Faz 4: Release
- [x] **Chat 19: RevenueCat & Premium ✅** (2026-05-20)
- [ ] Chat 20: App Store Submission

---

## 📎 EK KAYNAKLAR

### Mockup Görselleri
8 adet App Store screenshot mockup'ı (master plan oluşturulurken alındı):
1. Dashboard
2. AI Meal Scan
3. Personalized Goals
4. See Your Progress (Analytics)
5. Track Water Easily
6. Plan Meals Ahead
7. Build Better Habits
8. Get Daily Insights

Her chat'te ilgili görseli yükle.

### Flutter Paketleri (önerilen)
```yaml
dependencies:
  flutter:
    sdk: flutter
  # State
  flutter_riverpod: ^2.4.0
  # Routing
  go_router: ^13.0.0
  # Charts
  fl_chart: ^0.66.0
  # Supabase
  supabase_flutter: ^2.3.0
  # HTTP
  dio: ^5.4.0
  # Camera & Image
  camera: ^0.10.5
  image_picker: ^1.0.7
  # Notifications
  flutter_local_notifications: ^17.0.0
  firebase_messaging: ^14.7.0
  # Health
  health: ^10.0.0
  # Storage
  shared_preferences: ^2.2.2
  hive_flutter: ^1.1.0
  # UI Helpers
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^3.0.0
  # Utils
  intl: ^0.19.0
  uuid: ^4.3.0
  # Auth
  sign_in_with_apple: ^5.0.0
  # In-App Purchase
  purchases_flutter: ^6.20.0
```

### Backend Paketleri (FastAPI)
```
fastapi==0.110.0
uvicorn==0.27.0
pydantic==2.6.0
supabase==2.4.0
openai==1.12.0
python-dotenv==1.0.0
python-jose[cryptography]==3.3.0
httpx==0.27.0
apscheduler==3.10.4  # cron jobs
```

---

## 📋 CHAT 14–22 KAPANIŞ ÖZETİ (20 Mayıs 2026)

### Tamamlananlar
- **Chat 14:** Backend FastAPI iskeleti — Render'a deploy, `/health`, `/me` endpoint'leri
- **Chat 15:** Onboarding flow (5-step) + `OnboardingData` modeli + `CalorieCalculator`
- **Chat 16:** Repository integration (frontend ↔ backend wiring)
- **Chat 17:** *(routing — `_disabled_chat17_routing/`'de, henüz merge edilmedi)*
- **Chat 18:** Local notifications (FCM + flutter_local_notifications)
- **Chat 19:** Premium tier + RevenueCat entegrasyonu
- **Chat 20:** Launch submission docs (34 MD dosya)
- **Chat 21:** Project audit & cleanup
  - `flutter analyze` errors: **10071 → 0**
  - `analysis_options.yaml` exclude listesi (disabled/snippet/docs)
  - `macros_row.dart` int→num fix
- **Chat 22:** Integration & Smoke Test ✅
  - Signup → Onboarding → Dashboard akışı uçtan uca yeşil
  - **7 PR merge** edildi (#14, #15, #17, #18, #19 + Supabase SQL migration)

### Chat 22'nin Asıl Teknik Kazanımları
1. **Dual-algorithm JWT verifier** (`backend/core/auth.py`):
   - Supabase rotated to ES256 (asymmetric keys)
   - Backend JWKS endpoint'inden public key fetch + cache
   - HS256 + ES256/RS256 dual support
2. **`user_profiles` Supabase migration:**
   - 5 RENAME: `display_name→full_name`, `gender→sex`, `current_weight_kg→weight_kg`, `goal_type→weight_goal_direction`, `language→locale`
   - 6 ADD COLUMN: `dietary_preference`, `bmr`, `tdee`, `protein_target_g`, `carbs_target_g`, `fat_target_g`
   - `weight_goal_direction` CHECK constraint güncellendi (`lose|maintain|gain`)
3. **Frontend payload alignment** (`OnboardingData.toJson`):
   - Key names backend'e uyarlandı
   - `GoalType.toJson`: `loseWeight→lose`, `gainWeight→gain`, `buildMuscle→gain`
   - `ActivityLevel.toJson`: `veryActive→very_active`
4. **AuthGate wire-up:** Real `DashboardScreen` (was `_DashboardPlaceholder`)
5. **`ProfileService` Dio logger** — debug build'lerde `[ProfileService]` prefix'li request/response logları

### Chat 22'den Devralınan Technical Debt (Chat 23+ için)
- **`profiles` vs `user_profiles` dilemma:** `weight_logs` ve `weight_goals` foreign key'leri `profiles` tablosuna işaret ediyor, ama backend `user_profiles`'a yazıyor. Şu an try/except ile yutuluyor — gerçek fix migration gerektirir.
- **`bmr`, `tdee`, `protein_target_g`, `carbs_target_g`, `fat_target_g` upsert disabled:** Kolonlar artık var ama backend `_compute_targets` return'undan pop ediyor. Pop'u kaldır, response'ta da görünsün.
- **Email validator regex `+` aliasları reddediyor** (`auth_text_field.dart` `AuthValidators.email`).
- **3 ayrı Dio instance:** `ApiClient` (LogInterceptor + AuthInterceptor), `authedDioProvider` (manual token), `ProfileService._buildDio()` (manual options). `ApiClient`'a konsolide et.
- **Debug `[Onboarding]` print'leri** `onboarding_screen.dart` `_completeOnboarding`'de — Chat 23 sonrası temizle.
- **`api_client.dart.bak`** dosyası — temizlik.
- **Chat 17 routing** hâlâ disabled — `go_router` dependency'de ama kullanılmıyor.

### Production State (20 Mayıs 2026)
- **Backend:** `https://nuveli-api.onrender.com` (Render, free tier, dual-alg JWT live)
- **Supabase:** `asicgcnpahdnitzalcva.supabase.co` (Frankfurt, ES256 asymmetric keys, user_profiles schema aligned)
- **iOS Build:** `flutter build ios --debug --no-codesign` ✓ Built
- **Smoke test user:** `ambz@yandex.com` (verified, profile complete, dashboard rendering)

---

---

## 📋 CHAT 23 KAPANIŞ ÖZETİ (20 Mayıs 2026)

### Tamamlananlar — 14 PR (#22 → #34)
- Test infrastructure baseline temizlendi (haptics timing assertions, backend
  side_effect → shared chainable, `from __future__` import konumu fixes).
- **Flutter testleri: 70 → 198 (+128)**.
- **Backend testleri: 21 → 32** (+8 skipped follow-ups with clear reasons).
- Email validator `+` aliases artık kabul ediliyor (Gmail/iCloud tag flow'u
  fix); UserProfile.fromJson hem yeni hem legacy backend key isimlerini
  okur (Chat 22 alignment çakışması temizlendi).
- ApiClient + ProfileService + AuthedDio Dio'larının üçü de `kDebugMode`'da
  prefix'li LogInterceptor yayımlıyor — backend trafiği debug build'lerde
  tamamen görünür durumda.

### Coverage haritası
| Kritik path | Test sayısı |
|-------------|-------------|
| BMR / TDEE / Calorie pipeline | 29 (BMR formula 5, TDEE multiplier 4, calorie target + safety floors 7, water/macro split/grams 9, fromOnboarding 3) |
| Auth (validators / errors / service) | 48 (regex + form 23, fromSupabase mapping 14, AuthService mocktail 11) |
| UserProfile fromJson + key alignment | 14 (happy / null defaults / enum tolerance / date parse / dual-key backend support) |
| Auth widgets (Login / Signup / Welcome / Banner / Strength / AuthGate) | 21 (form gate, error surface, render, both AuthGate branches) |
| Integration (auth flow + onboarding complete) | 4 (Welcome → Signup, full submit happy paths, Step 5 → ProfileService.completeOnboarding) |
| Backend JWT verifier | 11 (HS256 happy, header parsing, expiry, alg whitelist, sub / aud claims, ES256 happy + unknown-kid via JWKS cache) |
| Backend other (health / meals / profiles / ai_coach / water) | 21 |

### Chat 23'ten Devralınan Technical Debt → Chat 24 takip
- **DashboardScreen widget testleri** ertelendi — `DashboardHeader` doğrudan
  `Supabase.instance.client` global singleton'ını okuyor; provider-driven hâle
  refactor edilene kadar mock'lanamıyor.
- **Onboarding step widget testleri** ertelendi — ListView içindeki
  AuthTextField + AppTypography asset bağımlılıkları test env'de stabil
  değil; custom surface size + Localizations delegate setup gerekiyor.
- **`test_get_me_returns_profile`** hâlâ skip — conftest mock_supabase
  fixture redesign'ı yetti ama runtime'da geri çağrılan chain test'in
  override ettiği instance ile aynı değil; daha derin bir conftest
  redesign gerekiyor.
- **`decision_engine` / `checkin_service` / `premium_service`** testleri
  module-level skip — bu servisler backend'de hiç implement edilmemiş,
  CLAUDE.md tasarım kalıntısı; ya implement edilmeli ya test rewrite.
- **3 Dio konsolidasyonu** ertelendi — ApiClient + authedDioProvider +
  ProfileService._buildDio() ayrı yaşıyor; LogInterceptor parity sağlandı
  ama tam birleştirme refactor + regression riski taşıyor.
- **CI workflow fix** (`.github/workflows/ci.yml`) ertelendi — backend
  syntax check adımı non-existent `app/` paket layout'una bakıyor, PAT'in
  `workflow` scope'u olmadığı için bu PR'da push edilemedi; el ile düzeltilmeli.
- **`profiles` vs `user_profiles` FK** — Chat 22'den devreden açık. `weight_logs` /
  `weight_goals` FK'ları yanlış tabloya bakıyor, try/except'le yutuluyor;
  SQL migration follow-up.

### Production State (sprint kapanışı)
- **Branch durumu:** main (head: PR #34 merged) — 14 Chat 23 PR'ı tek tek squash-merged.
- **Run komutu:**
  - Flutter: `cd app && flutter test` → 198 passed
  - Backend: `cd backend && source venv/bin/activate && pytest` → 32 passed, 8 skipped
- Smoke akışı (Chat 22'den): `ambz@yandex.com` ile signup → onboarding
  Step 5 → dashboard hâlâ green.

---

---

## 📋 CHAT 24 KAPANIŞ ÖZETİ — POLISH ROUND 1 (20 Mayıs 2026)

### Tamamlananlar — 8 PR (#36 → #43)

**Error surface (Polish 3 from prep doc):**
- AppError yeni alt sınıfları: `ForbiddenError` (403), `NotFoundError`
  (404), `ValidationError` (422). FastAPI `{detail: [{msg: ...}]}`
  payload da parse ediliyor. `sendTimeout` artık `NetworkError`'a düşüyor.
- `AppError.from(Object)` adapter — screens artık `e is AppError ? e : ...`
  yazmıyor.
- `AppErrorView` shared widget: her AppError alt sınıfı için icon + TR
  başlık eşleştirmesi (9 kategori), opsiyonel retry, compact mod.

**Loading + empty state primitives (Polish 1+2):**
- `SkeletonBox` + `SkeletonCircle` shared widget — shimmer wrapper
  cyan glow ile. Dashboard'ın inline `_DashboardSkeleton`'ı bu
  building block'lara taşındı, `_skeletonDecoration` helper'ı silindi.
- Dashboard meals_section'ın inline `_EmptyState`'i shared
  `EmptyStateView`'a (compact mode) çevrildi; tek görsel kaynak.

**Crash + telemetry wiring (Polish 9):**
- `CrashReporter.installGlobalHandlers()` — `FlutterError.onError` +
  `PlatformDispatcher.instance.onError` artık Crashlytics'e
  bağlı. Release'de unhandled hatalar artık sessizce kaybolmuyor.
- main() bunu dotenv/Supabase init'inden ÖNCE çağırıyor, yani
  startup-init exception'ları da raporlanıyor.
- `AuthNotifier` her auth state değişiminde
  `CrashReporter.setUser(user?.id)` çağırıyor — Crashlytics
  dashboard'unda her crash artık user_id taşıyor.

### Coverage delta
- Flutter tests: 198 → 224 passed (+26 — calorie 13 + error categories 5
  + AppErrorView 13 + SkeletonBox 4, eksi rakamlar mevcut suite içinde
  bulunan refactorlar).
- Backend tests: 32 passed (değişmedi).
- `flutter analyze`: 0 error baseline'ı korunuyor (sadece info-level
  `deprecated_member_use` uyarıları — `withOpacity` çağrıları, ayrı
  cleanup).

### Chat 24'ten Devralınan Polish Backlog
- **Localization (Polish 7)**: i18n setup TR/EN — yapılmadı, büyük iş.
  ARB dosyaları + `flutter_localizations` zaten dependency'de.
- **Dark mode (Polish 8)**: `theme_provider.dart` mevcut ama dark
  variant'ın bütün ekranlarda doğru render ettiği teyit edilmedi.
- **A11y (Polish 5)**: Semantic labels, dynamic font size, color
  contrast audit yapılmadı — App Store reject riski.
- **Haptic feedback (Polish 4)**: AppHaptics utility var ama UI tap'lerine
  sistemli yedirilmedi.
- **Onboarding tooltips (Polish 6)**: showcaseview ile dashboard
  first-launch tour eklenmedi.
- **Bug Hunt edge cases (Categories 1-6)**: Network/offline banner,
  permission flows, very large input values, double-tap throttle,
  iPhone SE / iPad layout verification — tek tek elden geçirilmedi.

### Devralınan teknik borç (Chat 22+23+24)
- **3 ayrı error class file** (`api_exception.dart` vs `api_exceptions.dart`
  vs `app_error.dart`) — AppError fiilen dominant, diğer iki dosya
  legacy import'larda yaşıyor; konsolide edilmesi gerek.
- **3 Dio unification** — ApiClient + authedDioProvider + ProfileService
  ._buildDio() hâlâ ayrı yaşıyor, sadece LogInterceptor parity sağlandı.
- **DashboardScreen widget testleri** — `DashboardHeader` Supabase
  global singleton'ını okuyor; provider-driven refactor gerek.
- **`test_get_me_returns_profile`** hâlâ skipped — mock chain runtime'da
  override edilen instance ile aynı değil.
- **`decision_engine` / `checkin_service` / `premium_service`** backend
  testleri — bu servisler implement edilmedi, sadece test'ler var.
- **CI workflow fix** (`.github/workflows/ci.yml`) — backend syntax check
  step'i non-existent app/ paket layout'una bakıyor.
- **`profiles` vs `user_profiles` FK** — `weight_logs` / `weight_goals`
  FK'ları yanlış tabloya bakıyor, try/except'le yutuluyor.

### Production State (sprint snapshot)
- Backend: `https://nuveli-api.onrender.com` (Render free, dual-alg JWT live)
- Supabase: `asicgcnpahdnitzalcva.supabase.co`, ES256 keys, user_profiles
  schema aligned.
- iOS Build: `flutter build ios --debug --no-codesign` ✓ Built.
- Smoke test akışı: signup → onboarding → dashboard green.

---

## 🎬 SONRAKİ ADIM

**Şu an:** Chat 24 — Polish round 1 + round 2 in progress (11 PR merged total).
224 frontend + 32 backend tests still green.

**Round 2 additions (PR #45 → #46):**
- PrimaryButton + AuthPrimaryButton wrapped in Semantics(label, button,
  enabled, hint) with excludeSemantics — VoiceOver/TalkBack now read
  out the right label + busy state. App Store reviewer-friendly.
- Same buttons fire AppHaptics.light() on tap — every CTA gets that
  subtle premium-feeling confirmation.
- progress_section empty state lifted from a tiny grey Text line to
  the shared EmptyStateView (icon + title + sub-message in TR).

**Hâlâ Round 2 backlog'unda:**
- i18n setup (TR/EN, ARB dosyaları + flutter_localizations delegates).
- Light mode full coverage (AppColors.X → theme-aware migration).
- Geniş A11y audit (her IconButton'a tooltip + semantic label,
  dynamic font size verification, color contrast 4.5:1).
- Tooltips / onboarding showcase (`showcaseview` paketi).
- Bug Hunt edge case scan (network/offline banner, double-tap throttle,
  iPhone SE layout, very-long input).

**Bir sonraki adım:** Yeni bir Claude chat aç, **Chat 24 round 2 polish
listesinden bir kategori seç ve devam et**. Önerilen: i18n setup
(`flutter gen-l10n` ile TR/EN dual base), sonra A11y audit (sistematik
ekran-ekran geçiş).

`docs/sprints/chat24_bughunt.md` dosyasını project files'a yükle — Claude
doğrudan Chat 24 hazırlık paketini görür.

Chat 24 kapsam özeti:
- **Bug Hunt (Defense):** Network kapalı, double-tap, çok uzun input,
  permission red etme, edge case veri, UI breaking points, state edge
  cases, performans dipleri.
- **Polish (Offense):** Loading skeletons, empty states, friendly
  error messages, micro-interactions + haptics, accessibility (A11y),
  onboarding tooltips, TR+EN localization, dark/light mode, Sentry
  crash reporting, Firebase/Mixpanel analytics.
- **Pre-launch final checklist:** Functional + UX + A11y + Performance
  + Production Setup + Marketing.

Başarılar! 🚀
