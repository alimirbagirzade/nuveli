-- =============================================================================
-- Migration 015: Schema-drift repair (PERMANENT FIX for the smoke-test bugs)
-- =============================================================================
-- Chat 25 smoke test surfaced three PGRST204 / 42703 failures from
-- columns that exist in migration 004 / 007 but are missing from the
-- live prod schema:
--
--   1) water_logs.logged_at   "column water_logs.logged_at does not exist"
--   2) water_logs.source      "Could not find the 'source' column..."
--   3) weight_logs.logged_at  "Could not find the 'logged_at' column..."
--
-- Root cause: prod was set up from an older version of these tables
-- (pre-001/004/007). Subsequent migrations updated the .sql files in
-- repo but never re-ran against prod.
--
-- This migration is IDEMPOTENT — re-running it is safe.
--
-- Run order (Supabase SQL Editor):
--   1. Open https://supabase.com/dashboard/project/<your-ref>/sql
--   2. Paste this whole file
--   3. Run
-- =============================================================================

BEGIN;

-- water_logs.logged_at: when records were created. DEFAULT NOW() so
-- existing rows backfill cleanly on ADD COLUMN.
ALTER TABLE public.water_logs
  ADD COLUMN IF NOT EXISTS logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- water_logs.source: where the row came from. CHECK constraint matches
-- migration 004's original definition.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'water_logs'
      AND column_name = 'source'
  ) THEN
    ALTER TABLE public.water_logs
      ADD COLUMN source TEXT NOT NULL DEFAULT 'manual'
        CHECK (source IN ('manual', 'quick_add', 'reminder'));
  END IF;
END $$;

-- weight_logs.logged_at: same shape as water_logs.
ALTER TABLE public.weight_logs
  ADD COLUMN IF NOT EXISTS logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Re-create the indexes declared in migrations 004 / 007 that were
-- silently skipped because logged_at didn't exist.
CREATE INDEX IF NOT EXISTS idx_water_logs_user_time
  ON public.water_logs(user_id, logged_at DESC);

CREATE INDEX IF NOT EXISTS idx_weight_logs_user_time
  ON public.weight_logs(user_id, logged_at DESC);

COMMIT;

-- =============================================================================
-- Verification (run AFTER the migration; all three rows should appear):
-- =============================================================================
-- SELECT table_name, column_name, data_type
-- FROM information_schema.columns
-- WHERE table_schema = 'public'
--   AND (
--     (table_name = 'water_logs' AND column_name IN ('logged_at', 'source'))
--     OR (table_name = 'weight_logs' AND column_name = 'logged_at')
--   )
-- ORDER BY table_name, column_name;
--
-- Expected:
--   water_logs   | logged_at | timestamp with time zone
--   water_logs   | source    | text
--   weight_logs  | logged_at | timestamp with time zone
-- =============================================================================
