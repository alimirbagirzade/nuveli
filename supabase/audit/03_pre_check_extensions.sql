-- =============================================================
-- PRE-CHECK: DROP SCHEMA public CASCADE GÜVENLİ Mİ?
-- =============================================================
-- 000_cleanup_old_schema.sql çalıştırılmadan ÖNCE bu çalışmalı.
-- Hiçbir extension public schema'da olmamalı.
-- =============================================================

SELECT
  e.extname    AS extension_name,
  n.nspname    AS schema_name,
  CASE
    WHEN n.nspname = 'public' THEN 'TEHLIKE - taşınmalı'
    ELSE 'OK - dokunulmuyor'
  END AS durum
FROM pg_extension e
JOIN pg_namespace n ON e.extnamespace = n.oid
ORDER BY n.nspname, e.extname;

-- BEKLENEN ÇIKTI (Supabase default):
--   plpgsql            | pg_catalog | OK
--   pgcrypto           | extensions | OK
--   uuid-ossp          | extensions | OK
--   pg_stat_statements | extensions | OK
--   supabase_vault     | vault      | OK
--
-- HİÇBİR satırda 'public' GÖRMEMELİSİN.
-- Görürsen: bana söyle, ALTER EXTENSION ile taşıma adımı ekleyeceğim.
