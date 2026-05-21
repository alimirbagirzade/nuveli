-- =============================================================================
-- Migration 017: FK repair — repoint user_id constraints to auth.users
-- =============================================================================
-- Smoke test after migration 016 surfaced the deepest schema-drift layer:
--
--   PGRST 23503: insert or update on table "weight_logs" violates
--                foreign key constraint "weight_logs_user_id_fkey"
--   Details: Key (user_id)=(<uuid>) is not present in table "profiles"
--
-- Migration 007 declared:
--   user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
--
-- But the live prod table's constraint points at `public.profiles`
-- (an old/empty Supabase-convention table that nothing actually
-- populates anymore). Newly-signed-up users exist in `auth.users` +
-- `user_profiles` but never in `profiles` → every INSERT fails.
--
-- Likely root cause: an older Supabase project template (pre 2024)
-- shipped with a `profiles` table that mirrored auth.users; the team
-- moved off it to `user_profiles` but forgot to redirect the FKs on
-- the *_logs tables that hadn't been touched since.
--
-- Fix: drop the wrong FK and recreate it pointing at auth.users(id),
-- the actual source of truth. Same shape, just correct target.
--
-- Idempotent: DROP CONSTRAINT IF EXISTS handles re-runs.
-- =============================================================================

BEGIN;

-- weight_logs.user_id → auth.users
ALTER TABLE public.weight_logs
  DROP CONSTRAINT IF EXISTS weight_logs_user_id_fkey;

ALTER TABLE public.weight_logs
  ADD CONSTRAINT weight_logs_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES auth.users(id)
    ON DELETE CASCADE;

-- water_logs.user_id → auth.users (preemptive — same drift pattern)
ALTER TABLE public.water_logs
  DROP CONSTRAINT IF EXISTS water_logs_user_id_fkey;

ALTER TABLE public.water_logs
  ADD CONSTRAINT water_logs_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES auth.users(id)
    ON DELETE CASCADE;

-- weight_goals.user_id → auth.users (preemptive)
ALTER TABLE public.weight_goals
  DROP CONSTRAINT IF EXISTS weight_goals_user_id_fkey;

ALTER TABLE public.weight_goals
  ADD CONSTRAINT weight_goals_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES auth.users(id)
    ON DELETE CASCADE;

-- meals.user_id → auth.users (preemptive — meal entries land soon)
ALTER TABLE public.meals
  DROP CONSTRAINT IF EXISTS meals_user_id_fkey;

ALTER TABLE public.meals
  ADD CONSTRAINT meals_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES auth.users(id)
    ON DELETE CASCADE;

COMMIT;

-- =============================================================================
-- Verification (paste in a separate query AFTER the migration; all four
-- rows should show `foreign_table = "users"` and `foreign_schema = "auth"`):
-- =============================================================================
-- SELECT
--   tc.table_name,
--   ccu.table_schema AS foreign_schema,
--   ccu.table_name   AS foreign_table,
--   ccu.column_name  AS foreign_column
-- FROM information_schema.table_constraints tc
-- JOIN information_schema.constraint_column_usage ccu
--   ON ccu.constraint_name = tc.constraint_name
-- WHERE tc.constraint_type = 'FOREIGN KEY'
--   AND tc.table_schema = 'public'
--   AND tc.table_name IN ('weight_logs','water_logs','weight_goals','meals')
--   AND tc.constraint_name LIKE '%user_id_fkey'
-- ORDER BY tc.table_name;
-- =============================================================================
