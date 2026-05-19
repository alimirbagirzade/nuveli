-- =============================================================================
-- Migration 001: PostgreSQL Extensions
-- =============================================================================
-- Amaç: Nuveli'nin ihtiyaç duyduğu Postgres extension'larını yükle.
-- Çalıştırma: Supabase SQL Editor → bu dosyayı yapıştır → Run
-- =============================================================================

BEGIN;

-- UUID generation (gen_random_uuid() için pgcrypto yeterli ama uuid-ossp da hazır olsun)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- gen_random_uuid(), bcrypt, hash fonksiyonları
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Trigram search (recipe arama, tag arama için)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- (Opsiyonel) pg_stat_statements — query performans takibi için
-- Supabase'de zaten genelde aktif, ama emin olalım
-- CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

COMMIT;

-- =============================================================================
-- Doğrulama (manuel çalıştır):
-- SELECT extname, extversion FROM pg_extension ORDER BY extname;
-- =============================================================================
