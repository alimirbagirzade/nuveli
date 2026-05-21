-- =============================================================================
-- Migration 014: Sanity upper bounds on calorie + macro columns
-- =============================================================================
-- Chat 25 Phase 3 (Data Integrity audit) flagged that `meals.total_calories`
-- and the per-macro columns only had `>= 0` constraints. That lets a buggy
-- client or a forged INSERT plant rows with calories = 999_999_999, which
-- corrupts dashboards (sums overflow visualisations) and can DoS the daily
-- summary view.
--
-- Real-world upper bounds:
--   - Single meal calories: realistic max ~10_000 kcal (an outlier feast).
--     Pad to 50_000 to leave room for badly-tagged "today total" inserts.
--   - Macro grams: realistic single-meal max ~5_000 g (5kg of food).
--   - meal_foods.grams: same 5kg cap, single food item.
--   - meal_foods per-row calories/macros: same cap as the parent meal,
--     since the trigger sums them into meals.total_* (audit: triggers).
--
-- These are forward-only — existing rows that violate the bound (there
-- shouldn't be any from real users; this is purely defensive) would block
-- the ALTER. Run prod check first:
--
--   SELECT id, total_calories FROM meals WHERE total_calories > 50000;
--
-- If 0 rows: safe to apply.
-- =============================================================================

BEGIN;

ALTER TABLE public.meals
  ADD CONSTRAINT chk_meals_total_calories_upper CHECK (total_calories <= 50000),
  ADD CONSTRAINT chk_meals_total_protein_upper CHECK (total_protein_g <= 5000),
  ADD CONSTRAINT chk_meals_total_carbs_upper   CHECK (total_carbs_g   <= 5000),
  ADD CONSTRAINT chk_meals_total_fat_upper     CHECK (total_fat_g     <= 5000);

-- meal_foods has its own columns (see migration 003); the recompute
-- trigger sums per-row macros into meals.total_* so an unbounded row
-- can blow the parent meal past the new cap regardless. Bound them
-- in parity.
ALTER TABLE public.meal_foods
  ADD CONSTRAINT chk_meal_foods_grams_upper      CHECK (grams IS NULL OR grams <= 5000),
  ADD CONSTRAINT chk_meal_foods_calories_upper   CHECK (calories <= 50000),
  ADD CONSTRAINT chk_meal_foods_protein_upper    CHECK (protein_g <= 5000),
  ADD CONSTRAINT chk_meal_foods_carbs_upper      CHECK (carbs_g <= 5000),
  ADD CONSTRAINT chk_meal_foods_fat_upper        CHECK (fat_g <= 5000);

-- Past/future date sanity (deterministic bounds only — NOW() in CHECK
-- constraints is technically allowed but Postgres warns it's non-portable
-- across dump/reload, so we use absolute dates). 2000-01-01 floor and
-- 2100-01-01 ceiling catch the egregious cases without touching real
-- timezone math. Pre-2000 / post-2100 entries are almost certainly
-- a buggy client clock or a forged INSERT.
ALTER TABLE public.meals
  ADD CONSTRAINT chk_meals_consumed_at_sane
    CHECK (
      consumed_at >= TIMESTAMPTZ '2000-01-01 00:00:00+00'
      AND consumed_at <  TIMESTAMPTZ '2100-01-01 00:00:00+00'
    );

COMMIT;
