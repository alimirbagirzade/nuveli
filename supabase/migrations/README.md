# 🗄️ Nuveli — Supabase Schema (Chat 13)

**Son güncelleme:** 18 Mayıs 2026
**Toplam:** 13 tablo + 2 view + ~45 RLS policy + 25+ index + 9 trigger + 5 helper fonksiyon
**Migration sayısı:** 13 SQL dosyası

---

## 📐 ER Diagram (Mantıksal)

```
                       auth.users  (Supabase managed)
                            │  (1)
                            │
       ┌────────────┬───────┴───────┬──────────────┬──────────────┐
       │            │               │              │              │
       ▼            ▼               ▼              ▼              ▼
 user_profiles   meals          water_logs      habits       weight_logs
   (1-1)         (1-N)            (1-N)          (1-N)         (1-N)
                  │                                │
                  ▼                                ▼
              meal_foods                   habit_completions
               (1-N)                            (1-N)
                                                   
       ┌────────────┬───────────────┬──────────────┐
       │            │               │              │
       ▼            ▼               ▼              ▼
   water_         meal_plans     weight_       ai_insights
   reminders        │            goals          (günde 1)
   (1-N)            │            (1 aktif)
                    ▼
                 recipes (sistem + private)
                    
                 user_achievements (1-N, default 4)
```

---

## 📂 Migration Sırası (ZORUNLU!)

Supabase SQL Editor'de **sırayla** çalıştırılmalı:

| # | Dosya | Ne yapar? |
|---|---|---|
| 1 | `001_extensions.sql` | uuid-ossp, pgcrypto, pg_trgm |
| 2 | `002_profiles_table.sql` | `user_profiles` tablosu |
| 3 | `003_meals_table.sql` | `meals` + `meal_foods` |
| 4 | `004_water_logs_table.sql` | `water_logs` + `water_reminders` |
| 5 | `005_habits_tables.sql` | `habits` + `habit_completions` |
| 6 | `006_meal_plans_tables.sql` | `recipes` + `meal_plans` |
| 7 | `007_weight_logs_table.sql` | `weight_logs` + `weight_goals` |
| 8 | `008_ai_insights_table.sql` | `ai_insights` |
| 9 | `009_achievements_table.sql` | `user_achievements` |
| 10 | `010_rls_policies.sql` | Tüm RLS policy'leri |
| 11 | `011_views.sql` | `user_7day_summary`, `dashboard_today` |
| 12 | `012_triggers.sql` | updated_at, meal totals, streak, new user, achievement unlock |
| 13 | `013_seed_data.sql` | Public recipes + mevcut user backfill |

**Hepsi idempotent** (`IF NOT EXISTS`, `ON CONFLICT DO NOTHING`, `DROP POLICY IF EXISTS`), yeniden çalıştırılabilir.

---

## 🧱 Tablolar — Tek Satır Özet

| Tablo | Amacı | Önemli Notlar |
|---|---|---|
| `user_profiles` | Onboarding bilgileri, hedefler, tercihler | `chk_macro_pct_sum`: protein+carbs+fat = 100 |
| `meals` | Öğün başlığı | `total_*` alanları trigger ile otomatik hesaplanır |
| `meal_foods` | Öğün içindeki yiyecekler | INSERT/UPDATE/DELETE → meals.total_* yeniden hesap |
| `water_logs` | Su içme kayıtları (her +250ml ayrı satır) | `amount_ml` 0-5000 arası |
| `water_reminders` | Su hatırlatıcı saatleri | `days_of_week` mon-sun arrayı |
| `habits` | Alışkanlık tanımları | Default 5 habit signup'ta otomatik |
| `habit_completions` | Günlük tamamlama | `UNIQUE(habit_id, completion_date)` |
| `recipes` | Tarif kütüphanesi | `user_id NULL` = sistem tarifi (public zorunlu) |
| `meal_plans` | Haftalık plan | `UNIQUE(user_id, plan_date, meal_type)` |
| `weight_logs` | Kilo ölçümleri | `UNIQUE(user_id, logged_at)` — günde 1 |
| `weight_goals` | Aktif kilo hedefi | Partial unique → aynı anda 1 aktif |
| `ai_insights` | Günlük AI çıktısı | `UNIQUE(user_id, insight_date)` — UPSERT pattern |
| `user_achievements` | Başarımlar | `UNIQUE(user_id, achievement_type)` |

