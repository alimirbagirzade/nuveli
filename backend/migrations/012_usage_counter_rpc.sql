-- 012_usage_counter_rpc.sql
-- Nuveli — atomic increment helper
-- decision_engine.increment_usage() bu fonksiyonu çağırır.
-- Race condition'sız sayaç artışı için.

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
  INSERT INTO usage_counters_daily (user_id, usage_date, feature, count)
  VALUES (p_user_id, p_date, p_feature, 1)
  ON CONFLICT (user_id, usage_date, feature)
  DO UPDATE SET
    count = usage_counters_daily.count + 1,
    updated_at = now()
  RETURNING count INTO new_count;

  RETURN new_count;
END;
$$;

-- Sadece authenticated/service_role çağırabilir
REVOKE ALL ON FUNCTION increment_usage_counter(UUID, DATE, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION increment_usage_counter(UUID, DATE, TEXT) TO authenticated, service_role;
