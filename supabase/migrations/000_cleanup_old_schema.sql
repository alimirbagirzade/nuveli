-- =============================================================
-- NUVELI SUPABASE CLEANUP — OLD SCHEMA
-- Tarih:   2026-05-18
-- Strateji: A) Hepsini sil, master plan'a göre sıfırdan kur (Chat 13)
--
-- DURUM:
--   - 22 tablo, hepsi BOŞ (0 satır) — veri kaybı YOK
--   - 6 user-defined function
--   - 11 trigger, 27 policy, 24 index (CASCADE ile otomatik silinecek)
--   - 2 storage bucket (avatars: 2 dosya, coach-audio: 0 dosya)
--   - auth.users: 1 (DOKUNULMUYOR — Supabase managed)
--
-- KORUNAN:
--   * auth.* (Supabase Auth — dokunulmaz)
--   * storage.buckets + storage.objects (TABLO yapısı kalır, sadece içerik silinir)
--   * Extensions (pg_stat_statements, pgcrypto, plpgsql, supabase_vault, uuid-ossp)
--
-- ÇALIŞTIRMA: Supabase SQL Editor -> Bu dosyanın tamamını yapıştır -> Run
--             Bir hata olursa script otomatik ROLLBACK olur (BEGIN/COMMIT içinde)
-- =============================================================

BEGIN;


-- =============================================================
-- AŞAMA 1 — 22 TABLOYU SİL (CASCADE ile bağımlılıklar otomatik silinir)
-- =============================================================
-- CASCADE = bu tablolara bağlı olan trigger, policy, index, foreign key
-- referansları otomatik silinir. Tablolar boş olduğu için veri kaybı yok.

DROP TABLE IF EXISTS public.ai_insights              CASCADE;
DROP TABLE IF EXISTS public.coach_messages           CASCADE;
DROP TABLE IF EXISTS public.coach_preferences        CASCADE;
DROP TABLE IF EXISTS public.coach_threads            CASCADE;
DROP TABLE IF EXISTS public.daily_checkins           CASCADE;
DROP TABLE IF EXISTS public.daily_summaries          CASCADE;
DROP TABLE IF EXISTS public.deletion_requests        CASCADE;
DROP TABLE IF EXISTS public.device_push_tokens       CASCADE;
DROP TABLE IF EXISTS public.device_tokens            CASCADE;
DROP TABLE IF EXISTS public.meal_analysis_results    CASCADE;
DROP TABLE IF EXISTS public.meal_logs                CASCADE;
DROP TABLE IF EXISTS public.notification_logs        CASCADE;
DROP TABLE IF EXISTS public.notification_preferences CASCADE;
DROP TABLE IF EXISTS public.premium_status_cache     CASCADE;
DROP TABLE IF EXISTS public.profiles                 CASCADE;
DROP TABLE IF EXISTS public.safety_acknowledgements  CASCADE;
DROP TABLE IF EXISTS public.safety_events            CASCADE;
DROP TABLE IF EXISTS public.safety_flags             CASCADE;
DROP TABLE IF EXISTS public.usage_counters_daily     CASCADE;
DROP TABLE IF EXISTS public.water_logs               CASCADE;
DROP TABLE IF EXISTS public.weekly_insights          CASCADE;
DROP TABLE IF EXISTS public.weight_logs              CASCADE;


-- =============================================================
-- AŞAMA 2 — KULLANICI TANIMLI FUNCTION'LARI SİL
-- =============================================================
-- Function'lar tablolara bağlı değil, CASCADE ile silinmezler.
-- Sadece public schema'daki + extension'a ait OLMAYAN function'ları siliyoruz.
-- (uuid-ossp vb. extension function'larına dokunmuyoruz.)

DO $$
DECLARE
  fn record;
  cnt int := 0;
BEGIN
  FOR fn IN
    SELECT
      p.proname,
      pg_catalog.pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_catalog.pg_proc p
    JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    LEFT JOIN pg_catalog.pg_depend d
      ON d.objid = p.oid AND d.deptype = 'e'  -- 'e' = extension dependency
    WHERE n.nspname = 'public'
      AND d.objid IS NULL  -- extension'a bağlı DEĞİL
  LOOP
    EXECUTE format(
      'DROP FUNCTION IF EXISTS public.%I(%s) CASCADE',
      fn.proname, fn.args
    );
    cnt := cnt + 1;
    RAISE NOTICE 'Dropped function: public.%(%)', fn.proname, fn.args;
  END LOOP;
  RAISE NOTICE 'Total functions dropped: %', cnt;
END $$;


-- =============================================================
-- AŞAMA 3 — STORAGE BUCKET'LARI VE DOSYALARI SİL
-- =============================================================
-- avatars bucket'ında 2 dosya var (muhtemelen eski test avatarları).
-- Nuveli'de yeni avatars bucket'ı Chat 13/14'te oluşturulacak.
--
-- UYARI: EĞER bu 2 dosyayı SAKLAMAK istiyorsan: aşağıdaki iki DELETE
--        satırını "--" ile yorum satırı yap.

-- Önce dosyaları sil (foreign key constraint için)
DELETE FROM storage.objects WHERE bucket_id IN ('avatars', 'coach-audio');

-- Sonra bucket'ları sil
DELETE FROM storage.buckets WHERE id IN ('avatars', 'coach-audio');


-- =============================================================
-- TRANSACTION'I ONAYLA
-- =============================================================
COMMIT;


-- =============================================================
-- DOĞRULAMA — Aşağıyı SEPARATE bir sorgu olarak ÇALIŞTIR
-- Her sayı 0 olmalı (auth_users hariç, o 1 kalmalı)
-- =============================================================
/*
SELECT 'tables'           AS kind, COUNT(*) AS adet FROM information_schema.tables  WHERE table_schema  = 'public' AND table_type = 'BASE TABLE'
UNION ALL SELECT 'views',           COUNT(*)        FROM information_schema.views    WHERE table_schema  = 'public'
UNION ALL SELECT 'functions',       COUNT(*)        FROM information_schema.routines WHERE routine_schema = 'public'
UNION ALL SELECT 'triggers',        COUNT(*)        FROM information_schema.triggers WHERE trigger_schema = 'public'
UNION ALL SELECT 'policies',        COUNT(*)        FROM pg_policies                 WHERE schemaname     = 'public'
UNION ALL SELECT 'indexes_non_pkey',COUNT(*)        FROM pg_indexes                  WHERE schemaname     = 'public' AND indexname NOT LIKE '%_pkey'
UNION ALL SELECT 'storage_buckets', COUNT(*)        FROM storage.buckets
UNION ALL SELECT 'storage_objects', COUNT(*)        FROM storage.objects
UNION ALL SELECT 'auth_users',      COUNT(*)        FROM auth.users
ORDER BY kind;
*/

-- BEKLENEN ÇIKTI:
--   tables           | 0
--   views            | 0
--   functions        | 0
--   triggers         | 0
--   policies         | 0
--   indexes_non_pkey | 0
--   storage_buckets  | 0
--   storage_objects  | 0
--   auth_users       | 1   <- DEĞİŞMEMELİ
