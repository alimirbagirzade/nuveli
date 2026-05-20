# 🔍 FAZ 3.1 — Database Consistency Check

**Çalıştırma yeri:** Supabase Dashboard → SQL Editor
**Tarih:** 2026-05-21
**Beklenen süre:** 10 dakika

Bu sorgular **service-role** olarak çalışır (RLS bypass'lı, tam görünüm).

---

## 1. Orphan Records — auth.users'a bağlı olmayan profile'lar

```sql
SELECT 'orphan_profiles' AS check, count(*) AS bad_rows
FROM user_profiles up
LEFT JOIN auth.users u ON u.id = up.user_id
WHERE u.id IS NULL;
-- BEKLEN: 0 (her profile'ın bir auth user'ı olmalı)
```

## 2. Orphan Records — Profile'ı olmayan auth user'lar

```sql
SELECT 'auth_without_profile' AS check, count(*) AS rows
FROM auth.users u
LEFT JOIN user_profiles up ON up.user_id = u.id
WHERE up.user_id IS NULL;
-- BEKLEN: Düşük olmalı (signup sırasındaki ara süre normal)
-- >50% → profile creation trigger broken
```

## 3. FK Violations — meal_foods'da olup meals'da olmayan

```sql
SELECT 'orphan_meal_foods' AS check, count(*) AS rows
FROM meal_foods mf
LEFT JOIN meals m ON m.id = mf.meal_id
WHERE m.id IS NULL;
-- BEKLEN: 0 (FK ON DELETE CASCADE ile temizlenmeli)
```

## 4. FK Violations — habit_completions'da habits eksik

```sql
SELECT 'orphan_habit_completions' AS check, count(*) AS rows
FROM habit_completions hc
LEFT JOIN habits h ON h.id = hc.habit_id
WHERE h.id IS NULL;
-- BEKLEN: 0
```

## 5. NULL Check — Zorunlu Alanlar

```sql
SELECT
  'user_profiles_null_display_name' AS check, count(*) FILTER (WHERE display_name IS NULL) AS rows
FROM user_profiles
UNION ALL SELECT
  'meals_null_user_id', count(*) FILTER (WHERE user_id IS NULL)
FROM meals
UNION ALL SELECT
  'meals_null_meal_type', count(*) FILTER (WHERE meal_type IS NULL)
FROM meals
UNION ALL SELECT
  'water_logs_null_amount', count(*) FILTER (WHERE amount_ml IS NULL)
FROM water_logs;
-- BEKLEN: HER SATIR 0
```

## 6. Streak Sanity Check

```sql
SELECT
  up.user_id,
  up.current_streak_days,
  (
    SELECT MAX(d) FROM (
      SELECT DISTINCT DATE(consumed_at) AS d
      FROM meals
      WHERE user_id = up.user_id
    ) sub
  ) AS last_meal_date,
  CURRENT_DATE - (
    SELECT MAX(d) FROM (
      SELECT DISTINCT DATE(consumed_at) AS d
      FROM meals
      WHERE user_id = up.user_id
    ) sub
  ) AS days_since_last_meal
FROM user_profiles up
WHERE up.current_streak_days > 0
LIMIT 10;
-- BEKLEN: days_since_last_meal ≤ 1 her satırda
-- Eğer days_since > 1 ve streak > 0 → streak güncelleme broken
```

## 7. Sanity Bounds — Yiyecek Miktarları

```sql
SELECT 'negative_calories' AS issue, count(*) FROM meals WHERE total_calories < 0
UNION ALL SELECT 'over_100000_calories', count(*) FROM meals WHERE total_calories > 100000
UNION ALL SELECT 'negative_weight', count(*) FROM weight_logs WHERE weight_kg < 0
UNION ALL SELECT 'weight_over_500kg', count(*) FROM weight_logs WHERE weight_kg > 500
UNION ALL SELECT 'water_negative', count(*) FROM water_logs WHERE amount_ml < 0
UNION ALL SELECT 'water_over_20L', count(*) FROM water_logs WHERE amount_ml > 20000;
-- BEKLEN: HER SATIR 0
```

## 8. Future/Past Date Sanity

```sql
SELECT
  'future_meals' AS issue, count(*) FROM meals
  WHERE consumed_at > NOW() + INTERVAL '1 day'
UNION ALL SELECT
  'pre_2020_meals', count(*) FROM meals
  WHERE consumed_at < '2020-01-01';
-- BEKLEN: Her ikisi 0 (sanity)
```

## 9. Premium State Tutarlılığı

```sql
SELECT
  count(*) FILTER (WHERE is_premium = true AND premium_expires_at < NOW()) AS expired_but_still_premium,
  count(*) FILTER (WHERE is_premium = false AND premium_expires_at > NOW()) AS valid_but_not_premium
FROM user_profiles;
-- BEKLEN: 0, 0 (RevenueCat webhook senkron tutmalı)
-- >0 → webhook senkron sorunu var
```

## 10. Index Coverage Check

```sql
-- Çok-sorgulanan kolonlarda index var mı?
SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- BEKLEN: user_id üzerinde her tabloda index OLMALI
-- meals(consumed_at, user_id) composite index OLMALI (sorgu pattern)
```

---

## Result Template

```
1. orphan_profiles: 0 ✅
2. auth_without_profile: ___ (düşük tutulmalı)
3. orphan_meal_foods: 0 ✅
4. orphan_habit_completions: 0 ✅
5. NULL checks: hepsi 0 ✅
6. Streak sanity: tutarlı ✅ / ❌
7. Sanity bounds: hepsi 0 ✅
8. Future/past dates: 0, 0 ✅
9. Premium state: 0, 0 ✅
10. Index coverage: user_id her tabloda ✅ / ❌
```

**Bulgular bu raporun altına özet olarak yazılır.**
