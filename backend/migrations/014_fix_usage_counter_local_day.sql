-- 014_fix_usage_counter_local_day.sql
-- Fix: usage_counters_daily tablosunda usage_date -> local_day rename
-- Backend kod tabanı her yerde "local_day" kullanıyor, ancak Migration 010
-- "usage_date" sütunu yarattı. Bu inconsistency Sprint 2 sırasında ortaya çıktı.
-- Idempotent: defalarca çalıştırılabilir.

-- 1) local_day sütununu ekle (yoksa)
ALTER TABLE usage_counters_daily 
  ADD COLUMN IF NOT EXISTS local_day DATE;

-- 2) Eğer usage_date varsa, değerleri local_day'e kopyala
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'usage_counters_daily' AND column_name = 'usage_date'
  ) THEN
    UPDATE usage_counters_daily SET local_day = usage_date WHERE local_day IS NULL;
  END IF;
END $$;

-- 3) NOT NULL constraint
ALTER TABLE usage_counters_daily 
  ALTER COLUMN local_day SET NOT NULL;

-- 4) Eski unique constraint'i kaldır
ALTER TABLE usage_counters_daily 
  DROP CONSTRAINT IF EXISTS usage_counters_daily_user_id_usage_date_feature_key;

-- 5) Yeni unique constraint (local_day ile)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'usage_counters_daily_user_local_day_feature_key'
  ) THEN
    ALTER TABLE usage_counters_daily 
      ADD CONSTRAINT usage_counters_daily_user_local_day_feature_key 
      UNIQUE(user_id, local_day, feature);
  END IF;
END $$;

-- 6) Eski usage_date sütununu kaldır
ALTER TABLE usage_counters_daily 
  DROP COLUMN IF EXISTS usage_date;

-- 7) Eski index'i sil, yeni index ekle
DROP INDEX IF EXISTS idx_usage_counters_user_date;
CREATE INDEX IF NOT EXISTS idx_usage_counters_user_local_day
  ON usage_counters_daily(user_id, local_day);

-- 8) RPC function'ı local_day ile güncelle
CREATE OR REPLACE FUNCTION increment_usage_counter(
  p_user_id UUID,
  p_date DATE,
  p_feature TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  new_count INTEGER;
BEGIN
  INSERT INTO usage_counters_daily (user_id, local_day, feature, count)
  VALUES (p_user_id, p_date, p_feature, 1)
  ON CONFLICT (user_id, local_day, feature)
  DO UPDATE SET
    count = usage_counters_daily.count + 1,
    updated_at = now()
  RETURNING count INTO new_count;

  RETURN new_count;
END;
$$;

REVOKE ALL ON FUNCTION increment_usage_counter(UUID, DATE, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION increment_usage_counter(UUID, DATE, TEXT) TO authenticated, service_role;

-- 9) Doğrulama
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'usage_counters_daily' 
ORDER BY ordinal_position;