---

## 👁️ Views

### `user_7day_summary`
Son 7 günün ortalama kalori/makro/su + hedef tutturma sayısı. Analytics ekranı tek SELECT ile beslenir.

### `dashboard_today`
Bugün için consumed_calories + macros + water + meal_count + streak. Dashboard ekranı tek SELECT ile beslenir.

İkisi de `security_invoker = true` ile çalışır → RLS otomatik uygulanır (user kendi verisini görür).

---

## 🔐 RLS Stratejisi

**Genel kural:** Her kullanıcı SADECE kendi verisini görür/yazar.

**Pattern (12 tablo için ayrı SELECT/INSERT/UPDATE/DELETE policy):**
```sql
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id)
```

**İstisnalar:**
- **`meal_foods`**: Meal'in sahibi üzerinden EXISTS kontrolü.
- **`recipes`**: `SELECT` için `is_public = TRUE OR auth.uid() = user_id`.
- **`ai_insights`**: Sadece SELECT (INSERT/UPDATE backend service_role ile).
- **`user_achievements`**: Sadece SELECT (unlock işlemi backend tarafı).

**service_role bypass:** Backend (FastAPI) `SUPABASE_SERVICE_ROLE_KEY` ile RLS'i bypass eder — bu **bilinçli** seçim. AI insight yazma, achievement unlock gibi sistem operasyonları için gerekli.

---

## ⚡ Trigger'lar

| Trigger | Tablo | Ne yapar? |
|---|---|---|
| `trg_*_updated_at` | 8 tabloda | `BEFORE UPDATE` → updated_at = NOW() |
| `trg_recalc_meal_on_food_change` | meal_foods | INSERT/UPDATE/DELETE → meals.total_* yeniden hesap |
| `trg_update_streak_on_meal` | meals | INSERT → user_profiles.current_streak_days güncelle |
| `on_auth_user_created` | auth.users | INSERT → profile + 5 habit + 4 achievement oluştur |
| `trg_check_achievement_unlock` | user_achievements | UPDATE OF current_value → is_unlocked = TRUE if hit target |

---

## 🛠️ Helper Fonksiyonlar

| Fonksiyon | İmza | Kullanım |
|---|---|---|
| `update_updated_at_column()` | RETURNS TRIGGER | Generic, 8 tabloya bağlı |
| `recalculate_meal_totals()` | RETURNS TRIGGER | meal_foods değişince çağrılır |
| `update_user_streak()` | RETURNS TRIGGER | meal INSERT'inde çağrılır |
| `handle_new_user()` | RETURNS TRIGGER | auth.users INSERT'inde çağrılır (SECURITY DEFINER) |
| `check_achievement_unlock()` | RETURNS TRIGGER | UPDATE OF current_value'da çağrılır |
| `create_default_habits_for_user(uuid)` | RETURNS VOID | Public, manuel çağrılabilir |
| `create_default_achievements_for_user(uuid)` | RETURNS VOID | Public, manuel çağrılabilir |

---

## 🔍 Doğrulama Sorguları

Tüm migration'lar çalıştıktan sonra:

