-- ============================================
-- HER TABLODAKİ SATIR SAYISI
-- Hangi tablo dolu, hangisi boş anlamak için
-- ÇIKTI: "Messages" sekmesinde görünür (Results değil)
-- ============================================

DO $$
DECLARE
  t record;
  cnt bigint;
  result text := E'\n';
BEGIN
  result := result || '=== TABLE ROW COUNTS ===' || E'\n';
  result := result || rpad('table_name', 45) || '| rows' || E'\n';
  result := result || rpad('-', 45, '-') || '+------' || E'\n';

  FOR t IN (
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    ORDER BY table_name
  ) LOOP
    EXECUTE format('SELECT COUNT(*) FROM public.%I', t.table_name) INTO cnt;
    result := result || rpad(t.table_name, 45) || '| ' || cnt || E'\n';
  END LOOP;

  RAISE NOTICE '%', result;
END $$;
