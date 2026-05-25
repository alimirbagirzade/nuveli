-- =============================================================================
-- Migration 021: exercise_logs source / health-import columns (V1.1)
-- =============================================================================
-- Adds the columns the HEALTH-DATA IMPORT path needs so workouts read from the
-- phone's health platform (Apple Health / Google Health Connect) can flow into
-- exercise_logs, deduplicated and tagged by where they came from.
--
-- WELLNESS BOUNDARY (hard rule, founder-locked — UNCHANGED by this migration):
--   Calories remain DISPLAY-ONLY. `device_calories` stores the figure the
--   health platform itself reported, shown exactly like the MET estimate — an
--   informational "~N kcal" badge. It is NEVER added to/subtracted from the
--   user's calorie target/budget, produces no "earned / eat more / burn it off"
--   semantics, and no endpoint mutates a calorie goal because of it.
--   See docs/protocols/safety-wellness-boundary.md.
--
-- Additive + idempotent: every statement is guarded (ADD COLUMN IF NOT EXISTS /
-- CREATE UNIQUE INDEX IF NOT EXISTS) so re-running is a no-op. Existing rows get
-- source='manual' via the DEFAULT, preserving the manual-log behaviour.
--
-- The partial unique index (user_id, external_id) WHERE external_id IS NOT NULL
-- dedupes re-imports of the same health record per user while leaving manual
-- rows (external_id NULL) completely unconstrained.
-- =============================================================================

BEGIN;

ALTER TABLE public.exercise_logs
  ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'manual',
  ADD COLUMN IF NOT EXISTS external_id TEXT,
  ADD COLUMN IF NOT EXISTS device_calories INT;

-- dedupe re-imports of the same health record per user
CREATE UNIQUE INDEX IF NOT EXISTS ux_exercise_logs_user_external
  ON public.exercise_logs(user_id, external_id) WHERE external_id IS NOT NULL;

COMMENT ON COLUMN public.exercise_logs.source IS 'manual | health_connect | apple_health';
COMMENT ON COLUMN public.exercise_logs.device_calories IS 'Calories reported by the health platform (display-only, never affects calorie budget).';

COMMIT;
