# Veritabanı Şeması

Tüm tablolar Supabase/PostgreSQL'de tutulur.  
Kural: UUID PK, `created_at` / `updated_at`, RLS aktif.

---

## Tablo Listesi

### `profiles`
Kullanıcı temel profili.

| Alan | Tip | Notlar |
|------|-----|--------|
| id | uuid PK | Supabase Auth user id ile eşleşir |
| display_name | text | |
| birth_year | int | Yaş hesabı için |
| gender | text | check: male/female/other/prefer_not |
| height_cm | numeric | |
| weight_kg | numeric | Onboarding başlangıç kilosu |
| goal | text | check: lose/maintain/gain |
| activity_level | text | check: sedentary/light/moderate/active |
| daily_calorie_target | int | Hesaplanan hedef |
| onboarding_completed | bool | default false |
| special_conditions | text[] | pregnancy, eating_disorder_history, chronic_illness |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | |

---

### `coach_preferences`
Kullanıcının koç tercihleri.

| Alan | Tip | Notlar |
|------|-----|--------|
| id | uuid PK | |
| user_id | uuid FK → profiles | |
| coach_persona | text | check: supportive/motivating/realistic |
| risk_mode | text | check: normal/low_intake/distress/crisis |
| created_at | timestamptz | |
| updated_at | timestamptz | |

---

### `notification_preferences`
Bildirim tercihleri.

| Alan | Tip | Notlar |
|------|-----|--------|
| id | uuid PK | |
| user_id | uuid FK → profiles | |
| meal_reminders | bool | default true |
| coach_nudges | bool | default true |
| weekly_summary | bool | default true |
| quiet_start | time | default 22:00 |
| quiet_end | time | default 08:00 |
| created_at | timestamptz | |
| updated_at | timestamptz | |

---

### `premium_status_cache`
RevenueCat'ten gelen premium durumu cache'i.

| Alan | Tip | Notlar |
|------|-----|--------|
| id | uuid PK | |
| user_id | uuid FK → profiles | |
| tier | text | check: free/trial/premium |
| trial_ends_at | timestamptz | nullable |
| subscription_ends_at | timestamptz | nullable |
| rc_customer_id | text | RevenueCat customer id |
| updated_at | timestamptz | |

---

### `usage_counters_daily`
Günlük kullanım sayacı (feature gating için).

| Alan | Tip | Notlar |
|------|-----|--------|
| id | uuid PK | |
| user_id | uuid FK → profiles | |
| local_day | date | Kullanıcı timezone'unda gün |
| meal_analyses | int | default 0 |
| coach_messages | int | default 0 |
| created_at | timestamptz | |
| updated_at | timestamptz | |

Unique constraint: `(user_id, local_day)`

---

### `meal_logs`
Kullanıcının onayladığı öğün kayıtları.

| Alan | Tip | Notlar |
|------|-----|--------|
| id | uuid PK | |
| user_id | uuid FK → profiles | |
| local_day | date | |
| meal_type | text | check: breakfast/lunch/dinner/snack |
| name | text | |
| calories | int | |
| protein_g | numeric | nullable |
| carb_g | numeric | nullable |
| fat_g | numeric | nullable |
| source | text | check: ai_confirmed/ai_edited/manual |
| analysis_id | uuid FK → meal_analysis_results | nullable |
| created_at | timestamptz | |
| updated_at | timestamptz | |

---

### `meal_analysis_results`
AI ham tahmin sonuçları (değişmez audit trail).

| Alan | Tip | Notlar |
|------|-----|--------|
| id | uuid PK | |
| user_id | uuid FK | |
| raw_response | jsonb | OpenAI ham yanıtı |
| confidence | text | check: high/medium/low/failed |
| suggested_name | text | |
| suggested_calories | int | |
| suggested_protein_g | numeric | |
| suggested_carb_g | numeric | |
| suggested_fat_g | numeric | |
| created_at | timestamptz | |

---

### `daily_summaries`
Günlük özet cache.

| Alan | Tip | Notlar |
|------|-----|--------|
| id | uuid PK | |
| user_id | uuid FK | |
| local_day | date | |
| total_calories | int | |
| total_protein_g | numeric | |
| total_carb_g | numeric | |
| total_fat_g | numeric | |
| water_ml | int | |
| weight_kg | numeric | nullable |
| meal_count | int | |
| generated_at | timestamptz | |

Unique constraint: `(user_id, local_day)`

---

## RLS Politikası (Genel Kural)

Her tabloda: `user_id = auth.uid()` şartı ile SELECT, INSERT, UPDATE, DELETE.  
Adminler service role key ile erişir.
