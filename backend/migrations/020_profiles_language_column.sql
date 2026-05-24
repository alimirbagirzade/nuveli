-- =============================================================================
-- Migration 020: add language column to user_profiles
-- =============================================================================
-- Adds a `language` column (text, default 'en') so the AI Coach insight
-- can respond in the user's preferred language.
--
-- NOTE: This migration must be applied to prod Supabase manually (schema drift).
-- All backend code reads it drift-safe: (profile or {}).get('language') or 'en'
-- =============================================================================

BEGIN;

ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS language TEXT DEFAULT 'en';

COMMENT ON COLUMN public.user_profiles.language IS
  'BCP-47-style language code for AI Coach insight localisation. '
  'Supported: en, tr, de, es, fr, it, ru. Defaults to en.';

COMMIT;
