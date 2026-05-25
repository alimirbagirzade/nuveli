-- =============================================================================
-- Migration 020: exercise_logs table (Manual Exercise Logging — V1.1)
-- =============================================================================
-- Nuveli is a WELLNESS app, not a fitness/medical tracker. Exercise is logged
-- as a POSITIVE HABIT ONLY. By explicit product decision (founder, locked):
--
--   * NO "calories burned" column — never computed, stored, or exposed.
--   * Logged exercise does NOT affect the user's calorie target/budget.
--   * No compensation / "burn it off / you earned calories" semantics.
--
-- This table is a pure activity log: what the user did, how long, how hard.
-- See docs/protocols/safety-wellness-boundary.md.
--
-- Owner-only RLS mirrors water_logs / weight_logs (migration 010). Defaults
-- (local_day = CURRENT_DATE, logged_at = NOW()) make the column self-filling
-- so any future INSERT path stays drift-safe — same treatment migration 016
-- applied to weight_logs.local_day.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- exercise_logs: one row per logged activity session
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.exercise_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- walking|running|cycling|gym|yoga|swimming|sports|other
  activity_type TEXT NOT NULL,

  duration_min INT NOT NULL CHECK (duration_min > 0 AND duration_min <= 1440),

  -- nullable; perceived effort, NOT a calorie multiplier
  intensity TEXT CHECK (intensity IN ('light', 'moderate', 'vigorous')),

  note TEXT,

  logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  local_day DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- (user_id, local_day) → today-summary + weekly aggregate range queries
CREATE INDEX IF NOT EXISTS idx_exercise_logs_user_day
  ON public.exercise_logs(user_id, local_day);

COMMENT ON TABLE public.exercise_logs IS
  'Manual exercise log (wellness positive-habit only). NO calories-burned, never affects calorie target.';
COMMENT ON COLUMN public.exercise_logs.intensity IS
  'Perceived effort (light/moderate/vigorous). NOT a calorie/energy multiplier.';

-- -----------------------------------------------------------------------------
-- Row Level Security — owner-only, mirrors water_logs / weight_logs
-- -----------------------------------------------------------------------------
ALTER TABLE public.exercise_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS users_select_own_exercise_logs ON public.exercise_logs;
CREATE POLICY users_select_own_exercise_logs ON public.exercise_logs
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS users_insert_own_exercise_logs ON public.exercise_logs;
CREATE POLICY users_insert_own_exercise_logs ON public.exercise_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_update_own_exercise_logs ON public.exercise_logs;
CREATE POLICY users_update_own_exercise_logs ON public.exercise_logs
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS users_delete_own_exercise_logs ON public.exercise_logs;
CREATE POLICY users_delete_own_exercise_logs ON public.exercise_logs
  FOR DELETE USING (auth.uid() = user_id);

COMMIT;
