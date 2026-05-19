-- ============================================
-- NUVELI SUPABASE FULL AUDIT
-- Bu script HİÇBİR ŞEYİ DEĞİŞTİRMEZ, sadece okur.
-- Çıktıyı kopyala ve Claude'a yapıştır.
-- ============================================

-- 1) PUBLIC SCHEMA'DAKI TÜM TABLOLAR
SELECT
  'TABLE' as type,
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = t.table_name) as columns
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2) TÜM VIEW'LER
SELECT
  'VIEW' as type,
  table_name as view_name
FROM information_schema.views
WHERE table_schema = 'public';

-- 3) TÜM FUNCTION'LAR / STORED PROCEDURE'LER
SELECT
  'FUNCTION' as type,
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public';

-- 4) TÜM TRIGGER'LAR
SELECT
  'TRIGGER' as type,
  trigger_name,
  event_object_table as table_name,
  event_manipulation as event
FROM information_schema.triggers
WHERE trigger_schema = 'public';

-- 5) TÜM RLS POLICY'LER
SELECT
  'POLICY' as type,
  tablename,
  policyname,
  cmd as command,
  CASE WHEN permissive = 'PERMISSIVE' THEN 'YES' ELSE 'NO' END as permissive
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 6) INDEX'LER (primary key hariç)
SELECT
  'INDEX' as type,
  tablename,
  indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname NOT LIKE '%_pkey'
ORDER BY tablename, indexname;

-- 7) STORAGE BUCKET'LAR
SELECT
  'BUCKET' as type,
  id as bucket_id,
  name,
  CASE WHEN public THEN 'PUBLIC' ELSE 'PRIVATE' END as access,
  created_at
FROM storage.buckets;

-- 8) AUTH KULLANICI SAYISI (sadece sayı, kişisel veri yok)
SELECT
  'USERS' as type,
  COUNT(*) as user_count,
  COUNT(CASE WHEN last_sign_in_at > NOW() - INTERVAL '30 days' THEN 1 END) as active_30d
FROM auth.users;

-- 9) ENABLED EXTENSION'LAR (referans için, silmiyoruz)
SELECT
  'EXTENSION' as type,
  extname as name,
  extversion as version
FROM pg_extension
ORDER BY extname;
