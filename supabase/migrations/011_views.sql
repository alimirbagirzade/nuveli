-- =============================================================================
-- Migration 011 (DÜZELTILMIŞ): Views (özet sorgular)
-- =============================================================================
-- DEĞIŞIKLIK: user_7day_summary'nin scalar subquery'si LEFT JOIN'e çevrildi.
--             Önceki: SELECT içinde "(SELECT SUM(amount_ml) FROM water_logs WHERE
--                     ... DATE(logged_at) = DATE(m.consumed_at))" → GROUP BY ile
--                     çakışıyordu (m.consumed_at outer'da grouped değil).
--             Şimdi: daily_water adında ikinci CTE + LEFT JOIN day üzerinden.
--             Bonus: daha hızlı (su bir kez agrega edilir, her satırda değil).
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- user_7day_summary: Son 7 günün özetli verileri (Analytics ekranı için)
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS public.user_7day_summary CASCADE;

CREATE VIEW public.user_7day_summary
WITH (security_invoker = true)
AS
WITH daily_meals AS (
  SELECT
    m.user_id,
    DATE(m.consumed_at) AS day,
    SUM(m.total_calories)::INT      AS daily_calories,
    SUM(m.total_protein_g)::NUMERIC AS daily_protein,
    SUM(m.total_carbs_g)::NUMERIC   AS daily_carbs,
    SUM(m.total_fat_g)::NUMERIC     AS daily_fat,
    p.daily_calorie_target,
    (p.daily_calorie_target * 0.9)::NUMERIC AS target_low,
    (p.daily_calorie_target * 1.1)::NUMERIC AS target_high
  FROM public.meals m
  JOIN public.user_profiles p ON p.user_id = m.user_id
  WHERE m.consumed_at >= NOW() - INTERVAL '7 days'
  GROUP BY m.user_id, DATE(m.consumed_at), p.daily_calorie_target
),
daily_water AS (
  SELECT
    w.user_id,
    DATE(w.logged_at) AS day,
    SUM(w.amount_ml)::INT AS daily_water_ml
  FROM public.water_logs w
  WHERE w.logged_at >= NOW() - INTERVAL '7 days'
  GROUP BY w.user_id, DATE(w.logged_at)
),
daily AS (
  SELECT
    dm.user_id,
    dm.day,
    dm.daily_calories,
    dm.daily_protein,
    dm.daily_carbs,
    dm.daily_fat,
    COALESCE(dw.daily_water_ml, 0) AS daily_water_ml,
    dm.target_low,
    dm.target_high
  FROM daily_meals dm
  LEFT JOIN daily_water dw
    ON dw.user_id = dm.user_id
   AND dw.day     = dm.day
)
SELECT
  user_id,
  ROUND(AVG(daily_calories))::INT      AS avg_calories,
  ROUND(AVG(daily_protein), 1)         AS avg_protein_g,
  ROUND(AVG(daily_carbs), 1)           AS avg_carbs_g,
  ROUND(AVG(daily_fat), 1)             AS avg_fat_g,
  ROUND(AVG(daily_water_ml))::INT      AS avg_water_ml,
  MAX(day)                             AS last_day,
  MIN(day)                             AS first_day,
  COUNT(*) FILTER (WHERE daily_calories BETWEEN target_low AND target_high)::INT AS days_on_target,
  COUNT(*)::INT                        AS total_days
FROM daily
GROUP BY user_id;

COMMENT ON VIEW public.user_7day_summary IS 'Son 7 günün özet metrikleri. Analytics ekranı bu view''dan tek SELECT ile beslenir.';

-- -----------------------------------------------------------------------------
-- dashboard_today: Bugünün dashboard verisi (Dashboard ekranı için)
-- Bu view'da problem yoktu, aynen koruyoruz.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS public.dashboard_today CASCADE;

CREATE VIEW public.dashboard_today
WITH (security_invoker = true)
AS
SELECT
  p.user_id,
  CURRENT_DATE AS date,

  -- Bugün totalleri
  COALESCE(SUM(m.total_calories), 0)::INT                  AS consumed_calories,
  COALESCE(SUM(m.total_protein_g), 0)::NUMERIC             AS consumed_protein_g,
  COALESCE(SUM(m.total_carbs_g), 0)::NUMERIC               AS consumed_carbs_g,
  COALESCE(SUM(m.total_fat_g), 0)::NUMERIC                 AS consumed_fat_g,

  -- Hedefler
  p.daily_calorie_target,
  p.protein_target_pct,
  p.carbs_target_pct,
  p.fat_target_pct,

  -- Su (subquery — burada GROUP BY problemi yok çünkü scalar context'te m'e referans yok)
  COALESCE((
    SELECT SUM(w.amount_ml)
    FROM public.water_logs w
    WHERE w.user_id = p.user_id
      AND DATE(w.logged_at) = CURRENT_DATE
  ), 0)::INT AS consumed_water_ml,
  p.daily_water_target_ml,

  -- Meal sayısı
  COUNT(m.id) FILTER (WHERE DATE(m.consumed_at) = CURRENT_DATE)::INT AS meal_count_today,

  -- Streak
  p.current_streak_days
FROM public.user_profiles p
LEFT JOIN public.meals m
  ON m.user_id = p.user_id
 AND DATE(m.consumed_at) = CURRENT_DATE
GROUP BY
  p.user_id,
  p.daily_calorie_target,
  p.protein_target_pct,
  p.carbs_target_pct,
  p.fat_target_pct,
  p.daily_water_target_ml,
  p.current_streak_days;

COMMENT ON VIEW public.dashboard_today IS 'Bugünkü tüketim + hedef + streak. Dashboard ekranı bu view''dan tek SELECT ile beslenir.';

COMMIT;