```sql
-- 1. Tablo sayısı: 13 (+ 2 view)
SELECT table_name, table_type FROM information_schema.tables
WHERE table_schema = 'public' ORDER BY table_type, table_name;

-- 2. RLS hepsinde aktif mi?
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
-- Hepsi true olmalı.

-- 3. Policy sayısı (~45 bekleniyor)
SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public';

-- 4. Index sayısı (~25+ bekleniyor)
SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public';

-- 5. Trigger sayısı (~12 bekleniyor)
SELECT tgname, tgrelid::regclass
FROM pg_trigger
WHERE NOT tgisinternal AND tgrelid::regclass::text LIKE 'public.%'
ORDER BY tgname;

-- 6. Public recipes geldi mi?
SELECT name, calories, meal_types FROM public.recipes WHERE is_public = TRUE;
-- 5 satır gelmeli (Greek Yogurt Bowl, Grilled Chicken Salad, ...)

-- 7. Yeni kullanıcı testi (Supabase Authentication → Add User ile bir test user oluştur):
-- Otomatik profile, 5 habit, 4 achievement gelmeli
SELECT
  (SELECT COUNT(*) FROM user_profiles WHERE user_id = 'TEST_USER_ID') AS profile_count,
  (SELECT COUNT(*) FROM habits WHERE user_id = 'TEST_USER_ID') AS habit_count,
  (SELECT COUNT(*) FROM user_achievements WHERE user_id = 'TEST_USER_ID') AS achievement_count;
-- 1, 5, 4 olmalı
```

---

## 🚨 Bilinen Konular ve Trade-off'lar

1. **`meal_foods` trigger her DELETE'te full SUM yapıyor** — küçük tabloda OK, ileride büyürse incremental update'e çevirebiliriz.
2. **`ai_insights` JSONB heavy** — Supabase free tier'da satır başı ~5KB sınırı aşılabilir; tokens_used metrikleri kontrol et.
3. **`pg_cron` Supabase free tier'da yok** — `ai_insights` üretimi için Render scheduled task (Chat 14) veya GitHub Actions kullanılacak.
4. **`weight_goals.is_active` partial unique** — sadece TRUE olanlar UNIQUE; bu yüzden eski hedefler `is_active = FALSE` ile saklanır.
5. **`handle_new_user` SECURITY DEFINER** — gerekli çünkü trigger auth.users'a bağlı (postgres user'ı public.* yazamayabilir). `SET search_path = public, auth` injection'a karşı koruma.
6. **Streak hesabı yalnızca meal ekleyince çalışıyor** — water/habit log streak'i tetiklemiyor. İstenirse genişletilebilir (Chat 14'te tartışılacak).

---

## 🚀 Sonraki Adım

**Chat 14:** Backend API (FastAPI) bu schema'ya CRUD yapar. Endpoint'ler:
- `POST /meals/scan` — AI vision + meals/meal_foods insert
- `POST /meals` — manuel meal log
- `GET /dashboard/summary` → `dashboard_today` view'ı çağırır
- `GET /analytics/weekly` → `user_7day_summary` view'ı çağırır
- `POST /ai/generate-insight` (cron) — service_role ile ai_insights upsert
- `POST /premium/webhook` — RevenueCat → user_profiles.is_premium update

---

## 📞 Sorun Çıkarsa

| Hata | Çözüm |
|---|---|
| `permission denied for table X` | RLS aktif, ama policy yok. `pg_policies` kontrol et. |
| `new row violates check constraint` | CHECK constraint failed (ör: `chk_macro_pct_sum`). Veriyi kontrol et. |
| `duplicate key value violates unique` | UNIQUE ihlali — UPSERT pattern (`ON CONFLICT ... DO UPDATE`) kullan. |
| `function gen_random_uuid() does not exist` | `pgcrypto` extension yüklenmemiş → migration 001'i çalıştır. |
| Yeni user için profile gelmiyor | `on_auth_user_created` trigger var mı kontrol et: `SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';` |
| `auth.uid()` NULL döndürüyor | Anonymous request, JWT yok. Frontend Supabase client init kontrolü. |

---

**Hazırlayan:** Claude (Anthropic) — Chat 13
**Repo:** github.com/alimirbagirzade/nuveli_test
**Sonraki:** Chat 14 — Backend API Integration
