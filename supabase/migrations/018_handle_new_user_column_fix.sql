-- =============================================================================
-- Migration 018: Fix handle_new_user trigger column name
-- =============================================================================
-- Bug: the trigger inserted into a column "display_name" that does not exist
-- on public.user_profiles. The real column is "full_name". This caused
-- 500 "Database error saving new user" on every signup attempt.
--
-- Discovered via Supabase Postgres logs on 2026-05-22:
--   ERROR: column "display_name" of relation "user_profiles" does not exist
--   (SQLSTATE 42703)
--
-- Fix: replace handle_new_user() so the INSERT targets full_name.
-- Function body is otherwise identical to migration 012.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_full_name TEXT;
BEGIN
  -- Pull display name from auth metadata, fall back to email handle.
  -- Several possible metadata keys are tried because Supabase clients
  -- (web, mobile, OAuth providers) populate different ones.
  v_full_name := COALESCE(
    NEW.raw_user_meta_data->>'name',
    NEW.raw_user_meta_data->>'display_name',
    NEW.raw_user_meta_data->>'full_name',
    split_part(NEW.email, '@', 1),
    'Nuveli User'
  );

  -- 1. Profile — full_name is NOT NULL on the live schema.
  INSERT INTO public.user_profiles (user_id, full_name, onboarding_completed)
  VALUES (NEW.id, v_full_name, FALSE)
  ON CONFLICT (user_id) DO NOTHING;

  -- 2. Default habits
  PERFORM public.create_default_habits_for_user(NEW.id);

  -- 3. Default achievements (locked)
  PERFORM public.create_default_achievements_for_user(NEW.id);

  RETURN NEW;
END;
$$;

-- Sanity-check: the trigger itself is already attached from migration 012,
-- so we don't need DROP/CREATE TRIGGER. CREATE OR REPLACE FUNCTION above
-- hot-swaps the body. Existing rows are untouched.
