# 🔐 FAZ 3.2 — RLS Policy Test Plan

**Çalıştırma yeri:** Supabase Dashboard → SQL Editor
**Tarih:** 2026-05-21
**Beklenen süre:** 15 dakika

Bu sorgular **production DB**'de çalıştırılacak. Her sorgu sonucu raporda altına yapıştır.

---

## Setup — Test User'ları Oluştur (gerekli değilse atla)

```sql
-- 2 test user ID'si seçelim (mevcut auth.users'tan)
SELECT id, email, created_at FROM auth.users
ORDER BY created_at DESC LIMIT 5;
```

Çıktı (örnek):
```
| id                                  | email                       |
| ----                                | -----                       |
| 11111111-...                        | reviewer@nuveli.app         |
| 22222222-...                        | test2@nuveli.app            |
```

İki ID'yi aşağıdaki sorgularda **USER_A** ve **USER_B** ile değiştir.

---

## Test Suite — 13 Tablo × Cross-User Erişim

### 1. user_profiles

```sql
-- USER_A perspektifinden (Supabase Dashboard → Impersonate)
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claim.sub" = 'USER_A_ID';

-- A kendi profilini görmeli
SELECT * FROM user_profiles WHERE user_id = 'USER_A_ID';
-- BEKLEN: 1 satır

-- A B'nin profilini GÖRMEMELI
SELECT * FROM user_profiles WHERE user_id = 'USER_B_ID';
-- BEKLEN: 0 satır (RLS engel)

-- A B'ye INSERT yapamamalı
INSERT INTO user_profiles (user_id, display_name) VALUES ('USER_B_ID', 'Hacker');
-- BEKLEN: RLS violation error
```

### 2. meals

```sql
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claim.sub" = 'USER_A_ID';

-- A kendi meal'lerini görür
SELECT count(*) FROM meals WHERE user_id = 'USER_A_ID';

-- A B'nin meal'lerini GÖRMEMELI
SELECT count(*) FROM meals WHERE user_id = 'USER_B_ID';
-- BEKLEN: 0

-- A B için meal insert yapamamalı
INSERT INTO meals (user_id, meal_type, consumed_at) 
VALUES ('USER_B_ID', 'lunch', NOW());
-- BEKLEN: new row violates row-level security policy

-- A B'nin meal'ini silemez
DELETE FROM meals WHERE user_id = 'USER_B_ID';
-- BEKLEN: 0 satır etkilendi
```

### 3. meal_foods (INDIRECT OWNERSHIP — KRİTİK)

```sql
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claim.sub" = 'USER_A_ID';

-- B'nin meal'inin meal_foods'unu görüyor mu? GÖRMEMELI.
SELECT mf.* FROM meal_foods mf
JOIN meals m ON m.id = mf.meal_id
WHERE m.user_id = 'USER_B_ID';
-- BEKLEN: 0 satır
```

### 4-13. Diğer Tablolar (aynı pattern)

```sql
-- Generic test: USER_A olarak USER_B verisi görünüyor mu?
SET LOCAL "request.jwt.claim.sub" = 'USER_A_ID';

SELECT 'water_logs' AS tbl, count(*) FROM water_logs WHERE user_id = 'USER_B_ID'
UNION ALL
SELECT 'water_reminders', count(*) FROM water_reminders WHERE user_id = 'USER_B_ID'
UNION ALL
SELECT 'habits', count(*) FROM habits WHERE user_id = 'USER_B_ID'
UNION ALL
SELECT 'habit_completions', count(*) FROM habit_completions WHERE user_id = 'USER_B_ID'
UNION ALL
SELECT 'meal_plans', count(*) FROM meal_plans WHERE user_id = 'USER_B_ID'
UNION ALL
SELECT 'weight_logs', count(*) FROM weight_logs WHERE user_id = 'USER_B_ID'
UNION ALL
SELECT 'weight_goals', count(*) FROM weight_goals WHERE user_id = 'USER_B_ID'
UNION ALL
SELECT 'ai_insights', count(*) FROM ai_insights WHERE user_id = 'USER_B_ID'
UNION ALL
SELECT 'user_achievements', count(*) FROM user_achievements WHERE user_id = 'USER_B_ID';
-- BEKLEN: HER SATIRDA count=0
```

### 14. Recipes (HİBRİT — public + private)

```sql
SET LOCAL "request.jwt.claim.sub" = 'USER_A_ID';

-- Public recipes herkes görmeli
SELECT count(*) FROM recipes WHERE is_public = true;
-- BEKLEN: >0 (eğer seed data varsa)

-- Private recipes — sadece sahibinin
SELECT count(*) FROM recipes WHERE is_public = false AND user_id = 'USER_B_ID';
-- BEKLEN: 0 (A B'nin private recipe'lerini görmemeli)

SELECT count(*) FROM recipes WHERE is_public = false AND user_id = 'USER_A_ID';
-- BEKLEN: A'nın private recipe sayısı (≥0)
```

---

## Result Template (sonuçları aşağıya yapıştır)

```
1. user_profiles cross-user SELECT count → 0 ✅
2. meals cross-user SELECT count → 0 ✅
3. meal_foods (indirect) cross-user SELECT count → 0 ✅
4. water_logs cross-user → 0 ✅
5. water_reminders cross-user → 0 ✅
6. habits cross-user → 0 ✅
7. habit_completions cross-user → 0 ✅
8. meal_plans cross-user → 0 ✅
9. weight_logs cross-user → 0 ✅
10. weight_goals cross-user → 0 ✅
11. ai_insights cross-user → 0 ✅
12. user_achievements cross-user → 0 ✅
13. recipes private cross-user → 0 ✅
14. INSERT into B's data as A → RLS violation ✅
```

**Eğer herhangi biri ≠ 0 veya error gelmezse → 🔴 CRITICAL BLOCKER.**
