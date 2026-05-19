# 🌊 Nuveli — Master Development Plan

**Proje:** Nuveli AI Calorie Coach (Flutter + FastAPI + Supabase + OpenAI)
**Repo:** github.com/alimirbagirzade/nuveli_test
**Backend URL:** https://nuveli-api.onrender.com
**Son Güncelleme:** 19 Mayıs 2026 (Chat 12 tamamlandı)
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

#### 🗄️ Chat 13: Supabase Schema & Migrations
**Çıktılar:** Tüm SQL migrations, RLS policies, indexes
**Tablolar:**
- `user_profiles`
- `meals`
- `weight_logs`
- `water_logs`
- `meal_plans`
- `recipes`
- `habits`
- `habit_completions`
- `ai_insights`
- `user_achievements`

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
- [ ] Chat 13: Supabase Schema
- [ ] Chat 14: Backend API
- [ ] Chat 15: Authentication
- [ ] Chat 16: State Management & Repository Integration
- [ ] Chat 17: Navigation & Routing
- [ ] Chat 18: Notifications

### Faz 4: Release
- [ ] Chat 19: RevenueCat & Premium
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

## 🎬 SONRAKİ ADIM

**Şu an:** Bu master plan oluşturuldu ✅

**Bir sonraki adım:** Yeni bir chat aç ve **Chat 1: Theme & Design System** ile başla.

Açılış mesajı şablonunu kullan, bu master plan'ı project files'a yükle.

Başarılar! 🚀
