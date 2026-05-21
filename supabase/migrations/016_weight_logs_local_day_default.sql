-- =============================================================================
-- Migration 016: Make weight_logs.local_day self-filling
-- =============================================================================
-- Smoke test after migration 015: weight log INSERT still fails with
--
--   'null value in column "local_day" of relation "weight_logs"
--    violates not-null constraint' (23502)
--
-- Prod weight_logs has a `local_day DATE NOT NULL` column with no default.
-- Backend now sends it explicitly (PR after this migration), but adding
-- a DEFAULT CURRENT_DATE makes the column self-filling so any future
-- INSERT path (admin scripts, manual SQL inserts, future endpoints)
-- doesn't have to remember to populate it.
--
-- Also adds weight_goals.status if missing (was queried in the active-goal
-- endpoint and the Profile screen was 500-ing on it).
-- =============================================================================

BEGIN;

ALTER TABLE public.weight_logs
  ALTER COLUMN local_day SET DEFAULT CURRENT_DATE;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'weight_goals'
      AND column_name = 'status'
  ) THEN
    ALTER TABLE public.weight_goals
      ADD COLUMN status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'paused', 'completed', 'abandoned'));
  END IF;
END $$;

COMMIT;
